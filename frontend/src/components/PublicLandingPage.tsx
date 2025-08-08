import { useEffect, useState } from "react";

interface ServiceStatus {
    name: string;
    endpoint: string;
    status: "online" | "error" | "offline";
    responseTime?: number;
}

export default function PublicLandingPage() {
    const [services, setServices] = useState<ServiceStatus[]>([
        { name: "Authentication Service", endpoint: "https://auth.theangrygamershow.com/health", status: "offline" },
        { name: "API Backend", endpoint: "https://api.theangrygamershow.com/health", status: "offline" },
        { name: "Discord Integration", endpoint: "https://discord.theangrygamershow.com/health", status: "offline" },
        { name: "Dashboard Service", endpoint: "https://dashboard.theangrygamershow.com/health", status: "offline" }
    ]);

    useEffect(() => {
        const serviceEndpoints = [
            { name: "Authentication Service", endpoint: "https://auth.theangrygamershow.com/health" },
            { name: "API Backend", endpoint: "https://api.theangrygamershow.com/health" },
            { name: "Discord Integration", endpoint: "https://discord.theangrygamershow.com/health" },
            { name: "Dashboard Service", endpoint: "https://dashboard.theangrygamershow.com/health" }
        ];

        const checkServiceHealth = async () => {
            const updatedServices = await Promise.all(
                serviceEndpoints.map(async (service) => {
                    try {
                        const startTime = Date.now();
                        const response = await fetch(service.endpoint, {
                            method: "GET",
                            mode: "cors",
                            signal: AbortSignal.timeout(5000)
                        });
                        const responseTime = Date.now() - startTime;

                        if (response.ok) {
                            return { ...service, status: "online" as const, responseTime };
                        } else {
                            return { ...service, status: "error" as const, responseTime };
                        }
                    } catch {
                        return { ...service, status: "offline" as const };
                    }
                })
            );
            setServices(updatedServices);
        };

        checkServiceHealth();
        const interval = setInterval(checkServiceHealth, 30000); // Check every 30 seconds

        return () => clearInterval(interval);
    }, []); // Empty dependency array to run only once

    const getStatusColor = (status: string) => {
        switch (status) {
            case "online": return "text-green-600 bg-green-100";
            case "error": return "text-yellow-600 bg-yellow-100";
            case "offline": return "text-red-600 bg-red-100";
            default: return "text-gray-600 bg-gray-100";
        }
    };

    const getStatusIcon = (status: string) => {
        switch (status) {
            case "online": return "🟢";
            case "error": return "🟡";
            case "offline": return "🔴";
            default: return "⚫";
        }
    };

    return (
        <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
            {/* Hero Section */}
            <div className="container mx-auto px-6 py-8">
                <div className="text-center mb-12">
                    <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
                        Comprehensive Onboarding Platform
                    </h1>
                    <p className="text-lg md:text-xl text-gray-600 mb-6">
                        Designed to work quietly and reliably — comprehensive automation for development teams
                    </p>
                    <div className="flex justify-center space-x-4">
                        <a
                            href="/dashboard"
                            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition duration-200"
                        >
                            Staff Dashboard
                        </a>
                        <a
                            href="https://github.com/theangrygamershowproductions/DevOnboarder"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="bg-gray-800 hover:bg-gray-900 text-white font-bold py-3 px-6 rounded-lg transition duration-200"
                        >
                            View Source
                        </a>
                    </div>
                </div>

                {/* Project Information */}
                <div className="grid md:grid-cols-2 gap-12 mb-16">
                    <div className="bg-white rounded-lg shadow-lg p-8">
                        <h2 className="text-2xl font-bold text-gray-900 mb-4">Project Overview</h2>
                        <p className="text-gray-600 mb-4">
                            DevOnboarder is a multi-service architecture platform built with a trunk-based workflow
                            and extensive automation. Our philosophy: "This project wasn't built to impress —
                            it was built to work. Quietly. Reliably. And in service of those who need it."
                        </p>
                        <ul className="text-gray-600 space-y-2">
                            <li>• <strong>Backend:</strong> Python 3.12 + FastAPI + SQLAlchemy</li>
                            <li>• <strong>Frontend:</strong> React + Vite + TypeScript</li>
                            <li>• <strong>Bot:</strong> Discord.js with role management</li>
                            <li>• <strong>Infrastructure:</strong> Docker + Traefik + Cloudflare Tunnel</li>
                        </ul>
                    </div>

                    <div className="bg-white rounded-lg shadow-lg p-8">
                        <h2 className="text-2xl font-bold text-gray-900 mb-4">Key Features</h2>
                        <ul className="text-gray-600 space-y-2">
                            <li>• Multi-environment Discord bot integration</li>
                            <li>• Automated CI/CD with 22+ GitHub Actions workflows</li>
                            <li>• Comprehensive test coverage (95%+ requirement)</li>
                            <li>• Advanced CORS and security configuration</li>
                            <li>• Real-time service health monitoring</li>
                            <li>• Role-based access control</li>
                        </ul>
                    </div>
                </div>

                {/* Service Status Dashboard */}
                <div className="bg-white rounded-lg shadow-lg p-8">
                    <h2 className="text-2xl font-bold text-gray-900 mb-6">Service Status</h2>
                    <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
                        {services.map((service, index) => (
                            <div
                                key={index}
                                className="border rounded-lg p-4 hover:shadow-md transition duration-200"
                            >
                                <div className="flex items-center justify-between mb-2">
                                    <span className="font-medium text-gray-900">{service.name}</span>
                                    <span className="text-2xl">{getStatusIcon(service.status)}</span>
                                </div>
                                <div className={`inline-flex px-2 py-1 rounded-full text-sm font-medium ${getStatusColor(service.status)}`}>
                                    {service.status.toUpperCase()}
                                </div>
                                {service.responseTime && (
                                    <div className="text-xs text-gray-500 mt-1">
                                        Response: {service.responseTime}ms
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                    <div className="mt-6 text-sm text-gray-500">
                        Status updates every 30 seconds • Last updated: {new Date().toLocaleTimeString()}
                    </div>
                </div>

                {/* Public APIs Section */}
                <div className="mt-16 bg-white rounded-lg shadow-lg p-8">
                    <h2 className="text-2xl font-bold text-gray-900 mb-6">Public APIs</h2>
                    <div className="grid md:grid-cols-2 gap-6">
                        <div>
                            <h3 className="text-lg font-semibold mb-2">Health Endpoints</h3>
                            <ul className="text-sm text-gray-600 space-y-1">
                                <li><code className="bg-gray-100 px-2 py-1 rounded">GET /health</code> - Service health check</li>
                                <li><code className="bg-gray-100 px-2 py-1 rounded">GET /status</code> - Detailed service status</li>
                            </ul>
                        </div>
                        <div>
                            <h3 className="text-lg font-semibold mb-2">Documentation</h3>
                            <ul className="text-sm text-gray-600 space-y-1">
                                <li><a href="https://auth.theangrygamershow.com/docs" className="text-blue-600 hover:underline">Auth Service API</a></li>
                                <li><a href="https://api.theangrygamershow.com/docs" className="text-blue-600 hover:underline">Backend API</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
