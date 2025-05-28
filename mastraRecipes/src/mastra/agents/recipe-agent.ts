import { openai } from '@ai-sdk/openai';
import { Agent } from '@mastra/core';
import { Memory } from '@mastra/memory';
import { LibSQLStore } from '@mastra/libsql';
import { 
  getRecipeTool, 
  searchRecipesTool, 
  saveFavoriteRecipeTool, 
  convertMeasurementsTool 
} from '../tools/recipe-tools';

const recipeAgent = new Agent({
  name: 'Recipe Agent',
  instructions: `You are a helpful cooking assistant with access to various recipe tools. 

  Your capabilities include:
  - Finding detailed recipes for specific dishes
  - Searching recipes based on available ingredients  
  - Saving favorite recipes for users
  - Converting recipe measurements between units

  When a user asks for a recipe:
  1. Use the get_recipe tool to fetch detailed recipe information
  2. Present the recipe in a clear, organized format
  3. Offer additional help like measurement conversions or ingredient substitutions

  When users mention available ingredients:
  1. Use search_recipes tool to find matching recipes
  2. Suggest recipes with highest ingredient match percentage

  Always be helpful, friendly, and provide practical cooking advice.
  If users want to save recipes, use the save_favorite_recipe tool.
  For measurement questions, use the convert_measurements tool.`,
  
  model: openai('gpt-4o-mini'),
  
  tools: {
    getRecipe: getRecipeTool,
    searchRecipes: searchRecipesTool,
    saveFavoriteRecipe: saveFavoriteRecipeTool,
    convertMeasurements: convertMeasurementsTool
  },
     
  memory: new Memory({
    storage: new LibSQLStore({
      url: 'file:../mastra.db',
    }),
  }),
});

export default recipeAgent;