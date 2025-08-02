import Vapor

/// Configures all application routes including web pages and API endpoints.
/// - Parameter app: The Vapor application instance to configure routes for
func routes(_ app: Application) throws {
    try configureWebRoutes(app)
    try configureAPIRoutes(app)
}

// MARK: - Storage Keys

/// Storage key for ContentService in application storage.
struct ContentServiceKey: StorageKey {
    typealias Value = ContentService
}

/// Storage key for ProfileService in application storage.
struct ProfileServiceKey: StorageKey {
    typealias Value = ProfileService
}

/// Storage key for ContactService in application storage.
struct ContactServiceKey: StorageKey {
    typealias Value = ContactService
}

// MARK: - Web Routes

/// Configures web page routes that return rendered HTML views.
/// - Parameter app: The Vapor application instance
private func configureWebRoutes(_ app: Application) throws {
    app.get { request async throws -> View in
        guard let profileService = request.application.storage[ProfileServiceKey.self] else {
            throw Abort(.internalServerError, reason: "ProfileService not configured")
        }
        let homeContext = try await profileService.getHomeContext()
        
        // Log context for debugging
        app.logger.info("Rendering home template for: \(homeContext.personalInfo.name)")
        
        return try await request.view.render("home", homeContext)
    }
}

// MARK: - API Routes

/// Configures API endpoints that return JSON responses.
/// - Parameter app: The Vapor application instance
private func configureAPIRoutes(_ app: Application) throws {
    app.group("api") { apiGroup in
        configureProfileRoutes(apiGroup)
        configureSkillsRoutes(apiGroup)
        configureContactRoutes(apiGroup)
    }
}

/// Configures profile-related API endpoints.
/// - Parameter apiGroup: The API route group
private func configureProfileRoutes(_ apiGroup: RoutesBuilder) {
    apiGroup.get("profile") { request async throws -> ProfileResponse in
        guard let profileService = request.application.storage[ProfileServiceKey.self] else {
            throw Abort(.internalServerError, reason: "ProfileService not configured")
        }
        return try await profileService.getProfileResponse()
    }
}

/// Configures skills-related API endpoints.
/// - Parameter apiGroup: The API route group
private func configureSkillsRoutes(_ apiGroup: RoutesBuilder) {
    apiGroup.get("skills") { request async throws -> [Skill] in
        guard let contentService = request.application.storage[ContentServiceKey.self] else {
            throw Abort(.internalServerError, reason: "ContentService not configured")
        }
        return try await contentService.getSkills()
    }
}

/// Configures contact form API endpoints.
/// - Parameter apiGroup: The API route group
private func configureContactRoutes(_ apiGroup: RoutesBuilder) {
    apiGroup.post("contact") { request async throws -> ContactResponse in
        do {
            let contactForm = try request.content.decode(ContactForm.self)
            guard let contactService = request.application.storage[ContactServiceKey.self] else {
                throw Abort(.internalServerError, reason: "ContactService not configured")
            }
            
            return try await contactService.processContactSubmission(contactForm, logger: request.logger)
            
        } catch let decodingError as DecodingError {
            request.logger.error("Failed to decode contact form: \(decodingError)")
            return ContactResponse(
                isSuccessful: false,
                responseMessage: "Invalid form data. Please check your input and try again."
            )
        } catch let businessError as BusinessError {
            request.logger.error("Business logic error: \(businessError.localizedDescription)")
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
}
