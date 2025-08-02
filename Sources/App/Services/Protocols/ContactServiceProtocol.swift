import Vapor

/// Protocol defining contact form processing and communication operations.
/// Handles form validation, submission processing, and response generation.
protocol ContactServiceProtocol {
    /// Processes a contact form submission with validation and business logic.
    /// - Parameter contactForm: The submitted contact form data
    /// - Parameter logger: Logger instance for tracking submissions
    /// - Returns: ContactResponse indicating success or failure with appropriate message
    /// - Throws: BusinessError for validation failures or processing errors
    func processContactSubmission(_ contactForm: ContactForm, logger: Logger) async throws -> ContactResponse
    
    /// Validates contact form data according to business rules.
    /// - Parameter contactForm: The contact form to validate
    /// - Returns: ValidationResult indicating success or specific validation failures  
    /// - Throws: ValidationError for detailed validation feedback
    func validateContactForm(_ contactForm: ContactForm) async throws -> ValidationResult
}