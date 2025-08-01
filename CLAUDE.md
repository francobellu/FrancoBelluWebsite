# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Franco Bellu's personal website built with Swift Vapor 4.76.0 and Leaf 4.2.4 templating. Server-side rendered architecture with client-side JavaScript enhancements, featuring modern glassmorphism design, RESTful API endpoints, and comprehensive deployment documentation.

## Development Commands

### Core Development
```bash
# Build project
swift build

# Run development server (http://localhost:8080)
swift run

# Run tests
swift test

# Build for release
swift build -c release

# Run specific test target
swift test --filter AppTests
```

### Docker Development
```bash
# Build container (uses Swift 6.1-jammy images)
docker build -t franco-website .

# Run locally
docker run -p 8080:8080 franco-website

# Run with development environment
docker run -p 8080:8080 -e VAPOR_ENV=development franco-website
```

### Deployment Commands
```bash
# Railway CLI deployment (after setup)
railway up

# Check Railway logs
railway logs

# Railway environment variables
railway variables
```

## Architecture & Code Organization

### Three-Layer Architecture
1. **Swift Vapor Backend**: Server logic, routing, data models
2. **Leaf Templates**: Server-side HTML rendering with dynamic content  
3. **JavaScript/CSS Frontend**: Client-side enhancements and animations

### Clean Code Implementation
The codebase follows Swift clean code principles documented in `SWIFT_CLEAN_CODE_PRINCIPLES.md`:

- **Single Responsibility**: Each struct/function has one clear purpose
- **Meaningful Names**: Intention-revealing names (e.g., `personalInfo.professionalTitle` not `title`)
- **Modular Organization**: Route functions separated by concern (web, API, contact)
- **Documentation**: Comprehensive docs for all public APIs
- **Error Handling**: Proper validation and logging throughout

### Key Architectural Patterns

#### Data Flow
```
Swift Models (HomeContext) → Leaf Templates → HTML → JavaScript Enhancement
                          ↘ JSON APIs → AJAX calls → UI Updates
```

#### Route Organization (`Sources/App/routes.swift`)
- **Modular Functions**: `configureWebRoutes()`, `configureAPIRoutes()`, `configureContactRoutes()`
- **Clean Separation**: Web routes return HTML views, API routes return JSON
- **Error Handling**: Comprehensive validation and logging in contact form processing

#### Model Structure (`Sources/App/Models/HomeContext.swift`)
- **HomeContext**: Main data container with nested models
- **PersonalInfo**: Contact details extracted into separate struct
- **Validation**: `ContactForm.isValid()` with client-server consistency
- **Factory Methods**: `createDefault()` methods for all models

## Content Management

### Personal Information Updates
Edit static methods in `Sources/App/Models/HomeContext.swift`:

```swift
// Contact details and professional title
PersonalInfo.createDefault()

// About section content  
PersonalInfo.defaultAboutText

// Skills and expertise
Skill.createDefaultSkills()

// Work experience
Experience.createDefaultExperiences()

// Portfolio projects
Project.createDefaultProjects()
```

### Template Customization
- **Base Template**: `Resources/Views/base.leaf` - HTML structure, CSS/JS imports
- **Home Page**: `Resources/Views/home.leaf` - Content layout using Leaf syntax
- **Dynamic Content**: Uses `#(variable)` interpolation and `#for()` loops

### Frontend Enhancements
- **Styling**: `Public/styles/main.css` - Glassmorphism design system
- **JavaScript**: `Public/js/main.js` - Modular functions for animations, forms, interactions
- **Progressive Enhancement**: Core functionality works without JavaScript

## API Endpoints & Integration

### Available Endpoints
- `GET /` - Main website (server-rendered HTML)
- `GET /api/profile` - Personal information (JSON)
- `GET /api/skills` - Skills array (JSON)  
- `POST /api/contact` - Contact form submission (JSON)

### Full-Stack Contact Form Example
Demonstrates complete integration pattern:

1. **HTML Form** (`home.leaf`): Proper field names matching Swift model
2. **JavaScript** (`main.js`): AJAX submission with validation and error handling
3. **Swift Backend** (`routes.swift`): Validation, logging, structured response
4. **Data Model** (`HomeContext.swift`): `ContactForm` with `isValid()` method

## Deployment Configuration

### Current Setup: Railway (Recommended)
- **Configuration**: `railway.json` for Railway-specific settings
- **Environment**: `.env.example` template for required variables
- **Documentation**: `RAILWAY_DEPLOYMENT.md` for step-by-step deployment
- **Cost**: Free tier ($5 monthly credit) sufficient for personal website

### Docker Configuration
- **Multi-stage Build**: `swift:6.1-jammy` → `swift:6.1-jammy-slim`
- **Security**: Non-root `vapor` user in container
- **Resource Copying**: Ensures `Public/` and `Resources/` available in production
- **Port**: Exposes 8080 (Railway handles external routing)

### Alternative Platforms
See `DEPLOYMENT_GUIDE.md` for comprehensive comparison:
- **Render**: Good for teams, predictable pricing
- **Heroku**: Expensive but proven (not recommended for personal sites)
- **Fly.io**: Performance-focused alternative

## Development Workflow

### Branch Strategy - IMPORTANT
**ALL code changes must be made through feature branches and pull requests. Never commit directly to main.**

```bash
# Create feature branch for any changes
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix

# Make your changes, commit, and push
git add .
git commit -m "Descriptive commit message"
git push -u origin feature/your-feature-name

# Create pull request to main branch (required)
gh pr create --title "Your PR Title" --body "Description of changes"
```

### Adding New Features
1. **Create Feature Branch**: Always start with `git checkout -b feature/feature-name`
2. **Models**: Add data structures to `HomeContext.swift` following clean code patterns
3. **Routes**: Create route handlers in `routes.swift` with proper documentation
4. **Templates**: Update Leaf templates with new data bindings
5. **JavaScript**: Add client-side enhancements following modular pattern
6. **Testing**: Add tests in `Tests/AppTests/` using XCTVapor
7. **Pull Request**: Create PR to main branch for review and merge

### Content Updates
- **Create Branch**: `git checkout -b content/update-personal-info`
- **Personal Info**: Modify static factory methods in models
- **Styling**: Update CSS variables and classes in `main.css`
- **Animations**: Extend JavaScript modules in `main.js`
- **Templates**: Add new sections to `home.leaf` using Leaf syntax
- **Pull Request**: Required for all content changes

### Deployment Process
1. **Feature Branch**: Create feature branch for all changes (required)
2. **Development**: Test locally with `swift run`
3. **Testing**: Ensure tests pass with `swift test`
4. **Pull Request**: Create PR to main branch (required - no direct commits to main)
5. **Review & Merge**: PR must be approved and merged
6. **Auto-Deploy**: Railway automatically deploys from main branch after merge

### Git Workflow Rules
- ❌ **Never commit directly to main branch**
- ✅ **Always use feature branches**: `feature/`, `fix/`, `content/`, `docs/`
- ✅ **All changes require pull requests**
- ✅ **Test locally before creating PR**
- ✅ **Use descriptive branch names and commit messages**
- ✅ **Commit messages should not mention Claude Code or AI assistance**

## Code Quality Standards

### Swift Conventions (from SWIFT_CLEAN_CODE_PRINCIPLES.md)
- **Naming**: UpperCamelCase for types, lowerCamelCase for variables/functions
- **Documentation**: Use `///` for public APIs with parameter descriptions
- **Error Handling**: Proper Swift error handling, avoid force unwrapping
- **Value Types**: Prefer structs over classes where appropriate
- **Protocol-Oriented**: Use protocols for abstraction and testing

### Testing Patterns
- **XCTVapor**: Use for testing route handlers and API endpoints
- **Descriptive Names**: `testContactForm_WithValidData_ReturnsSuccess()`
- **Dependency Injection**: Make components testable through protocols

### JavaScript Standards
- **Modular Functions**: Separate initialization functions for different features
- **Progressive Enhancement**: Graceful degradation when JS disabled
- **Error Handling**: Proper try-catch blocks with user-friendly messages
- **API Integration**: Consistent field names matching Swift models

## Important Files Reference

- **`PROJECT_DOCUMENTATION.md`**: Detailed architecture and data flow explanation
- **`SWIFT_CLEAN_CODE_PRINCIPLES.md`**: Comprehensive Swift coding standards
- **`DEPLOYMENT_GUIDE.md`**: Platform comparison and Docker requirements
- **`RAILWAY_DEPLOYMENT.md`**: Step-by-step Railway deployment instructions
- **`README.md`**: Quick start guide and basic project information

## Configuration Details

### Environment Variables
```bash
# Required for production
ENVIRONMENT=production
VAPOR_ENV=production
PORT=8080

# Optional
CUSTOM_DOMAIN=your-domain.com
```

### Directory Structure
```
Sources/App/configure.swift: Sets up template and static file paths
Resources/Views/: Leaf templates (server-side rendering)
Public/: Static assets served by FileMiddleware
Tests/: XCTVapor test suite
```

### Template System
- **Inheritance**: `base.leaf` extended by `home.leaf`
- **Content Blocks**: `#import("title")` and `#import("body")`
- **Dynamic Data**: `#(personalInfo.name)`, `#for(skill in skills)`
- **Static Assets**: `/styles/main.css`, `/js/main.js`