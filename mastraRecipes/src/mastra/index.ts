import { Mastra } from '@mastra/core';
import { PinoLogger } from '@mastra/loggers';
import { LibSQLStore } from '@mastra/libsql';

import recipeAgent from './agents/recipe-agent';

export const mastra = new Mastra({
  agents: { 
    recipeAgent // Make sure this matches the agent name
  },
  storage: new LibSQLStore({
    url: ":memory:",
  }),
  logger: new PinoLogger({
    name: 'Mastra',
    level: 'info',
  }),
});
        