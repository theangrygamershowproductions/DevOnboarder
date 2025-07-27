import { useEffect, useState } from 'react';

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
    const authUrl = import.meta.env.VITE_AUTH_URL;

    useEffect(() => {
        const params = new URLSearchParams(window.location.search);
        const code = params.get('code');
        const stored = localStorage.getItem('jwt');
        const path = window.location.pathname;

        if (!stored && path === '/login/discord/callback' && code) {
            fetch(`${authUrl}/login/discord/callback?code=${code}`)
                .then((r) => r.json())
                .then((data) => {
                    localStorage.setItem('jwt', data.token);
                    setToken(data.token);
                    window.history.replaceState({}, '', '/');
                })
                .catch(console.error);
        } else if (stored) {
            setToken(stored);
        }
    }, [authUrl]);

    useEffect(() => {
        if (!token) return;
        const headers = { Authorization: `Bearer ${token}` };

        fetch(`${authUrl}/api/user`, { headers })
            .then((r) => r.json())
            .then(setUser)
            .catch(console.error);

        fetch(`${authUrl}/api/user/level`, { headers })
            .then((r) => r.json())
            .then((d) => setLevel(d.level))
            .catch(console.error);

        fetch(`${authUrl}/api/user/onboarding-status`, { headers })
            .then((r) => r.json())
            .then((d) => setStatus(d.status))
            .catch(console.error);
    }, [token, authUrl]);

    if (!token) {
        return <a href={`${authUrl}/login/discord`}>Log in with Discord</a>;
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
            <p data-testid="user-level">Level: {level ?? '...'}</p>
            <p data-testid="onboarding-status">Onboarding: {status ?? '...'}</p>
            {status === 'intro' && <button>Start Onboarding</button>}
        </div>
    );
}
