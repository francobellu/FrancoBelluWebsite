import Vapor

// MARK: - Home Context Data Models

/// Represents the complete context data for the home page, containing all information
/// needed to render the personal website including profile, skills, experience, and projects.
struct HomeContext: Content {
    let personalInfo: PersonalInfo
    let about: String
    let skills: [Skill]
    let experiences: [Experience]
    let projects: [Project]
    
    /// Creates a default home context with sample data for Franco Bellu's website.
    /// - Returns: A fully populated HomeContext with default values
    static func createDefault() -> HomeContext {
        HomeContext(
            personalInfo: PersonalInfo.createDefault(),
            about: PersonalInfo.defaultAboutText,
            skills: Skill.createDefaultSkills(),
            experiences: Experience.createDefaultExperiences(),
            projects: Project.createDefaultProjects()
        )
    }
}

// MARK: - Personal Information

/// Contains basic personal contact information and professional title.
struct PersonalInfo: Content {
    let name: String
    let professionalTitle: String
    let email: String
    let phoneNumber: String
    let location: String
    
    /// Creates default personal information for Franco Bellu.
    /// - Returns: PersonalInfo with default contact details
    static func createDefault() -> PersonalInfo {
        PersonalInfo(
            name: "Franco Bellu",
            professionalTitle: "Professional • Innovator • Creative Thinker",
            email: "franco.bellu@email.com",
            phoneNumber: "+1 (555) 123-4567",
            location: "Your City, Country"
        )
    }
    
    /// Default about text describing Franco's professional background and approach.
    static let defaultAboutText = """
        Welcome to my personal website! I'm Franco Bellu, a passionate professional dedicated to excellence and innovation. 
        With years of experience in my field, I bring creativity, technical expertise, and a commitment to delivering outstanding results.
        
        I believe in continuous learning, collaboration, and making a positive impact through my work. Whether you're looking to 
        connect professionally or explore potential collaborations, I'd love to hear from you.
        """
}

// MARK: - Skills

/// Represents a professional skill with name and detailed description.
struct Skill: Content {
    let name: String
    let description: String
    
    /// Creates a collection of default professional skills.
    /// - Returns: Array of skills covering leadership, communication, problem solving, and innovation
    static func createDefaultSkills() -> [Skill] {
        [
            Skill(
                name: "Leadership",
                description: "Team management and strategic planning"
            ),
            Skill(
                name: "Communication",
                description: "Effective written and verbal communication"
            ),
            Skill(
                name: "Problem Solving",
                description: "Analytical thinking and creative solutions"
            ),
            Skill(
                name: "Innovation",
                description: "Creative thinking and process improvement"
            )
        ]
    }
}

// MARK: - Work Experience

/// Represents a work experience entry with position details and achievements.
struct Experience: Content {
    let jobTitle: String
    let companyName: String
    let employmentPeriod: String
    let achievementsDescription: String
    
    /// Creates a collection of default work experiences.
    /// - Returns: Array of professional experiences with sample achievements
    static func createDefaultExperiences() -> [Experience] {
        [
            Experience(
                jobTitle: "Senior Position Title",
                companyName: "Company Name",
                employmentPeriod: "2020 - Present",
                achievementsDescription: "Led major initiatives and managed cross-functional teams to deliver exceptional results. Implemented innovative solutions that improved efficiency by 30% and enhanced customer satisfaction."
            ),
            Experience(
                jobTitle: "Previous Position Title",
                companyName: "Previous Company",
                employmentPeriod: "2017 - 2020",
                achievementsDescription: "Developed and executed strategic plans that drove business growth. Collaborated with stakeholders to identify opportunities and implement best practices across the organization."
            )
        ]
    }
}

// MARK: - Portfolio Projects

/// Represents a portfolio project with title and description of achievements.
struct Project: Content {
    let title: String
    let description: String
    
    /// Creates a collection of default portfolio projects.
    /// - Returns: Array of sample projects showcasing different types of achievements
    static func createDefaultProjects() -> [Project] {
        [
            Project(
                title: "Featured Project",
                description: "Description of your key project or achievement. Highlight the impact, technologies used, and results achieved."
            ),
            Project(
                title: "Notable Achievement",
                description: "Another significant project or accomplishment that demonstrates your expertise and value."
            ),
            Project(
                title: "Innovation Project",
                description: "Showcase of innovative work that sets you apart and demonstrates your unique approach."
            )
        ]
    }
}

// MARK: - API Response Models

/// API response model containing essential profile information for client requests.
struct ProfileResponse: Content {
    let name: String
    let professionalTitle: String
    let email: String
    let phoneNumber: String
    let location: String
    
    /// Creates a profile response from the default personal information.
    /// - Returns: ProfileResponse with current personal details
    static func createDefault() -> ProfileResponse {
        let personalInfo = PersonalInfo.createDefault()
        return ProfileResponse(
            name: personalInfo.name,
            professionalTitle: personalInfo.professionalTitle,
            email: personalInfo.email,
            phoneNumber: personalInfo.phoneNumber,
            location: personalInfo.location
        )
    }
}

// MARK: - Contact Form Models

/// Represents incoming contact form data from website visitors.
struct ContactForm: Content {
    let senderName: String
    let senderEmail: String
    let messageContent: String
    
    /// Validates that all required fields are present and not empty.
    /// - Returns: true if form data is valid, false otherwise
    func isValid() -> Bool {
        !senderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !senderEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !messageContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmailFormat(senderEmail)
    }
    
    /// Performs basic email format validation.
    /// - Parameter email: Email address to validate
    /// - Returns: true if email format appears valid
    private func isValidEmailFormat(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}

/// Represents the response sent back after contact form submission.
struct ContactResponse: Content {
    let isSuccessful: Bool
    let responseMessage: String
    
    /// Creates a success response with personalized message.
    /// - Parameter senderName: Name of the person who sent the message
    /// - Returns: ContactResponse indicating successful submission
    static func createSuccessResponse(for senderName: String) -> ContactResponse {
        ContactResponse(
            isSuccessful: true,
            responseMessage: "Thank you for your message, \(senderName)! I'll get back to you soon."
        )
    }
    
    /// Creates a failure response for submission errors.
    /// - Returns: ContactResponse indicating submission failure
    static func createFailureResponse() -> ContactResponse {
        ContactResponse(
            isSuccessful: false,
            responseMessage: "Sorry, there was an error processing your message. Please try again."
        )
    }
}
