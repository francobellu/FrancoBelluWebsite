# Franco Bellu Website - Project Documentation

## Project Overview

This is a personal website built with **Swift Vapor** (backend) and **Leaf templating** (frontend), showcasing Franco Bellu's professional profile, skills, experience, and portfolio. The application follows a server-side rendering architecture with client-side enhancements.

### Technology Stack
- **Backend**: Swift Vapor 4.76.0 (web framework)
- **Templating**: Leaf 4.2.4 (server-side HTML templating)
- **Frontend**: Vanilla JavaScript + CSS3
- **Build System**: Swift Package Manager

## Project Structure

```
FrancoBelluWebsite/
├── Package.swift                 # Swift Package Manager configuration
├── Package.resolved             # Dependency lock file
├── Sources/
│   └── App/
│       ├── configure.swift      # App configuration & middleware setup
│       ├── main.swift          # App entry point
│       ├── routes.swift        # Route definitions & API endpoints
│       └── Models/
│           └── HomeContext.swift # Data models & contexts
├── Resources/
│   └── Views/
│       ├── base.leaf           # Base HTML template
│       └── home.leaf           # Home page template
├── Public/                     # Static assets served by FileMiddleware
│   ├── js/
│   │   └── main.js            # Client-side JavaScript
│   ├── styles/
│   │   └── main.css           # Styling & animations
│   └── images/                # Image assets
└── Tests/                     # Test files
```

## Backend Components (Swift/Vapor)

### 1. Application Configuration (`configure.swift`)
- **Leaf Setup**: Configures Leaf templating engine with caching for production
- **Directory Paths**: Sets up views and public directories for template and static file serving
- **Middleware**: Registers FileMiddleware for serving static assets from `/Public`
- **Debug Logging**: Includes path verification and file existence checks

```swift
app.views.use(.leaf)
app.leaf.cache.isEnabled = app.environment.isRelease
app.directory.viewsDirectory = app.directory.workingDirectory + "Resources/Views/"
app.directory.publicDirectory = app.directory.workingDirectory + "Public/"
```

### 2. Route Definitions (`routes.swift`)
- **Home Route**: `GET /` - Renders home page using HomeContext data
- **API Routes**: RESTful endpoints under `/api` prefix
  - `GET /api/profile` - Returns profile data as JSON
  - `GET /api/skills` - Returns skills array as JSON  
  - `POST /api/contact` - Handles contact form submissions

### 3. Data Models (`HomeContext.swift`)
**Primary Models:**
- `HomeContext`: Main data structure containing all page content
- `Skill`: Individual skill with name and description
- `Experience`: Work experience entries
- `Project`: Portfolio project entries
- `ProfileResponse`: API response for profile data
- `ContactForm`: Contact form input structure
- `ContactResponse`: Contact form response structure

All models conform to `Content` protocol for JSON serialization.

## Frontend Components

### 1. Leaf Templating System

**Base Template (`base.leaf`)**
- Provides HTML document structure with `<head>` and `<body>`
- Imports CSS (`/styles/main.css`) and JavaScript (`/js/main.js`)
- Uses Leaf's `#import()` directive for content injection:
  - `#import("title")` - Page title
  - `#import("body")` - Main content area

**Home Template (`home.leaf`)**
- Extends base template using `#extend("base")`
- Exports content sections using `#export()`
- Renders dynamic content using Leaf syntax:
  - `#(variableName)` - Variable interpolation
  - `#for(item in array):` - Loop iteration
  - `#endfor` - Loop termination

**Key Leaf Features Used:**
```leaf
#extend("base"):
    #export("title", "Franco Bellu - Personal Website")
    #export("body"):
        <h1>#(name)</h1>
        #for(skill in skills):
            <div class="skill-item">
                <h3>#(skill.name)</h3>
                <p>#(skill.description)</p>
            </div>
        #endfor
```

### 2. JavaScript Functionality (`main.js`)

**Core Features:**

1. **Scroll Animations**
   - Uses `IntersectionObserver` API to detect when sections enter viewport
   - Applies fade-in and slide-up animations to `.section` elements
   - Initial state: `opacity: 0, transform: translateY(30px)`
   - Animated state: `opacity: 1, transform: translateY(0)`

2. **Contact Form Handling**
   - Prevents default form submission
   - Collects form data using `FormData` API
   - Makes asynchronous POST request to `/api/contact`
   - Displays success/error messages dynamically
   - Resets form on successful submission

3. **Interactive Effects**
   - Hover animations for skill items (lift and scale effect)
   - Smooth scrolling for anchor links
   - Transforms: `translateY(-5px) scale(1.02)` on hover

**JavaScript Architecture:**
```javascript
document.addEventListener('DOMContentLoaded', function() {
    // 1. Setup scroll animations with IntersectionObserver
    // 2. Handle contact form with fetch API
    // 3. Add interactive hover effects
    // 4. Enable smooth scrolling
});
```

### 3. CSS Styling (`main.css`)

**Design System:**
- **Color Palette**: Purple gradient theme (`#667eea` to `#764ba2`)
- **Layout**: CSS Grid and Flexbox for responsive design
- **Effects**: Backdrop blur, box shadows, and smooth transitions
- **Typography**: Segoe UI font family with gradient text effects

**Key Features:**
- Glassmorphism design with `backdrop-filter: blur(10px)`
- Responsive grid layouts for skills and portfolio sections
- Hover animations with `transform` and `box-shadow` changes
- Mobile-responsive breakpoints at 768px

## API Endpoints

### GET Routes
- `GET /` → Renders home page with full HomeContext
- `GET /api/profile` → Returns ProfileResponse JSON
- `GET /api/skills` → Returns Skill array JSON

### POST Routes
- `POST /api/contact` → Accepts ContactForm, returns ContactResponse

**API Response Examples:**
```json
// GET /api/profile
{
  "name": "Franco Bellu",
  "title": "Professional • Innovator • Creative Thinker",
  "email": "franco.bellu@email.com",
  "phone": "+1 (555) 123-4567",
  "location": "Your City, Country"
}

// POST /api/contact
{
  "success": true,
  "message": "Thank you for your message, John! I'll get back to you soon."
}
```

## Data Flow Architecture

### Server-Side Rendering Flow
1. **Request**: Browser requests `GET /`
2. **Route Handler**: `routes.swift` processes request
3. **Data Preparation**: Creates `HomeContext.defaultContext()`
4. **Template Rendering**: Leaf processes `home.leaf` with context data
5. **HTML Generation**: Leaf generates complete HTML with interpolated data
6. **Response**: Server sends rendered HTML to browser

### Client-Side Enhancement Flow
1. **DOM Ready**: JavaScript executes after HTML loads
2. **Form Interaction**: User submits contact form
3. **API Call**: JavaScript sends POST request to `/api/contact`
4. **JSON Response**: Server returns ContactResponse
5. **UI Update**: JavaScript updates page with response message

### Template Data Binding
```
Swift Model (HomeContext) 
    ↓
Leaf Template (#(name), #for(skill in skills))
    ↓  
Rendered HTML (<h1>Franco Bellu</h1>)
    ↓
Browser Display + JavaScript Enhancement
```

## Key Integration Points

1. **Static Asset Serving**: FileMiddleware serves `/Public` content at root URL paths
2. **Template Resolution**: Vapor's view rendering system locates templates in `/Resources/Views`
3. **JSON API**: Same data models serve both template rendering and API responses
4. **Form Processing**: JavaScript form data matches Swift `ContactForm` structure
5. **Error Handling**: Both client and server implement graceful error responses

This architecture provides a fast, SEO-friendly server-rendered experience enhanced with modern client-side interactions.