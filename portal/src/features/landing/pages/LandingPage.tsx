import { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Sprout,
  ArrowRight,
  ChevronRight,
  MapPin,
  CheckCircle2,
  Menu,
  X,
  Building2,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { ScrollReveal } from '../components/ScrollReveal';
import { HowItWorksWorkflow } from '../components/HowItWorksWorkflow';

export function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#FDFEFC] text-slate-900 selection:bg-emerald-100 selection:text-emerald-900 font-sans antialiased overflow-x-hidden">
      {/* ============================================================
          1. HEADER NAVIGATION
          ============================================================ */}
      <header className="sticky top-0 z-50 w-full border-b border-slate-200/80 bg-white/90 backdrop-blur-md transition-all">
        <div className="mx-auto flex h-16 max-w-7xl xl:max-w-[1440px] items-center justify-between px-4 sm:px-6 lg:px-8">
          {/* Brand Identity */}
          <Link to="/" className="flex items-center gap-3 group focus:outline-none">
            <img
              src="/icons/bhoomi-logo.png"
              alt="BHOOMI Logo"
              className="h-10 w-10 shrink-0 object-contain drop-shadow-xs transition-transform duration-300 ease-out group-hover:scale-105"
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
          <nav className="hidden md:flex items-center gap-1 lg:gap-2 text-sm font-medium text-slate-600">
            <a
              href="#overview"
              className="px-3 py-1.5 rounded-lg hover:text-emerald-800 hover:bg-emerald-50/70 transition-all duration-200"
            >
              Overview
            </a>
            <a
              href="#portals"
              className="px-3 py-1.5 rounded-lg hover:text-emerald-800 hover:bg-emerald-50/70 transition-all duration-200"
            >
              Workspaces
            </a>
            <a
              href="#how-it-works"
              className="px-3 py-1.5 rounded-lg hover:text-emerald-800 hover:bg-emerald-50/70 transition-all duration-200"
            >
              How It Works
            </a>
            <a
              href="#principles"
              className="px-3 py-1.5 rounded-lg hover:text-emerald-800 hover:bg-emerald-50/70 transition-all duration-200"
            >
              Principles
            </a>
          </nav>

          {/* Desktop CTA Action */}
          <div className="hidden md:flex items-center gap-3">
            <Link to="/login">
              <Button
                variant="outline"
                size="sm"
                className="font-medium text-xs text-slate-700 hover:text-emerald-900 hover:border-emerald-300 border-slate-300 transition-all duration-200 ease-out hover:-translate-y-0.5 active:translate-y-0 active:scale-[0.98]"
              >
                Sign In
              </Button>
            </Link>
            <Link to="/login">
              <Button
                size="sm"
                className="group bg-[#1B5E20] hover:bg-[#14532D] text-white font-medium text-xs gap-1.5 shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
              >
                <span>Access Portal</span>
                <ChevronRight className="h-3.5 w-3.5 transition-transform duration-200 group-hover:translate-x-0.5" />
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
          <div className="border-b border-slate-200 bg-white/95 backdrop-blur-md px-4 py-4 md:hidden animate-bhm-fade-in space-y-3">
            <nav className="flex flex-col space-y-1 text-sm font-medium text-slate-700">
              <a
                href="#overview"
                onClick={() => setMobileMenuOpen(false)}
                className="px-3 py-2 rounded-lg hover:bg-emerald-50 hover:text-emerald-800 transition-colors"
              >
                Overview
              </a>
              <a
                href="#portals"
                onClick={() => setMobileMenuOpen(false)}
                className="px-3 py-2 rounded-lg hover:bg-emerald-50 hover:text-emerald-800 transition-colors"
              >
                Workspaces
              </a>
              <a
                href="#how-it-works"
                onClick={() => setMobileMenuOpen(false)}
                className="px-3 py-2 rounded-lg hover:bg-emerald-50 hover:text-emerald-800 transition-colors"
              >
                How It Works
              </a>
              <a
                href="#principles"
                onClick={() => setMobileMenuOpen(false)}
                className="px-3 py-2 rounded-lg hover:bg-emerald-50 hover:text-emerald-800 transition-colors"
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
      <section id="overview" className="relative overflow-hidden min-h-[calc(100vh-4rem)] flex items-center py-10 lg:py-16 scroll-mt-16">
        {/* Subtle background natural contour atmosphere */}
        <div className="absolute inset-0 bg-gradient-to-b from-emerald-50/50 via-white/50 to-transparent pointer-events-none" />
        <div className="absolute right-0 top-0 -mt-20 -mr-20 h-96 w-96 rounded-full bg-emerald-100/40 blur-3xl pointer-events-none" />
        <div className="absolute left-0 bottom-0 -mb-20 -ml-20 h-80 w-80 rounded-full bg-emerald-50/60 blur-3xl pointer-events-none" />

        <div className="relative mx-auto w-full max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 gap-12 lg:grid-cols-12 lg:gap-8 items-center">
            {/* Left Content Column */}
            <div className="lg:col-span-7 space-y-6">
              {/* Official Mission Badge (Hero Stagger 1) */}
              <div className="inline-flex items-center gap-2 rounded-full border border-emerald-300/80 bg-emerald-50/90 px-3.5 py-1 text-xs font-semibold text-emerald-900 shadow-xs animate-bhm-hero-badge">
                <span className="flex h-2 w-2 rounded-full bg-emerald-600 animate-pulse" />
                <span>SIH26131 · Government of Maharashtra</span>
              </div>

              {/* Main Headline (Hero Stagger 2) */}
              <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl leading-[1.15] animate-bhm-hero-heading">
                Agricultural Intelligence for Ground-Level Field Decisions
              </h1>

              {/* Editorial Value Statement (Hero Stagger 3) */}
              <p className="text-base sm:text-lg text-slate-600 leading-relaxed max-w-2xl font-normal animate-bhm-hero-subheading">
                Early detection and proactive surveillance across{' '}
                <strong className="font-semibold text-slate-900">Paddy</strong>,{' '}
                <strong className="font-semibold text-slate-900">Cotton</strong>,{' '}
                <strong className="font-semibold text-slate-900">Soybean</strong>, and{' '}
                <strong className="font-semibold text-slate-900">Jowar</strong>. Resolves ambiguous
                symptoms with field cues and vetoes unauthorized sprays.
              </p>

              {/* Action Buttons (Hero Stagger 4) */}
              <div className="flex flex-wrap items-center gap-3.5 pt-2 animate-bhm-hero-cta">
                <Link to="/login">
                  <Button
                    size="lg"
                    className="group bg-[#1B5E20] hover:bg-[#14532D] text-white text-sm font-semibold h-12 px-6 rounded-xl shadow-sm gap-2 transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
                  >
                    <span>Access Portal</span>
                    <ArrowRight className="h-4 w-4 transition-transform duration-200 group-hover:translate-x-1" />
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

              {/* Verified Product Spec Badges (Hero Stagger 5) */}
              <div className="pt-6 border-t border-slate-200/80 grid grid-cols-2 sm:grid-cols-4 gap-3.5 animate-bhm-hero-metrics">
                <div className="rounded-xl border border-slate-200/60 bg-white/60 p-3 backdrop-blur-xs transition-all duration-200 hover:bg-emerald-50/60 hover:border-emerald-200 hover:-translate-y-0.5">
                  <div className="text-xl font-bold text-slate-900">4 Crops</div>
                  <div className="text-xs text-slate-500 font-medium">Paddy, Cotton, Soy, Jowar</div>
                </div>
                <div className="rounded-xl border border-slate-200/60 bg-white/60 p-3 backdrop-blur-xs transition-all duration-200 hover:bg-emerald-50/60 hover:border-emerald-200 hover:-translate-y-0.5">
                  <div className="text-xl font-bold text-slate-900">26 Targets</div>
                  <div className="text-xs text-slate-500 font-medium">14 Diagnosable · 12 Inspect</div>
                </div>
                <div className="rounded-xl border border-slate-200/60 bg-white/60 p-3 backdrop-blur-xs transition-all duration-200 hover:bg-emerald-50/60 hover:border-emerald-200 hover:-translate-y-0.5">
                  <div className="text-xl font-bold text-slate-900">&lt; 3 Min</div>
                  <div className="text-xs text-slate-500 font-medium">KVK Review Target</div>
                </div>
                <div className="rounded-xl border border-slate-200/60 bg-white/60 p-3 backdrop-blur-xs transition-all duration-200 hover:bg-emerald-50/60 hover:border-emerald-200 hover:-translate-y-0.5">
                  <div className="text-xl font-bold text-slate-900">CIB&RC</div>
                  <div className="text-xs text-slate-500 font-medium">Registered Veto Logic</div>
                </div>
              </div>
            </div>

            {/* Right Visual Composition (Hero Stagger 6) */}
            <div className="lg:col-span-5">
              <div className="relative mx-auto max-w-md lg:max-w-none animate-bhm-hero-visual">
                {/* Elevated Agricultural Visual Card */}
                <div className="relative rounded-2xl border border-slate-200/90 bg-white p-2.5 shadow-xl shadow-slate-900/5 transition-all duration-300 hover:shadow-2xl hover:border-emerald-600/30">
                  <div className="relative aspect-[4/3] w-full overflow-hidden rounded-xl bg-slate-100">
                    <img
                      src="/images/bhoomi-agri-bg.jpg"
                      alt="Agricultural field landscape in Maharashtra"
                      className="h-full w-full object-cover object-center transition-transform duration-700 hover:scale-105"
                      loading="eager"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950/70 via-slate-950/20 to-transparent pointer-events-none" />
                    
                    {/* Live Case Bundle Card Overlay */}
                    <div className="absolute bottom-3 left-3 right-3 rounded-lg border border-white/20 bg-white/95 backdrop-blur-md p-3 shadow-md transition-transform duration-200 hover:translate-y-[-2px]">
                      <div className="flex items-center justify-between pb-1.5 border-b border-slate-100">
                        <div className="flex items-center gap-1.5">
                          <span className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
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
      <section id="portals" className="border-t border-slate-200 bg-slate-50/60 min-h-[calc(100vh-4rem)] flex flex-col justify-center py-12 lg:py-16 scroll-mt-16">
        <div className="mx-auto w-full max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <ScrollReveal>
            <div className="text-center max-w-2xl mx-auto">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
                Operational Workspaces
              </span>
              <h2 className="mt-1.5 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
                Two Dedicated Workspaces for Extension & Governance
              </h2>
              <p className="mt-2 text-sm sm:text-base text-slate-600 leading-relaxed">
                Dedicated operational surfaces for expert plant pathologists and district
                surveillance officers.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal delay={120}>
            <div className="mt-8 lg:mt-10 grid grid-cols-1 gap-6 lg:grid-cols-2">
              {/* Workspace 1: KVK Agronomist Portal */}
              <div className="flex flex-col justify-between rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-7 shadow-xs hover:border-emerald-700/40 hover:shadow-lg hover:-translate-y-1 transition-all duration-200 ease-out">
                <div className="space-y-3.5">
                  <div className="flex items-center justify-between">
                    <div className="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-50 text-emerald-800 border border-emerald-200/80">
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
                    Review case bundles with field photos, growth stages, and model uncertainty in
                    under 3 minutes.
                  </p>

                  <div className="pt-3 border-t border-slate-100 space-y-2">
                    <span className="text-xs font-semibold text-slate-700 block">
                      Supported Workflows:
                    </span>
                    <ul className="space-y-1.5 text-xs text-slate-600">
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
                        <span>Live prioritized case queue with triage indicators</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
                        <span>One-click verification (Confirm, Correct, Request Info)</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
                        <span>Doubt Doctor physical cues & farmer notes inspection</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
                        <span>Treatment efficacy & resolution history tracking</span>
                      </li>
                    </ul>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100">
                  <Link to="/login">
                    <Button className="group w-full bg-[#1B5E20] hover:bg-[#14532D] text-white font-medium text-xs h-10 gap-2 shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]">
                      <span>Open Agronomist Queue</span>
                      <ArrowRight className="h-3.5 w-3.5 transition-transform duration-200 group-hover:translate-x-1" />
                    </Button>
                  </Link>
                </div>
              </div>

              {/* Workspace 2: Agriculture Officials Portal */}
              <div className="flex flex-col justify-between rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-7 shadow-xs hover:border-emerald-700/40 hover:shadow-lg hover:-translate-y-1 transition-all duration-200 ease-out">
                <div className="space-y-3.5">
                  <div className="flex items-center justify-between">
                    <div className="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-800 border border-blue-200/80">
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
                    District command for outbreak clusters, containment approvals, and real-time
                    accuracy tracking.
                  </p>

                  <div className="pt-3 border-t border-slate-100 space-y-2">
                    <span className="text-xs font-semibold text-slate-700 block">
                      Supported Workflows:
                    </span>
                    <ul className="space-y-1.5 text-xs text-slate-600">
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-blue-600 shrink-0" />
                        <span>Live District Hotspot Map with severity tracking</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-blue-600 shrink-0" />
                        <span>Official confirmation queue for containment action</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-blue-600 shrink-0" />
                        <span>Field accuracy analytics (confirmed vs. corrected)</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-blue-600 shrink-0" />
                        <span>Targeted outbreak radius alert broadcasts</span>
                      </li>
                    </ul>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100">
                  <Link to="/login">
                    <Button
                      variant="secondary"
                      className="group w-full bg-slate-900 hover:bg-slate-800 text-white font-medium text-xs h-10 gap-2 border-slate-900 shadow-xs transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md active:translate-y-0 active:scale-[0.98]"
                    >
                      <span>Open Officials Dashboard</span>
                      <ArrowRight className="h-3.5 w-3.5 transition-transform duration-200 group-hover:translate-x-1" />
                    </Button>
                  </Link>
                </div>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          4. HOW BHOOMI WORKS (UNIFIED PROJECT ROADMAP & WORKFLOW)
          ============================================================ */}
      <HowItWorksWorkflow />

      {/* ============================================================
          6. ENGINEERING & DESIGN PRINCIPLES
          ============================================================ */}
      <section id="principles" className="py-16 lg:py-24 border-t border-slate-200 scroll-mt-16">
        <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
          <ScrollReveal>
            <div className="text-center max-w-2xl mx-auto">
              <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
                Architectural Guardrails
              </span>
              <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
                Non-Negotiable Product Principles
              </h2>
              <p className="mt-2 text-sm sm:text-base text-slate-600 leading-relaxed">
                Enforced directly in code and verified by automated testing.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal delay={100}>
            <div className="mt-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-1 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 01
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Never Fabricate</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Zero advice below threshold. The system explicitly states what it does not know.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-1 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 02
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Uncertainty as a Feature</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  When ambiguous, the farmer inspects one physical discriminating cue.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-1 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 03
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Veto, Never Endorse</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Vetoes unapproved chemicals without endorsing safety. The label is the sole
                  authority.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-1 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 04
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Chemical Last, Structurally</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Hierarchy is cultural → biological → chemical, never leading with pesticides.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-1 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 05
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">Every Alert Carries a Task</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Alerts specify actionable inspection tasks with mandatory outcome recording.
                </p>
              </div>

              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs hover:-translate-y-1 hover:shadow-md hover:border-emerald-600/30 transition-all duration-200 ease-out">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                  Principle 06
                </span>
                <h4 className="mt-2 text-base font-bold text-slate-900">The Farm is a Case File</h4>
                <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                  Persistent multi-season history provides clinical context for rapid expert triage.
                </p>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* ============================================================
          7. FINAL CALL TO ACTION
          ============================================================ */}
      <section className="border-t border-slate-200 bg-slate-900 text-white py-16 lg:py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-radial from-emerald-950/40 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8 text-center space-y-6">
          <ScrollReveal>
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-950/60 px-3.5 py-1 text-xs font-semibold text-emerald-300 shadow-xs">
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
                  className="group bg-[#2E7D32] hover:bg-[#1B5E20] text-white font-semibold text-sm h-12 px-8 rounded-xl shadow-md gap-2 transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-lg active:translate-y-0 active:scale-[0.98]"
                >
                  <span>Sign In to Workspace</span>
                  <ArrowRight className="h-4 w-4 transition-transform duration-200 group-hover:translate-x-1" />
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
            <div className="flex flex-wrap items-center gap-4 sm:gap-6 text-slate-400">
              <a href="#overview" className="hover:text-white transition-colors duration-200">
                Overview
              </a>
              <a href="#portals" className="hover:text-white transition-colors duration-200">
                Workspaces
              </a>
              <a href="#how-it-works" className="hover:text-white transition-colors duration-200">
                Lifecycle
              </a>
              <a href="#capabilities" className="hover:text-white transition-colors duration-200">
                Capabilities
              </a>
              <a href="#principles" className="hover:text-white transition-colors duration-200">
                Principles
              </a>
              <Link to="/login" className="text-emerald-400 hover:text-emerald-300 transition-colors duration-200">
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

