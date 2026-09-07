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

export function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#FDFEFC] text-slate-900 selection:bg-emerald-100 selection:text-emerald-900 font-sans antialiased">
      {/* ============================================================
          1. HEADER NAVIGATION
          ============================================================ */}
      <header className="sticky top-0 z-50 w-full border-b border-slate-200/80 bg-white/95 backdrop-blur-md transition-all">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
          {/* Brand Identity */}
          <Link to="/" className="flex items-center gap-3 group focus:outline-none">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#1B5E20] text-white shadow-xs transition-transform group-hover:scale-105">
              <Sprout className="h-6 w-6" />
            </div>
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
            <a href="#overview" className="hover:text-emerald-800 transition-colors">
              Platform Overview
            </a>
            <a href="#how-it-works" className="hover:text-emerald-800 transition-colors">
              Field Lifecycle
            </a>
            <a href="#portals" className="hover:text-emerald-800 transition-colors">
              Workspaces
            </a>
            <a href="#capabilities" className="hover:text-emerald-800 transition-colors">
              Core Capabilities
            </a>
            <a href="#principles" className="hover:text-emerald-800 transition-colors">
              Engineering Principles
            </a>
          </nav>

          {/* Desktop CTA Action */}
          <div className="hidden md:flex items-center gap-3">
            <Link to="/login">
              <Button
                variant="outline"
                size="sm"
                className="font-medium text-xs text-slate-700 hover:text-emerald-900 border-slate-300"
              >
                Sign In
              </Button>
            </Link>
            <Link to="/login">
              <Button
                size="sm"
                className="bg-[#1B5E20] hover:bg-[#14532D] text-white font-medium text-xs gap-1.5 shadow-xs"
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
              className="p-2 text-slate-600 hover:text-slate-900 focus:outline-none"
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
                className="py-1 hover:text-emerald-800"
              >
                Platform Overview
              </a>
              <a
                href="#how-it-works"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800"
              >
                Field Lifecycle
              </a>
              <a
                href="#portals"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800"
              >
                Workspaces
              </a>
              <a
                href="#capabilities"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800"
              >
                Core Capabilities
              </a>
              <a
                href="#principles"
                onClick={() => setMobileMenuOpen(false)}
                className="py-1 hover:text-emerald-800"
              >
                Engineering Principles
              </a>
            </nav>
            <div className="pt-2 border-t border-slate-100 flex flex-col gap-2">
              <Link to="/login" onClick={() => setMobileMenuOpen(false)}>
                <Button className="w-full bg-[#1B5E20] hover:bg-[#14532D] text-white text-xs">
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
      <section id="overview" className="relative overflow-hidden pt-12 pb-16 lg:pt-20 lg:pb-24">
        {/* Subtle background natural contour atmosphere */}
        <div className="absolute inset-0 bg-gradient-to-b from-emerald-50/40 via-transparent to-transparent pointer-events-none" />
        <div className="absolute right-0 top-0 -mt-20 -mr-20 h-96 w-96 rounded-full bg-emerald-100/30 blur-3xl pointer-events-none" />

        <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 gap-12 lg:grid-cols-12 lg:gap-8 items-center">
            {/* Left Content Column */}
            <div className="lg:col-span-7 space-y-6">
              {/* Official Mission Badge */}
              <div className="inline-flex items-center gap-2 rounded-full border border-emerald-300/80 bg-emerald-50/90 px-3.5 py-1 text-xs font-semibold text-emerald-900 shadow-xs">
                <span className="flex h-2 w-2 rounded-full bg-emerald-600 animate-pulse" />
                <span>SIH26131 · Government of Maharashtra</span>
              </div>

              {/* Main Headline */}
              <h1 className="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl leading-[1.15]">
                Agricultural Intelligence for Ground-Level Field Decisions
              </h1>

              {/* Editorial Value Statement */}
              <p className="text-base sm:text-lg text-slate-600 leading-relaxed max-w-2xl font-normal">
                Early detection and proactive surveillance of 26 crop diseases and pest infestations
                across <strong className="font-semibold text-slate-900">Paddy</strong>,{' '}
                <strong className="font-semibold text-slate-900">Cotton</strong>,{' '}
                <strong className="font-semibold text-slate-900">Soybean</strong>, and{' '}
                <strong className="font-semibold text-slate-900">Jowar</strong>. Built on a strict
                principle: admitting uncertainty when torn, asking clarifying field cues, and
                vetoing wrong pesticides before application.
              </p>

              {/* Action Buttons */}
              <div className="flex flex-wrap items-center gap-3.5 pt-2">
                <Link to="/login">
                  <Button
                    size="lg"
                    className="bg-[#1B5E20] hover:bg-[#14532D] text-white text-sm font-semibold h-12 px-6 rounded-xl shadow-sm gap-2"
                  >
                    <span>Access Portal</span>
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
                <a href="#portals">
                  <Button
                    variant="secondary"
                    size="lg"
                    className="bg-white hover:bg-slate-50 border-slate-300 text-slate-700 text-sm font-semibold h-12 px-6 rounded-xl shadow-xs"
                  >
                    Explore Workspaces
                  </Button>
                </a>
              </div>

              {/* Verified Product Spec Badges */}
              <div className="pt-6 border-t border-slate-200/80 grid grid-cols-2 sm:grid-cols-4 gap-4">
                <div>
                  <div className="text-xl font-bold text-slate-900">4 Crops</div>
                  <div className="text-xs text-slate-500 font-medium">Paddy, Cotton, Soy, Jowar</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900">26 Targets</div>
                  <div className="text-xs text-slate-500 font-medium">14 Diagnosable · 12 Inspect</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900">&lt; 3 Min</div>
                  <div className="text-xs text-slate-500 font-medium">KVK Review Target</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900">CIB&RC</div>
                  <div className="text-xs text-slate-500 font-medium">Registered Veto Logic</div>
                </div>
              </div>
            </div>

            {/* Right Visual Composition */}
            <div className="lg:col-span-5">
              <div className="relative mx-auto max-w-md lg:max-w-none">
                {/* Elevated Agricultural Visual Card */}
                <div className="relative rounded-2xl border border-slate-200/90 bg-white p-2.5 shadow-xl shadow-slate-900/5">
                  <div className="relative aspect-[4/3] w-full overflow-hidden rounded-xl bg-slate-100">
                    <img
                      src="/images/bhoomi-agri-bg.jpg"
                      alt="Agricultural field landscape in Maharashtra"
                      className="h-full w-full object-cover object-center"
                      loading="eager"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950/70 via-slate-950/20 to-transparent" />
                    
                    {/* Live Case Bundle Card Overlay */}
                    <div className="absolute bottom-3 left-3 right-3 rounded-lg border border-white/20 bg-white/95 backdrop-blur-md p-3 shadow-md">
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
      <section id="portals" className="border-t border-slate-200 bg-slate-50/60 py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl">
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
              Operational Workspaces
            </span>
            <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
              Two Dedicated Workspaces for Extension & Governance
            </h2>
            <p className="mt-3 text-sm sm:text-base text-slate-600 leading-relaxed">
              BHOOMI separates high-speed case triage from macro surveillance, providing custom
              surfaces tailored to the specific responsibilities of plant pathologists and
              agriculture officials.
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 gap-8 lg:grid-cols-2">
            {/* Workspace 1: KVK Agronomist Portal */}
            <div className="flex flex-col justify-between rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs hover:border-emerald-700/40 hover:shadow-md transition-all">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-emerald-50 text-emerald-800 border border-emerald-200/80">
                    <Sprout className="h-6 w-6 text-[#1B5E20]" />
                  </div>
                  <span className="rounded-full bg-emerald-50 px-3 py-1 text-[11px] font-semibold text-[#1B5E20] border border-emerald-200">
                    KVK Expert Review
                  </span>
                </div>

                <div>
                  <h3 className="text-xl font-bold text-slate-900">
                    Agronomist Case Management Portal
                  </h3>
                  <p className="mt-1 text-xs text-slate-500 font-medium">
                    ICAR-Krishi Vigyan Kendra (KVK) & Extension Specialists
                  </p>
                </div>

                <p className="text-sm text-slate-600 leading-relaxed">
                  Engineered to protect expert time. Escalated cases arrive pre-assembled with
                  photographic evidence, growth stage, historical weather risk, and model
                  uncertainty breakdowns, enabling confident review in under three minutes.
                </p>

                <div className="pt-3 border-t border-slate-100 space-y-2">
                  <span className="text-xs font-semibold text-slate-700 block">
                    Supported Workflows:
                  </span>
                  <ul className="space-y-1.5 text-xs text-slate-600">
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                      <span>Live Case Queue with priority indicators & triage statuses</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                      <span>One-click Diagnosis Verification (Confirm / Correct / Request Info)</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                      <span>Inspection of Doubt Doctor field cues & farmer observations</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                      <span>Closed-loop Treatment Efficacy & resolved case history</span>
                    </li>
                  </ul>
                </div>
              </div>

              <div className="mt-8 pt-4 border-t border-slate-100">
                <Link to="/login">
                  <Button className="w-full bg-[#1B5E20] hover:bg-[#14532D] text-white font-medium text-xs h-10 gap-2 shadow-xs">
                    <span>Open Agronomist Queue</span>
                    <ArrowRight className="h-3.5 w-3.5" />
                  </Button>
                </Link>
              </div>
            </div>

            {/* Workspace 2: Agriculture Officials Portal */}
            <div className="flex flex-col justify-between rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs hover:border-emerald-700/40 hover:shadow-md transition-all">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-blue-50 text-blue-800 border border-blue-200/80">
                    <Building2 className="h-6 w-6 text-blue-700" />
                  </div>
                  <span className="rounded-full bg-blue-50 px-3 py-1 text-[11px] font-semibold text-blue-800 border border-blue-200">
                    District Surveillance
                  </span>
                </div>

                <div>
                  <h3 className="text-xl font-bold text-slate-900">
                    Agriculture Officials Surveillance Portal
                  </h3>
                  <p className="mt-1 text-xs text-slate-500 font-medium">
                    Department of Agriculture, Maharashtra · Surveillance Officers
                  </p>
                </div>

                <p className="text-sm text-slate-600 leading-relaxed">
                  A high-level command surface providing district and taluka-level outbreak
                  monitoring, epidemic hotspot tracking, and real-time field model accuracy metrics
                  across all four supported crops.
                </p>

                <div className="pt-3 border-t border-slate-100 space-y-2">
                  <span className="text-xs font-semibold text-slate-700 block">
                    Supported Workflows:
                  </span>
                  <ul className="space-y-1.5 text-xs text-slate-600">
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                      <span>Live District Hotspot Map with epidemic clustering & severity levels</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                      <span>Official Confirmation Queue for containment approvals</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                      <span>Model Field Accuracy Analytics (confirmed vs. corrected ratios)</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 shrink-0" />
                      <span>Verified same-crop radius outbreak alerts propagation</span>
                    </li>
                  </ul>
                </div>
              </div>

              <div className="mt-8 pt-4 border-t border-slate-100">
                <Link to="/login">
                  <Button
                    variant="secondary"
                    className="w-full bg-slate-900 hover:bg-slate-800 text-white font-medium text-xs h-10 gap-2 border-slate-900 shadow-xs"
                  >
                    <span>Open Officials Dashboard</span>
                    <ArrowRight className="h-3.5 w-3.5" />
                  </Button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          4. THE PRODUCT STORY / OPERATIONAL LIFECYCLE
          ============================================================ */}
      <section id="how-it-works" className="py-16 lg:py-24 border-t border-slate-200">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
              End-to-End Field Lifecycle
            </span>
            <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
              From Ground Risk Alert to Regional Surveillance
            </h2>
            <p className="mt-3 text-sm sm:text-base text-slate-600">
              How BHOOMI connects farmers, plant pathologists, and government officials into a
              single closed-loop intelligence architecture.
            </p>
          </div>

          <div className="mt-14 relative">
            <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
              {/* Step 1 */}
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                      Step 01
                    </span>
                    <Clock className="h-4 w-4 text-slate-400" />
                  </div>
                  <h4 className="font-bold text-sm text-slate-900">Forward Risk Alert</h4>
                  <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                    Micro-climate, weather forecasts, and growth stage combine into an alert naming{' '}
                    <strong className="text-slate-800">where on the plant to inspect</strong> before
                    damage spreads.
                  </p>
                </div>
                <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                  Non-nullable tasks
                </div>
              </div>

              {/* Step 2 */}
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                      Step 02
                    </span>
                    <Sliders className="h-4 w-4 text-slate-400" />
                  </div>
                  <h4 className="font-bold text-sm text-slate-900">Confidence Gate</h4>
                  <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                    Photo evaluated against 3 bands. If ambiguous, the{' '}
                    <strong className="text-slate-800">Doubt Doctor</strong> asks one physical cue
                    rather than guessing.
                  </p>
                </div>
                <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                  Uncertainty as feature
                </div>
              </div>

              {/* Step 3 */}
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                      Step 03
                    </span>
                    <ShieldCheck className="h-4 w-4 text-slate-400" />
                  </div>
                  <h4 className="font-bold text-sm text-slate-900">Pesticide Veto</h4>
                  <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                    OCR bottle scan checks active ingredients against CIB&RC records to veto the
                    wrong chemical before spraying.
                  </p>
                </div>
                <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                  Veto, never endorse
                </div>
              </div>

              {/* Step 4 */}
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                      Step 04
                    </span>
                    <Sprout className="h-4 w-4 text-slate-400" />
                  </div>
                  <h4 className="font-bold text-sm text-slate-900">KVK Expert Triage</h4>
                  <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                    Escalations compile into complete case bundles. Agronomists confirm, correct,
                    or request information in &lt; 3 mins.
                  </p>
                </div>
                <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                  Human-in-the-loop
                </div>
              </div>

              {/* Step 5 */}
              <div className="rounded-xl border border-slate-200/90 bg-white p-5 shadow-xs flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded">
                      Step 05
                    </span>
                    <Activity className="h-4 w-4 text-slate-400" />
                  </div>
                  <h4 className="font-bold text-sm text-slate-900">State Surveillance</h4>
                  <p className="mt-1.5 text-xs text-slate-600 leading-relaxed">
                    Confirmed diagnoses adjust regional priors, light up the district hotspot map,
                    and trigger radius alerts.
                  </p>
                </div>
                <div className="mt-4 pt-3 border-t border-slate-100 text-[11px] font-medium text-emerald-800">
                  Epidemic prevention
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          5. CORE CAPABILITIES (EDITORIAL GRID)
          ============================================================ */}
      <section id="capabilities" className="py-16 lg:py-24 bg-slate-50/60 border-t border-slate-200">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl">
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
              PRD-Enforced Specifications
            </span>
            <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
              Engineered Against the Confident Wrong Answer
            </h2>
            <p className="mt-3 text-sm sm:text-base text-slate-600">
              The named harm in crop protection is not "no answer." It is the confident wrong
              answer that leads to crop failure and chemical over-spraying. Every capability in
              BHOOMI is built around this reality.
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 md:grid-cols-12 gap-6">
            {/* Feature 1: The Confidence Gate & Doubt Doctor (Wide 8-col) */}
            <div className="md:col-span-8 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                  <Sliders className="h-4 w-4 text-emerald-700" />
                  <span>F2 & F4 · Autonomous Confidence Gate</span>
                </div>
                <h3 className="mt-3 text-xl font-bold text-slate-900">
                  Three-Band Gate & The Doubt Doctor
                </h3>
                <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                  One strict mathematical function gates every single prediction. If the model is
                  confident (top1 ≥ 0.70 and margin ≥ 0.15), it composes an advisory. If it falls
                  into the ambiguous band (0.45 to 0.70), it activates the Doubt Doctor: presenting
                  both candidates transparently and asking the farmer a single physical
                  discriminating cue rather than taking a guess.
                </p>

                <div className="mt-6 grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
                  <div className="rounded-lg bg-emerald-50/80 border border-emerald-200/70 p-3">
                    <span className="font-bold text-emerald-900 block">Above Gate (≥ 0.70)</span>
                    <span className="text-emerald-800 text-[11px] mt-0.5 block">
                      Direct IPM advisory composed
                    </span>
                  </div>
                  <div className="rounded-lg bg-amber-50/80 border border-amber-200/70 p-3">
                    <span className="font-bold text-amber-900 block">Ambiguous (0.45 - 0.70)</span>
                    <span className="text-amber-800 text-[11px] mt-0.5 block">
                      Doubt Doctor clarifying question
                    </span>
                  </div>
                  <div className="rounded-lg bg-red-50/80 border border-red-200/70 p-3">
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
            <div className="md:col-span-4 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                  <ShieldCheck className="h-4 w-4 text-emerald-700" />
                  <span>F7 & F8 · Pesticide Safety</span>
                </div>
                <h3 className="mt-3 text-xl font-bold text-slate-900">
                  Veto, Never Endorse
                </h3>
                <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                  Advisory schema requires Cultural → Biological → Chemical hierarchy. OCR bottle
                  checks match ingredients against official CIB&RC registered-use records. If a
                  chemical is unregistered for that target or crop, it is vetoed immediately.
                </p>
              </div>

              <div className="mt-6 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
                <span>The printed label remains the sole dosage authority.</span>
              </div>
            </div>

            {/* Feature 3: Persistent Farm Memory (Compact 4-col) */}
            <div className="md:col-span-4 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                  <Database className="h-4 w-4 text-emerald-700" />
                  <span>F1 · Farm Persistent Memory</span>
                </div>
                <h3 className="mt-3 text-xl font-bold text-slate-900">
                  The Farm as a Clinical Case File
                </h3>
                <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                  Farms maintain persistent memory across seasons: variety, growth stage, soil type,
                  and past pest records. History acts as a mathematical risk prior rather than a
                  passive archive.
                </p>
              </div>

              <div className="mt-6 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
                <span>Mandatory geolocation for spatial containment</span>
              </div>
            </div>

            {/* Feature 4: Outbreak Hotspots & Macro Surveillance (Wide 8-col) */}
            <div className="md:col-span-8 rounded-2xl border border-slate-200/90 bg-white p-6 sm:p-8 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-800">
                  <Activity className="h-4 w-4 text-emerald-700" />
                  <span>F6 & F15 · Regional Surveillance</span>
                </div>
                <h3 className="mt-3 text-xl font-bold text-slate-900">
                  District Outbreak Hotspots & Spread Radius
                </h3>
                <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                  Only verified expert confirmations propagate radius spread alerts to nearby farms
                  of the same crop. Officials monitor active clusters across Maharashtra with live
                  outbreak counts, severity indices, and accuracy verification metrics (confirmed
                  vs. corrected diagnoses).
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
        </div>
      </section>

      {/* ============================================================
          6. ENGINEERING & DESIGN PRINCIPLES
          ============================================================ */}
      <section id="principles" className="py-16 lg:py-24 border-t border-slate-200">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl">
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-800">
              Architectural Guardrails
            </span>
            <h2 className="mt-2 text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
              Non-Negotiable Product Principles
            </h2>
            <p className="mt-3 text-sm sm:text-base text-slate-600">
              Enforced directly in code and verified by automated testing. These are not marketing
              aspirations; they dictate every state transition.
            </p>
          </div>

          <div className="mt-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div className="rounded-xl border border-slate-200/80 bg-white p-5">
              <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                Principle 01
              </span>
              <h4 className="mt-2 text-base font-bold text-slate-900">Never Fabricate</h4>
              <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                No retrieval above threshold means zero advice. No corpus entry for a chemical means
                no verdict on that chemical. The system says what it does not know.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200/80 bg-white p-5">
              <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                Principle 02
              </span>
              <h4 className="mt-2 text-base font-bold text-slate-900">Uncertainty as a Feature</h4>
              <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                When torn, the farmer sees both candidate diagnoses and gets asked one physical cue.
                Uncertainty becomes the most trustworthy moment in the interaction.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200/80 bg-white p-5">
              <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                Principle 03
              </span>
              <h4 className="mt-2 text-base font-bold text-slate-900">Veto, Never Endorse</h4>
              <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                The system may declare "this is wrong here." It may never say "this is safe." The
                printed label remains the authority on dosage and application.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200/80 bg-white p-5">
              <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                Principle 04
              </span>
              <h4 className="mt-2 text-base font-bold text-slate-900">Chemical Last, Structurally</h4>
              <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                The action ladder is cultural → biological → chemical as schema, not as writing
                style. The system is structurally incapable of leading with a pesticide.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200/80 bg-white p-5">
              <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                Principle 05
              </span>
              <h4 className="mt-2 text-base font-bold text-slate-900">Every Alert Carries a Task</h4>
              <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                "Risk is high" without "examine the base of the stems this week" is noise.
                Inspection tasks are non-nullable and require explicit outcome recording.
              </p>
            </div>

            <div className="rounded-xl border border-slate-200/80 bg-white p-5">
              <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider block">
                Principle 06
              </span>
              <h4 className="mt-2 text-base font-bold text-slate-900">The Farm is a Case File</h4>
              <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                Persistent history, not isolated sessions. Prior treatments, follow-ups, and
                confirmed diagnoses form the context required for high-speed expert triage.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          7. FINAL CALL TO ACTION
          ============================================================ */}
      <section className="border-t border-slate-200 bg-slate-900 text-white py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center space-y-6">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-950/60 px-3.5 py-1 text-xs font-semibold text-emerald-300">
            <span>BHOOMI Operations Portal Access</span>
          </div>

          <h2 className="text-3xl font-extrabold tracking-tight sm:text-4xl">
            Ready to Access the BHOOMI Portal?
          </h2>

          <p className="text-sm sm:text-base text-slate-300 max-w-2xl mx-auto leading-relaxed">
            Secure entry point for ICAR-KVK Agronomists, Extension Research Specialists, and
            Government of Maharashtra Agriculture Surveillance Officers.
          </p>

          <div className="pt-4 flex flex-wrap items-center justify-center gap-3.5">
            <Link to="/login">
              <Button
                size="lg"
                className="bg-[#2E7D32] hover:bg-[#1B5E20] text-white font-semibold text-sm h-12 px-8 rounded-xl shadow-md gap-2"
              >
                <span>Sign In to Workspace</span>
                <ArrowRight className="h-4 w-4" />
              </Button>
            </Link>
          </div>

          <p className="text-xs text-slate-400 pt-4">
            Supports official single sign-on & demo instant credentials for authorized roles.
          </p>
        </div>
      </section>

      {/* ============================================================
          8. FOOTER
          ============================================================ */}
      <footer className="border-t border-slate-800 bg-slate-950 py-12 text-slate-400 text-xs">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
            {/* Brand in footer */}
            <div className="flex items-center gap-3">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#1B5E20] text-white">
                <Sprout className="h-5 w-5" />
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
