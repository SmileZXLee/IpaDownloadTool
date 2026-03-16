import Foundation

enum L10n {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    static func formatted(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: .autoupdatingCurrent, arguments: arguments)
    }

    static let agreementBody = string("agreement.body")

    static func blockedHostMessage(_ host: String) -> String {
        formatted("notice.blockedAccess.message", host)
    }

    static func importCompleteMessage(ipaCount: Int, webHistoryCount: Int) -> String {
        formatted("notice.importComplete.message", ipaCount, webHistoryCount)
    }
}

extension Date {
    var localizedTimestamp: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}

extension ByteCountFormatter {
    private static let appFileSizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter
    }()

    static func appFileSizeString(from byteCount: Int64) -> String {
        appFileSizeFormatter.string(fromByteCount: byteCount)
    }
}
