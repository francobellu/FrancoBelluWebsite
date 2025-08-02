import Vapor

/// Configures all application routes including web pages and API endpoints.
/// Uses controller-based architecture for better organization and testability.
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
/// Uses WebController for clean separation of concerns.
/// - Parameter app: The Vapor application instance
private func configureWebRoutes(_ app: Application) throws {
    let webController = WebController()
    
    // Home page
    app.get(use: webController.renderHome)
    
    // Error handling routes
    app.get("error", use: webController.renderError)
}

// MARK: - API Routes

/// Configures API endpoints that return JSON responses.
/// Uses dedicated controllers for each domain area.
/// - Parameter app: The Vapor application instance
private func configureAPIRoutes(_ app: Application) throws {
    try app.group("api") { apiGroup in
        try configureProfileRoutes(apiGroup)
        try configureContentRoutes(apiGroup)
        try configureContactRoutes(apiGroup)
        try configureHealthRoutes(apiGroup)
    }
}

/// Configures profile-related API endpoints.
/// - Parameter apiGroup: The API route group
/// - Throws: Configuration errors
private func configureProfileRoutes(_ apiGroup: RoutesBuilder) throws {
    let profileController = ProfileController()
    
    apiGroup.group("profile") { profileGroup in
        // GET /api/profile - Basic profile information
        profileGroup.get(use: profileController.getProfile)
        
        // GET /api/profile/context - Complete profile context
        profileGroup.get("context", use: profileController.getProfileContext)
        
        // GET /api/profile/health - Health check
        profileGroup.get("health", use: profileController.healthCheck)
    }
}

/// Configures content-related API endpoints (skills, experiences, projects).
/// - Parameter apiGroup: The API route group
/// - Throws: Configuration errors
private func configureContentRoutes(_ apiGroup: RoutesBuilder) throws {
    let contentController = ContentController()
    
    // Skills endpoints
    apiGroup.get("skills", use: contentController.getSkills)
    
    // Experiences endpoints  
    apiGroup.get("experiences", use: contentController.getExperiences)
    
    // Projects endpoints
    apiGroup.get("projects", use: contentController.getProjects)
    
    // About text endpoint
    apiGroup.get("about", use: contentController.getAboutText)
    
    // Content summary endpoint
    apiGroup.get("content", "summary", use: contentController.getContentSummary)
    
    // Health check
    apiGroup.get("content", "health", use: contentController.healthCheck)
}

/// Configures contact form API endpoints.
/// - Parameter apiGroup: The API route group
/// - Throws: Configuration errors
private func configureContactRoutes(_ apiGroup: RoutesBuilder) throws {
    let contactController = ContactController()
    
    apiGroup.group("contact") { contactGroup in
        // POST /api/contact - Submit contact form
        contactGroup.post(use: contactController.submitContact)
        
        // POST /api/contact/validate - Validate contact form without submitting
        contactGroup.post("validate", use: contactController.validateContact)
        
        // GET /api/contact/stats - Contact statistics (for admin)
        contactGroup.get("stats", use: contactController.getContactStats)
        
        // GET /api/contact/health - Health check
        contactGroup.get("health", use: contactController.healthCheck)
    }
}

/// Configures health check and monitoring endpoints.
/// - Parameter apiGroup: The API route group  
/// - Throws: Configuration errors
private func configureHealthRoutes(_ apiGroup: RoutesBuilder) throws {
    apiGroup.group("health") { healthGroup in
        // GET /api/health - Overall application health
        healthGroup.get { request async throws -> ApplicationHealthResponse in
            let profileController = ProfileController()
            let contactController = ContactController()
            let contentController = ContentController()
            
            // Check all services concurrently
            async let profileHealth = profileController.healthCheck(request: request)
            async let contactHealth = contactController.healthCheck(request: request)
            async let contentHealth = contentController.healthCheck(request: request)
            
            let healthChecks = try await [profileHealth, contactHealth, contentHealth]
            let allHealthy = healthChecks.allSatisfy { $0.status == "healthy" }
            
            return ApplicationHealthResponse(
                status: allHealthy ? "healthy" : "degraded",
                services: healthChecks,
                timestamp: Date().timeIntervalSince1970
            )
        }
    }
}

// MARK: - Supporting Models

/// Overall application health response.
struct ApplicationHealthResponse: Content {
    let status: String
    let services: [HealthCheckResponse]
    let timestamp: TimeInterval
}

