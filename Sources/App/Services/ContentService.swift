import Vapor
import Foundation

/// Service responsible for content management operations.
/// Handles retrieval and management of skills, experiences, projects, and about text.
final class ContentService: ContentServiceProtocol {
    
    /// Initializes the ContentService.
    /// Future versions may accept configuration or repository dependencies.
    init() {
        // Currently no dependencies required
        // In production, might inject repositories or configuration services
    }
    
    /// Retrieves all skills for display on the website.
    /// Skills are returned in a prioritized order for optimal presentation.
    /// - Returns: Array of Skill objects with descriptions and categories
    /// - Throws: BusinessError if skills retrieval fails
    func getSkills() async throws -> [Skill] {
        do {
            let skills = Skill.createDefaultSkills()
            
            // Apply business logic: validate skills have required data
            let validatedSkills = try validateSkillsData(skills)
            
            // Apply business logic: sort skills by priority/category
            return sortSkillsByPriority(validatedSkills)
            
        } catch {
            throw BusinessError.dataNotFound("Failed to retrieve skills: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves all work experiences for the portfolio section.
    /// Experiences are ordered by relevance and date for optimal presentation.
    /// - Returns: Array of Experience objects ordered by relevance
    /// - Throws: BusinessError if experiences retrieval fails
    func getExperiences() async throws -> [Experience] {
        do {
            let experiences = Experience.createDefaultExperiences()
            
            // Apply business logic: validate experience data
            let validatedExperiences = try validateExperienceData(experiences)
            
            // Apply business logic: sort by date/relevance
            return sortExperiencesByRelevance(validatedExperiences)
            
        } catch {
            throw BusinessError.dataNotFound("Failed to retrieve experiences: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves all portfolio projects for showcase.
    /// Projects are filtered and ordered to show the most impressive work first.
    /// - Returns: Array of Project objects with details and links
    /// - Throws: BusinessError if projects retrieval fails
    func getProjects() async throws -> [Project] {
        do {
            let projects = Project.createDefaultProjects()
            
            // Apply business logic: validate project data
            let validatedProjects = try validateProjectData(projects)
            
            // Apply business logic: filter and sort projects
            return sortProjectsByImpact(validatedProjects)
            
        } catch {
            throw BusinessError.dataNotFound("Failed to retrieve projects: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves the about section text content.
    /// Applies formatting and business rules for about text presentation.
    /// - Returns: Formatted about text for profile display
    /// - Throws: BusinessError if about text retrieval fails
    func getAboutText() async throws -> String {
        do {
            let aboutText = PersonalInfo.defaultAboutText
            
            // Apply business logic: validate text length and format
            guard !aboutText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.dataNotFound("About text is empty")
            }
            
            // Apply business logic: format text for display
            return formatAboutText(aboutText)
            
        } catch {
            throw BusinessError.dataNotFound("Failed to retrieve about text: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Business Logic Methods
    
    /// Validates that skills have all required data fields.
    /// - Parameter skills: Array of skills to validate
    /// - Returns: Validated skills array
    /// - Throws: BusinessError if validation fails
    private func validateSkillsData(_ skills: [Skill]) throws -> [Skill] {
        for skill in skills {
            guard !skill.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.validationFailed("Skill name cannot be empty")
            }
            guard !skill.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.validationFailed("Skill description cannot be empty")
            }
        }
        return skills
    }
    
    /// Sorts skills by priority and category for optimal presentation.
    /// - Parameter skills: Skills to sort
    /// - Returns: Sorted skills array
    private func sortSkillsByPriority(_ skills: [Skill]) -> [Skill] {
        // Business logic: Could implement priority-based sorting
        // For now, maintain original order
        return skills
    }
    
    /// Validates that experiences have all required data fields.
    /// - Parameter experiences: Array of experiences to validate
    /// - Returns: Validated experiences array
    /// - Throws: BusinessError if validation fails
    private func validateExperienceData(_ experiences: [Experience]) throws -> [Experience] {
        for experience in experiences {
            guard !experience.jobTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.validationFailed("Experience job title cannot be empty")
            }
            guard !experience.companyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.validationFailed("Experience company name cannot be empty")
            }
        }
        return experiences
    }
    
    /// Sorts experiences by relevance and recency.
    /// - Parameter experiences: Experiences to sort
    /// - Returns: Sorted experiences array
    private func sortExperiencesByRelevance(_ experiences: [Experience]) -> [Experience] {
        // Business logic: Could implement date-based or relevance-based sorting
        // For now, maintain original order
        return experiences
    }
    
    /// Validates that projects have all required data fields.
    /// - Parameter projects: Array of projects to validate
    /// - Returns: Validated projects array
    /// - Throws: BusinessError if validation fails
    private func validateProjectData(_ projects: [Project]) throws -> [Project] {
        for project in projects {
            guard !project.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.validationFailed("Project title cannot be empty")
            }
            guard !project.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BusinessError.validationFailed("Project description cannot be empty")
            }
        }
        return projects
    }
    
    /// Sorts projects by impact and showcase value.
    /// - Parameter projects: Projects to sort
    /// - Returns: Sorted projects array
    private func sortProjectsByImpact(_ projects: [Project]) -> [Project] {
        // Business logic: Could implement impact-based sorting
        // For now, maintain original order
        return projects
    }
    
    /// Formats about text for optimal display.
    /// - Parameter text: Raw about text
    /// - Returns: Formatted about text
    private func formatAboutText(_ text: String) -> String {
        // Business logic: Apply text formatting rules
        // For now, return text as-is
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}