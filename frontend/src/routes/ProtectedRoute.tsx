import { Navigate } from "react-router-dom";
import { authRedirectTarget } from "../auth/authRedirect";

interface ProtectedRouteProps {
    children: React.ReactNode;
    isAuthenticated: boolean;
    hasDashboard: boolean;
}

export default function ProtectedRoute({ children, isAuthenticated, hasDashboard }: ProtectedRouteProps) {
    if (!isAuthenticated) {
        return <Navigate to="/" replace />;
    }

    const target = authRedirectTarget({ isAuthenticated, hasDashboard });

    if (window.location.pathname !== target) {
        return <Navigate to={target} replace />;
    }

    return <>{children}</>;
}
