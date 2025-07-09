import Foundation

/// Central error type for DeepSeek/AI API operations.
enum DeepSeekError: Error, LocalizedError, Equatable {
    case networkError(String)
    case message(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return msg
        case .message(let msg): return msg
        case .unknown: return "An unknown error occurred."
        }
    }
}
