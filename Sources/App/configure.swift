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
    
    // Register routes
    try routes(app)
}
