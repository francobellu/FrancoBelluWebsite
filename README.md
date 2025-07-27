# Franco Bellu - Personal Website

A modern, responsive personal website built with Swift Vapor framework.

## Features

- 🎨 Modern glassmorphism design
- 📱 Fully responsive layout
- ⚡ Interactive animations
- 📧 Working contact form
- 🚀 Server-side rendering with Leaf templates
- 🔧 RESTful API endpoints

## Getting Started

### Prerequisites
- Swift 5.6+ 
- macOS 12+ (for development)

### Installation

1. Clone the repository
2. Build the project:
   ```bash
   swift build
   ```

3. Run the server:
   ```bash
   swift run
   ```

4. Visit `http://localhost:8080`

### API Endpoints

- `GET /` - Main website
- `GET /api/profile` - Profile information (JSON)
- `GET /api/skills` - Skills data (JSON)
- `POST /api/contact` - Contact form submission

### Customization

Edit the data in `Sources/App/routes.swift` to customize:
- Personal information
- Skills and experience
- Projects and portfolio items
- Contact details

### Deployment

Use the included Dockerfile for containerized deployment:

```bash
docker build -t franco-website .
docker run -p 8080:8080 franco-website
```

## Project Structure

```
FrancoBelluWebsite/
├── Package.swift                 # Dependencies
├── Sources/App/                  # Swift backend code
├── Resources/Views/              # Leaf templates
├── Public/                       # Static assets (CSS, JS)
└── Dockerfile                    # Container config
```

## License

This project is open source and available under the MIT License.
