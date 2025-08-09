import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
    server: {
        port: 3000,
        host: "0.0.0.0",
        allowedHosts: process.env.NODE_ENV === "production"
            ? [
                process.env.VITE_ALLOWED_HOST_DEV || "dev.theangrygamershow.com",
                process.env.VITE_ALLOWED_HOST_PROD || "theangrygamershow.com",
                "localhost"
              ]
            : true, // Allow all hosts in development for Traefik compatibility
    },
    plugins: [react()],
});
