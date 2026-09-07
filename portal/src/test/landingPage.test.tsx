import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { createMemoryRouter, RouterProvider } from 'react-router-dom';
import { AppProviders } from '@/app/providers';
import { routes } from '@/app/router';

describe('BHOOMI Portal — Landing Page Integration Tests', () => {
  const renderLandingPage = (initialPath = '/') => {
    const memoryRouter = createMemoryRouter(routes, {
      initialEntries: [initialPath],
    });

    return render(
      <AppProviders>
        <RouterProvider router={memoryRouter} />
      </AppProviders>
    );
  };

  it('renders landing page at root path / with main value proposition', () => {
    renderLandingPage('/');

    expect(
      screen.getByRole('heading', {
        name: /agricultural intelligence for ground-level field decisions/i,
      })
    ).toBeInTheDocument();
    expect(screen.getByText(/SIH26131 · Government of Maharashtra/i)).toBeInTheDocument();
  });

  it('renders verified scope metrics for the 4 supported crops and 26 targets', () => {
    renderLandingPage('/');

    expect(screen.getByText('4 Crops')).toBeInTheDocument();
    expect(screen.getByText('26 Targets')).toBeInTheDocument();
    expect(screen.getByText(/14 Diagnosable · 12 Inspect/i)).toBeInTheDocument();
    expect(screen.getAllByText(/CIB&RC/i).length).toBeGreaterThanOrEqual(1);
  });

  it('renders both Agronomist and Officials workspace entry panels', () => {
    renderLandingPage('/');

    expect(screen.getByText('Agronomist Case Management Portal')).toBeInTheDocument();
    expect(screen.getByText('Agriculture Officials Surveillance Portal')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /open agronomist queue/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /open officials dashboard/i })
    ).toBeInTheDocument();
  });

  it('renders all six architectural principles from the PRD', () => {
    renderLandingPage('/');

    expect(screen.getByText('Never Fabricate')).toBeInTheDocument();
    expect(screen.getByText('Uncertainty as a Feature')).toBeInTheDocument();
    expect(screen.getAllByText('Veto, Never Endorse').length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText('Chemical Last, Structurally')).toBeInTheDocument();
    expect(screen.getByText('Every Alert Carries a Task')).toBeInTheDocument();
    expect(screen.getByText('The Farm is a Case File')).toBeInTheDocument();
  });

  it('renders portal access buttons that navigate towards login', () => {
    renderLandingPage('/');

    const accessButtons = screen.getAllByRole('button', { name: /access portal/i });
    expect(accessButtons.length).toBeGreaterThanOrEqual(1);
  });
});
