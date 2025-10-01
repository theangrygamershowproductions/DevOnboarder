import { useEffect, useState } from "react";
import ThemeToggle from "./ThemeToggle";

interface User {
    username: string;
    discord_id: string;
    avatar?: string;
    roles: string[];
    isAuthenticated: boolean;
}

interface HeaderProps {
    className?: string;
}

export default function Header({ className = "" }: HeaderProps) {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const checkAuth = async () => {
            try {
                const token = localStorage.getItem("jwt");
                if (!token) {
                    setLoading(false);
                    return;
                }

                const response = await fetch(`${import.meta.env.VITE_AUTH_URL}/api/user/me`, {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });

                if (response.ok) {
                    const userData = await response.json();
                    setUser({
                        username: userData.username,
                        discord_id: userData.discord_id,
                        avatar: userData.avatar,
                        roles: userData.roles || [],
                        isAuthenticated: true,
                    });
                } else {
                    // Token is invalid, remove it
                    localStorage.removeItem("jwt");
                }
            } catch {
                // Auth check failed, remove invalid token
                localStorage.removeItem("jwt");
            } finally {
                setLoading(false);
            }
        };

        checkAuth();
    }, []);

    const logout = () => {
        localStorage.removeItem("jwt");
        setUser(null);
        window.location.href = "/";
    };

    const getDiscordAvatarUrl = (discordId: string, avatar: string) => {
        return `https://cdn.discordapp.com/avatars/${discordId}/${avatar}.png?size=64`;
    };

    const getDefaultAvatarUrl = (discordId: string) => {
        // Discord's default avatar calculation
        const discriminator = parseInt(discordId) % 5;
        return `https://cdn.discordapp.com/embed/avatars/${discriminator}.png`;
    };

    return (
        <header className={`theme-header border-b ${className}`}>
            <div className="container mx-auto px-6 py-4">
                <div className="flex justify-between items-center">
                    {/* Logo/Brand */}
                    <div className="flex items-center space-x-4">
                        <a href="/" className="text-2xl font-bold theme-header-text hover:theme-header-text transition-colors">
                            DevOnboarder
                        </a>
                        <span className="text-sm theme-text-muted theme-surface px-2 py-1 rounded">
                            Beta
                        </span>
                    </div>

                    {/* Navigation & User Info */}
                    <div className="flex items-center space-x-4">
                        {/* Navigation Links */}
                        <nav className="hidden md:flex items-center space-x-6">
                            <a href="/" className="theme-nav-text hover:theme-nav-text transition-colors">
                                Home
                            </a>
                            <a
                                href="https://github.com/theangrygamershowproductions/DevOnboarder"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="theme-nav-text hover:theme-nav-text transition-colors"
                            >
                                Source
                            </a>
                        </nav>

                        {/* Theme Toggle */}
                        <ThemeToggle className="hidden sm:flex" />

                        {/* Authentication State */}
                        <div className="flex items-center space-x-3">
                            {loading ? (
                                <div className="animate-spin rounded-full h-6 w-6 border-b-2 theme-spinner"></div>
                            ) : user && user.isAuthenticated ? (
                                <div className="flex items-center space-x-3">
                                    {/* User Avatar & Info */}
                                    <div className="flex items-center space-x-2">
                                        <img
                                            src={
                                                user.avatar
                                                    ? getDiscordAvatarUrl(user.discord_id, user.avatar)
                                                    : getDefaultAvatarUrl(user.discord_id)
                                            }
                                            alt={`${user.username}'s avatar`}
                                            className="w-8 h-8 rounded-full border-2 theme-border"
                                        />
                                        <div className="hidden sm:block">
                                            <div className="text-sm font-medium theme-text">{user.username}</div>
                                            <div className="text-xs theme-text-muted">
                                                {user.roles.length > 0 ? user.roles.join(", ") : "Member"}
                                            </div>
                                        </div>
                                    </div>

                                    {/* Dashboard Link */}
                                    <a
                                        href="/dashboard"
                                        className="theme-button-primary hover:theme-button-primary px-3 py-2 rounded-lg text-sm font-medium transition duration-200"
                                    >
                                        Dashboard
                                    </a>

                                    {/* Logout Button */}
                                    <button
                                        onClick={logout}
                                        className="theme-nav-text hover:text-red-500 transition-colors text-sm"
                                        title="Logout"
                                    >
                                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                                        </svg>
                                    </button>

                                    {/* Mobile Theme Toggle */}
                                    <ThemeToggle className="sm:hidden" />
                                </div>
                            ) : (
                                <div className="flex items-center space-x-2">
                                    <a
                                        href="/dashboard"
                                        className="theme-button-primary hover:theme-button-primary px-4 py-2 rounded-lg text-sm font-medium transition duration-200"
                                    >
                                        Staff Login
                                    </a>
                                    {/* Mobile Theme Toggle for non-authenticated users */}
                                    <ThemeToggle className="sm:hidden" />
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </header>
    );
}
