import { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Sprout,
  ShieldCheck,
  ArrowRight,
  ChevronRight,
  Activity,
  MapPin,
  Clock,
  CheckCircle2,
  Menu,
  X,
  Sliders,
  Database,
  Building2,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { ScrollReveal } from '../components/ScrollReveal';

export function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#FDFEFC] text-slate-900 selection:bg-emerald-100 selection:text-emerald-900 font-sans antialiased">
      {/* ============================================================
          1. HEADER NAVIGATION
          ============================================================ */}
      <header className="sticky top-0 z-50 w-full border-b border-slate-200/80 bg-white/95 backdrop-blur-md transition-all">
        <div className="mx-auto flex h-16 max-w-7xl xl:max-w-[1440px] items-center justify-between px-4 sm:px-6 lg:px-8">
          {/* Brand Identity */}
          <Link to="/" className="flex items-center gap-3 group focus:outline-none">
            <img
              src="/icons/bhoomi-logo.png"
              alt="BHOOMI Logo"
              className="h-10 w-10 shrink-0 object-contain drop-shadow-xs transition-transform duration-200 group-hover:scale-105"
            />
            <div className="flex flex-col">
              <div className="flex items-center gap-2">
                <span className="text-xl font-bold tracking-tight text-slate-900">BHOOMI</span>
                <span className="rounded-md border border-emerald-200 bg-emerald-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-emerald-800">
                  SIH26131
                </span>
              </div>
              <span className="text-[11px] font-medium text-slate-500 leading-none">
                Govt. of Maharashtra
              </span>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-600">
            <a href="#overview" className="hover:text-emerald-800 transition-colors duration-200">
              Overview
            </a>
            <a href="#how-it-works" className="hover:text-emerald-800 transition-colors duration-200">
              Lifecycle
            </a>
            <a href="#portals" className="hover:text-emerald-800 transition-colors duration-200">
              Workspaces
            </a>
            <a href="#capabilities" className="hover:text-emerald-800 transition-colors duration-200">
              Capabilities
            </a>
            <a href="#principles" className="hover:text-emerald-800 transition-colors duration-200">
              Principles
            </a>
          </nav>

          {/* Desktop CTA Action */}
          <div className="hidden md:flex items-center gap-3">
            <Link to="/login">
              <Button
                variant="outline"
                size="sm"
                className="font-medium text-xs text-slate-700 hover:text-emerald-900 border-slate-300 transition-all duration-200 ease-out hover:-translate-y-0.5 active:translate-y-0 active:scale-[0.98]"
              >
                Sign In
              </Button>
            </Link>
            <Link to="/login">
              <Button
                size="sm"
                className="bg-[#1B5E20] hover:bg-[#14532D] text-white font-medium text-xs gap-1.5 shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
              >
                <span>Access Portal</span>
                <ChevronRight className="h-3.5 w-3.5" />
              </Button>
            </Link>
          </div>

          {/* Mobile Menu Toggle */}
          <div className="flex md:hidden">
            <button
              type="button"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 text-slate-600 hover:text-slate-900 focus:outline-none transition-colors"
              aria-label="Toggle navigation menu"
            >
              {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Dropdown Menu */}
        {mobileMenuOpen && (
          <div className="border-b border-slate-200 bg-white px-4 py-4 md:hidden animate-bhm-fade-in space-y-3">
            <nav className="flex flex-col space-y-2.5 text-sm font-medium text-slate-700">
              <a
                href="#overview"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800 transition-colors"
              >
                Overview
              </a>
              <a
                href="#how-it-works"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800 transition-colors"
              >
                Lifecycle
              </a>
              <a
                href="#portals"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800 transition-colors"
              >
                Workspaces
              </a>
              <a
                href="#capabilities"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800 transition-colors"
              >
                Capabilities
              </a>
              <a
                href="#principles"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800 transition-colors"
              >
                Principles
              </a>
            </nav>
            <div className="pt-2 border-t border-slate-100 flex flex-col gap-2">
              <Link to="/login" onClick={() => setMobileMenuOpen(false)}>
                <Button className="w-full bg-[#1B5E20] hover:bg-[#14532D] text-white text-xs transition-all active:scale-[0.98]">
                  Access Portal
                </Button>
              </Link>
            </div>
          </div>
        )}
      </header>

      {/* ============================================================
          2. HERO SECTION
          ============================================================ */}
      <section id="overview" className="relative overflow-hidden min-h-[calc(100vh-4rem)] flex items-center py-8 lg:py-12 scroll-mt-16">
        {/* Subtle background natural contour atmosphere */}
        <div className="absolute inset-0 bg-gradient-to-b from-emerald-50/40 via-transparent to-transparent pointer-events-none" />
        <div className="absolute right-0 top-0 -mt-20 -mr-20 h-96 w-96 rounded-full bg-emerald-100/30 blur-3xl pointer-events-none" />

        <div className="relative mx-auto w-full max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 gap-12 lg:grid-cols-12 lg:gap-8 items-center">
            {/* Left Content Column */}
            <div className="lg:col-span-7 space-y-6">
              {/* Official Mission Badge */}
              <div className="inline-flex items-center gap-2 rounded-full border border-emerald-300/80 bg-emerald-50/90 px-3.5 py-1 text-xs font-semibold text-emerald-900 shadow-xs animate-bhm-fade-in-up">
                <span className="flex h-2 w-2 rounded-full bg-emerald-600 animate-pulse" />
                <span>SIH26131 · Government of Maharashtra</span>
              </div>

              {/* Main Headline */}
              <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl leading-[1.15] animate-bhm-fade-in-up [animation-delay:80ms]">
                Agricultural Intelligence for Ground-Level Field Decisions
              </h1>

              {/* Editorial Value Statement */}
              <p className="text-base sm:text-lg text-slate-600 leading-relaxed max-w-2xl font-normal animate-bhm-fade-in-up [animation-delay:160ms]">
                Early detection and proactive surveillance across{' '}
                <strong className="font-semibold text-slate-900">Paddy</strong>,{' '}
                <strong className="font-semibold text-slate-900">Cotton</strong>,{' '}
                <strong className="font-semibold text-slate-900">Soybean</strong>, and{' '}
                <strong className="font-semibold text-slate-900">Jowar</strong>. Detects 26 crop
                targets, resolves ambiguous symptoms with field cues, and vetoes unauthorized
                chemical sprays.
              </p>

              {/* Action Buttons */}
              <div className="flex flex-wrap items-center gap-3.5 pt-2 animate-bhm-fade-in-up [animation-delay:240ms]">
                <Link to="/login">
                  <Button
                    size="lg"
                    className="bg-[#1B5E20] hover:bg-[#14532D] text-white text-sm font-semibold h-12 px-6 rounded-xl shadow-sm gap-2 transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
                  >
                    <span>Access Portal</span>
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
                <a href="#portals">
                  <Button
                    variant="secondary"
                    size="lg"
                    className="bg-white hover:bg-slate-50 border-slate-300 text-slate-700 text-sm font-semibold h-12 px-6 rounded-xl shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
                  >
                    Explore Workspaces
                  </Button>
                </a>
              </div>

              {/* Verified Product Spec Badges */}
              <div className="pt-6 border-t border-slate-200/80 grid grid-cols-2 sm:grid-cols-4 gap-4 animate-bhm-fade-in-up [animation-delay:320ms]">
                <div className="rounded-xl p-2 transition-all duration-200 hover:bg-emerald-50/50">
                  <div className="text-xl font-bold text-slate-900">4 Crops</div>
                  <div className="text-xs text-slate-500 font-medium">Paddy, Cotton, Soy, Jowar</div>
                </div>
                <div className="rounded-xl p-2 transition-all duration-200 hover:bg-emerald-50/50">
                  <div className="text-xl font-bold text-slate-900">26 Targets</div>
                  <div className="text-xs text-slate-500 font-medium">14 Diagnosable · 12 Inspect</div>
                </div>
                <div className="rounded-xl p-2 transition-all duration-200 hover:bg-emerald-50/50">
                  <div className="text-xl font-bold text-slate-900">&lt; 3 Min</div>
                  <div className="text-xs text-slate-500 font-medium">KVK Review Target</div>
                </div>
                <div className="rounded-xl p-2 transition-all duration-200 hover:bg-emerald-50/50">
                  <div className="text-xl font-bold text-slate-900">CIB&RC</div>
                  <div className="text-xs text-slate-500 font-medium">Registered Veto Logic</div>
                </div>
              </div>
            </div>

            {/* Right Visual Composition */}
            <div className="lg:col-span-5">
              <div className="relative mx-auto max-w-md lg:max-w-none animate-bhm-fade-in-up [animation-delay:120ms]">
                {/* Elevated Agricultural Visual Card */}
                <div className="relative rounded-2xl border border-slate-200/90 bg-white p-2.5 shadow-xl shadow-slate-900/5 transition-all duration-300 hover:shadow-2xl hover:border-emerald-600/30">
                  <div className="relative aspect-[4/3] w-full overflow-hidden rounded-xl bg-slate-100">
                    <img
                      src="/images/bhoomi-agri-bg.jpg"
                      alt="Agricultural field landscape in Maharashtra"
                      className="h-full w-full object-cover object-center transition-transform duration-700 hover:scale-105"
                      loading="eager"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950/70 via-slate-950/20 to-transparent" />
                    
                    {/* Live Case Bundle Card Overlay */}
                    <div className="absolute bottom-3 left-3 right-3 rounded-lg border border-white/20 bg-white/95 backdrop-blur-md p-3 shadow-md transition-transform duration-200 hover:translate-y-[-2px]">
                      <div className="flex items-center justify-between pb-1.5 border-b border-slate-100">
                        <div className="flex items-center gap-1.5">
                          <span className="h-2 w-2 rounded-full bg-amber-500" />
                          <span className="text-[11px] font-bold uppercase tracking-wider text-slate-700">
                            Ambiguous Gate · Case #F12-Nashik
                          </span>
                        </div>
                        <span className="text-[10px] font-semibold text-emerald-800 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200/60">
                          Active Triage
                        </span>
                      </div>
                      <div className="mt-2 grid grid-cols-2 gap-2 text-xs">
                        <div className="bg-slate-50 rounded p-1.5 border border-slate-100">
                          <span className="text-[10px] text-slate-500 block">Top Hypothesis</span>
                          <span className="font-semibold text-slate-800">Paddy Blast (50%)</span>
                        </div>
                        <div className="bg-slate-50 rounded p-1.5 border border-slate-100">
                          <span className="text-[10px] text-slate-500 block">Doubt Doctor Cue</span>
                          <span className="font-semibold text-emerald-800">Underside Fuzz: Yes</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Metadata Bar below photograph */}
                  <div className="mt-2.5 flex items-center justify-between px-2 text-[11px] text-slate-500">
                    <span className="flex items-center gap-1">
                      <MapPin className="h-3 w-3 text-emerald-700" />
                      Nashik Division · Kharif Monitoring
                    </span>
                    <span className="font-medium text-slate-700">Autonomous Gate & Triage</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          3. PORTAL WORKSPACES ENTRY (AGRONOMIST & OFFICIALS)
          ============================================================ */}
      <section id="portals" className="border-t border-slate-200 bg-slate-50/60 min-h-[calc(100vh-4rem)] flex flex-col justify-center py-6 sm:py-8 lg:py-10 scroll-mt-16">
        <div className="mx-auto w-full max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <ScrollReveal>
            <div className="max-w-2xl">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
                Operational Workspaces
              </span>
              <h2 className="mt-1 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
                Two Dedicated Workspaces for Extension & Governance
              </h2>
              <p className="mt-1 text-sm sm:text-base text-slate-600 leading-relaxed">
                Dedicated operational surfaces for expert plant pathologists and district
                surveillance officers.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal delay={120}>
            <div className="mt-5 lg:mt-6 grid grid-cols-1 gap-5 lg:grid-cols-2">
              {/* Workspace 1: KVK Agronomist Portal */}
              <div className="flex flex-col justify-between rounded-2xl border border-slate-200/90 bg-white p-5 sm:p-6 shadow-xs hover:border-emerald-700/40 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 ease-out">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-800 border border-emerald-200/80">
                      <Sprout className="h-5 w-5 text-[#1B5E20]" />
                    </div>
                    <span className="rounded-full bg-emerald-50 px-2.5 py-0.5 text-[11px] font-semibold text-[#1B5E20] border border-emerald-200">
                      KVK Expert Review
                    </span>
                  </div>

                  <div>
                    <h3 className="text-lg sm:text-xl font-bold text-slate-900">
                      Agronomist Case Management Portal
                    </h3>
                    <p className="mt-0.5 text-xs text-slate-500 font-medium">
                      ICAR-Krishi Vigyan Kendra (KVK) & Extension Specialists
                    </p>
                  </div>

                  <p className="text-xs sm:text-sm text-slate-600 leading-relaxed">
                    Review pre-assembled case bundles with field photographs, growth stages, and model
                    uncertainty metrics in under three minutes.
                  </p>

                  <div className="pt-2.5 border-t border-slate-100 space-y-1.5">
                    <span className="text-xs font-semibold text-slate-700 block">
                      Supported Workflows:
                    </span>
                    <ul className="space-y-1 text-xs text-slate-600">
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                        <span>Live prioritized case queue with triage indicators</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                        <span>One-click verification (Confirm, Correct, or Request Info)</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                        <span>Inspection of Doubt Doctor physical cues & farmer notes</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                        <span>Closed-loop treatment efficacy & resolution history</span>
                      </li>
                    </ul>
                  </div>
                </div>

                <div className="mt-4 pt-3 border-t border-slate-100">
                  <Link to="/login">
                    <Button className="w-full bg-[#1B5E20] hover:bg-[#14532D] text-white font-medium text-xs h-10 gap-2 shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]">
                      <span>Open Agronomist Queue</span>
                      <ArrowRight className="h-3.5 w-3.5" />
                    </Button>
                  </Link>
                </div>
              </div>

              {/* Workspace 2: Agriculture Officials Portal */}
              <div className="flex flex-col justify-between rounded-2xl border border-slate-200/90 bg-white p-5 sm:p-6 shadow-xs hover:border-emerald-700/40 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 ease-out">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-blue-50 text-blue-800 border border-blue-200/80">
                      <Building2 className="h-5 w-5 text-blue-700" />
                    </div>
                    <span className="rounded-full bg-blue-50 px-2.5 py-0.5 text-[11px] font-semibold text-blue-800 border border-blue-200">
                      District Surveillance
                    </span>
                  </div>

                  <div>
                    <h3 className="text-lg sm:text-xl font-bold text-slate-900">
                      Agriculture Officials Surveillance Portal
                    </h3>
                    <p className="mt-0.5 text-xs text-slate-500 font-medium">
                      Department of Agriculture, Maharashtra · Surveillance Officers
                    </p>
                  </div>

                  <p className="text-xs sm:text-sm text-slate-600 leading-relaxed">
                    District-level command surface for outbreak clusters, containment approvals, and
                    real-time field model accuracy tracking.
                  </p>

                  <div className="pt-2.5 border-t border-slate-100 space-y-1.5">
                    <span className="text-xs font-semibold text-slate-700 block">
                      Supported Workflows:
                    </span>
                    <ul className="space-y-1 text-xs text-slate-600">
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                        <span>Live District Hotspot Map with cluster severity tracking</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                        <span>Official confirmation queue for containment action</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                        <span>Field accuracy analytics (confirmed vs. corrected ratios)</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                        <span>Targeted outbreak radius alert broadcasts</span>
                      </li>
                    </ul>
                  </div>
                </div>

                <div className="mt-4 pt-3 border-t border-slate-100">
                  <Link to="/login">
                    <Button
                      variant="secondary"
                      className="w-full bg-slate-900 hover:bg-slate-800 text-white font-medium text-xs h-10 gap-2 border-slate-900 shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
                    >
                      <span>Open Officials Dashboard</span>
                      <ArrowRight className="h-3.5 w-3.5" />
                    </Button>
                  </Link>
                </div>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          4. THE PRODUCT STORY / OPERATIONAL LIFECYCLE
          ============================================================ */}
      <section id="how-it-works" className="py-16 lg:py-24 border-t border-slate-200 scroll-mt-16">
        <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <ScrollReveal>
            <div className="text-center max-w-2xl mx-auto">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
                End-to-End Field Lifecycle
              </span>
              <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
                From Ground Risk Alert to Regional Surveillance
              </h2>
              <p className="mt-2 text-sm sm:text-base text-slate-600">
                A closed-loop diagnostic and surveillance lifecycle connecting farm to state.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal delay={100}>
            <div className="mt-14 relative">
              <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
                {/* Step 1 */}
                <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                        Step 01
                      </span>
                      <Clock className="h-4 w-4 text-slate-400" />
                    </div>
                    <h4 className="font-bold text-sm text-slate-900">Forward Risk Alert</h4>
                    <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                      Micro-climate alerts directing farmers where on the plant to inspect before
                      symptoms spread.
                    </p>
                  </div>
                  <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                    Non-nullable tasks
                  </div>
                </div>

                {/* Step 2 */}
                <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                        Step 02
                      </span>
                      <Sliders className="h-4 w-4 text-slate-400" />
                    </div>
                    <h4 className="font-bold text-sm text-slate-900">Confidence Gate</h4>
                    <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                      Three-band evaluation prompting for a physical cue when symptoms are ambiguous
                      rather than guessing.
                    </p>
                  </div>
                  <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                    Uncertainty as feature
                  </div>
                </div>

                {/* Step 3 */}
                <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                        Step 03
                      </span>
                      <ShieldCheck className="h-4 w-4 text-slate-400" />
                    </div>
                    <h4 className="font-bold text-sm text-slate-900">Pesticide Veto</h4>
                    <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                      OCR bottle verification against CIB&RC records to veto unapproved chemicals
                      before spraying.
                    </p>
                  </div>
                  <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                    Veto, never endorse
                  </div>
                </div>

                {/* Step 4 */}
                <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                        Step 04
                      </span>
                      <Sprout className="h-4 w-4 text-slate-400" />
                    </div>
                    <h4 className="font-bold text-sm text-slate-900">KVK Expert Triage</h4>
                    <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                      Escalated case bundles reviewed and confirmed by certified agronomists in
                      under 3 minutes.
                    </p>
                  </div>
                  <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                    Human-in-the-loop
                  </div>
                </div>

                {/* Step 5 */}
                <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                        Step 05
                      </span>
                      <Activity className="h-4 w-4 text-slate-400" />
                    </div>
                    <h4 className="font-bold text-sm text-slate-900">State Surveillance</h4>
                    <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                      Verified diagnoses update district hotspot maps and broadcast regional
                      containment alerts.
                    </p>
                  </div>
                  <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                    Epidemic prevention
                  </div>
                </div>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          5. CORE CAPABILITIES (EDITORIAL GRID)
          ============================================================ */}
      <section id="capabilities" className="py-16 lg:py-24 bg-slate-50/60 border-t border-slate-200 scroll-mt-16">
        <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <ScrollReveal>
            <div className="max-w-2xl">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
                PRD-Enforced Specifications
              </span>
              <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
                Engineered Against the Confident Wrong Answer
              </h2>
              <p className="mt-2 text-sm sm:text-base text-slate-600">
                Preventing incorrect AI predictions that cause crop loss and chemical over-spraying.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal delay={100}>
            <div className="mt-12 grid grid-cols-1 md:grid-cols-12 gap-6">
              {/* Feature 1: The Confidence Gate & Doubt Doctor (Wide 8-col) */}
              <div className="md:col-span-8 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <div>
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                    <Sliders className="h-4 w-4 text-emerald-700" />
                    <span>F2 & F4 · Autonomous Confidence Gate</span>
                  </div>
                  <h3 className="mt-3 text-xl font-bold text-slate-900">
                    Three-Band Gate & The Doubt Doctor
                  </h3>
                  <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                    Predictions pass through strict mathematical thresholds. Ambiguous cases activate
                    the Doubt Doctor to verify physical cues rather than guessing.
                  </p>

                  <div className="mt-6 grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
                    <div className="rounded-lg bg-emerald-50/80 border border-emerald-200/70 p-3 transition-colors hover:bg-emerald-50">
                      <span className="font-bold text-emerald-900 block">Above Gate (≥ 0.70)</span>
                      <span className="text-emerald-800 text-[11px] mt-0.5 block">
                        Direct IPM advisory composed
                      </span>
                    </div>
                    <div className="rounded-lg bg-amber-50/80 border border-amber-200/70 p-3 transition-colors hover:bg-amber-50">
                      <span className="font-bold text-amber-900 block">Ambiguous (0.45 - 0.70)</span>
                      <span className="text-amber-800 text-[11px] mt-0.5 block">
                        Doubt Doctor clarifying question
                      </span>
                    </div>
                    <div className="rounded-lg bg-red-50/80 border border-red-200/70 p-3 transition-colors hover:bg-red-50">
                      <span className="font-bold text-red-900 block">Below Floor (&lt; 0.45)</span>
                      <span className="text-red-800 text-[11px] mt-0.5 block">
                        Direct KVK agronomist escalation
                      </span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500 font-medium">
                  <span>Enforced before advisory generation</span>
                  <span className="text-slate-800 font-semibold">Zero hallucinated advice</span>
                </div>
              </div>

              {/* Feature 2: Chemical Last & Label Check (Compact 4-col) */}
              <div className="md:col-span-4 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <div>
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                    <ShieldCheck className="h-4 w-4 text-emerald-700" />
                    <span>F7 & F8 · Pesticide Safety</span>
                  </div>
                  <h3 className="mt-3 text-xl font-bold text-slate-900">
                    Veto, Never Endorse
                  </h3>
                  <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                    Enforces Cultural → Biological → Chemical hierarchy. OCR bottle scans verify CIB&RC
                    registration to veto unapproved chemicals before spraying.
                  </p>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
                  <span>The printed label remains the sole dosage authority.</span>
                </div>
              </div>

              {/* Feature 3: Persistent Farm Memory (Compact 4-col) */}
              <div className="md:col-span-4 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <div>
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                    <Database className="h-4 w-4 text-emerald-700" />
                    <span>F1 · Farm Persistent Memory</span>
                  </div>
                  <h3 className="mt-3 text-xl font-bold text-slate-900">
                    The Farm as a Clinical Case File
                  </h3>
                  <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                    Maintains longitudinal soil, variety, and infestation history as an active Bayesian
                    risk prior across growing seasons.
                  </p>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
                  <span>Mandatory geolocation for spatial containment</span>
                </div>
              </div>

              {/* Feature 4: Outbreak Hotspots & Macro Surveillance (Wide 8-col) */}
              <div className="md:col-span-8 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <div>
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                    <Activity className="h-4 w-4 text-emerald-700" />
                    <span>F6 & F15 · Regional Surveillance</span>
                  </div>
                  <h3 className="mt-3 text-xl font-bold text-slate-900">
                    District Outbreak Hotspots & Spread Radius
                  </h3>
                  <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                    Only verified diagnoses propagate radius alerts to nearby farms. Officials
                    monitor active clusters with live outbreak counts and accuracy tracking.
                  </p>

                  <div className="mt-6 flex flex-wrap items-center gap-4 text-xs font-medium text-slate-700">
                    <div className="flex items-center gap-1.5">
                      <span className="h-2.5 w-2.5 rounded-full bg-red-600" />
                      <span>High Severity Hotspots</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <span className="h-2.5 w-2.5 rounded-full bg-amber-500" />
                      <span>Active Confirmation Queue</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <span className="h-2.5 w-2.5 rounded-full bg-emerald-600" />
                      <span>Field Accuracy Tracking</span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500 font-medium">
                  <span>Prevents village-wide false panic</span>
                  <span className="text-slate-800 font-semibold">Verified ground truth only</span>
                </div>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          6. ENGINEERING & DESIGN PRINCIPLES
          ============================================================ */}
      <section id="principles" className="py-16 lg:py-24 border-t border-slate-200 scroll-mt-16">
        <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <ScrollReveal>
            <div className="max-w-2xl">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
                Architectural Guardrails
              </span>
              <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
                Non-Negotiable Product Principles
              </h2>
              <p className="mt-2 text-sm sm:text-base text-slate-600">
                Enforced directly in code and verified by automated testing.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal delay={100}>
            <div className="mt-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 01
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Never Fabricate</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  No retrieval above threshold means zero advice. The system explicitly states what it
                  does not know.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 02
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Uncertainty as a Feature</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  When ambiguous, the farmer sees candidate diagnoses and answers one physical
                  discriminating cue.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 03
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Veto, Never Endorse</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  The system may veto an unapproved chemical, but never endorses chemical safety. The
                  label remains the sole authority.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 04
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Chemical Last, Structurally</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  The action hierarchy is cultural → biological → chemical as enforced schema, never
                  leading with a pesticide.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 05
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Every Alert Carries a Task</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Alerts always specify actionable inspection tasks with required outcome recording.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-0.5 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 06
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">The Farm is a Case File</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Persistent multi-season history provides the clinical context required for
                  rapid expert triage.
                </p>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          7. FINAL CALL TO ACTION
          ============================================================ */}
      <section className="border-t border-slate-200 bg-slate-900 text-white py-16 lg:py-20">
        <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8 text-center space-y-6">
          <ScrollReveal>
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-950/60 px-3.5 py-1 text-xs font-semibold text-emerald-300">
              <span>BHOOMI Operations Portal Access</span>
            </div>

            <h2 className="mt-4 text-3xl font-extrabold tracking-tight sm:text-4xl">
              Ready to Access the BHOOMI Portal?
            </h2>

            <p className="mt-3 text-sm sm:text-base text-slate-300 max-w-xl mx-auto leading-relaxed">
              Secure entry point for ICAR-KVK Agronomists and Maharashtra Agriculture Surveillance
              Officers.
            </p>

            <div className="mt-6 flex flex-wrap items-center justify-center gap-3.5">
              <Link to="/login">
                <Button
                  size="lg"
                  className="bg-[#2E7D32] hover:bg-[#1B5E20] text-white font-semibold text-sm h-12 px-8 rounded-xl shadow-md gap-2 transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-lg active:translate-y-0 active:scale-[0.98]"
                >
                  <span>Sign In to Workspace</span>
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
            </div>

            <p className="text-xs text-slate-400 pt-3">
              Supports official credentials and demo instant access for authorized roles.
            </p>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          8. FOOTER
          ============================================================ */}
      <footer className="border-t border-slate-800 bg-slate-950 py-12 text-slate-400 text-xs">
        <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
            {/* Brand in footer */}
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-white/95 p-1 shadow-xs ring-1 ring-white/20">
                <img
                  src="/icons/bhoomi-logo.png"
                  alt="BHOOMI Logo"
                  className="h-7 w-7 object-contain"
                />
              </div>
              <div>
                <span className="font-bold text-sm text-slate-200 block">BHOOMI Portal</span>
                <span className="text-[11px] text-slate-500 block">
                  Agronomist Case Management & Officials Surveillance
                </span>
              </div>
            </div>

            {/* Quick anchors */}
            <div className="flex flex-wrap items-center gap-6 text-slate-400">
              <a href="#overview" className="hover:text-white transition-colors">
                Overview
              </a>
              <a href="#how-it-works" className="hover:text-white transition-colors">
                Lifecycle
              </a>
              <a href="#portals" className="hover:text-white transition-colors">
                Workspaces
              </a>
              <a href="#capabilities" className="hover:text-white transition-colors">
                Capabilities
              </a>
              <a href="#principles" className="hover:text-white transition-colors">
                Principles
              </a>
              <Link to="/login" className="text-emerald-400 hover:text-emerald-300 transition-colors">
                Portal Login
              </Link>
            </div>
          </div>

          <div className="mt-8 pt-6 border-t border-slate-900 flex flex-col sm:flex-row items-center justify-between gap-3 text-slate-500 text-[11px]">
            <div>Government of Maharashtra · Smart India Hackathon PS SIH26131</div>
            <div>Built for ICAR-KVKs, district surveillance teams, and agricultural extension offices.</div>
          </div>
        </div>
      </footer>
    </div>
  );
}
