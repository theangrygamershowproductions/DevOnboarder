import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Header from "./components/Header";
import PublicLandingPage from "./components/PublicLandingPage";
import ProtectedDashboard from "./components/ProtectedDashboard";
import { ThemeProvider } from "./hooks/useTheme";

// Import theme styles
import "./styles/themes.css";

export default function App() {
    return (
        <ThemeProvider>
            <Router>
                <div className="min-h-screen theme-bg">
                    <Header />
                    <Routes>
                        <Route path="/" element={<PublicLandingPage />} />
                        <Route path="/dashboard" element={<ProtectedDashboard />} />
                        <Route path="/login/discord/callback" element={<ProtectedDashboard />} />
                        {/* Redirect legacy routes */}
                        <Route path="/admin" element={<ProtectedDashboard />} />
                        <Route path="/staff" element={<ProtectedDashboard />} />
                    </Routes>
                </div>
            </Router>
        </ThemeProvider>
    );
}
