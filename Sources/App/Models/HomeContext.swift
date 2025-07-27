import Vapor

struct HomeContext: Content {
    let name: String
    let title: String
    let email: String
    let phone: String
    let location: String
    let about: String
    let skills: [Skill]
    let experiences: [Experience]
    let projects: [Project]
    
    static func defaultContext() -> HomeContext {
        HomeContext(
            name: "Franco Bellu",
            title: "Professional • Innovator • Creative Thinker",
            email: "franco.bellu@email.com",
            phone: "+1 (555) 123-4567",
            location: "Your City, Country",
            about: """
            Welcome to my personal website! I'm Franco Bellu, a passionate professional dedicated to excellence and innovation. 
            With years of experience in my field, I bring creativity, technical expertise, and a commitment to delivering outstanding results.
            
            I believe in continuous learning, collaboration, and making a positive impact through my work. Whether you're looking to 
            connect professionally or explore potential collaborations, I'd love to hear from you.
            """,
            skills: [
                Skill(name: "Leadership", description: "Team management and strategic planning"),
                Skill(name: "Communication", description: "Effective written and verbal communication"),
                Skill(name: "Problem Solving", description: "Analytical thinking and creative solutions"),
                Skill(name: "Innovation", description: "Creative thinking and process improvement")
            ],
            experiences: [
                Experience(
                    title: "Senior Position Title",
                    company: "Company Name",
                    date: "2020 - Present",
                    description: "Led major initiatives and managed cross-functional teams to deliver exceptional results. Implemented innovative solutions that improved efficiency by 30% and enhanced customer satisfaction."
                ),
                Experience(
                    title: "Previous Position Title",
                    company: "Previous Company",
                    date: "2017 - 2020",
                    description: "Developed and executed strategic plans that drove business growth. Collaborated with stakeholders to identify opportunities and implement best practices across the organization."
                )
            ],
            projects: [
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
        )
    }
}

struct Skill: Content {
    let name: String
    let description: String
    
    static var defaultSkills: [Skill] {
        [
            Skill(name: "Leadership", description: "Team management and strategic planning"),
            Skill(name: "Communication", description: "Effective written and verbal communication"),
            Skill(name: "Problem Solving", description: "Analytical thinking and creative solutions"),
            Skill(name: "Innovation", description: "Creative thinking and process improvement")
        ]
    }
}

struct Experience: Content {
    let title: String
    let company: String
    let date: String
    let description: String
    
    static var defaultExperiences: [Experience] {
        [
            Experience(
                title: "Senior Position Title",
                company: "Company Name",
                date: "2020 - Present",
                description: "Led major initiatives and managed cross-functional teams to deliver exceptional results. Implemented innovative solutions that improved efficiency by 30% and enhanced customer satisfaction."
            ),
            Experience(
                title: "Previous Position Title",
                company: "Previous Company",
                date: "2017 - 2020",
                description: "Developed and executed strategic plans that drove business growth. Collaborated with stakeholders to identify opportunities and implement best practices across the organization."
            )
        ]
    }
}

struct Project: Content {
    let title: String
    let description: String
    
    static var defaultProjects: [Project] {
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

struct ProfileResponse: Content {
    let name: String
    let title: String
    let email: String
    let phone: String
    let location: String
    
    static var defaultProfile: ProfileResponse {
        ProfileResponse(
            name: "Franco Bellu",
            title: "Professional • Innovator • Creative Thinker",
            email: "franco.bellu@email.com",
            phone: "+1 (555) 123-4567",
            location: "Your City, Country"
        )
    }
}

struct ContactForm: Content {
    let name: String
    let email: String
    let message: String
}

struct ContactResponse: Content {
    let success: Bool
    let message: String
    
    static func success(name: String) -> ContactResponse {
        ContactResponse(
            success: true,
            message: "Thank you for your message, \(name)! I'll get back to you soon."
        )
    }
    static var failure: ContactResponse {
        ContactResponse(
            success: false,
            message: "Sorry, there was an error processing your message. Please try again."
        )
    }
}
