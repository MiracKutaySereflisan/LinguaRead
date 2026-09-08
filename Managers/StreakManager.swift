import Foundation
import Observation

@Observable
final class StreakManager {
    var current: Int      { didSet { save("streak_current", current) } }
    var longest: Int      { didSet { save("streak_longest", longest) } }
    var todaySeconds: Int { didSet { save("streak_todaySec", todaySeconds) } }
    var totalSeconds: Int { didSet { save("streak_totalSec", totalSeconds) } }
    var weekPages: Int    { didSet { save("streak_weekPages", weekPages) } }
    var weekGoal: Int     { didSet { save("streak_weekGoal", weekGoal) } }
    private var lastDateStr: String { didSet { UserDefaults.standard.set(lastDateStr, forKey: "streak_lastDate") } }
    private var lastWeekNum: Int    { didSet { save("streak_weekNum", lastWeekNum) } }

    private let cal = Calendar.current
    private func save(_ k: String, _ v: Int) { UserDefaults.standard.set(v, forKey: k) }

    init() {
        let d = UserDefaults.standard
        current = d.integer(forKey: "streak_current")
        longest = d.integer(forKey: "streak_longest")
        todaySeconds = d.integer(forKey: "streak_todaySec")
        totalSeconds = d.integer(forKey: "streak_totalSec")
        weekPages = d.integer(forKey: "streak_weekPages")
        weekGoal = d.object(forKey: "streak_weekGoal") as? Int ?? 50
        lastDateStr = d.string(forKey: "streak_lastDate") ?? ""
        lastWeekNum = d.integer(forKey: "streak_weekNum")
    }

    var todayMinutes: Int { todaySeconds / 60 }
    var totalHours: Double { Double(totalSeconds) / 3600 }
    var weekProgress: Double { weekGoal > 0 ? min(1.0, Double(weekPages) / Double(weekGoal)) : 0 }

    private var lastDate: Date? { ISO8601DateFormatter().date(from: lastDateStr) }

    var isActive: Bool {
        guard let d = lastDate else { return false }
        return cal.isDateInToday(d) || cal.isDateInYesterday(d)
    }

    func recordPage() {
        weekPages += 1
        updateStreak()
    }

    func addTime(seconds: Int) {
        guard seconds > 0 else { return }
        todaySeconds += seconds
        totalSeconds += seconds
    }

    func checkResets() {
        let weekNum = cal.component(.weekOfYear, from: Date())
        if weekNum != lastWeekNum {
            weekPages = 0
            lastWeekNum = weekNum
        }
        if let d = lastDate, !cal.isDateInToday(d) {
            todaySeconds = 0
        }
    }

    private func updateStreak() {
        if let d = lastDate {
            if cal.isDateInToday(d) { return }
            current = cal.isDateInYesterday(d) ? current + 1 : 1
        } else {
            current = 1
        }
        if current > longest { longest = current }
        lastDateStr = ISO8601DateFormatter().string(from: Date())
    }
}
