import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@lib': path.resolve(__dirname, './lib')
    }
  },
  server: {
    port: 5174,
    host: '0.0.0.0',
    proxy: {
      '/api': {
        target: process.env.AAR_API_URL || 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          forms: ['react-hook-form', '@hookform/resolvers', 'zod']
        }
      }
    }
  },
  base: '/',  // Serve from root in production
  preview: {
    port: 5174,
    host: '0.0.0.0'
  }
})
