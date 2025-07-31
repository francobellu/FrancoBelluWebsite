import Vapor

/// Configures all application routes including web pages and API endpoints.
/// - Parameter app: The Vapor application instance to configure routes for
func routes(_ app: Application) throws {
    try configureWebRoutes(app)
    try configureAPIRoutes(app)
}

// MARK: - Web Routes

/// Configures web page routes that return rendered HTML views.
/// - Parameter app: The Vapor application instance
private func configureWebRoutes(_ app: Application) throws {
    app.get { request async throws -> View in
        let homeContext = HomeContext.createDefault()
        
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
    apiGroup.get("profile") { _ -> ProfileResponse in
        ProfileResponse.createDefault()
    }
}

/// Configures skills-related API endpoints.
/// - Parameter apiGroup: The API route group
private func configureSkillsRoutes(_ apiGroup: RoutesBuilder) {
    apiGroup.get("skills") { _ -> [Skill] in
        Skill.createDefaultSkills()
    }
}

/// Configures contact form API endpoints.
/// - Parameter apiGroup: The API route group
private func configureContactRoutes(_ apiGroup: RoutesBuilder) {
    apiGroup.post("contact") { request async throws -> ContactResponse in
        try await processContactFormSubmission(request: request)
    }
}

/// Processes contact form submission with validation and response generation.
/// - Parameter request: The incoming HTTP request containing form data
/// - Returns: ContactResponse indicating success or failure
/// - Throws: DecodingError if the request body cannot be decoded
private func processContactFormSubmission(request: Request) async throws -> ContactResponse {
    do {
        let contactForm = try request.content.decode(ContactForm.self)
        
        guard contactForm.isValid() else {
            request.logger.warning("Invalid contact form submission received")
            return ContactResponse.createFailureResponse()
        }
        
        // Log successful form submission
        request.logger.info("Contact form submitted by: \(contactForm.senderName)")
        
        // In a real application, you would:
        // 1. Save to database
        // 2. Send email notification
        // 3. Queue background jobs
        
        return ContactResponse.createSuccessResponse(for: contactForm.senderName)
        
    } catch {
        request.logger.error("Failed to process contact form: \(error)")
        return ContactResponse.createFailureResponse()
    }
}
