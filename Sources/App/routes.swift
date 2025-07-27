import Vapor

func routes(_ app: Application) throws {
    // Home page route
    app.get { req async throws -> View in
        let context = HomeContext.defaultContext()
        print("Rendering home template with context: \(context.name)")
        
        return try await req.view.render("home", context)
    }

    // API endpoints
    app.group("api") { api in
        // Get profile data
        api.get("profile") { req -> ProfileResponse in
            return ProfileResponse.defaultProfile
        }

        // Get skills
        api.get("skills") { req -> [Skill] in
            return Skill.defaultSkills
        }

        // Contact form submission
        api.post("contact") { req -> EventLoopFuture<ContactResponse> in
            do {
                let contactForm = try req.content.decode(ContactForm.self)

                // Here you would typically save to database or send email
                // For now, we'll just return a success response
                let response = ContactResponse.success(name: contactForm.name)

                return req.eventLoop.makeSucceededFuture(response)
            } catch {
                let response = ContactResponse.failure
                return req.eventLoop.makeSucceededFuture(response)
            }
        }
    }
}
