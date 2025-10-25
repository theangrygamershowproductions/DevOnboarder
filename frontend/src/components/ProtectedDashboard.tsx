import { useEffect, useState } from "react";
import Login from "./Login";
import FeedbackForm from "./FeedbackForm";
import FeedbackStatusBoard from "./FeedbackStatusBoard";
import FeedbackAnalytics from "./FeedbackAnalytics";

interface User {
    username: string;
    roles: string[];
    isAuthenticated: boolean;
}

export default function ProtectedDashboard() {
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

    const hasPermission = (requiredRoles: string[]) => {
        if (!user || !user.isAuthenticated) return false;
        return requiredRoles.some(role => user.roles.includes(role));
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
            </div>
        );
    }

    if (!user || !user.isAuthenticated) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="max-w-md w-full bg-white shadow-lg rounded-lg p-8">
                    <div className="text-center mb-6">
                        <h1 className="text-2xl font-bold text-gray-900">Staff Dashboard</h1>
                        <p className="text-gray-600 mt-2">Please authenticate with Discord to continue</p>
                    </div>
                    <Login />
                    <div className="mt-4 text-center">
                        <a
                            href="/"
                            className="text-blue-600 hover:underline text-sm"
                        >
                            ← Back to public site
                        </a>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50">
            {/* Dashboard Content */}
            <main className="container mx-auto px-6 py-8">
                {/* Welcome Section */}
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-gray-900 mb-2">Welcome back, {user.username}!</h1>
                    <p className="text-gray-600">
                        Role{user.roles.length > 1 ? 's' : ''}: {user.roles.join(", ") || "Member"} •
                        Access the DevOnboarder staff dashboard below
                    </p>
                </div>
                {/* Admin Section */}
                {hasPermission(["ADMINISTRATOR", "OWNER"]) && (
                    <div className="mb-8 bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded">
                        <div className="flex">
                            <div className="flex-shrink-0">
                                <span className="text-yellow-400"></span>
                            </div>
                            <div className="ml-3">
                                <h3 className="text-sm font-medium text-yellow-800">Administrator Access</h3>
                                <p className="text-sm text-yellow-700">
                                    You have administrative privileges. Use them responsibly.
                                </p>
                            </div>
                        </div>
                    </div>
                )}

                {/* Main Dashboard Widgets */}
                <div className="grid xl:grid-cols-3 lg:grid-cols-2 gap-8">
                    {/* Feedback Management */}
                    <div className="bg-white rounded-lg shadow-lg p-6">
                        <h2 className="text-xl font-bold text-gray-900 mb-4">Feedback Management</h2>
                        {hasPermission(["MODERATOR", "ADMINISTRATOR", "OWNER"]) ? (
                            <>
                                <FeedbackForm />
                                <div className="mt-6">
                                    <FeedbackStatusBoard />
                                </div>
                            </>
                        ) : (
                            <div className="text-center py-8 text-gray-500">
                                <p>You need Moderator or higher privileges to access feedback management.</p>
                            </div>
                        )}
                    </div>

                    {/* Analytics */}
                    <div className="bg-white rounded-lg shadow-lg p-6">
                        <h2 className="text-xl font-bold text-gray-900 mb-4">Analytics</h2>
                        {hasPermission(["ADMINISTRATOR", "OWNER"]) ? (
                            <FeedbackAnalytics />
                        ) : (
                            <div className="text-center py-8 text-gray-500">
                                <p>You need Administrator privileges to access analytics.</p>
                            </div>
                        )}
                    </div>

                    {/* CI Dashboard */}
                    {hasPermission(["OWNER"]) && (
                        <div className="bg-white rounded-lg shadow-lg p-6 xl:col-span-1 lg:col-span-2">
                            <h2 className="text-xl font-bold text-gray-900 mb-4">CI Dashboard</h2>
                            <p className="text-sm text-gray-600 mb-4">
                                Access the comprehensive CI troubleshooting dashboard with script execution and real-time monitoring.
                            </p>
                            <div className="space-y-3">
                                <a
                                    href="https://dashboard.theangrygamershow.com"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="block w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg text-center transition duration-200"
                                >
                                    Open CI Dashboard (External)
                                </a>
                                <p className="text-xs text-gray-500 text-center">
                                    Provides script execution, CI health monitoring, and real-time automation tools
                                </p>
                            </div>
                        </div>
                    )}
                </div>

                {/* Quick Actions */}
                <div className="mt-8 bg-white rounded-lg shadow-lg p-6">
                    <h2 className="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
                    <div className="grid md:grid-cols-4 gap-4">
                        {hasPermission(["OWNER"]) && (
                            <a
                                href="https://dashboard.theangrygamershow.com"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="block p-4 border-2 border-blue-200 bg-blue-50 rounded-lg hover:bg-blue-100 transition duration-200"
                            >
                                <h3 className="font-medium text-blue-900">CI Dashboard</h3>
                                <p className="text-sm text-blue-700">CI troubleshooting & automation</p>
                            </a>
                        )}
                        <a
                            href="http://api.dev.theangrygamershow.com/docs"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition duration-200"
                        >
                            <h3 className="font-medium text-gray-900">API Documentation</h3>
                            <p className="text-sm text-gray-600">View backend API docs</p>
                        </a>
                        <a
                            href="http://auth.dev.theangrygamershow.com/docs"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition duration-200"
                        >
                            <h3 className="font-medium text-gray-900">Auth Service</h3>
                            <p className="text-sm text-gray-600">Authentication API</p>
                        </a>
                        <a
                            href="/"
                            className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition duration-200"
                        >
                            <h3 className="font-medium text-gray-900">Public Site</h3>
                            <p className="text-sm text-gray-600">View public landing page</p>
                        </a>
                    </div>
                </div>
            </main>
        </div>
    );
}
