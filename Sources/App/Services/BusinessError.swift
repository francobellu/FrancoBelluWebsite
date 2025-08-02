import Vapor

/// Represents business logic errors that can occur during service operations.
/// Provides structured error handling with appropriate HTTP status codes.
enum BusinessError: Error, LocalizedError {
    case validationFailed(String)
    case contactSubmissionFailed(String)
    case dataNotFound(String)
    case serviceUnavailable(String)
    case configurationError(String)
    
    /// Human-readable error description for logging and debugging.
    var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .contactSubmissionFailed(let message):
            return "Contact submission failed: \(message)"
        case .dataNotFound(let message):
            return "Data not found: \(message)"
        case .serviceUnavailable(let message):
            return "Service unavailable: \(message)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        }
    }
    
    /// HTTP status code appropriate for this business error.
    var httpStatus: HTTPStatus {
        switch self {
        case .validationFailed:
            return .badRequest
        case .contactSubmissionFailed:
            return .unprocessableEntity
        case .dataNotFound:
            return .notFound
        case .serviceUnavailable:
            return .serviceUnavailable
        case .configurationError:
            return .internalServerError
        }
    }
}