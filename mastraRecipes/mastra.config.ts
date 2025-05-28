import { Config } from '@mastra/core';
import recipeAgent from './src/mastra/agents/recipe-agent';

export default {
  agents: {
    'recipe-agent': recipeAgent
  }
} satisfies Config; 