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

  const getSafeRedirectPath = (fromPath: string | undefined, user: UserProfile): string => {
    const defaultPath = user.role === 'agronomist' ? '/agronomist' : '/official';
    if (!fromPath) return defaultPath;

    // Open redirect protection: ensure internal relative path only
    if (!fromPath.startsWith('/') || fromPath.startsWith('//') || fromPath.includes('\\')) {
      return defaultPath;
    }

    // Role-boundary check for destination
    if (user.role === 'agronomist' && fromPath.startsWith('/agronomist')) {
      return fromPath;
    }
    if (user.role === 'official' && fromPath.startsWith('/official')) {
      return fromPath;
    }

    return defaultPath;
  };

  const handleDemoLogin = (role: 'official' | 'agronomist') => {
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
    <div className="relative min-h-screen w-full flex flex-col justify-between items-center px-4 py-8 sm:px-6 lg:px-8 select-none overflow-x-hidden overflow-y-auto">
      {/* Layer 1: Agricultural Landscape Background */}
      <div
        className="fixed inset-0 bg-cover bg-center bg-no-repeat transition-transform duration-1000 ease-out pointer-events-none scale-100 animate-bhm-fade-in"
        style={{
          backgroundImage: "url('/images/bhoomi-agri-bg.jpg')",
        }}
        aria-hidden="true"
      />

      {/* Layer 2: Soft Translucent Base Overlay */}
      <div
        className="fixed inset-0 bg-slate-950/40 pointer-events-none"
        aria-hidden="true"
      />

      {/* Layer 3: Atmospheric Green Gradient & Depth */}
      <div
        className="fixed inset-0 bg-gradient-to-t from-emerald-950/80 via-slate-950/30 to-emerald-950/60 backdrop-blur-[1.5px] pointer-events-none"
        aria-hidden="true"
      />

      {/* Subtle Ambient Sunlight Glow Orbs */}
      <div
        className="fixed -top-32 left-1/2 -translate-x-1/2 w-[650px] h-[450px] bg-emerald-400/15 rounded-full blur-3xl pointer-events-none animate-bhm-pulse-soft"
        aria-hidden="true"
      />
      <div
        className="fixed -bottom-40 right-10 w-[500px] h-[400px] bg-lime-500/10 rounded-full blur-3xl pointer-events-none"
        aria-hidden="true"
      />

      {/* Layer 4: Foreground Login Interface */}
      <div className="relative z-10 my-auto w-full max-w-[430px] space-y-6 animate-bhm-fade-in-up">
        {/* Brand Identity Area */}
        <div className="text-center space-y-3">
          {/* Government Operations Badge */}
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-950/50 backdrop-blur-md px-3.5 py-1 text-[11px] font-semibold tracking-wider text-emerald-200 shadow-sm">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-400"></span>
            </span>
            <span>GOVERNMENT OF MAHARASHTRA</span>
          </div>

          {/* Official Bhoomi Emblem */}
          <Link
            to="/"
            className="mx-auto block w-fit rounded-2xl focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400"
            title="Return to Landing Page"
          >
            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-white/95 p-2 shadow-xl shadow-emerald-950/50 ring-2 ring-emerald-400/30 transition-transform duration-300 hover:scale-105">
              <img
                src="/icons/bhoomi-logo.png"
                alt="BHOOMI Logo"
                className="h-12 w-12 object-contain"
              />
            </div>
          </Link>

          {/* Title & Subtitle */}
          <div className="space-y-1">
            <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white drop-shadow-md">
              BHOOMI Portal
            </h1>
            <p className="text-xs sm:text-sm font-medium text-emerald-100/90 drop-shadow-xs max-w-sm mx-auto">
              Agronomist Case Management & Officials Surveillance
            </p>
          </div>
        </div>

        {/* Elevated Glassmorphism Login Card */}
        <Card className="rounded-2xl border border-white/80 bg-white/95 backdrop-blur-xl shadow-[0_20px_50px_rgba(0,0,0,0.35),0_1px_3px_rgba(0,0,0,0.08)] text-bhoomi-text-primary transition-all">
          <CardHeader className="space-y-1 pb-4 pt-6 px-6 sm:px-8">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg sm:text-xl font-bold tracking-tight text-slate-900">
                Sign In
              </CardTitle>
              <div className="inline-flex items-center gap-1.5 rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-semibold text-emerald-800 border border-emerald-200/70">
                <ShieldCheck className="h-3.5 w-3.5 text-emerald-600" />
                <span>Secure Access</span>
              </div>
            </div>
            <CardDescription className="text-xs text-slate-500">
              Enter your official credentials to access your portal workspace.
            </CardDescription>
          </CardHeader>

          <form onSubmit={handleSubmit} noValidate>
            <CardContent className="space-y-4 px-6 sm:px-8">
              {generalError && (
                <div
                  role="alert"
                  className="rounded-xl bg-red-50/95 p-3.5 text-xs text-bhoomi-danger border border-red-200 flex items-start gap-2.5 shadow-xs animate-bhm-fade-in"
                >
                  {generalError.isNetwork ? (
                    <WifiOff className="h-4 w-4 shrink-0 text-bhoomi-danger mt-0.5" />
                  ) : (
                    <AlertCircle className="h-4 w-4 shrink-0 text-bhoomi-danger mt-0.5" />
                  )}
                  <div className="leading-snug font-medium">{generalError.message}</div>
                </div>
              )}

              <Input
                label="Official Email"
                type="email"
                placeholder="name@kvk.gov.in"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                autoComplete="email"
                error={fieldErrors.email}
                required
                disabled={isSubmitting}
                icon={<Mail className="h-4 w-4 text-slate-400" />}
                className="h-11 bg-slate-50/70 focus:bg-white text-slate-900 placeholder:text-slate-400 border-slate-300/80 focus:border-emerald-600 focus:ring-emerald-600/20 rounded-xl transition-all"
              />

              <Input
                label="Password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
                error={fieldErrors.password}
                required
                disabled={isSubmitting}
                icon={<Lock className="h-4 w-4 text-slate-400" />}
                className="h-11 bg-slate-50/70 focus:bg-white text-slate-900 placeholder:text-slate-400 border-slate-300/80 focus:border-emerald-600 focus:ring-emerald-600/20 rounded-xl transition-all"
              />
            </CardContent>

            <CardFooter className="flex flex-col gap-3 pt-2 pb-6 px-6 sm:px-8">
              <Button
                type="submit"
                className="w-full h-11 text-sm font-semibold bg-[#1B5E20] hover:bg-[#14532D] active:bg-[#0F3E22] text-white shadow-md shadow-emerald-950/20 hover:shadow-lg active:scale-[0.99] transition-all duration-200 rounded-xl flex items-center justify-center gap-2 group"
                isLoading={isSubmitting}
              >
                <span>Sign In to Workspace</span>
                {!isSubmitting && (
                  <ArrowRight className="h-4 w-4 transition-transform duration-200 group-hover:translate-x-1" />
                )}
              </Button>

              <div className="relative w-full my-2">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-slate-200" />
                </div>
                <div className="relative flex justify-center text-xs uppercase">
                  <span className="bg-white px-2.5 text-slate-400 font-semibold tracking-wider flex items-center gap-1.5">
                    <Sparkles className="h-3 w-3 text-amber-500" />
                    Demo Fast Access
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5 w-full">
                <Button
                  type="button"
                  variant="secondary"
                  size="sm"
                  className="w-full h-10 flex items-center justify-center gap-1.5 text-xs font-semibold border border-slate-200 bg-slate-50/80 hover:bg-amber-50 hover:border-amber-300 hover:text-amber-950 text-slate-700 transition-all rounded-xl shadow-xs active:scale-[0.98]"
                  onClick={() => handleDemoLogin('official')}
                >
                  <Zap className="h-3.5 w-3.5 text-amber-600 fill-amber-500/20 shrink-0" />
                  <span>Official Dashboard</span>
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="w-full h-10 flex items-center justify-center gap-1.5 text-xs font-semibold border border-slate-200 bg-slate-50/80 hover:bg-emerald-50 hover:border-emerald-300 hover:text-emerald-950 text-slate-700 transition-all rounded-xl shadow-xs active:scale-[0.98]"
                  onClick={() => handleDemoLogin('agronomist')}
                >
                  <Sprout className="h-3.5 w-3.5 text-[#1B5E20] shrink-0" />
                  <span>Agronomist Queue</span>
                </Button>
              </div>
            </CardFooter>
          </form>
        </Card>

        {/* Official Footer Banner */}
        <div className="text-center pt-1">
          <div className="inline-flex items-center gap-2 rounded-full bg-slate-950/40 backdrop-blur-md px-3.5 py-1.5 text-xs font-medium text-emerald-100/80 border border-white/10 shadow-xs">
            <ShieldCheck className="h-3.5 w-3.5 text-emerald-400" />
            <span>Government of Maharashtra · SIH26131</span>
          </div>
        </div>
      </div>
    </div>
  );
}


