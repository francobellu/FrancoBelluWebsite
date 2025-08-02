import Vapor

/// Controller responsible for contact form processing and communication endpoints.
/// Handles form validation, submission processing, and response generation.
final class ContactController: BaseController {
    
    /// Processes contact form submissions with comprehensive validation.
    /// - Parameter request: The incoming HTTP request containing form data
    /// - Returns: ContactResponse indicating success or failure
    func submitContact(request: Request) async throws -> ContactResponse {
        logRequest(request, action: "submitContact")
        
        do {
            // Decode and validate request data
            let contactForm = try request.content.decode(ContactForm.self)
            
            request.logger.info("Contact form received", metadata: [
                "senderName": .string(contactForm.senderName),
                "senderEmail": .string(contactForm.senderEmail),
                "messageLength": .string("\(contactForm.messageContent.count)")
            ])
            
            let contactService = try getContactService(from: request)
            let response = try await contactService.processContactSubmission(contactForm, logger: request.logger)
            
            if response.isSuccessful {
                request.logger.info("Contact form processed successfully", metadata: [
                    "senderName": .string(contactForm.senderName)
                ])
            }
            
            return response
            
        } catch let decodingError as DecodingError {
            request.logger.warning("Contact form decoding failed: \(decodingError)")
            return ContactResponse(
                isSuccessful: false,
                responseMessage: "Invalid form data. Please check your input and try again."
            )
            
        } catch let businessError as BusinessError {
            request.logger.error("Contact form business logic error: \(businessError.localizedDescription)")
            return ContactResponse(
                isSuccessful: false,
                responseMessage: businessError.localizedDescription
            )
            
        } catch {
            request.logger.error("Unexpected error processing contact form: \(error)")
            return ContactResponse(
                isSuccessful: false,
                responseMessage: "An unexpected error occurred. Please try again later."
            )
        }
    }
    
    /// Validates contact form data without processing submission.
    /// Useful for client-side validation feedback.
    /// - Parameter request: The incoming HTTP request containing form data
    /// - Returns: ValidationResult with detailed validation feedback
    func validateContact(request: Request) async throws -> ValidationResult {
        logRequest(request, action: "validateContact")
        
        do {
            let contactForm = try request.content.decode(ContactForm.self)
            let contactService = try getContactService(from: request)
            
            let validationResult = try await contactService.validateContactForm(contactForm)
            
            request.logger.info("Contact form validation completed", metadata: [
                "isValid": .string("\(validationResult.isValid)"),
                "errorCount": .string("\(validationResult.errors.count)"),
                "warningCount": .string("\(validationResult.warnings.count)")
            ])
            
            return validationResult
            
        } catch let decodingError as DecodingError {
            request.logger.warning("Contact form validation decoding failed: \(decodingError)")
            
            return ValidationResult.failure(errors: [
                ValidationError(
                    field: "form",
                    message: "Invalid form data format",
                    code: "INVALID_FORMAT"
                )
            ])
            
        } catch let businessError as BusinessError {
            request.logger.error("Contact form validation error: \(businessError.localizedDescription)")
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error validating contact form: \(error)")
            throw Abort(.internalServerError, reason: "Validation service temporarily unavailable")
        }
    }
    
    /// Retrieves contact form submission statistics (for admin use).
    /// - Parameter request: The incoming HTTP request
    /// - Returns: ContactStatistics with submission metrics
    func getContactStats(request: Request) async throws -> ContactStatistics {
        logRequest(request, action: "getContactStats")
        
        // In a real application, this would query database for statistics
        // For now, return mock statistics
        
        request.logger.info("Contact statistics requested")
        
        return ContactStatistics(
            totalSubmissions: 0,
            successfulSubmissions: 0,
            failedSubmissions: 0,
            averageResponseTime: 0.0,
            lastSubmissionDate: nil
        )
    }
    
    /// Health check endpoint for contact service availability.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Health status response
    func healthCheck(request: Request) async throws -> HealthCheckResponse {
        logRequest(request, action: "contactHealthCheck")
        
        do {
            let contactService = try getContactService(from: request)
            
            // Test service availability with a basic validation
            let testForm = ContactForm(
                senderName: "Test",
                senderEmail: "test@example.com",
                messageContent: "Health check test message"
            )
            
            _ = try await contactService.validateContactForm(testForm)
            
            return HealthCheckResponse(
                status: "healthy",
                service: "ContactService",
                timestamp: Date().timeIntervalSince1970
            )
            
        } catch {
            request.logger.warning("Contact service health check failed: \(error)")
            
            return HealthCheckResponse(
                status: "unhealthy",
                service: "ContactService",
                timestamp: Date().timeIntervalSince1970,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Supporting Models

/// Statistics for contact form submissions.
struct ContactStatistics: Content {
    let totalSubmissions: Int
    let successfulSubmissions: Int
    let failedSubmissions: Int
    let averageResponseTime: Double
    let lastSubmissionDate: Date?
}