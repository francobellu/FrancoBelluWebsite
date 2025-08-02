import Vapor

/// Protocol defining content management operations for skills, experiences, and projects.
/// Provides business logic for retrieving and managing website content data.
protocol ContentServiceProtocol {
    /// Retrieves all skills for display on the website.
    /// - Returns: Array of Skill objects with descriptions and categories
    func getSkills() async throws -> [Skill]
    
    /// Retrieves all work experiences for the portfolio section.
    /// - Returns: Array of Experience objects ordered by relevance
    func getExperiences() async throws -> [Experience]
    
    /// Retrieves all portfolio projects for showcase.
    /// - Returns: Array of Project objects with details and links
    func getProjects() async throws -> [Project]
    
    /// Retrieves the about section text content.
    /// - Returns: Formatted about text for profile display
    func getAboutText() async throws -> String
}