import Foundation

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    init?(date: Date, calendar: Calendar = Calendar.current) {
        let value = calendar.component(.weekday, from: date)
        self.init(rawValue: value)
    }
}

struct DailySchedule: Codable, Equatable {
    var enabled: Bool
    var startMinutes: Int
    var endMinutes: Int
    
    static let fullDay = DailySchedule(enabled: true, startMinutes: 0, endMinutes: 24 * 60 - 1)
    
    func contains(_ date: Date, calendar: Calendar = Calendar.current) -> Bool {
        guard enabled else { return false }
        let minutes = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        if startMinutes <= endMinutes {
            return minutes >= startMinutes && minutes <= endMinutes
        } else {
            // Handles overnight windows (e.g. 22:00 - 02:00)
            return minutes >= startMinutes || minutes <= endMinutes
        }
    }
    
    var startDate: Date {
        get { Date.fromMinutes(startMinutes) }
        set { startMinutes = newValue.minutesSinceStartOfDay }
    }
    
    var endDate: Date {
        get { Date.fromMinutes(endMinutes) }
        set { endMinutes = newValue.minutesSinceStartOfDay }
    }
}

struct NotificationSchedule: Codable, Equatable {
    private var rawItems: [Int: DailySchedule]
    
    init(rawItems: [Int: DailySchedule] = [:]) {
        self.rawItems = rawItems
    }
    
    static let defaultValue: NotificationSchedule = {
        var items: [Int: DailySchedule] = [:]
        Weekday.allCases.forEach { weekday in
            let workday = weekday != .saturday && weekday != .sunday
            let base = DailySchedule(enabled: workday, startMinutes: 8 * 60, endMinutes: 18 * 60)
            items[weekday.rawValue] = workday ? base : DailySchedule(enabled: false, startMinutes: base.startMinutes, endMinutes: base.endMinutes)
        }
        return NotificationSchedule(rawItems: items)
    }()
    
    func schedule(for weekday: Weekday) -> DailySchedule {
        rawItems[weekday.rawValue] ?? .fullDay
    }
    
    mutating func setSchedule(_ schedule: DailySchedule, for weekday: Weekday) {
        rawItems[weekday.rawValue] = schedule
    }
    
    func shouldRing(on date: Date = Date(), calendar: Calendar = Calendar.current) -> Bool {
        guard let weekday = Weekday(date: date, calendar: calendar) else { return true }
        let schedule = schedule(for: weekday)
        return schedule.contains(date, calendar: calendar)
    }
}

enum NotificationScheduleStore {
    private static let key = "notificationSchedule"
    
    static func load() -> NotificationSchedule {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return .defaultValue
        }
        
        if let schedule = try? JSONDecoder().decode(NotificationSchedule.self, from: data) {
            return schedule
        }
        
        return .defaultValue
    }
    
    static func save(_ schedule: NotificationSchedule) {
        guard let data = try? JSONEncoder().encode(schedule) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

private extension Date {
    static func fromMinutes(_ minutes: Int) -> Date {
        let clamped = max(0, min(minutes, 24 * 60 - 1))
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = clamped / 60
        components.minute = clamped % 60
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var minutesSinceStartOfDay: Int {
        let calendar = Calendar.current
        return (calendar.component(.hour, from: self) * 60) + calendar.component(.minute, from: self)
    }
}
