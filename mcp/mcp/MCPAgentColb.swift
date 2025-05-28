//
//  Recipe.swift
//  mcp
//
//  Created by Murat on 28.05.2025.
//
import Foundation
import Combine

// MARK: - Models
struct Recipe: Codable, Identifiable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let cookingTime: String?
    let servings: Int?
    let difficulty: String?
    let cuisine: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, ingredients, instructions
        case cookingTime = "cooking_time"
        case servings, difficulty, cuisine
    }
}

struct RecipeRequest: Codable {
    let ingredients: [String]
    let cuisine: String?
    let dietaryRestrictions: [String]?
    let cookingTime: String?
    let difficulty: String?
    
    private enum CodingKeys: String, CodingKey {
        case ingredients, cuisine
        case dietaryRestrictions = "dietary_restrictions"
        case cookingTime = "cooking_time"
        case difficulty
    }
}

struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let success: Bool
}

// MARK: - Recipe Service
class RecipeService: ObservableObject {
    
    // MARK: - Properties
    private let baseURL = "https://server.smithery.ai/@MuratYurtseven/recipemcp/mcp"
    private let apiKey = "f7a08cd0-4be5-4ec0-9c4d-bf8bae4c6b24"
    private let generateEndpoint = "/api/agents/recipeAgent/generate"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recipes: [Recipe] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Generate recipe based on ingredients and preferences
    func generateRecipe(
        ingredients: [String],
        cuisine: String? = nil,
        dietaryRestrictions: [String]? = nil,
        cookingTime: String? = nil,
        difficulty: String? = nil
    ) -> AnyPublisher<Recipe, Error> {
        
        let request = RecipeRequest(
            ingredients: ingredients,
            cuisine: cuisine,
            dietaryRestrictions: dietaryRestrictions,
            cookingTime: cookingTime,
            difficulty: difficulty
        )
        
        return performRecipeRequest(request: request)
    }
    
    /// Generate recipe with async/await
    @MainActor
    func generateRecipeAsync(
        ingredients: [String],
        cuisine: String? = nil,
        dietaryRestrictions: [String]? = nil,
        cookingTime: String? = nil,
        difficulty: String? = nil
    ) async throws -> Recipe {
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let recipe = try await withCheckedThrowingContinuation { continuation in
                generateRecipe(
                    ingredients: ingredients,
                    cuisine: cuisine,
                    dietaryRestrictions: dietaryRestrictions,
                    cookingTime: cookingTime,
                    difficulty: difficulty
                )
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { recipe in
                        continuation.resume(returning: recipe)
                    }
                )
                .store(in: &cancellables)
            }
            
            // Add to recipes array
            recipes.append(recipe)
            return recipe
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Clear all recipes
    func clearRecipes() {
        recipes.removeAll()
        errorMessage = nil
    }
    
    /// Remove specific recipe
    func removeRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
    }
    
    // MARK: - Private Methods
    
    private func performRecipeRequest(request: RecipeRequest) -> AnyPublisher<Recipe, Error> {
        
        guard let url = URL(string: baseURL + generateEndpoint) else {
            return Fail(error: RecipeServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: RecipeServiceError.encodingError(error))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: APIResponse<Recipe>.self, decoder: JSONDecoder())
            .tryMap { response in
                if response.success, let recipe = response.data {
                    return recipe
                } else {
                    throw RecipeServiceError.apiError(response.message ?? "Unknown error")
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Error Types
enum RecipeServiceError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case apiError(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Extension for Preview/Testing
extension RecipeService {
    static let shared = RecipeService()
    
    // Mock data for previews
    static let mockRecipe = Recipe(
        name: "Spaghetti Carbonara",
        ingredients: [
            "400g spaghetti",
            "200g pancetta",
            "4 large eggs",
            "100g Pecorino Romano cheese",
            "Black pepper",
            "Salt"
        ],
        instructions: [
            "Cook spaghetti in salted boiling water until al dente",
            "Fry pancetta until crispy",
            "Beat eggs with grated cheese and black pepper",
            "Combine hot pasta with pancetta",
            "Add egg mixture and toss quickly",
            "Serve immediately with extra cheese"
        ],
        cookingTime: "20 minutes",
        servings: 4,
        difficulty: "Medium",
        cuisine: "Italian"
    )
}
