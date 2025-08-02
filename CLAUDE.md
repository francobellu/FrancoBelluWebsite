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

# Run specific test suite
swift test --filter ErrorHandlingTests

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

## Testing

### Test Structure
The project includes comprehensive integration tests that validate the controller layer and error handling functionality.

### Test Suites
- **ErrorHandlingTests**: Complete 404 error handling validation
  - Web requests return styled HTML 404 pages
  - API requests return JSON error responses  
  - All existing routes continue to work
  - Edge cases and response structure validation

### Running Tests
```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ErrorHandlingTests

# Run with verbose output
swift test --verbose
```

### Test Coverage
- ✅ 404 error handling (HTML vs JSON responses)
- ✅ Controller layer functionality
- ✅ API endpoint validation
- ✅ Error response structure validation
- ✅ Edge case handling

## Architecture & Code Organization

### Four-Layer MVC Architecture
1. **Swift Vapor Backend**: Server logic, routing, data models
2. **Controller Layer**: HTTP request/response handling, service orchestration
3. **Service Layer**: Business logic, validation, data processing
4. **Leaf Templates + JavaScript/CSS**: Server-side rendering with client-side enhancements

### Clean Code Implementation
The codebase follows Swift clean code principles documented in `SWIFT_CLEAN_CODE_PRINCIPLES.md`:

- **Single Responsibility**: Each class/struct/function has one clear purpose
- **Meaningful Names**: Intention-revealing names (e.g., `personalInfo.professionalTitle` not `title`)
- **Controller-Service Pattern**: Clean separation between HTTP handling and business logic
- **Protocol-Based Design**: All services implement protocols for testability
- **Comprehensive Documentation**: All public APIs thoroughly documented
- **Structured Error Handling**: BusinessError and ValidationResult types throughout

### Key Architectural Patterns

#### Enhanced Data Flow
```
HTTP Request → Controllers → Services → Models → Database/Storage
                     ↓
            Leaf Templates/JSON APIs
                     ↓
          HTML/JavaScript Enhancement
```

#### Controller Layer (`Sources/App/Controllers/`)
- **BaseController**: Common functionality, service injection, error handling
- **WebController**: Home page rendering and web routes
- **ProfileController**: Profile data API endpoints (`/api/profile`)
- **ContactController**: Contact form processing (`/api/contact`)
- **ContentController**: Skills, experiences, projects (`/api/skills`, `/api/experiences`)

#### Service Layer (`Sources/App/Services/`)
- **ProfileService**: Profile data retrieval and home context generation
- **ContactService**: Contact form validation, processing, spam detection
- **ContentService**: Skills/experiences/projects with business logic validation
- **Protocol-Based**: All services implement protocols for dependency injection

#### Route Organization (`Sources/App/routes.swift`)
- **Controller-Based**: Routes delegate to controller methods
- **Grouped Endpoints**: Related functionality grouped logically
- **Health Check System**: Comprehensive service monitoring at `/api/health`
- **Enhanced API**: Extended endpoints with validation and admin features

#### Model Structure (`Sources/App/Models/HomeContext.swift`)
- **HomeContext**: Main data container with nested models
- **PersonalInfo**: Contact details extracted into separate struct
- **Validation**: Enhanced validation with `ValidationResult` and `BusinessError`
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

### Core Web Endpoints
- `GET /` - Main website (server-rendered HTML via WebController)

### Profile API Endpoints
- `GET /api/profile` - Basic personal information (JSON)
- `GET /api/profile/context` - Complete profile context with all data
- `GET /api/profile/health` - Profile service health check

### Content API Endpoints
- `GET /api/skills` - Skills array with descriptions
- `GET /api/experiences` - Work experiences with details  
- `GET /api/projects` - Portfolio projects with links
- `GET /api/about` - About section text content
- `GET /api/content/summary` - Content overview with counts
- `GET /api/content/health` - Content service health check

### Contact API Endpoints
- `POST /api/contact` - Submit contact form with validation
- `POST /api/contact/validate` - Validate form data without submitting
- `GET /api/contact/stats` - Contact submission statistics (admin)
- `GET /api/contact/health` - Contact service health check

### System Endpoints
- `GET /api/health` - Overall application health status

### Enhanced Controller-Service Integration
Demonstrates complete MVC pattern with clean separation:

1. **HTML Form** (`home.leaf`): Proper field names matching Swift model
2. **JavaScript** (`main.js`): AJAX submission with validation and error handling
3. **Controller Layer** (`ContactController`): HTTP handling, request/response processing
4. **Service Layer** (`ContactService`): Business logic, validation, spam detection
5. **Data Models** (`HomeContext.swift`): Structured data with validation logic

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