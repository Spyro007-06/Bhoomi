import { ComponentType } from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '@/features/auth/hooks';
import { cn } from '@/lib/utils/cn';
import {
  Inbox,
  AlertTriangle,
  CheckCircle2,
  Activity,
  History,
  LayoutDashboard,
  MapPin,
  ListChecks,
  HelpCircle,
  LucideProps,
} from 'lucide-react';

interface NavItem {
  to: string;
  label: string;
  icon: ComponentType<LucideProps>;
  badge?: number | string;
  end?: boolean;
}

export function Sidebar() {
  const { user } = useAuth();
  const role = user?.role;

  const agronomistNav: NavItem[] = [
    {
      to: '/agronomist/cases',
      label: 'Escalated Cases',
      icon: Inbox,
      badge: 3,
    },
    {
      to: '/agronomist/under-review',
      label: 'Under Review',
      icon: AlertTriangle,
    },
    {
      to: '/agronomist/resolved',
      label: 'Resolved History',
      icon: CheckCircle2,
    },
    {
      to: '/agronomist/efficacy',
      label: 'Treatment Efficacy',
      icon: Activity,
    },
    {
      to: '/agronomist/logs',
      label: 'Activity Logs',
      icon: History,
    },
  ];

  const officialNav: NavItem[] = [
    {
      to: '/official',
      label: 'Dashboard',
      icon: LayoutDashboard,
      end: true,
    },
    {
      to: '/official/hotspots',
      label: 'Hotspots Map',
      icon: MapPin,
    },
    {
      to: '/official/accuracy',
      label: 'Model Accuracy',
      icon: Activity,
    },
    {
      to: '/official/queue',
      label: 'Confirmation Queue',
      icon: ListChecks,
    },
  ];

  const items: NavItem[] =
    role === 'agronomist' ? agronomistNav : role === 'official' ? officialNav : [];

  return (
    <aside className="sticky top-[70px] h-[calc(100vh-70px)] w-60 shrink-0 border-r border-bhoomi-border bg-bhoomi-surface p-4 flex flex-col justify-between overflow-y-auto select-none z-20">
      <div className="space-y-4">
        <div>
          <h2 className="px-3 text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-2.5">
            {role === 'agronomist' ? 'CASE MANAGEMENT' : 'SURVEILLANCE OPERATIONS'}
          </h2>

          <nav className="space-y-1">
            {items.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                className={({ isActive }) =>
                  cn(
                    'group flex items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-semibold transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-bhoomi-primary',
                    isActive
                      ? 'bg-[#1B5E20] text-white shadow-xs'
                      : 'text-bhoomi-text-secondary hover:bg-bhoomi-primary-soft hover:text-bhoomi-primary-dark'
                  )
                }
              >
                {({ isActive }) => (
                  <>
                    <div className="flex items-center gap-2.5">
                      <item.icon
                        className={cn(
                          'h-4 w-4 shrink-0 transition-colors',
                          isActive
                            ? 'text-white'
                            : 'text-bhoomi-text-muted group-hover:text-bhoomi-primary'
                        )}
                      />
                      <span className="leading-tight">{item.label}</span>
                    </div>

                    {item.badge !== undefined && (
                      <span
                        className={cn(
                          'rounded-full px-2 py-0.5 text-[10px] font-bold',
                          isActive
                            ? 'bg-[#2E7D32] text-white'
                            : 'bg-bhoomi-canvas text-bhoomi-text-secondary border border-bhoomi-border'
                        )}
                      >
                        {item.badge}
                      </span>
                    )}
                  </>
                )}
              </NavLink>
            ))}
          </nav>
        </div>
      </div>

      {/* KVK Extension Guide Card Footer */}
      {role === 'agronomist' ? (
        <div className="rounded-2xl border border-bhoomi-border bg-[#F8FAFC] p-3.5 space-y-1.5 mt-6">
          <div className="flex items-center gap-1.5 text-bhoomi-text-primary font-bold text-xs">
            <HelpCircle className="h-4 w-4 text-emerald-600" />
            <span>KVK Extension Guide</span>
          </div>
          <p className="text-[11px] text-bhoomi-text-muted leading-relaxed">
            Review crop photographs and prescribe scientific management based on TNAU/ICAR bulletins.
          </p>
        </div>
      ) : (
        <div className="rounded-2xl border border-bhoomi-border bg-[#F8FAFC] p-3.5 text-xs text-bhoomi-text-muted space-y-1 mt-6">
          <div className="flex items-center gap-1.5 text-bhoomi-text-primary font-bold text-xs">
            <span>BHOOMI Surveillance</span>
          </div>
          <p className="text-[11px] text-bhoomi-text-secondary leading-snug">
            Official State Crop Health Shell
          </p>
        </div>
      )}
    </aside>
  );
}
