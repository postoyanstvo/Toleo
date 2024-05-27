import Foundation

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    static let justDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
}

extension String {
    func toDate() -> Date? {
        DateFormatter.iso8601.date(from: self)
    }
}

extension Date {
    func toStringJustDate() -> String? {
        DateFormatter.justDate.string(from: self)
    }
}
