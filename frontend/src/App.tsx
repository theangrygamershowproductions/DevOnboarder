import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { useState, useEffect } from "react";
import Header from "./components/Header";
import PublicLandingPage from "./components/PublicLandingPage";
import ProtectedDashboard from "./components/ProtectedDashboard";
import ProtectedRoute from "./routes/ProtectedRoute";

export default function App() {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [hasDashboard, setHasDashboard] = useState(false);

    useEffect(() => {
        // Check authentication status from localStorage or API
        const token = localStorage.getItem("jwt");
        if (token) {
            setIsAuthenticated(true);
            // You could also check user roles here for dashboard access
            setHasDashboard(true);
        }
    }, []);

    return (
        <Router>
            <div className="min-h-screen">
                <Header />
                <Routes>
                    <Route path="/" element={<PublicLandingPage />} />
                    <Route path="/dashboard" element={
                        <ProtectedRoute isAuthenticated={isAuthenticated} hasDashboard={hasDashboard}>
                            <ProtectedDashboard />
                        </ProtectedRoute>
                    } />
                    <Route path="/login/discord/callback" element={
                        <ProtectedRoute isAuthenticated={isAuthenticated} hasDashboard={hasDashboard}>
                            <ProtectedDashboard />
                        </ProtectedRoute>
                    } />
                    {/* Redirect legacy routes */}
                    <Route path="/admin" element={
                        <ProtectedRoute isAuthenticated={isAuthenticated} hasDashboard={hasDashboard}>
                            <ProtectedDashboard />
                        </ProtectedRoute>
                    } />
                    <Route path="/staff" element={
                        <ProtectedRoute isAuthenticated={isAuthenticated} hasDashboard={hasDashboard}>
                            <ProtectedDashboard />
                        </ProtectedRoute>
                    } />
                </Routes>
            </div>
        </Router>
    );
}
