# DevOnboarder Frontend

This directory houses the DevOnboarder React application built with Vite.

Install dependencies with `pnpm install` (or `npm install` if `pnpm` is not available`). Commit the generated lockfile (`pnpm-lock.yaml` or `package-lock.json`).
Start the development server with `npm run dev`.
Run `npm run lint` to check code style and `npm run format` to apply Prettier formatting.
Environment variables are defined in `.env.example`.

## Login Flow

Open `http://localhost:3000` and click **Log in with Discord**.
After approving the OAuth prompt, Discord redirects back to
`/login/discord/callback` on the frontend. The `Login` component exchanges the
provided `code` for a JWT via the auth service, stores it in `localStorage`, and
then displays your onboarding status and level.
