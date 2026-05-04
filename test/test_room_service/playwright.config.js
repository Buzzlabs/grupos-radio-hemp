import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './',
  outputDir: './test-results', 
  use: {
    baseURL: 'http://localhost:43567', 
    headless: false,
  },
});