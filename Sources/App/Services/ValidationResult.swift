import Vapor

/// Represents the result of a validation operation with detailed feedback.
/// Provides structured validation results for business logic operations.
struct ValidationResult: Content {
    let isValid: Bool
    let errors: [ValidationError]
    let warnings: [String]
    
    /// Creates a successful validation result.
    /// - Returns: ValidationResult indicating successful validation
    static func success() -> ValidationResult {
        ValidationResult(isValid: true, errors: [], warnings: [])
    }
    
    /// Creates a failed validation result with specific errors.
    /// - Parameter errors: Array of ValidationError objects describing failures
    /// - Returns: ValidationResult indicating validation failure
    static func failure(errors: [ValidationError]) -> ValidationResult {
        ValidationResult(isValid: false, errors: errors, warnings: [])
    }
    
    /// Creates a validation result with warnings but no blocking errors.
    /// - Parameter warnings: Array of warning messages
    /// - Returns: ValidationResult indicating success with warnings
    static func successWithWarnings(_ warnings: [String]) -> ValidationResult {
        ValidationResult(isValid: true, errors: [], warnings: warnings)
    }
}

/// Represents a specific validation error with field and message details.
struct ValidationError: Content, Error {
    let field: String
    let message: String
    let code: String
    
    /// Creates a validation error for a specific field.
    /// - Parameters:
    ///   - field: The field name that failed validation
    ///   - message: Human-readable error message
    ///   - code: Machine-readable error code for client handling
    init(field: String, message: String, code: String) {
        self.field = field
        self.message = message
        self.code = code
    }
    
    // MARK: - Common Validation Errors
    
    static func required(field: String) -> ValidationError {
        ValidationError(
            field: field,
            message: "\(field.capitalized) is required",
            code: "FIELD_REQUIRED"
        )
    }
    
    static func invalidEmail(field: String) -> ValidationError {
        ValidationError(
            field: field,
            message: "Please enter a valid email address",
            code: "INVALID_EMAIL"
        )
    }
    
    static func tooShort(field: String, minLength: Int) -> ValidationError {
        ValidationError(
            field: field,
            message: "\(field.capitalized) must be at least \(minLength) characters long",
            code: "TOO_SHORT"
        )
    }
    
    static func tooLong(field: String, maxLength: Int) -> ValidationError {
        ValidationError(
            field: field,
            message: "\(field.capitalized) must be no more than \(maxLength) characters long",
            code: "TOO_LONG"
        )
    }
}