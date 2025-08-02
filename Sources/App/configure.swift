import Vapor
import Leaf

public func configure(_ app: Application) throws {
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

