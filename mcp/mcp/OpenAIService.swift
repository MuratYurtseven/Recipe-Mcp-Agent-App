//
//  OpenAIService.swift
//  mcp
//
//  Created by Murat on 27.05.2025.
//
import Foundation
struct Recipe: Codable {
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let cookingTime: String
    let servings: Int
    let youtubeURL: String?
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}



// MARK: - Service Class
class RecipeService: ObservableObject {
    @Published var recipe: Recipe?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let openAIKey = ""
    
    func getRecipe(dishName: String) {
        isLoading = true
        errorMessage = nil
        recipe = nil
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [[
                "role": "user",
                "content": """
                '\(dishName)' tarifini JSON formatında ver ve bu tarif için gerçek bir YouTube video linki bul. 
                Lütfen sadece gerçek, mevcut YouTube videolarının linklerini ver. 
                Format: {"name":"","ingredients":[""],"instructions":[""],"cookingTime":"","servings":0,"youtubeURL":""}
                
                Önemli: youtubeURL alanına sadece gerçek, çalışan YouTube video linkleri koy. 
                Eğer uygun video bulamazsan youtubeURL'yi boş bırak.
                """
            ]],
            "max_tokens": 600
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Veri alınamadı"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    let content = response.choices.first?.message.content ?? ""
                    
                    // JSON'u temizle
                    var jsonString = content
                    if let start = content.range(of: "{")?.lowerBound,
                       let end = content.range(of: "}", options: .backwards)?.upperBound {
                        jsonString = String(content[start..<end])
                    }
                    
                    let jsonData = jsonString.data(using: .utf8)!
                    self.recipe = try JSONDecoder().decode(Recipe.self, from: jsonData)
                    
                } catch {
                    self.errorMessage = "Tarif okunamadı: \(error.localizedDescription)"
                    print("JSON Parse Error: \(error)")

                }
            }
        }.resume()
    }
}
