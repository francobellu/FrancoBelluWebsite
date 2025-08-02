import Vapor

/// Controller responsible for content-related API endpoints.
/// Handles skills, experiences, projects, and about text retrieval.
final class ContentController: BaseController {
    
    /// Retrieves all skills for display on the website.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Array of Skill objects with descriptions
    func getSkills(request: Request) async throws -> [Skill] {
        logRequest(request, action: "getSkills")
        
        do {
            let contentService = try getContentService(from: request)
            let skills = try await contentService.getSkills()
            
            request.logger.info("Skills retrieved successfully", metadata: [
                "skillsCount": .string("\(skills.count)")
            ])
            
            return skills
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error retrieving skills: \(error)")
            throw Abort(.internalServerError, reason: "Failed to retrieve skills")
        }
    }
    
    /// Retrieves all work experiences for the portfolio section.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Array of Experience objects ordered by relevance
    func getExperiences(request: Request) async throws -> [Experience] {
        logRequest(request, action: "getExperiences")
        
        do {
            let contentService = try getContentService(from: request)
            let experiences = try await contentService.getExperiences()
            
            request.logger.info("Experiences retrieved successfully", metadata: [
                "experiencesCount": .string("\(experiences.count)")
            ])
            
            return experiences
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error retrieving experiences: \(error)")
            throw Abort(.internalServerError, reason: "Failed to retrieve experiences")
        }
    }
    
    /// Retrieves all portfolio projects for showcase.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Array of Project objects with details
    func getProjects(request: Request) async throws -> [Project] {
        logRequest(request, action: "getProjects")
        
        do {
            let contentService = try getContentService(from: request)
            let projects = try await contentService.getProjects()
            
            request.logger.info("Projects retrieved successfully", metadata: [
                "projectsCount": .string("\(projects.count)")
            ])
            
            return projects
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error retrieving projects: \(error)")
            throw Abort(.internalServerError, reason: "Failed to retrieve projects")
        }
    }
    
    /// Retrieves the about section text content.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Formatted about text for profile display
    func getAboutText(request: Request) async throws -> AboutTextResponse {
        logRequest(request, action: "getAboutText")
        
        do {
            let contentService = try getContentService(from: request)
            let aboutText = try await contentService.getAboutText()
            
            request.logger.info("About text retrieved successfully", metadata: [
                "textLength": .string("\(aboutText.count)")
            ])
            
            return AboutTextResponse(content: aboutText)
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error retrieving about text: \(error)")
            throw Abort(.internalServerError, reason: "Failed to retrieve about text")
        }
    }
    
    /// Retrieves comprehensive content summary for overview purposes.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: ContentSummary with counts and metadata
    func getContentSummary(request: Request) async throws -> ContentSummary {
        logRequest(request, action: "getContentSummary")
        
        do {
            let contentService = try getContentService(from: request)
            
            // Retrieve all content concurrently for better performance
            async let skills = contentService.getSkills()
            async let experiences = contentService.getExperiences()
            async let projects = contentService.getProjects()
            async let aboutText = contentService.getAboutText()
            
            let skillsArray = try await skills
            let experiencesArray = try await experiences
            let projectsArray = try await projects
            let aboutTextString = try await aboutText
            
            let summary = ContentSummary(
                skillsCount: skillsArray.count,
                experiencesCount: experiencesArray.count,
                projectsCount: projectsArray.count,
                aboutTextLength: aboutTextString.count,
                lastUpdated: Date()
            )
            
            request.logger.info("Content summary generated successfully", metadata: [
                "skillsCount": .string("\(summary.skillsCount)"),
                "experiencesCount": .string("\(summary.experiencesCount)"),
                "projectsCount": .string("\(summary.projectsCount)")
            ])
            
            return summary
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error generating content summary: \(error)")
            throw Abort(.internalServerError, reason: "Failed to generate content summary")
        }
    }
    
    /// Health check endpoint for content service availability.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Health status response
    func healthCheck(request: Request) async throws -> HealthCheckResponse {
        logRequest(request, action: "contentHealthCheck")
        
        do {
            let contentService = try getContentService(from: request)
            
            // Test service availability by attempting to get skills
            _ = try await contentService.getSkills()
            
            return HealthCheckResponse(
                status: "healthy",
                service: "ContentService",
                timestamp: Date().timeIntervalSince1970
            )
            
        } catch {
            request.logger.warning("Content service health check failed: \(error)")
            
            return HealthCheckResponse(
                status: "unhealthy",
                service: "ContentService",
                timestamp: Date().timeIntervalSince1970,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Supporting Models

/// Response wrapper for about text content.
struct AboutTextResponse: Content {
    let content: String
}

/// Summary of all content with metadata.
struct ContentSummary: Content {
    let skillsCount: Int
    let experiencesCount: Int
    let projectsCount: Int
    let aboutTextLength: Int
    let lastUpdated: Date
}