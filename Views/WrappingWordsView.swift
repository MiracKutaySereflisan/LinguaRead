import SwiftUI

/// Kelimeleri akış düzeninde gösterir. Aktif kelime amber, aktif cümle mavi.
struct WrappingWordsView: View {
    let words: ArraySlice<String>
    let globalOffset: Int
    let highlightIndex: Int
    let sentenceRange: Range<Int>?
    let onTap: (Int) -> Void
    let onLongPress: (String) -> Void

    var body: some View {
        FlowLayout(spacing: 6, lineSpacing: 10) {
            ForEach(Array(words.enumerated()), id: \.offset) { offset, word in
                let globalIndex = globalOffset + offset
                Text(word)
                    .font(.system(size: 19, design: .serif))
                    .padding(.horizontal, 2)
                    .background(background(for: globalIndex))
                    .cornerRadius(4)
                    .onTapGesture { onTap(globalIndex) }
                    .onLongPressGesture(minimumDuration: 0.4) {
                        onLongPress(cleanWord(word))
                    }
            }
        }
    }

    private func background(for index: Int) -> Color {
        if index == highlightIndex { return .orange.opacity(0.45) }
        if let r = sentenceRange, r.contains(index) { return .blue.opacity(0.15) }
        return .clear
    }

    private func cleanWord(_ w: String) -> String {
        w.trimmingCharacters(in: .punctuationCharacters)
    }
}

/// Basit soldan sağa akış düzeni (iOS 16+ Layout API)
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
