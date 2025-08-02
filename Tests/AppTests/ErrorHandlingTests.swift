import XCTVapor
@testable import App

/// Integration tests for 404 error handling functionality.
/// Tests that web requests return HTML and API requests return JSON for 404 errors.
final class ErrorHandlingTests: XCTestCase {
    
    var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    // MARK: - Web Request 404 Tests
    
    /// Tests that a web request to a non-existent route returns HTML 404 page.
    func testWebRequest404ReturnsHTML() throws {
        try app.test(.GET, "/nonexistent") { response in
            // Should return 404 status
            XCTAssertEqual(response.status, .notFound)
            
            // Should return HTML content type
            XCTAssertEqual(response.headers.contentType, .html)
            
            // Should contain HTML structure
            let body = response.body.string
            XCTAssertTrue(body.contains("<!DOCTYPE html>"))
            XCTAssertTrue(body.contains("<html"))
            XCTAssertTrue(body.contains("404"))
            XCTAssertTrue(body.contains("Page Not Found"))
            XCTAssertTrue(body.contains("Franco Bellu"))
            
            // Should contain navigation link back to home
            XCTAssertTrue(body.contains("<a href=\"/\">Go Home</a>"))
            
            // Should contain glassmorphism styling
            XCTAssertTrue(body.contains("backdrop-filter: blur(10px)"))
            XCTAssertTrue(body.contains("rgba(255,255,255,0.1)"))
        }
    }
    
    /// Tests that a web request to a deep non-existent path returns HTML 404 page.
    func testWebRequestDeepPath404ReturnsHTML() throws {
        try app.test(.GET, "/some/deep/nonexistent/path") { response in
            XCTAssertEqual(response.status, .notFound)
            XCTAssertEqual(response.headers.contentType, .html)
            
            let body = response.body.string
            XCTAssertTrue(body.contains("404"))
            XCTAssertTrue(body.contains("Page Not Found"))
        }
    }
    
    /// Tests that a web request with query parameters to non-existent route returns HTML.
    func testWebRequestWithQueryParams404ReturnsHTML() throws {
        try app.test(.GET, "/nonexistent?param=value&test=123") { response in
            XCTAssertEqual(response.status, .notFound)
            XCTAssertEqual(response.headers.contentType, .html)
            
            let body = response.body.string
            XCTAssertTrue(body.contains("404"))
        }
    }
    
    // MARK: - API Request 404 Tests
    
    /// Tests that an API request to a non-existent endpoint returns JSON 404 error.
    func testAPIRequest404ReturnsJSON() throws {
        try app.test(.GET, "/api/nonexistent") { response in
            // Should return 404 status
            XCTAssertEqual(response.status, .notFound)
            
            // Should return JSON content type
            XCTAssertEqual(response.headers.contentType, .json)
            
            // Should contain proper JSON error structure
            let errorResponse = try response.content.decode(ErrorResponse.self)
            
            XCTAssertTrue(errorResponse.error)
            XCTAssertEqual(errorResponse.reason, "Endpoint not found")
            XCTAssertEqual(errorResponse.code, "NOT_FOUND")
        }
    }
    
    /// Tests that API requests to different non-existent endpoints return JSON.
    func testAPIRequestDifferentEndpoints404ReturnsJSON() throws {
        let endpoints = [
            "/api/unknown",
            "/api/profile/invalid", 
            "/api/contact/missing",
            "/api/skills/nonexistent",
            "/api/v2/anything"
        ]
        
        for endpoint in endpoints {
            try app.test(.GET, endpoint) { response in
                XCTAssertEqual(response.status, .notFound, "Failed for endpoint: \(endpoint)")
                XCTAssertEqual(response.headers.contentType, .json, "Failed for endpoint: \(endpoint)")
                
                let errorResponse = try response.content.decode(ErrorResponse.self)
                XCTAssertTrue(errorResponse.error)
                XCTAssertEqual(errorResponse.reason, "Endpoint not found")
            }
        }
    }
    
    /// Tests that API requests with different HTTP methods return JSON 404s.
    func testAPIRequestDifferentMethods404ReturnsJSON() throws {
        let methods: [HTTPMethod] = [.GET, .POST, .PUT, .DELETE]
        
        for method in methods {
            try app.test(method, "/api/nonexistent") { response in
                XCTAssertEqual(response.status, .notFound, "Failed for method: \(method)")
                XCTAssertEqual(response.headers.contentType, .json, "Failed for method: \(method)")
                
                let errorResponse = try response.content.decode(ErrorResponse.self)
                XCTAssertTrue(errorResponse.error)
            }
        }
    }
    
    // MARK: - Existing Routes Still Work Tests
    
    /// Tests that the home page still works correctly.
    func testHomePageStillWorks() throws {
        try app.test(.GET, "/") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.headers.contentType, .html)
            
            let body = response.body.string
            XCTAssertTrue(body.contains("Franco Bellu"))
            XCTAssertTrue(body.contains("<!DOCTYPE html>"))
        }
    }
    
    /// Tests that API endpoints still work correctly.
    func testAPIEndpointsStillWork() throws {
        let validEndpoints = [
            "/api/profile",
            "/api/skills",
            "/api/experiences", 
            "/api/projects",
            "/api/health"
        ]
        
        for endpoint in validEndpoints {
            try app.test(.GET, endpoint) { response in
                // Should not be 404
                XCTAssertNotEqual(response.status, .notFound, "Endpoint \(endpoint) returned 404")
                
                // Should be successful or have a valid status
                XCTAssertTrue([.ok, .created, .accepted].contains(response.status), 
                             "Endpoint \(endpoint) returned unexpected status: \(response.status)")
                
                // Should return JSON for API endpoints
                XCTAssertEqual(response.headers.contentType, .json,
                             "Endpoint \(endpoint) did not return JSON")
            }
        }
    }
    
    /// Tests that the error page route still works.
    func testErrorPageRouteStillWorks() throws {
        try app.test(.GET, "/error") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.headers.contentType, .html)
        }
    }
    
    // MARK: - Error Response Structure Tests
    
    /// Tests that the HTML 404 page has proper structure and styling.
    func testHTML404PageStructure() throws {
        try app.test(.GET, "/test404") { response in
            let body = response.body.string
            
            // Basic HTML structure
            XCTAssertTrue(body.contains("<!DOCTYPE html>"))
            XCTAssertTrue(body.contains("<html lang=\"en\">"))
            XCTAssertTrue(body.contains("<head>"))
            XCTAssertTrue(body.contains("<body>"))
            XCTAssertTrue(body.contains("</html>"))
            
            // Meta tags
            XCTAssertTrue(body.contains("charset=\"UTF-8\""))
            XCTAssertTrue(body.contains("viewport"))
            
            // Title
            XCTAssertTrue(body.contains("<title>Page Not Found - Franco Bellu</title>"))
            
            // Main content structure
            XCTAssertTrue(body.contains("error-container"))
            XCTAssertTrue(body.contains("<h1>404</h1>"))
            XCTAssertTrue(body.contains("Page Not Found"))
            XCTAssertTrue(body.contains("Go Home"))
            
            // Styling - glassmorphism design
            XCTAssertTrue(body.contains("background: linear-gradient"))
            XCTAssertTrue(body.contains("backdrop-filter: blur(10px)"))
            XCTAssertTrue(body.contains("border-radius: 20px"))
        }
    }
    
    /// Tests that JSON 404 responses have proper structure.
    func testJSON404ResponseStructure() throws {
        try app.test(.GET, "/api/test404") { response in
            XCTAssertEqual(response.status, .notFound)
            
            let errorResponse = try response.content.decode(ErrorResponse.self)
            
            // Should have all required fields
            XCTAssertTrue(errorResponse.error)
            XCTAssertEqual(errorResponse.reason, "Endpoint not found")
            XCTAssertEqual(errorResponse.code, "NOT_FOUND")
            
            // Verify JSON structure in raw response
            let body = response.body.string
            XCTAssertTrue(body.contains("\"error\":true"))
            XCTAssertTrue(body.contains("\"reason\":\"Endpoint not found\""))
            XCTAssertTrue(body.contains("\"code\":\"NOT_FOUND\""))
        }
    }
    
    // MARK: - Edge Cases
    
    /// Tests various edge cases for 404 handling.
    func testEdgeCases() throws {
        // Empty path after API
        try app.test(.GET, "/api/") { response in
            XCTAssertEqual(response.status, .notFound)
            XCTAssertEqual(response.headers.contentType, .json)
        }
        
        // Path that looks like API but isn't
        try app.test(.GET, "/apitest/something") { response in
            XCTAssertEqual(response.status, .notFound)
            XCTAssertEqual(response.headers.contentType, .html)
        }
        
        // Path with special characters
        try app.test(.GET, "/special!@#$%^&*()") { response in
            XCTAssertEqual(response.status, .notFound)
            XCTAssertEqual(response.headers.contentType, .html)
        }
    }
}

// MARK: - Test Extensions


extension ByteBuffer {
    /// Converts ByteBuffer to String for testing.
    var string: String {
        return String(buffer: self)
    }
}