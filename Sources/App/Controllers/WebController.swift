import Vapor

/// Controller responsible for web page routes that return rendered HTML views.
/// Handles server-side rendering with Leaf templates.
/// Note: 404 error handling is managed by ErrorMiddleware in configure.swift
final class WebController: BaseController {
    
    /// Renders the home page with complete profile context.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Rendered HTML view
    /// - Throws: Abort if service is unavailable or rendering fails
    func renderHome(request: Request) async throws -> View {
        logRequest(request, action: "renderHome")
        
        do {
            let profileService = try getProfileService(from: request)
            let homeContext = try await profileService.getHomeContext()
            
            // Log successful context retrieval
            request.logger.info("Home context retrieved successfully", metadata: [
                "personalName": .string(homeContext.personalInfo.name),
                "skillsCount": .string("\(homeContext.skills.count)"),
                "experiencesCount": .string("\(homeContext.experiences.count)"),
                "projectsCount": .string("\(homeContext.projects.count)")
            ])
            
            return try await request.view.render("home", homeContext)
            
        } catch let businessError as BusinessError {
            request.logger.error("Business error in renderHome: \(businessError.localizedDescription)")
            // For web pages, we might want to render an error page instead of JSON
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error in renderHome: \(error)")
            throw Abort(.internalServerError, reason: "Failed to render home page")
        }
    }
    
    /// Renders an error page for web requests.
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - error: The error to display
    /// - Returns: Rendered error page
    func renderError(request: Request, error: Error) async throws -> View {
        logRequest(request, action: "renderError")
        
        let errorContext = ErrorPageContext(
            title: "Error",
            message: error.localizedDescription,
            statusCode: 500
        )
        
        return try await request.view.render("error", errorContext)
    }
    
    /// Renders a generic error page for web requests.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Rendered error page
    func renderError(request: Request) async throws -> View {
        logRequest(request, action: "renderError")
        
        let errorContext = ErrorPageContext(
            title: "Error",
            message: "An unexpected error occurred. Please try again later.",
            statusCode: 500
        )
        
        return try await request.view.render("error", errorContext)
    }
    
}

// MARK: - Supporting Models

/// Context for error page rendering.
struct ErrorPageContext: Content {
    let title: String
    let message: String
    let statusCode: Int
}