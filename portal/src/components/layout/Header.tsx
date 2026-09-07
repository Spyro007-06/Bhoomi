import { useAuth } from '@/features/auth/hooks';
import { Button } from '@/components/ui/Button';
import { LogOut, Sprout, User as UserIcon } from 'lucide-react';
import { NotificationDropdown } from './NotificationDropdown';

export function Header() {
  const { user, logout } = useAuth();

  const isAgronomist = user?.role === 'agronomist';
  const roleBadgeText = isAgronomist ? 'Agronomist Portal' : 'Officials Dashboard';
  const subtitleText = isAgronomist
    ? 'ICAR-KVK Erode (MYRADA)'
    : 'Government of Maharashtra · Crop Health System';
  const designationText = isAgronomist
    ? 'Crop Protection & Plant Pathology'
    : 'Agriculture Surveillance Officer';
  const displayName = user?.name || (isAgronomist ? 'Dr. S. Sundaram' : 'Officer Deshmukh');

  return (
    <header className="sticky top-0 z-30 flex h-[70px] w-full items-center justify-between border-b border-bhoomi-border bg-bhoomi-surface px-6 shadow-xs transition-colors select-none">
      {/* Brand & Portal Identity Area */}
      <div className="flex items-center gap-3.5">
        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[#1B5E20] text-white shadow-xs">
          <Sprout className="h-6 w-6" />
        </div>

        <div className="flex flex-col justify-center">
          <div className="flex items-center gap-2.5">
            <span className="text-xl font-extrabold tracking-tight text-bhoomi-text-primary">
              BHOOMI
            </span>
            {user?.role && (
              <span className="inline-flex items-center rounded-md border border-[#86EFAC] bg-[#DCFCE7] px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-[#15803D]">
                {roleBadgeText}
              </span>
            )}
          </div>
          <p className="text-xs font-medium text-bhoomi-text-muted leading-tight mt-0.5">
            {subtitleText}
          </p>
        </div>
      </div>

      {/* User Session & Actions Area */}
      <div className="flex items-center gap-4">
        {/* Notification Bell Dropdown */}
        <NotificationDropdown />

        <div className="h-7 w-px bg-bhoomi-border hidden sm:block" />

        {/* User Profile Summary */}
        <div className="flex items-center gap-3">
          <div className="text-right hidden sm:block">
            <p className="font-bold text-xs text-bhoomi-text-primary leading-tight">
              {displayName}
            </p>
            <p className="text-[11px] text-bhoomi-text-muted mt-0.5">
              {designationText}
            </p>
          </div>

          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-bhoomi-border-strong bg-bhoomi-canvas text-bhoomi-text-secondary shadow-xs">
            <UserIcon className="h-5 w-5 text-bhoomi-text-secondary" />
          </div>
        </div>

        <div className="h-7 w-px bg-bhoomi-border hidden sm:block" />

        <Button
          variant="ghost"
          size="sm"
          onClick={logout}
          className="text-bhoomi-text-secondary hover:text-bhoomi-danger hover:bg-bhoomi-danger-soft transition-colors text-xs font-medium h-9 px-2.5"
        >
          <LogOut className="h-3.5 w-3.5 mr-1.5" />
          Sign Out
        </Button>
      </div>
    </header>
  );
}
