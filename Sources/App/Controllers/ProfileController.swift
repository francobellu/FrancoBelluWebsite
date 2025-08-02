import Vapor

/// Controller responsible for profile-related API endpoints.
/// Handles profile data retrieval and personal information APIs.
final class ProfileController: BaseController {
    
    /// Retrieves basic profile information for API consumption.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: ProfileResponse with essential profile details
    func getProfile(request: Request) async throws -> ProfileResponse {
        logRequest(request, action: "getProfile")
        
        do {
            let profileService = try getProfileService(from: request)
            let profileResponse = try await profileService.getProfileResponse()
            
            request.logger.info("Profile data retrieved successfully", metadata: [
                "profileName": .string(profileResponse.name),
                "profileEmail": .string(profileResponse.email)
            ])
            
            return profileResponse
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error in getProfile: \(error)")
            throw Abort(.internalServerError, reason: "Failed to retrieve profile information")
        }
    }
    
    /// Retrieves comprehensive profile context for advanced API clients.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Complete HomeContext with all profile information
    func getProfileContext(request: Request) async throws -> HomeContext {
        logRequest(request, action: "getProfileContext")
        
        do {
            let profileService = try getProfileService(from: request)
            let homeContext = try await profileService.getHomeContext()
            
            request.logger.info("Profile context retrieved successfully", metadata: [
                "personalName": .string(homeContext.personalInfo.name),
                "dataPoints": .string("skills(\(homeContext.skills.count)), experiences(\(homeContext.experiences.count)), projects(\(homeContext.projects.count))")
            ])
            
            return homeContext
            
        } catch let businessError as BusinessError {
            throw Abort(businessError.httpStatus, reason: businessError.localizedDescription)
            
        } catch {
            request.logger.error("Unexpected error in getProfileContext: \(error)")
            throw Abort(.internalServerError, reason: "Failed to retrieve profile context")
        }
    }
    
    /// Health check endpoint for profile service availability.
    /// - Parameter request: The incoming HTTP request
    /// - Returns: Health status response
    func healthCheck(request: Request) async throws -> HealthCheckResponse {
        logRequest(request, action: "profileHealthCheck")
        
        do {
            let profileService = try getProfileService(from: request)
            
            // Test service availability by attempting to get profile data
            _ = try await profileService.getProfileResponse()
            
            return HealthCheckResponse(
                status: "healthy",
                service: "ProfileService",
                timestamp: Date().timeIntervalSince1970
            )
            
        } catch {
            request.logger.warning("Profile service health check failed: \(error)")
            
            return HealthCheckResponse(
                status: "unhealthy",
                service: "ProfileService",
                timestamp: Date().timeIntervalSince1970,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Supporting Models

/// Response model for health check endpoints.
struct HealthCheckResponse: Content {
    let status: String
    let service: String
    let timestamp: TimeInterval
    let error: String?
    
    init(status: String, service: String, timestamp: TimeInterval, error: String? = nil) {
        self.status = status
        self.service = service
        self.timestamp = timestamp
        self.error = error
    }
}