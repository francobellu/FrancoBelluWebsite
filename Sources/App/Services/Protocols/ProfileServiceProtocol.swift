import Vapor

/// Protocol defining profile-related business operations.
/// Provides an abstraction layer for profile data management and retrieval.
protocol ProfileServiceProtocol {
    /// Retrieves the complete home page context including all profile information.
    /// - Returns: HomeContext containing profile data, skills, experiences, and projects
    func getHomeContext() async throws -> HomeContext
    
    /// Retrieves basic profile information for API responses.
    /// - Returns: ProfileResponse containing essential profile details
    func getProfileResponse() async throws -> ProfileResponse
}