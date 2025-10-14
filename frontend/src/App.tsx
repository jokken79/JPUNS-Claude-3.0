import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';

// Pages
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Candidates from './pages/Candidates';
import CandidatesList from './pages/CandidatesList';
import PendingApproval from './pages/PendingApproval';
import CandidateEdit from './pages/CandidateEdit';
import Employees from './pages/Employees';
import EmployeesExtended from './pages/EmployeesExtended';
import EmployeeDetail from './pages/EmployeeDetail';
import EmployeeForm from './pages/EmployeeForm';
import Factories from './pages/Factories';
import TimerCards from './pages/TimerCards';
import Salary from './pages/Salary';
import Requests from './pages/Requests';
import ImportData from './pages/ImportData';
import RirekishoPrintView from './pages/RirekishoPrintView';
import RirekishoPrintViewJPModif2 from './pages/RirekishoPrintViewJPModif2';

// Components
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';
import VisibilityGuard from './components/VisibilityGuard';
import { PageVisibilityProvider } from './context/PageVisibilityContext';
import { ThemeProvider } from './context/ThemeContext';

// Styles
import './index.css';

function App() {
  return (
    <PageVisibilityProvider>
      <ThemeProvider>
        <Router>
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
              success: {
                duration: 3000,
                iconTheme: {
                  primary: '#22c55e',
                  secondary: '#fff',
                },
              },
              error: {
                duration: 5000,
                iconTheme: {
                  primary: '#ef4444',
                  secondary: '#fff',
                },
              },
            }}
          />

          <Routes>
            {/* Public Routes */}
            <Route path="/login" element={<Login />} />

            {/* Protected Routes */}
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <Layout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Navigate to="/dashboard" replace />} />
              <Route
                path="dashboard"
                element={(
                  <VisibilityGuard pageKey="dashboard">
                    <Dashboard />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="candidates"
                element={(
                  <VisibilityGuard pageKey="candidates">
                    <Candidates />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="candidates/list"
                element={(
                  <VisibilityGuard pageKey="candidates">
                    <CandidatesList />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="candidates/:id/edit"
                element={(
                  <VisibilityGuard pageKey="candidates">
                    <CandidateEdit />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="candidates/:id"
                element={(
                  <VisibilityGuard pageKey="candidates">
                    <CandidateEdit />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="candidates/:id/print"
                element={(
                  <ProtectedRoute>
                    <RirekishoPrintView />
                  </ProtectedRoute>
                )}
              />
              <Route
                path="candidates/:id/print-jp2"
                element={(
                  <ProtectedRoute>
                    <RirekishoPrintViewJPModif2 />
                  </ProtectedRoute>
                )}
              />
              <Route
                path="pending-approval"
                element={(
                  <VisibilityGuard pageKey="pendingApproval">
                    <PendingApproval />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="employees"
                element={(
                  <VisibilityGuard pageKey="employees">
                    <Employees />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="employees-extended"
                element={(
                  <VisibilityGuard pageKey="employeesExtended">
                    <EmployeesExtended />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="employees/new"
                element={(
                  <VisibilityGuard pageKey="employees">
                    <EmployeeForm />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="employees/:id"
                element={(
                  <VisibilityGuard pageKey="employees">
                    <EmployeeDetail />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="employees/:id/edit"
                element={(
                  <VisibilityGuard pageKey="employees">
                    <EmployeeForm />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="factories"
                element={(
                  <VisibilityGuard pageKey="factories">
                    <Factories />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="timer-cards"
                element={(
                  <VisibilityGuard pageKey="timerCards">
                    <TimerCards />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="salary"
                element={(
                  <VisibilityGuard pageKey="salary">
                    <Salary />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="requests"
                element={(
                  <VisibilityGuard pageKey="requests">
                    <Requests />
                  </VisibilityGuard>
                )}
              />
              <Route
                path="import-data"
                element={(
                  <VisibilityGuard pageKey="importData">
                    <ImportData />
                  </VisibilityGuard>
                )}
              />
            </Route>

            {/* 404 */}
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </Router>
      </ThemeProvider>
    </PageVisibilityProvider>
  );
}

export default App;