import { useEffect, useState } from "react";

interface UserInfo {
    id: string | null;
    username: string | null;
    avatar: string | null;
}

export default function Login() {
    const [token, setToken] = useState<string | null>(null);
    const [user, setUser] = useState<UserInfo | null>(null);
    const [level, setLevel] = useState<number | null>(null);
    const [status, setStatus] = useState<string | null>(null);
    const [loading, setLoading] = useState<boolean>(false);
    const authUrl = import.meta.env.VITE_AUTH_URL;

    useEffect(() => {
        const params = new URLSearchParams(window.location.search);
        const code = params.get("code");
        const tokenParam = params.get("token");
        const stored = localStorage.getItem("jwt");
        const path = window.location.pathname;

        // Handle direct token return from auth service
        if (!stored && path === "/login/discord/callback" && tokenParam) {
            localStorage.setItem("jwt", tokenParam);
            setToken(tokenParam);
            window.history.replaceState({}, "", "/");
            return;
        }

        // Handle Discord OAuth code callback
        if (!stored && path === "/login/discord/callback" && code) {
            fetch(`${authUrl}/login/discord/callback?code=${code}`)
                .then((r) => r.json())
                .then((data) => {
                    localStorage.setItem("jwt", data.token);
                    setToken(data.token);
                    window.history.replaceState({}, "", "/");
                })
                .catch((error) => {
                    console.error("Failed to fetch user info:", error);
                });
        } else if (stored) {
            setToken(stored);
        }
    }, [authUrl]);

    useEffect(() => {
        if (!token) return;

        setLoading(true);
        const headers = { Authorization: `Bearer ${token}` };

        Promise.all([
            fetch(`${authUrl}/api/user`, { headers }).then((r) => r.json()),
            fetch(`${authUrl}/api/user/level`, { headers }).then((r) => r.json()),
            fetch(`${authUrl}/api/user/onboarding-status`, { headers }).then((r) => r.json())
        ])
        .then(([userData, levelData, statusData]) => {
            setUser(userData);
            setLevel(levelData.level);
            setStatus(statusData.status);
        })
        .catch(() => {
            // Clear token if API calls fail (invalid token)
            localStorage.removeItem("jwt");
            setToken(null);
            setUser(null);
            setLevel(null);
            setStatus(null);
        })
        .finally(() => {
            setLoading(false);
        });
    }, [token, authUrl]);

    if (!token) {
        const callbackUrl = `${window.location.origin}/login/discord/callback`;
        const loginUrl = `${authUrl}/login/discord?redirect_to=${encodeURIComponent(callbackUrl)}`;
        return <a href={loginUrl}>Log in with Discord</a>;
    }

    if (loading) {
        return <div>Loading dashboard...</div>;
    }

    return (
        <div>
            {user && (
                <p data-testid="user-welcome">
                    Logged in as {user.username}
                    {user.avatar && user.id && (
                        <img
                            src={`https://cdn.discordapp.com/avatars/${user.id}/${user.avatar}.png`}
                            alt="avatar"
                            width={40}
                            height={40}
                        />
                    )}
                </p>
            )}
            <p data-testid="user-level">Level: {level ?? "..."}</p>
            <p data-testid="onboarding-status">Onboarding: {status ?? "..."}</p>
            {status === "intro" && <button>Start Onboarding</button>}
        </div>
    );
}
