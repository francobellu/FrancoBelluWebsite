import Vapor
import Foundation

/// Base controller providing common functionality for all controllers.
/// Handles service injection, error handling, and standardized responses.
class BaseController {
    
    // MARK: - Service Injection Helpers
    
    /// Retrieves ProfileService from application storage.
    /// - Parameter request: The incoming request
    /// - Returns: ProfileService instance
    /// - Throws: Abort if service is not configured
    internal func getProfileService(from request: Request) throws -> ProfileService {
        guard let service = request.application.storage[ProfileServiceKey.self] else {
            request.logger.error("ProfileService not configured in application storage")
            throw Abort(.internalServerError, reason: "ProfileService not available")
        }
        return service
    }
    
    /// Retrieves ContactService from application storage.
    /// - Parameter request: The incoming request
    /// - Returns: ContactService instance
    /// - Throws: Abort if service is not configured
    internal func getContactService(from request: Request) throws -> ContactService {
        guard let service = request.application.storage[ContactServiceKey.self] else {
            request.logger.error("ContactService not configured in application storage")
            throw Abort(.internalServerError, reason: "ContactService not available")
        }
        return service
    }
    
    /// Retrieves ContentService from application storage.
    /// - Parameter request: The incoming request
    /// - Returns: ContentService instance
    /// - Throws: Abort if service is not configured
    internal func getContentService(from request: Request) throws -> ContentService {
        guard let service = request.application.storage[ContentServiceKey.self] else {
            request.logger.error("ContentService not configured in application storage")
            throw Abort(.internalServerError, reason: "ContentService not available")
        }
        return service
    }
    
    // MARK: - Error Handling
    
    /// Converts BusinessError to appropriate HTTP response.
    /// - Parameters:
    ///   - error: BusinessError to convert
    ///   - request: The request for logging context
    /// - Returns: Appropriate HTTP response
    internal func handleBusinessError(_ error: BusinessError, request: Request) -> Response {
        request.logger.error("Business error occurred: \(error.localizedDescription)")
        
        let errorResponse = ErrorResponse(
            error: true,
            reason: error.localizedDescription,
            code: error.errorCode
        )
        
        let response = Response(status: error.httpStatus)
        do {
            try response.content.encode(errorResponse)
        } catch {
            request.logger.error("Failed to encode error response: \(error)")
        }
        
        return response
    }
    
    /// Handles validation errors with detailed field information.
    /// - Parameters:
    ///   - validationResult: ValidationResult containing errors
    ///   - request: The request for logging context
    /// - Returns: HTTP 400 response with validation details
    internal func handleValidationErrors(_ validationResult: ValidationResult, request: Request) -> Response {
        request.logger.warning("Validation failed", metadata: [
            "errors": .array(validationResult.errors.map { .string($0.message) })
        ])
        
        let errorResponse = ValidationErrorResponse(
            error: true,
            reason: "Validation failed",
            code: "VALIDATION_FAILED",
            validationErrors: validationResult.errors
        )
        
        let response = Response(status: .badRequest)
        do {
            try response.content.encode(errorResponse)
        } catch {
            request.logger.error("Failed to encode validation error response: \(error)")
        }
        
        return response
    }
    
    /// Handles unexpected errors with generic response.
    /// - Parameters:
    ///   - error: The unexpected error
    ///   - request: The request for logging context
    /// - Returns: HTTP 500 response
    internal func handleUnexpectedError(_ error: Error, request: Request) -> Response {
        request.logger.error("Unexpected error occurred: \(error)")
        
        let errorResponse = ErrorResponse(
            error: true,
            reason: "An unexpected error occurred. Please try again later.",
            code: "INTERNAL_ERROR"
        )
        
        let response = Response(status: .internalServerError)
        do {
            try response.content.encode(errorResponse)
        } catch {
            request.logger.error("Failed to encode unexpected error response: \(error)")
        }
        
        return response
    }
    
    // MARK: - Response Helpers
    
    /// Creates a successful JSON response.
    /// - Parameters:
    ///   - data: Data to encode in response
    ///   - status: HTTP status code (defaults to .ok)
    ///   - request: The request for context
    /// - Returns: Successful HTTP response
    internal func successResponse<T: Content>(_ data: T, status: HTTPStatus = .ok, request: Request) -> Response {
        let response = Response(status: status)
        do {
            try response.content.encode(data)
        } catch {
            request.logger.error("Failed to encode success response: \(error)")
            return handleUnexpectedError(error, request: request)
        }
        
        return response
    }
    
    // MARK: - Logging Helpers
    
    /// Logs request details for debugging and monitoring.
    /// - Parameters:
    ///   - request: The request to log
    ///   - action: Description of the action being performed
    internal func logRequest(_ request: Request, action: String) {
        request.logger.info("Controller action: \(action)", metadata: [
            "method": .string(request.method.rawValue),
            "path": .string(request.url.path),
            "userAgent": .string(request.headers.first(name: .userAgent) ?? "unknown")
        ])
    }
}

// MARK: - Error Response Models

/// Standard error response structure for API endpoints.
struct ErrorResponse: Content {
    let error: Bool
    let reason: String
    let code: String
}

/// Enhanced error response for validation failures.
struct ValidationErrorResponse: Content {
    let error: Bool
    let reason: String
    let code: String
    let validationErrors: [ValidationError]
}

// MARK: - BusinessError Extension

extension BusinessError {
    /// Machine-readable error code for client handling.
    var errorCode: String {
        switch self {
        case .validationFailed:
            return "VALIDATION_FAILED"
        case .contactSubmissionFailed:
            return "CONTACT_SUBMISSION_FAILED"
        case .dataNotFound:
            return "DATA_NOT_FOUND"
        case .serviceUnavailable:
            return "SERVICE_UNAVAILABLE"
        case .configurationError:
            return "CONFIGURATION_ERROR"
        }
    }
}