import Vapor
import Foundation

/// Service responsible for profile-related business operations.
/// Handles profile data retrieval, context generation, and profile management.
final class ProfileService: ProfileServiceProtocol {
    private let contentService: ContentServiceProtocol
    
    /// Initializes the ProfileService with required dependencies.
    /// - Parameter contentService: Service for managing content data
    init(contentService: ContentServiceProtocol) {
        self.contentService = contentService
    }
    
    /// Retrieves the complete home page context including all profile information.
    /// Aggregates data from multiple sources to create a comprehensive context.
    /// - Returns: HomeContext containing profile data, skills, experiences, and projects
    /// - Throws: BusinessError if data retrieval fails
    func getHomeContext() async throws -> HomeContext {
        do {
            // Retrieve all required data concurrently for better performance
            async let personalInfo = getPersonalInfo()
            async let about = contentService.getAboutText()
            async let skills = contentService.getSkills()
            async let experiences = contentService.getExperiences()
            async let projects = contentService.getProjects()
            
            // Await all concurrent operations
            let context = HomeContext(
                personalInfo: try await personalInfo,
                about: try await about,
                skills: try await skills,
                experiences: try await experiences,
                projects: try await projects
            )
            
            return context
            
        } catch {
            throw BusinessError.dataNotFound("Failed to retrieve home context: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves basic profile information for API responses.
    /// Optimized for API consumption with essential profile details only.
    /// - Returns: ProfileResponse containing essential profile details
    /// - Throws: BusinessError if profile data retrieval fails
    func getProfileResponse() async throws -> ProfileResponse {
        do {
            let personalInfo = try await getPersonalInfo()
            
            return ProfileResponse(
                name: personalInfo.name,
                professionalTitle: personalInfo.professionalTitle,
                email: personalInfo.email,
                phoneNumber: personalInfo.phoneNumber,
                location: personalInfo.location
            )
            
        } catch {
            throw BusinessError.dataNotFound("Failed to retrieve profile response: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Retrieves personal information from the configured data source.
    /// In a production application, this would fetch from a database or external service.
    /// - Returns: PersonalInfo containing contact details and professional information
    /// - Throws: BusinessError if personal info retrieval fails
    private func getPersonalInfo() async throws -> PersonalInfo {
        // For now, use the static factory method
        // In production, this would fetch from a database or configuration service
        return PersonalInfo.createDefault()
    }
}