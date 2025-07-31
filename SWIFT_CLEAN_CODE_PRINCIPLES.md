# Swift Clean Code Principles

## Overview

Clean code is code that is easy to read, understand, and maintain. These principles help create Swift code that is professional, sustainable, and enjoyable to work with. This guide focuses on Swift-specific best practices while incorporating universal clean code concepts.

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [Functions and Methods](#functions-and-methods)
3. [Classes and Structs](#classes-and-structs)
4. [Error Handling](#error-handling)
5. [Comments and Documentation](#comments-and-documentation)
6. [Code Organization](#code-organization)
7. [Swift-Specific Best Practices](#swift-specific-best-practices)
8. [Testing](#testing)

## Naming Conventions

### Use Descriptive and Meaningful Names

**✅ Good:**
```swift
let userAccountBalance: Double
let isUserLoggedIn: Bool
func calculateTotalPrice(items: [CartItem]) -> Double
```

**❌ Bad:**
```swift
let bal: Double
let flag: Bool
func calc(arr: [Any]) -> Double
```

### Follow Swift Naming Guidelines

**✅ Good:**
```swift
// Types: UpperCamelCase
struct UserAccount { }
class NetworkManager { }
enum HTTPStatusCode { }

// Variables/Functions: lowerCamelCase
let firstName: String
func authenticateUser() -> Bool

// Constants: lowerCamelCase
let maxRetryAttempts = 3
```

### Use Intention-Revealing Names

**✅ Good:**
```swift
func validateEmailAddress(_ email: String) -> Bool
let daysUntilExpiration = calculateRemainingDays()
```

**❌ Bad:**
```swift
func check(_ str: String) -> Bool
let d = calc()
```

## Functions and Methods

### Keep Functions Small and Focused

**✅ Good:**
```swift
func validateUser(_ user: User) -> ValidationResult {
    guard isValidEmail(user.email) else {
        return .invalid(.invalidEmail)
    }
    
    guard isValidAge(user.age) else {
        return .invalid(.invalidAge)
    }
    
    return .valid
}

private func isValidEmail(_ email: String) -> Bool {
    // Email validation logic
}

private func isValidAge(_ age: Int) -> Bool {
    return age >= 18 && age <= 120
}
```

**❌ Bad:**
```swift
func validateUser(_ user: User) -> ValidationResult {
    // 50+ lines of validation logic mixed together
    let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
    // ... more validation code
    // ... age validation
    // ... phone validation
    // ... address validation
}
```

### Use Clear Parameter Names

**✅ Good:**
```swift
func transfer(amount: Double, from sourceAccount: Account, to destinationAccount: Account)
func download(fileAt url: URL, to destination: URL, progressHandler: @escaping (Double) -> Void)
```

**❌ Bad:**
```swift
func transfer(_ amt: Double, _ src: Account, _ dst: Account)
func download(_ u1: URL, _ u2: URL, _ handler: @escaping (Double) -> Void)
```

### Avoid Flag Arguments

**✅ Good:**
```swift
func renderUserProfile() { }
func renderAdminProfile() { }

// Or use an enum
enum ProfileType {
    case user, admin
}

func renderProfile(type: ProfileType) { }
```

**❌ Bad:**
```swift
func renderProfile(isAdmin: Bool) { }
```

## Classes and Structs

### Single Responsibility Principle

**✅ Good:**
```swift
struct User {
    let id: String
    let name: String
    let email: String
}

class UserRepository {
    func save(_ user: User) throws { }
    func find(by id: String) throws -> User? { }
    func delete(_ user: User) throws { }
}

class EmailValidator {
    func isValid(_ email: String) -> Bool { }
}
```

**❌ Bad:**
```swift
class User {
    let id: String
    let name: String
    let email: String
    
    // Mixing responsibilities
    func save() throws { }
    func validateEmail() -> Bool { }
    func sendWelcomeEmail() throws { }
    func generatePDFReport() -> Data { }
}
```

### Prefer Composition Over Inheritance

**✅ Good:**
```swift
protocol Drawable {
    func draw()
}

protocol Movable {
    func move(to position: CGPoint)
}

struct GameObject: Drawable, Movable {
    private let renderer: Renderer
    private let physics: PhysicsComponent
    
    func draw() {
        renderer.render()
    }
    
    func move(to position: CGPoint) {
        physics.move(to: position)
    }
}
```

### Use Dependency Injection

**✅ Good:**
```swift
class UserService {
    private let repository: UserRepositoryProtocol
    private let validator: EmailValidatorProtocol
    
    init(repository: UserRepositoryProtocol, validator: EmailValidatorProtocol) {
        self.repository = repository
        self.validator = validator
    }
}
```

**❌ Bad:**
```swift
class UserService {
    private let repository = UserRepository() // Hard dependency
    private let validator = EmailValidator() // Hard dependency
}
```

## Error Handling

### Use Swift's Error Handling Mechanisms

**✅ Good:**
```swift
enum NetworkError: Error {
    case invalidURL
    case noConnection
    case serverError(Int)
    case decodingFailed
}

func fetchUserData(from url: String) throws -> UserData {
    guard let validURL = URL(string: url) else {
        throw NetworkError.invalidURL
    }
    
    // Network request logic
    // Return parsed data or throw appropriate error
}

// Usage
do {
    let userData = try fetchUserData(from: urlString)
    // Handle success
} catch NetworkError.invalidURL {
    // Handle invalid URL
} catch NetworkError.noConnection {
    // Handle no connection
} catch {
    // Handle other errors
}
```

### Avoid Force Unwrapping in Production Code

**✅ Good:**
```swift
func processUser(id: String?) -> String {
    guard let id = id else {
        return "Unknown User"
    }
    return "User: \(id)"
}

// Or use nil coalescing
let userName = user?.name ?? "Anonymous"
```

**❌ Bad:**
```swift
func processUser(id: String?) -> String {
    return "User: \(id!)" // Potential crash
}
```

## Comments and Documentation

### Write Self-Documenting Code

**✅ Good:**
```swift
func calculateMonthlyPayment(
    principalAmount: Double,
    annualInterestRate: Double,
    loanTermInYears: Int
) -> Double {
    let monthlyInterestRate = annualInterestRate / 12 / 100
    let numberOfPayments = loanTermInYears * 12
    
    let monthlyPayment = principalAmount * 
        (monthlyInterestRate * pow(1 + monthlyInterestRate, Double(numberOfPayments))) /
        (pow(1 + monthlyInterestRate, Double(numberOfPayments)) - 1)
    
    return monthlyPayment
}
```

### Use Documentation Comments for Public APIs

**✅ Good:**
```swift
/// Calculates the monthly payment for a loan using the standard amortization formula.
/// 
/// - Parameters:
///   - principalAmount: The initial loan amount in dollars
///   - annualInterestRate: The yearly interest rate as a percentage (e.g., 5.5 for 5.5%)
///   - loanTermInYears: The duration of the loan in years
/// - Returns: The monthly payment amount in dollars
/// - Throws: `LoanCalculationError.invalidParameters` if any parameter is negative or zero
func calculateMonthlyPayment(
    principalAmount: Double,
    annualInterestRate: Double,
    loanTermInYears: Int
) throws -> Double
```

### Avoid Obvious Comments

**❌ Bad:**
```swift
// Increment i by 1
i += 1

// Check if user is nil
if user == nil {
    // Return early if user is nil
    return
}
```

## Code Organization

### Use Extensions for Code Organization

**✅ Good:**
```swift
// MARK: - Core Implementation
class UserViewController: UIViewController {
    // Core properties and lifecycle methods
}

// MARK: - UITableViewDataSource
extension UserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Implementation
    }
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Implementation
    }
}

// MARK: - Private Methods
private extension UserViewController {
    func setupUI() {
        // UI setup logic
    }
}
```

### Group Related Functionality

```swift
// MARK: - Properties
class NetworkManager {
    private let session: URLSession
    private let baseURL: URL
    
    // MARK: - Initialization
    init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    // MARK: - Public Methods
    func fetchUser(id: String) async throws -> User {
        // Implementation
    }
    
    func updateUser(_ user: User) async throws {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func buildRequest(for endpoint: String) -> URLRequest {
        // Implementation
    }
}
```

## Swift-Specific Best Practices

### Prefer Value Types (Structs) Over Reference Types (Classes)

**✅ Good:**
```swift
struct Point {
    let x: Double
    let y: Double
    
    func distance(to other: Point) -> Double {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }
}
```

### Use Optionals Appropriately

**✅ Good:**
```swift
struct User {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String? // Optional because it might not be provided
}

func findUser(by id: String) -> User? {
    // Return nil if not found, User if found
}
```

### Leverage Swift's Type System

**✅ Good:**
```swift
enum PaymentMethod {
    case creditCard(number: String, expiryDate: Date)
    case paypal(email: String)
    case applePay
}

func processPayment(amount: Double, method: PaymentMethod) {
    switch method {
    case .creditCard(let number, let expiry):
        // Process credit card payment
    case .paypal(let email):
        // Process PayPal payment
    case .applePay:
        // Process Apple Pay payment
    }
}
```

### Use Protocol-Oriented Programming

**✅ Good:**
```swift
protocol Cacheable {
    associatedtype CacheKey: Hashable
    var cacheKey: CacheKey { get }
}

protocol DataSource {
    associatedtype Item
    func fetchItems() async throws -> [Item]
}

class Repository<T: Cacheable>: DataSource {
    typealias Item = T
    
    private let cache: Cache<T.CacheKey, T>
    
    func fetchItems() async throws -> [T] {
        // Check cache first, then fetch from network
    }
}
```

### Use Guard Statements for Early Returns

**✅ Good:**
```swift
func processOrder(_ order: Order) throws {
    guard order.items.count > 0 else {
        throw OrderError.emptyOrder
    }
    
    guard order.customer.isVerified else {
        throw OrderError.unverifiedCustomer
    }
    
    guard order.totalAmount > 0 else {
        throw OrderError.invalidAmount
    }
    
    // Process the order
}
```

**❌ Bad:**
```swift
func processOrder(_ order: Order) throws {
    if order.items.count > 0 {
        if order.customer.isVerified {
            if order.totalAmount > 0 {
                // Process the order - deeply nested
            } else {
                throw OrderError.invalidAmount
            }
        } else {
            throw OrderError.unverifiedCustomer
        }
    } else {
        throw OrderError.emptyOrder
    }
}
```

## Testing

### Write Testable Code

**✅ Good:**
```swift
protocol TimeProvider {
    var currentDate: Date { get }
}

class SystemTimeProvider: TimeProvider {
    var currentDate: Date { Date() }
}

class SubscriptionService {
    private let timeProvider: TimeProvider
    
    init(timeProvider: TimeProvider = SystemTimeProvider()) {
        self.timeProvider = timeProvider
    }
    
    func hasExpired(_ subscription: Subscription) -> Bool {
        return subscription.expiryDate < timeProvider.currentDate
    }
}

// In tests:
class MockTimeProvider: TimeProvider {
    var currentDate: Date = Date()
}
```

### Use Descriptive Test Names

**✅ Good:**
```swift
func testHasExpired_WhenSubscriptionExpiredYesterday_ReturnsTrue() {
    // Test implementation
}

func testHasExpired_WhenSubscriptionExpiresNext_ReturnsFalse() {
    // Test implementation
}
```

**❌ Bad:**
```swift
func testHasExpired1() { }
func testHasExpired2() { }
```

## Conclusion

Clean code is not just about following rules—it's about writing code that communicates its intent clearly, is easy to modify, and reduces cognitive load for future developers (including yourself). These principles should guide your decision-making, but remember that context matters. Sometimes pragmatic solutions require bending these guidelines, but such deviations should be conscious decisions with clear justifications.

### Key Takeaways

1. **Clarity over cleverness**: Write code that is obvious and easy to understand
2. **Consistency matters**: Follow established patterns within your codebase
3. **Embrace Swift's strengths**: Use optionals, value types, and protocol-oriented programming
4. **Test your code**: Write testable code and comprehensive tests
5. **Refactor regularly**: Clean code is an ongoing process, not a one-time effort

Remember: "Clean code always looks like it was written by someone who cares." - Robert C. Martin