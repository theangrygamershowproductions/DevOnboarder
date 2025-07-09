import Login from './components/Login';
import FeedbackForm from './components/FeedbackForm';
import FeedbackStatusBoard from './components/FeedbackStatusBoard';
import FeedbackAnalytics from './components/FeedbackAnalytics';

export default function App() {
    return (
        <main>
            <h1>DevOnboarder</h1>
            <Login />
            <FeedbackForm />
            <FeedbackStatusBoard />
            <FeedbackAnalytics />
        </main>
    );
}
