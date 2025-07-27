import Vapor
import Leaf

public func configure(_ app: Application) throws {
    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    // Debug: Print template directory path
    let viewsPath = app.directory.viewsDirectory
    print("Views directory: \(viewsPath)")
    
    // Serve static files
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Register routes
    try routes(app)
}
