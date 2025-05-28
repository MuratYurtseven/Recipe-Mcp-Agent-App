import { createTool } from '@mastra/core/tools';
import { z } from 'zod';

// Types for recipe data
interface RecipeApiResponse {
  id: number;
  title: string;
  summary: string;
  ingredients: Array<{
    name: string;
    amount: number;
    unit: string;
  }>;
  analyzedInstructions: Array<{
    steps: Array<{
      number: number;
      step: string;
    }>;
  }>;
  readyInMinutes: number;
  servings: number;
  spoonacularScore: number;
}

interface SearchRecipeResponse {
  results: Array<{
    id: number;
    title: string;
    image: string;
    usedIngredientCount: number;
    missedIngredientCount: number;
    missedIngredients: Array<{
      name: string;
    }>;
  }>;
}

// Get Recipe Tool
export const getRecipeTool = createTool({
  id: 'get-recipe',
  description: 'Get detailed recipe information for a specific dish',
  inputSchema: z.object({
    recipeName: z.string().describe('Name of the recipe to search for'),
    cuisine: z.string().optional().describe('Optional cuisine type to filter results'),
  }),
  outputSchema: z.object({
    id: z.number(),
    name: z.string(),
    description: z.string(),
    ingredients: z.array(z.object({
      name: z.string(),
      amount: z.number(),
      unit: z.string(),
    })),
    instructions: z.array(z.string()),
    prepTime: z.number(),
    servings: z.number(),
    difficulty: z.string(),
  }),
  execute: async ({ context }) => {
    return await getRecipe(context.recipeName, context.cuisine);
  },
});

// Search Recipes Tool
export const searchRecipesTool = createTool({
  id: 'search-recipes',
  description: 'Search for recipes based on available ingredients',
  inputSchema: z.object({
    ingredients: z.array(z.string()).describe('List of available ingredients'),
    maxResults: z.number().default(10).describe('Maximum number of recipes to return'),
    minMatchPercentage: z.number().default(50).describe('Minimum ingredient match percentage'),
  }),
  outputSchema: z.array(z.object({
    id: z.number(),
    name: z.string(),
    matchPercentage: z.number(),
    usedIngredients: z.number(),
    missingIngredients: z.array(z.string()),
    image: z.string().optional(),
  })),
  execute: async ({ context }) => {
    return await searchRecipesByIngredients(
      context.ingredients,
      context.maxResults,
      context.minMatchPercentage
    );
  },
});

// Save Favorite Recipe Tool
export const saveFavoriteRecipeTool = createTool({
  id: 'save-favorite-recipe',
  description: 'Save a recipe to user favorites',
  inputSchema: z.object({
    userId: z.string().describe('User identifier'),
    recipeId: z.number().describe('Recipe ID to save'),
    recipeName: z.string().describe('Name of the recipe'),
    notes: z.string().optional().describe('Optional personal notes'),
  }),
  outputSchema: z.object({
    success: z.boolean(),
    message: z.string(),
    savedAt: z.string(),
  }),
  execute: async ({ context }) => {
    return await saveFavoriteRecipe(
      context.userId,
      context.recipeId,
      context.recipeName,
      context.notes
    );
  },
});

// Convert Measurements Tool
export const convertMeasurementsTool = createTool({
  id: 'convert-measurements',
  description: 'Convert recipe measurements between different units',
  inputSchema: z.object({
    amount: z.number().describe('Amount to convert'),
    fromUnit: z.enum(['cups', 'tablespoons', 'teaspoons', 'ounces', 'pounds', 'grams', 'kilograms', 'milliliters', 'liters']).describe('Source unit'),
    toUnit: z.enum(['cups', 'tablespoons', 'teaspoons', 'ounces', 'pounds', 'grams', 'kilograms', 'milliliters', 'liters']).describe('Target unit'),
    ingredient: z.string().optional().describe('Ingredient name for density-based conversions'),
  }),
  outputSchema: z.object({
    originalAmount: z.number(),
    originalUnit: z.string(),
    convertedAmount: z.number(),
    convertedUnit: z.string(),
    conversionNote: z.string().optional(),
  }),
  execute: async ({ context }) => {
    return await convertMeasurements(
      context.amount,
      context.fromUnit,
      context.toUnit,
      context.ingredient
    );
  },
});

// Implementation functions
const getRecipe = async (recipeName: string, cuisine?: string) => {
  try {
    // In a real implementation, you'd use a recipe API like Spoonacular
    // For demo purposes, this is a mock implementation
    const searchUrl = `https://api.spoonacular.com/recipes/complexSearch?query=${encodeURIComponent(recipeName)}&number=1&addRecipeInformation=true&apiKey=${process.env.SPOONACULAR_API_KEY}`;
    
    // Mock response for demonstration
    const mockRecipe = {
      id: Math.floor(Math.random() * 1000),
      name: recipeName,
      description: `Delicious ${recipeName} recipe with authentic flavors`,
      ingredients: [
        { name: "Main ingredient", amount: 2, unit: "cups" },
        { name: "Seasoning", amount: 1, unit: "tablespoon" },
        { name: "Oil", amount: 2, unit: "tablespoons" }
      ],
      instructions: [
        "Prepare all ingredients",
        "Heat oil in a pan",
        "Add main ingredients and cook",
        "Season to taste and serve"
      ],
      prepTime: 30,
      servings: 4,
      difficulty: "medium"
    };

    return mockRecipe;
  } catch (error) {
    throw new Error(`Failed to fetch recipe: ${error}`);
  }
};

const searchRecipesByIngredients = async (
  ingredients: string[],
  maxResults: number,
  minMatchPercentage: number
) => {
  try {
    // Mock implementation - in reality, you'd call a recipe API
    const mockResults = ingredients.map((ingredient, index) => ({
      id: index + 1,
      name: `${ingredient} Recipe #${index + 1}`,
      matchPercentage: Math.floor(Math.random() * 40) + 60, // 60-100%
      usedIngredients: Math.floor(Math.random() * ingredients.length) + 1,
      missingIngredients: ["salt", "pepper"].slice(0, Math.floor(Math.random() * 2)),
      image: `https://example.com/recipe-${index + 1}.jpg`
    }));

    return mockResults
      .filter(recipe => recipe.matchPercentage >= minMatchPercentage)
      .slice(0, maxResults);
  } catch (error) {
    throw new Error(`Failed to search recipes: ${error}`);
  }
};

const saveFavoriteRecipe = async (
  userId: string,
  recipeId: number,
  recipeName: string,
  notes?: string
) => {
  try {
    // In a real implementation, you'd save to a database
    // This is a mock implementation
    const savedAt = new Date().toISOString();
    
    // Mock database save operation
    console.log(`Saving recipe ${recipeId} for user ${userId}`);
    
    return {
      success: true,
      message: `Recipe "${recipeName}" saved to favorites successfully`,
      savedAt
    };
  } catch (error) {
    return {
      success: false,
      message: `Failed to save recipe: ${error}`,
      savedAt: new Date().toISOString()
    };
  }
};

const convertMeasurements = async (
  amount: number,
  fromUnit: string,
  toUnit: string,
  ingredient?: string
) => {
  // Conversion factors (simplified)
  const conversions: Record<string, Record<string, number>> = {
    cups: {
      tablespoons: 16,
      teaspoons: 48,
      milliliters: 236.588,
      ounces: 8
    },
    tablespoons: {
      cups: 1/16,
      teaspoons: 3,
      milliliters: 14.787
    },
    teaspoons: {
      cups: 1/48,
      tablespoons: 1/3,
      milliliters: 4.929
    },
    ounces: {
      cups: 1/8,
      grams: 28.3495,
      pounds: 1/16
    },
    pounds: {
      ounces: 16,
      grams: 453.592,
      kilograms: 0.453592
    },
    grams: {
      ounces: 1/28.3495,
      pounds: 1/453.592,
      kilograms: 1/1000
    },
    kilograms: {
      pounds: 2.20462,
      grams: 1000
    },
    milliliters: {
      cups: 1/236.588,
      tablespoons: 1/14.787,
      teaspoons: 1/4.929,
      liters: 1/1000
    },
    liters: {
      milliliters: 1000,
      cups: 4.227
    }
  };

  let convertedAmount: number;
  let conversionNote: string | undefined;

  if (conversions[fromUnit]?.[toUnit]) {
    convertedAmount = amount * conversions[fromUnit][toUnit];
  } else if (conversions[toUnit]?.[fromUnit]) {
    convertedAmount = amount / conversions[toUnit][fromUnit];
  } else {
    // If direct conversion not available, try common intermediate units
    convertedAmount = amount; // Fallback
    conversionNote = "Approximate conversion - please verify for accuracy";
  }

  // Round to reasonable precision
  convertedAmount = Math.round(convertedAmount * 100) / 100;

  if (ingredient) {
    conversionNote = `Conversion for ${ingredient}. Note that density may affect accuracy for volume-to-weight conversions.`;
  }

  return {
    originalAmount: amount,
    originalUnit: fromUnit,
    convertedAmount,
    convertedUnit: toUnit,
    conversionNote
  };
};

