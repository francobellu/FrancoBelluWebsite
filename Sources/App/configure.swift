import Vapor
import Leaf

public func configure(_ app: Application) throws {
    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    // Use bundle resources for views
    if let bundlePath = Bundle.module.resourcePath {
        app.directory.viewsDirectory = bundlePath + "/Resources/Views/"
    }
    
    // Set public directory to project root for static files
    app.directory.publicDirectory = "/Users/francobellu/Documents/ClaudeProjects/claudeWebpage/FrancoBelluWebsite/Public/"
    
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
