import { useState, FormEvent } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { useAuth } from '@/features/auth/hooks';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from '@/components/ui/Card';
import {
  Sprout,
  AlertCircle,
  WifiOff,
  Zap,
  Mail,
  Lock,
  ShieldCheck,
  ArrowRight,
  Sparkles,
  Building2,
} from 'lucide-react';
import { isBhoomiApiError } from '@/lib/api/errors';
import { loginRequestSchema } from '../validation';
import { ZodError } from 'zod';
import { UserProfile } from '@/types/api';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState<{ email?: string; password?: string }>({});
  const [generalError, setGeneralError] = useState<{ message: string; isNetwork?: boolean } | null>(
    null
  );
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { login, loginDemo } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  // Initialize selected role based on redirect path if available, defaulting to official
  const fromPath = (location.state as { from?: { pathname: string } })?.from?.pathname;
  const initialRole: 'official' | 'agronomist' = fromPath?.startsWith('/agronomist')
    ? 'agronomist'
    : 'official';
  const [selectedRole, setSelectedRole] = useState<'official' | 'agronomist'>(initialRole);

  const getSafeRedirectPath = (fromPath: string | undefined, user: UserProfile): string => {
    const roleDefault = user.role === 'agronomist' ? '/agronomist/cases' : '/official';
    if (!fromPath) return roleDefault;

    // Open redirect protection: ensure internal relative path only
    if (!fromPath.startsWith('/') || fromPath.startsWith('//') || fromPath.includes('\\')) {
      return roleDefault;
    }

    // Role-boundary check for destination
    if (user.role === 'agronomist' && fromPath.startsWith('/agronomist')) {
      return fromPath;
    }
    if (user.role === 'official' && fromPath.startsWith('/official')) {
      return fromPath;
    }

    return roleDefault;
  };

  const handleDemoLogin = (role: 'official' | 'agronomist') => {
    setSelectedRole(role);
    loginDemo(role);
    const targetPath = role === 'official' ? '/official' : '/agronomist/cases';
    navigate(targetPath, { replace: true });
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setFieldErrors({});
    setGeneralError(null);

    // Client-side schema validation
    try {
      loginRequestSchema.parse({ email, password });
    } catch (err: unknown) {
      if (err instanceof ZodError) {
        const errors: { email?: string; password?: string } = {};
        err.errors.forEach((issue) => {
          if (issue.path[0] === 'email') errors.email = issue.message;
          if (issue.path[0] === 'password') errors.password = issue.message;
        });
        setFieldErrors(errors);
        return;
      }
    }

    setIsSubmitting(true);

    try {
      const response = await login({ email, password });
      const from = (location.state as { from?: { pathname: string } })?.from?.pathname;
      const targetPath = getSafeRedirectPath(from, response.user);
      navigate(targetPath, { replace: true });
    } catch (err: unknown) {
      if (isBhoomiApiError(err)) {
        if (err.isNetworkError()) {
          setGeneralError({
            message: 'Unable to reach the BHOOMI API server. Please verify your network connection.',
            isNetwork: true,
          });
        } else if (err.isUnauthorized()) {
          setGeneralError({
            message: 'Invalid official credentials. Please verify your email and password.',
          });
        } else if (err.isForbidden()) {
          setGeneralError({
            message: 'Your account is not authorized to access this portal.',
          });
        } else {
          setGeneralError({
            message: err.message || 'Authentication failed. Please try again.',
          });
        }
      } else if (err instanceof Error) {
        setGeneralError({ message: err.message });
      } else {
        setGeneralError({ message: 'An unexpected authentication error occurred.' });
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="relative min-h-screen w-full flex flex-col justify-center items-center lg:items-start px-4 sm:px-8 lg:pl-28 lg:pr-12 xl:pl-40 xl:pr-16 2xl:pl-52 py-6 sm:py-10 select-none overflow-x-hidden overflow-y-auto">
      {/* Primary Visual Background: BHOOMI Agriculture Image (Crystal Clear & Vibrant) */}
      <div
        className="fixed inset-0 pointer-events-none overflow-hidden"
        aria-hidden="true"
      >
        <img
          src="/images/bhoomi-agri-bg.jpg"
          alt="BHOOMI Agriculture Farmland"
          className="w-full h-full object-cover object-center select-none"
        />
        {/* Soft contrast gradient on desktop to ensure crisp legibility while preserving the tractor & field vista */}
        <div className="hidden lg:block absolute inset-y-0 left-0 w-[55%] bg-gradient-to-r from-slate-950/75 via-slate-950/35 to-transparent pointer-events-none" />
        {/* Subtle overall dark vignette on mobile */}
        <div className="lg:hidden absolute inset-0 bg-slate-950/30 pointer-events-none" />
      </div>

      {/* Foreground Login Interface: Left-Offset on Desktop, Centered on Mobile */}
      <div className="relative z-10 my-auto w-full max-w-[460px] space-y-3.5 animate-bhm-fade-in-up">
        {/* Brand Identity Area */}
        <div className="text-center lg:text-left space-y-2">
          {/* Official Bhoomi Emblem & Brand Title */}
          <div className="flex flex-col lg:flex-row items-center lg:items-center gap-3">
            <Link
              to="/"
              className="block w-fit rounded-2xl focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400 shrink-0"
              title="Return to Landing Page"
            >
              <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white/95 p-1.5 shadow-xl shadow-emerald-950/50 ring-2 ring-emerald-400/30 transition-transform duration-300 hover:scale-105">
                <img
                  src="/icons/bhoomi-logo.png"
                  alt="BHOOMI Logo"
                  className="h-9 w-9 object-contain"
                />
              </div>
            </Link>

            <div className="space-y-0.5 text-center lg:text-left">
              <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white drop-shadow-[0_2px_10px_rgba(0,0,0,0.85)]">
                BHOOMI Portal
              </h1>
              <p className="text-xs sm:text-sm font-semibold text-emerald-100 drop-shadow-[0_2px_8px_rgba(0,0,0,0.85)]">
                Agronomist Case Management & Officials Surveillance
              </p>
            </div>
          </div>
        </div>

        {/* Elevated Background-Adaptive Glassmorphism Login Card */}
        <Card className="relative rounded-3xl border border-emerald-500/25 bg-slate-950/55 backdrop-blur-2xl backdrop-saturate-150 shadow-[0_30px_70px_-15px_rgba(0,0,0,0.7),0_0_0_1px_rgba(255,255,255,0.12)_inset] text-white transition-all overflow-hidden">
          {/* Subtle Top-down Light Rim & Ambient Emerald Glows */}
          <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-emerald-400/50 to-transparent pointer-events-none" />
          <div className="absolute -top-24 -right-24 h-52 w-52 rounded-full bg-emerald-500/15 blur-3xl pointer-events-none" />
          <div className="absolute -bottom-24 -left-24 h-52 w-52 rounded-full bg-emerald-700/20 blur-3xl pointer-events-none" />

          <CardHeader className="relative z-10 space-y-1 pb-3 pt-6 px-6 sm:px-7">
            <div className="flex items-center justify-between">
              <CardTitle className="text-xl sm:text-2xl font-bold tracking-tight text-white drop-shadow-xs">
                Sign In
              </CardTitle>
              <div className="inline-flex items-center gap-1.5 rounded-full bg-emerald-950/70 backdrop-blur-md px-3 py-1 text-xs font-semibold text-emerald-300 border border-emerald-400/30 shadow-xs">
                <ShieldCheck className="h-4 w-4 text-emerald-400" />
                <span>Secure Access</span>
              </div>
            </div>
            <CardDescription className="text-xs sm:text-sm text-emerald-100/75">
              Enter your official credentials to access your portal workspace.
            </CardDescription>
          </CardHeader>

          <form onSubmit={handleSubmit} noValidate className="relative z-10">
            <CardContent className="space-y-3.5 px-6 sm:px-7 pt-1">
              {generalError && (
                <div
                  role="alert"
                  className="rounded-xl bg-red-950/80 backdrop-blur-md p-3 text-xs text-red-200 border border-red-500/40 flex items-start gap-2 shadow-sm animate-bhm-fade-in"
                >
                  {generalError.isNetwork ? (
                    <WifiOff className="h-4 w-4 shrink-0 text-red-400 mt-0.5" />
                  ) : (
                    <AlertCircle className="h-4 w-4 shrink-0 text-red-400 mt-0.5" />
                  )}
                  <div className="leading-snug font-medium">{generalError.message}</div>
                </div>
              )}

              {/* Workspace Role Selector */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-emerald-200/90 block">
                  Select Workspace Role
                </label>
                <div
                  role="radiogroup"
                  aria-label="Select Workspace Role"
                  className="grid grid-cols-2 p-1.5 rounded-2xl bg-black/40 backdrop-blur-md border border-white/10 gap-1.5 shadow-inner"
                >
                  <button
                    type="button"
                    role="radio"
                    aria-checked={selectedRole === 'official'}
                    onClick={() => setSelectedRole('official')}
                    className={`flex items-center justify-center gap-2 py-2 px-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all duration-150 cursor-pointer ${
                      selectedRole === 'official'
                        ? 'bg-emerald-600/90 text-white shadow-md border border-emerald-400/40 ring-1 ring-emerald-400/30'
                        : 'text-emerald-100/70 hover:text-white hover:bg-white/10 border border-transparent'
                    }`}
                  >
                    <Building2
                      className={`h-4 w-4 shrink-0 transition-colors ${
                        selectedRole === 'official' ? 'text-white' : 'text-emerald-300/70'
                      }`}
                    />
                    <span>Official Dashboard</span>
                  </button>

                  <button
                    type="button"
                    role="radio"
                    aria-checked={selectedRole === 'agronomist'}
                    onClick={() => setSelectedRole('agronomist')}
                    className={`flex items-center justify-center gap-2 py-2 px-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all duration-150 cursor-pointer ${
                      selectedRole === 'agronomist'
                        ? 'bg-emerald-600/90 text-white shadow-md border border-emerald-400/40 ring-1 ring-emerald-400/30'
                        : 'text-emerald-100/70 hover:text-white hover:bg-white/10 border border-transparent'
                    }`}
                  >
                    <Sprout
                      className={`h-4 w-4 shrink-0 transition-colors ${
                        selectedRole === 'agronomist' ? 'text-white' : 'text-emerald-300/70'
                      }`}
                    />
                    <span>Agronomist Portal</span>
                  </button>
                </div>
              </div>

              <Input
                label="Official Email"
                labelClassName="text-emerald-200/90"
                type="email"
                placeholder={selectedRole === 'official' ? 'officer@maha.gov.in' : 'name@kvk.gov.in'}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                autoComplete="email"
                error={fieldErrors.email}
                required
                disabled={isSubmitting}
                icon={<Mail className="h-4 w-4 text-emerald-400/70" />}
                className="h-10.5 bg-black/35 focus:bg-black/50 text-white placeholder:text-slate-400 border-white/15 focus:border-emerald-400 focus:ring-2 focus:ring-emerald-400/20 rounded-xl transition-all text-sm shadow-inner backdrop-blur-md"
              />

              <Input
                label="Password"
                labelClassName="text-emerald-200/90"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
                error={fieldErrors.password}
                required
                disabled={isSubmitting}
                icon={<Lock className="h-4 w-4 text-emerald-400/70" />}
                className="h-10.5 bg-black/35 focus:bg-black/50 text-white placeholder:text-slate-400 border-white/15 focus:border-emerald-400 focus:ring-2 focus:ring-emerald-400/20 rounded-xl transition-all text-sm shadow-inner backdrop-blur-md"
              />
            </CardContent>

            <CardFooter className="flex flex-col gap-2.5 pt-1.5 pb-5 px-6 sm:px-7">
              <Button
                type="submit"
                className="w-full h-11 text-sm font-semibold bg-[#2E7D32] hover:bg-[#1B5E20] active:bg-[#14532D] text-white shadow-lg shadow-emerald-950/60 hover:shadow-emerald-900/40 active:scale-[0.99] transition-all duration-200 rounded-xl flex items-center justify-center gap-2 group border border-emerald-400/20"
                isLoading={isSubmitting}
              >
                <span>Sign In to Workspace</span>
                {!isSubmitting && (
                  <ArrowRight className="h-4 w-4 transition-transform duration-200 group-hover:translate-x-1" />
                )}
              </Button>

              <div className="relative w-full my-1">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-white/15" />
                </div>
                <div className="relative flex justify-center text-[10px] sm:text-xs uppercase">
                  <span className="bg-slate-950/80 backdrop-blur-md px-3 py-0.5 rounded-full border border-white/15 text-emerald-200/80 font-semibold tracking-wider flex items-center gap-1.5 shadow-xs">
                    <Sparkles className="h-3.5 w-3.5 text-amber-400" />
                    Demo Fast Access
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5 w-full">
                <Button
                  type="button"
                  variant="secondary"
                  size="sm"
                  className="w-full h-10 flex items-center justify-center gap-1.5 text-xs sm:text-sm font-semibold border border-white/15 bg-white/5 hover:bg-amber-500/20 hover:border-amber-400/50 hover:text-amber-200 text-slate-200 transition-all rounded-xl shadow-xs active:scale-[0.98] backdrop-blur-md"
                  onClick={() => handleDemoLogin('official')}
                >
                  <Zap className="h-4 w-4 text-amber-400 fill-amber-400/20 shrink-0" />
                  <span>Official Dashboard</span>
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="w-full h-10 flex items-center justify-center gap-1.5 text-xs sm:text-sm font-semibold border border-white/15 bg-white/5 hover:bg-emerald-500/20 hover:border-emerald-400/50 hover:text-emerald-200 text-slate-200 transition-all rounded-xl shadow-xs active:scale-[0.98] backdrop-blur-md"
                  onClick={() => handleDemoLogin('agronomist')}
                >
                  <Sprout className="h-4 w-4 text-emerald-400 shrink-0" />
                  <span>Agronomist Queue</span>
                </Button>
              </div>
            </CardFooter>
          </form>
        </Card>

        {/* Official Footer Banner */}
        <div className="text-center">
          <div className="inline-flex items-center gap-2 rounded-full bg-slate-950/50 backdrop-blur-md px-3.5 py-1 text-xs font-medium text-emerald-100/80 border border-white/10 shadow-xs">
            <ShieldCheck className="h-3.5 w-3.5 text-emerald-400" />
            <span>Government of Maharashtra · SIH26131</span>
          </div>
        </div>
      </div>
    </div>
  );
}


