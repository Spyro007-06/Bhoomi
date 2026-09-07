import { Outlet } from 'react-router-dom';
import { Header } from './Header';
import { Sidebar } from './Sidebar';

export function AppShell() {
  return (
    <div className="min-h-screen bg-bhoomi-canvas flex flex-col font-sans antialiased text-bhoomi-text-primary">
      <Header />
      <div className="flex flex-1 min-h-0">
        <Sidebar />
        <main className="flex-1 min-w-0 bg-bhoomi-canvas">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
