//
//  ContentView.swift
//  mcp
//
//  Created by Murat on 27.05.2025.
//
import SwiftUI
import YouTubePlayerKit

struct ContentView: View {
    @StateObject private var service = RecipeService()
    @State private var dishName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Recipe Application")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                TextField("Enter dish name", text: $dishName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Get Recipe") {
                    service.getRecipe(dishName: dishName)
                }
                .buttonStyle(.borderedProminent)
                .disabled(dishName.isEmpty)
            }
            .padding(.horizontal)
            
            if service.isLoading {
                ProgressView("Loading...")
            }
            
            if let error = service.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            if let recipe = service.recipe {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(recipe.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(recipe.cookingTime) • Serves \(recipe.servings)")
                            .foregroundColor(.secondary)
                        
                        // YouTube Video Player
                        if let youtubeURL = recipe.youtubeURL, !youtubeURL.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Video Tutorial:")
                                    .font(.headline)
                                
                                YouTubePlayerView(
                                    YouTubePlayer(
                                        stringLiteral: "https://youtu.be/wPOVnJ46IkA?feature=shared"
                                    )
                                )
                                .frame(height: 200)
                                .cornerRadius(10)
                                .onAppear {
                                    // Video yüklenip yüklenmediğini kontrol et
                                    print("YouTube URL: \(youtubeURL)")
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Video Tutorial:")
                                    .font(.headline)
                                
                                Text("Bu tarif için video bulunamadı")
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        
                        Text("Ingredients:")
                            .font(.headline)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                        }
                        
                        Text("Instructions:")
                            .font(.headline)
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            Text("\(index + 1). \(instruction)")
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
