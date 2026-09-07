import { createBrowserRouter, Navigate, RouteObject } from 'react-router-dom';
import { LoginPage } from '@/features/auth/pages/LoginPage';
import { ProtectedRoute } from '@/routes/ProtectedRoute';
import { RoleRoute } from '@/routes/RoleRoute';
import { AppShell } from '@/components/layout/AppShell';

// Agronomist Pages
import { CaseQueuePage } from '@/features/agronomist/pages/CaseQueuePage';
import { CaseWorkspacePage } from '@/features/agronomist/pages/CaseWorkspacePage';
import { UnderReviewPage } from '@/features/agronomist/pages/UnderReviewPage';
import { ResolvedHistoryPage } from '@/features/agronomist/pages/ResolvedHistoryPage';
import { TreatmentEfficacyPage } from '@/features/agronomist/pages/TreatmentEfficacyPage';
import { ActivityLogsPage } from '@/features/agronomist/pages/ActivityLogsPage';

// Officials Pages (F15)
import { OfficialsDashboardPage } from '@/features/officials/pages/OfficialsDashboardPage';
import { OfficialsHotspotsPage } from '@/features/officials/pages/OfficialsHotspotsPage';
import { OfficialsAccuracyPage } from '@/features/officials/pages/OfficialsAccuracyPage';
import { OfficialsQueuePage } from '@/features/officials/pages/OfficialsQueuePage';

export const routes: RouteObject[] = [
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <AppShell />,
        children: [
          // F12 Agronomist Surface
          {
            element: <RoleRoute allowedRoles={['agronomist']} />,
            children: [
              {
                path: '/agronomist',
                element: <Navigate to="/agronomist/cases" replace />,
              },
              {
                path: '/agronomist/cases',
                element: <CaseQueuePage />,
              },
              {
                path: '/agronomist/cases/:caseId',
                element: <CaseWorkspacePage />,
              },
              {
                path: '/agronomist/under-review',
                element: <UnderReviewPage />,
              },
              {
                path: '/agronomist/resolved',
                element: <ResolvedHistoryPage />,
              },
              {
                path: '/agronomist/efficacy',
                element: <TreatmentEfficacyPage />,
              },
              {
                path: '/agronomist/logs',
                element: <ActivityLogsPage />,
              },
            ],
          },
          // F15 Officials Surface
          {
            element: <RoleRoute allowedRoles={['official']} />,
            children: [
              {
                path: '/official',
                element: <OfficialsDashboardPage />,
              },
              {
                path: '/official/hotspots',
                element: <OfficialsHotspotsPage />,
              },
              {
                path: '/official/accuracy',
                element: <OfficialsAccuracyPage />,
              },
              {
                path: '/official/queue',
                element: <OfficialsQueuePage />,
              },
            ],
          },
        ],
      },
    ],
  },
  {
    path: '/',
    element: <Navigate to="/login" replace />,
  },
  {
    path: '*',
    element: <Navigate to="/login" replace />,
  },
];

export const router = createBrowserRouter(routes);
