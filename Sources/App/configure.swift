import Vapor
import Leaf

public func configure(_ app: Application) async throws {
    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    // Use standard web server resource paths
    app.directory.viewsDirectory = app.directory.workingDirectory + "Resources/Views/"
    app.directory.publicDirectory = app.directory.workingDirectory + "Public/"
    
    // Debug: Print paths and check file existence
    let viewsPath = app.directory.viewsDirectory
    let homePath = viewsPath + "home.leaf"
    print("Working directory: \(app.directory.workingDirectory)")
    print("Views directory: \(viewsPath)")
    print("Home template path: \(homePath)")
    print("Home template exists: \(FileManager.default.fileExists(atPath: homePath))")
    
    // List all files in Views directory
    if let files = try? FileManager.default.contentsOfDirectory(atPath: viewsPath) {
        print("Files in Views directory: \(files)")
    }
    
    // Serve static files
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure custom error handling using Vapor's ErrorMiddleware
    app.middleware.use(ErrorMiddleware { request, error in
        return handleApplicationError(request: request, error: error, environment: app.environment)
    })
    
    // Register services for dependency injection
    try configureServices(app)
    
    // Register routes
    try routes(app)
}

/// Configures and registers all application services.
/// - Parameter app: The Vapor application instance
private func configureServices(_ app: Application) throws {
    // Create services and store them in app.storage for access in routes
    // This is a simple dependency injection approach for this application
    
    // Content service - handles skills, experiences, projects, about text
    let contentService = ContentService()
    app.storage[ContentServiceKey.self] = contentService
    
    // Profile service - depends on content service
    let profileService = ProfileService(contentService: contentService)
    app.storage[ProfileServiceKey.self] = profileService
    
    // Contact service - handles contact form processing and validation
    let contactService = ContactService()
    app.storage[ContactServiceKey.self] = contactService
    
    app.logger.info("Services configured successfully")
}

// MARK: - Custom Error Handling

/// Custom error handler function for Vapor's ErrorMiddleware
/// Provides proper 404 handling for both web and API requests.
func handleApplicationError(request: Request, error: Error, environment: Environment) -> Response {
    let status: HTTPResponseStatus
    let reason: String
    
    // Determine error status and reason
    switch error {
    case let abort as Abort:
        status = abort.status
        reason = abort.reason
    case let abortError as AbortError:
        status = abortError.status
        reason = abortError.reason
    case let validation as ValidationError:
        status = .badRequest
        reason = validation.localizedDescription
    default:
        status = .internalServerError
        reason = environment.isRelease ? "Internal Server Error" : String(describing: error)
    }
    
    request.logger.error("Error: \(status.code) - \(reason)")
    
    // Handle 404 Not Found specifically with custom logic
    if status == .notFound {
        return handle404Error(for: request, reason: reason)
    }
    
    // Handle other errors with appropriate response format
    if request.url.path.hasPrefix("/api/") {
        // API requests get JSON error responses
        let errorResponse = ErrorResponse(
            error: true,
            reason: reason,
            code: status.code.description
        )
        let response = Response(status: status)
        try! response.content.encode(errorResponse)
        return response
    } else {
        // Web requests get basic error response for non-404 errors
        let response = Response(status: status)
        response.body = Response.Body(string: "Error: \(reason)")
        response.headers.contentType = .plainText
        return response
    }
}

/// Handles 404 errors with custom logic for API vs web requests.
func handle404Error(for request: Request, reason: String) -> Response {
    // For API requests, return JSON error
    if request.url.path.hasPrefix("/api/") {
        let errorResponse = ErrorResponse(
            error: true,
            reason: "Endpoint not found",
            code: "NOT_FOUND"
        )
        let response = Response(status: .notFound)
        try! response.content.encode(errorResponse)
        return response
    }
    
    // For web requests, return simple HTML 404 page
    let response = Response(status: .notFound)
    response.body = Response.Body(string: """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Page Not Found - Franco Bellu</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
                       background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                       margin: 0; padding: 40px; min-height: 100vh; display: flex; 
                       align-items: center; justify-content: center; }
                .error-container { background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); 
                                  border-radius: 20px; padding: 40px; text-align: center; 
                                  color: white; max-width: 500px; }
                h1 { font-size: 3rem; margin-bottom: 1rem; }
                p { font-size: 1.2rem; margin-bottom: 2rem; }
                a { background: rgba(255,255,255,0.2); color: white; padding: 12px 24px; 
                   border-radius: 25px; text-decoration: none; font-weight: 600; 
                   border: 1px solid rgba(255,255,255,0.3); }
                a:hover { background: rgba(255,255,255,0.3); }
            </style>
        </head>
        <body>
            <div class="error-container">
                <h1>404</h1>
                <p>Page Not Found</p>
                <p>The page you're looking for doesn't exist.</p>
                <a href="/">Go Home</a>
            </div>
        </body>
        </html>
    """)
    response.headers.contentType = .html
    return response
}
