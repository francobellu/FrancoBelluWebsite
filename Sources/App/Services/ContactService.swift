import Vapor
import Foundation

/// Service responsible for contact form processing and communication operations.
/// Handles form validation, submission processing, and response generation with business logic.
final class ContactService: ContactServiceProtocol {
    
    // MARK: - Configuration Constants
    private struct ValidationLimits {
        static let minNameLength = 2
        static let maxNameLength = 100
        static let minMessageLength = 10
        static let maxMessageLength = 2000
        static let maxEmailLength = 254
    }
    
    /// Initializes the ContactService.
    /// Future versions may accept email service or repository dependencies.
    init() {
        // Currently no dependencies required
        // In production, might inject email service, database repository, etc.
    }
    
    /// Processes a contact form submission with validation and business logic.
    /// Performs comprehensive validation, logging, and response generation.
    /// - Parameters:
    ///   - contactForm: The submitted contact form data
    ///   - logger: Logger instance for tracking submissions
    /// - Returns: ContactResponse indicating success or failure with appropriate message
    /// - Throws: BusinessError for validation failures or processing errors
    func processContactSubmission(_ contactForm: ContactForm, logger: Logger) async throws -> ContactResponse {
        // Step 1: Validate the contact form
        let validationResult = try await validateContactForm(contactForm)
        
        guard validationResult.isValid else {
            logger.warning("Contact form validation failed", metadata: [
                "sender": .string(contactForm.senderName),
                "errors": .array(validationResult.errors.map { .string($0.message) })
            ])
            
            // Return failure response with validation details
            return ContactResponse(
                isSuccessful: false,
                responseMessage: formatValidationErrorMessage(validationResult.errors)
            )
        }
        
        // Step 2: Apply business logic processing
        do {
            try await processContactFormBusiness(contactForm, logger: logger)
            
            // Step 3: Log successful submission
            logger.info("Contact form processed successfully", metadata: [
                "sender": .string(contactForm.senderName),
                "email": .string(contactForm.senderEmail)
            ])
            
            // Step 4: Generate success response
            return ContactResponse.createSuccessResponse(for: contactForm.senderName)
            
        } catch {
            logger.error("Contact form processing failed", metadata: [
                "sender": .string(contactForm.senderName),
                "error": .string(error.localizedDescription)
            ])
            
            throw BusinessError.contactSubmissionFailed("Failed to process contact submission: \(error.localizedDescription)")
        }
    }
    
    /// Validates contact form data according to business rules.
    /// Performs comprehensive validation including format, length, and content checks.
    /// - Parameter contactForm: The contact form to validate
    /// - Returns: ValidationResult indicating success or specific validation failures
    /// - Throws: ValidationError for detailed validation feedback
    func validateContactForm(_ contactForm: ContactForm) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Validate sender name
        if contactForm.senderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.required(field: "senderName"))
        } else {
            let nameLength = contactForm.senderName.trimmingCharacters(in: .whitespacesAndNewlines).count
            if nameLength < ValidationLimits.minNameLength {
                errors.append(.tooShort(field: "senderName", minLength: ValidationLimits.minNameLength))
            } else if nameLength > ValidationLimits.maxNameLength {
                errors.append(.tooLong(field: "senderName", maxLength: ValidationLimits.maxNameLength))
            }
            
            // Business rule: Check for potentially suspicious names
            if containsSuspiciousContent(contactForm.senderName) {
                warnings.append("Name contains unusual characters")
            }
        }
        
        // Validate sender email
        if contactForm.senderEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.required(field: "senderEmail"))
        } else {
            let email = contactForm.senderEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            if email.count > ValidationLimits.maxEmailLength {
                errors.append(.tooLong(field: "senderEmail", maxLength: ValidationLimits.maxEmailLength))
            } else if !isValidEmailFormat(email) {
                errors.append(.invalidEmail(field: "senderEmail"))
            }
        }
        
        // Validate message content
        if contactForm.messageContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.required(field: "messageContent"))
        } else {
            let messageLength = contactForm.messageContent.trimmingCharacters(in: .whitespacesAndNewlines).count
            if messageLength < ValidationLimits.minMessageLength {
                errors.append(.tooShort(field: "messageContent", minLength: ValidationLimits.minMessageLength))
            } else if messageLength > ValidationLimits.maxMessageLength {
                errors.append(.tooLong(field: "messageContent", maxLength: ValidationLimits.maxMessageLength))
            }
            
            // Business rule: Check for spam indicators
            if containsSpamIndicators(contactForm.messageContent) {
                warnings.append("Message may contain spam indicators")
            }
        }
        
        // Return validation result
        if errors.isEmpty {
            return warnings.isEmpty ? 
                ValidationResult.success() : 
                ValidationResult.successWithWarnings(warnings)
        } else {
            return ValidationResult.failure(errors: errors)
        }
    }
    
    // MARK: - Private Business Logic Methods
    
    /// Processes the contact form according to business rules.
    /// In production, this would handle email sending, database storage, etc.
    /// - Parameters:
    ///   - contactForm: Validated contact form data
    ///   - logger: Logger for tracking processing steps
    /// - Throws: Error if processing fails
    private func processContactFormBusiness(_ contactForm: ContactForm, logger: Logger) async throws {
        // Business logic: In production, this would:
        // 1. Save to database
        // 2. Send email notification
        // 3. Queue background processing
        // 4. Update analytics/metrics
        // 5. Trigger integrations (CRM, etc.)
        
        logger.debug("Processing contact form business logic", metadata: [
            "sender": .string(contactForm.senderName),
            "messageLength": .string("\(contactForm.messageContent.count)")
        ])
        
        // Simulate processing time for realistic behavior
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Business rule: Additional processing based on message content
        if isHighPriorityMessage(contactForm.messageContent) {
            logger.info("High priority contact form detected", metadata: [
                "sender": .string(contactForm.senderName)
            ])
            // In production: Send immediate notification, flag for priority handling
        }
    }
    
    /// Validates email format using business-appropriate regex.
    /// - Parameter email: Email address to validate
    /// - Returns: Boolean indicating if email format is valid
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        do {
            let regex = try NSRegularExpression(pattern: emailRegex)
            let range = NSRange(location: 0, length: email.utf16.count)
            return regex.firstMatch(in: email, options: [], range: range) != nil
        } catch {
            return false
        }
    }
    
    /// Checks if content contains suspicious patterns that might indicate spam or malicious input.
    /// - Parameter content: Content to check
    /// - Returns: Boolean indicating if suspicious content is detected
    private func containsSuspiciousContent(_ content: String) -> Bool {
        let suspiciousPatterns = [
            #"\b(script|javascript|onclick|onerror)\b"#,
            #"<[^>]*>"#, // HTML tags
            #"\b(http|https|www\.)\b"# // URLs in names
        ]
        
        for pattern in suspiciousPatterns {
            if content.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                return true
            }
        }
        
        return false
    }
    
    /// Checks if message content contains common spam indicators.
    /// - Parameter message: Message content to analyze
    /// - Returns: Boolean indicating if spam indicators are detected
    private func containsSpamIndicators(_ message: String) -> Bool {
        let spamKeywords = [
            "buy now", "click here", "free money", "urgent", "act now",
            "limited time", "earn money", "work from home", "guaranteed"
        ]
        
        let lowercaseMessage = message.lowercased()
        return spamKeywords.contains { keyword in
            lowercaseMessage.contains(keyword)
        }
    }
    
    /// Determines if a message should be treated as high priority.
    /// - Parameter message: Message content to analyze
    /// - Returns: Boolean indicating if message is high priority
    private func isHighPriorityMessage(_ message: String) -> Bool {
        let priorityKeywords = [
            "urgent", "emergency", "asap", "immediately", "critical",
            "important", "priority", "deadline"
        ]
        
        let lowercaseMessage = message.lowercased()
        return priorityKeywords.contains { keyword in
            lowercaseMessage.contains(keyword)
        }
    }
    
    /// Formats validation errors into a user-friendly message.
    /// - Parameter errors: Array of validation errors
    /// - Returns: Formatted error message string
    private func formatValidationErrorMessage(_ errors: [ValidationError]) -> String {
        if errors.count == 1 {
            return errors.first?.message ?? "Please check your input and try again."
        } else {
            let messages = errors.map { "• \($0.message)" }.joined(separator: "\n")
            return "Please correct the following issues:\n\(messages)"
        }
    }
}