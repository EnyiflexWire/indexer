import { defineConfig } from 'vitest/config'

export const defineConf = () =>
  defineConfig({
    resolve: {
      alias: {
        '#': './src'
      }
    },
    test: {
      setupFiles: ['./tests/setup.ts']
    }
  })
