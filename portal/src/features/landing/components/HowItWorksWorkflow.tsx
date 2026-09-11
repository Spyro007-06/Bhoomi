import { useState, useEffect } from 'react';
import {
  UserCheck,
  Mic,
  Database,
  CloudSun,
  Sparkles,
  HelpCircle,
  TrendingUp,
  Building2,
  ShieldCheck,
  CheckCircle2,
  ArrowDown,
} from 'lucide-react';
import { ScrollReveal } from './ScrollReveal';
import { cn } from '@/lib/utils/cn';

interface WorkflowStep {
  number: string;
  title: string;
  description: string;
  icon: typeof UserCheck;
  tag: string;
}

interface StageData {
  id: 'farmer' | 'intelligence' | 'expert';
  stageNumber: string;
  stageTitle: string;
  stageEyebrow: string;
  stageSummary: string;
  imageSrc: string;
  imageAlt: string;
  imageBadge: string;
  accentBadgeClass: string;
  accentBorderClass: string;
  steps: WorkflowStep[];
}

const STAGE_01: StageData = {
  id: 'farmer',
  stageNumber: '01',
  stageEyebrow: 'Stage 01 · Ground-Level Telemetry',
  stageTitle: 'Farmer & Field Context',
  stageSummary: 'Geolocated plot boundaries and dialect voice inputs initialize clinical farm memory.',
  imageSrc: '/images/landing/workflow/stage1-farmer-field.jpg',
  imageAlt: 'Agricultural farmland landscape in Maharashtra with crop telemetry at sunrise',
  imageBadge: 'Ground-Level Telemetry · Wardha',
  accentBadgeClass: 'bg-emerald-50 text-emerald-800 border-emerald-200/80',
  accentBorderClass: 'border-emerald-500 ring-emerald-500/15',
  steps: [
    {
      number: '01',
      title: 'Farmer Onboarding',
      description: 'Farmer registers geolocated land boundaries and verified Kharif crop plots.',
      icon: UserCheck,
      tag: 'GPS Boundary',
    },
    {
      number: '02',
      title: 'Voice-First Input',
      description: 'Farmer speaks naturally in local dialect to report observations, symptoms, or queries.',
      icon: Mic,
      tag: 'Dialect Voice AI',
    },
    {
      number: '03',
      title: 'Persistent Farm Profile',
      description: 'BHOOMI builds clinical farm memory across soil, variety, and multi-season history.',
      icon: Database,
      tag: 'Clinical Memory',
    },
  ],
};

const STAGE_02: StageData = {
  id: 'intelligence',
  stageNumber: '02',
  stageEyebrow: 'Stage 02 · Multimodal Evaluation',
  stageTitle: 'BHOOMI Intelligence & Confidence Gate',
  stageSummary: 'Diagnostic vision models evaluate field symptoms through Bayesian confidence gates.',
  imageSrc: '/images/landing/workflow/stage2-crop-intelligence.jpg',
  imageAlt: 'BHOOMI AI crop intelligence and diagnostics interface on tablet in field',
  imageBadge: 'Calibrated Vision Models',
  accentBadgeClass: 'bg-teal-50 text-teal-800 border-teal-200/80',
  accentBorderClass: 'border-teal-500 ring-teal-500/15',
  steps: [
    {
      number: '04',
      title: 'Daily Farm Companion',
      description: 'Delivers micro-climate weather alerts, proactive task guidance, and growth tracking.',
      icon: CloudSun,
      tag: 'Proactive Advisory',
    },
    {
      number: '05',
      title: 'Case & Intelligence',
      description: 'Farmer submits field photos or symptoms for multi-modal vision analysis.',
      icon: Sparkles,
      tag: 'Vision Diagnosis',
    },
    {
      number: '06',
      title: 'Doubt Doctor & Gate',
      description: 'When ambiguous, prompts for a physical cue rather than producing a wrong answer.',
      icon: HelpCircle,
      tag: 'Confidence Gate',
    },
  ],
};

const STAGE_03: StageData = {
  id: 'expert',
  stageNumber: '03',
  stageEyebrow: 'Stage 03 · Surveillance & Governance',
  stageTitle: 'Human Expert & Regional Surveillance',
  stageSummary: 'Uncertain cases route to KVK agronomists, broadcasting verified containment alerts.',
  imageSrc: '/images/landing/workflow/stage3-agronomist-surveillance.jpg',
  imageAlt: 'KVK Agronomist reviewing farm telemetry and geospatial hotspot alerts',
  imageBadge: 'KVK Expert Verification · Maharashtra',
  accentBadgeClass: 'bg-blue-50 text-blue-800 border-blue-200/80',
  accentBorderClass: 'border-blue-500 ring-blue-500/15',
  steps: [
    {
      number: '07',
      title: 'Follow-Up Progression',
      description: 'Monitors symptom progression over time (improved, worsening, no change) to verify recovery.',
      icon: TrendingUp,
      tag: 'Efficacy Tracking',
    },
    {
      number: '08',
      title: 'Expert & Official Escalation',
      description: 'Uncertain cases route to KVK agronomists, broadcasting verified containment alerts.',
      icon: Building2,
      tag: 'District Hotspots',
    },
  ],
};

const ALL_STEPS: readonly WorkflowStep[] = [...STAGE_01.steps, ...STAGE_02.steps, ...STAGE_03.steps];

export function HowItWorksWorkflow() {
  const [activeStepNumber, setActiveStepNumber] = useState<string>('01');

  useEffect(() => {
    // Smooth cyclical step progression along the roadmap
    const interval = setInterval(() => {
      const allStepNumbers = ALL_STEPS.map((st) => st.number);
      setActiveStepNumber((prev) => {
        const nextIndex = (allStepNumbers.indexOf(prev) + 1) % allStepNumbers.length;
        return allStepNumbers[nextIndex] ?? '01';
      });
    }, 4500);

    return () => clearInterval(interval);
  }, []);

  return (
    <section
      id="how-it-works"
      className="py-16 sm:py-20 lg:py-28 border-t border-slate-200 bg-[#FDFEFC] scroll-mt-16 overflow-hidden"
    >
      <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
        {/* Section Heading */}
        <ScrollReveal>
          <div className="text-center max-w-3xl mx-auto space-y-2.5">
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-300/80 bg-emerald-50 px-3.5 py-1 text-xs font-bold uppercase tracking-wider text-emerald-900 shadow-2xs">
              <span className="flex h-2 w-2 rounded-full bg-emerald-600 animate-pulse" />
              <span>How BHOOMI Works</span>
            </div>
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-extrabold tracking-tight text-slate-900">
              From Farmer Input to Expert Intelligence
            </h2>
            <p className="text-sm sm:text-base text-slate-600 leading-relaxed font-normal max-w-2xl mx-auto">
              A closed-loop agricultural intelligence roadmap: ground-level farmer inputs flow into
              clinical case memory, confidence checking, and district-wide expert surveillance.
            </p>
          </div>
        </ScrollReveal>

        {/* ============================================================
            ALTERNATING EDITORIAL ROADMAP FLOW
            ============================================================ */}
        <div className="mt-14 sm:mt-18 lg:mt-22 space-y-16 lg:space-y-20">
          {/* ============================================================
              STAGE 01: FARMER & FIELD CONTEXT (Left Image, Right Steps)
              ============================================================ */}
          <ScrollReveal>
            <div className="space-y-4">
              {/* Stage Eyebrow Bar */}
              <div className="flex items-center gap-3">
                <span className="font-mono text-xs font-bold px-2.5 py-0.5 rounded-md border bg-emerald-50 text-emerald-800 border-emerald-200/80">
                  STAGE 01
                </span>
                <span className="text-xs font-extrabold uppercase tracking-wider text-emerald-900">
                  Farmer &amp; Field Context
                </span>
                <div className="h-px bg-slate-200 flex-1" />
              </div>

              {/* Alternating Grid: Left Image, Right Steps */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8 items-center">
                {/* Left Visual Image Anchor */}
                <div className="lg:col-span-5 flex flex-col">
                  <div className="group relative aspect-[4/3] sm:aspect-[16/10] lg:aspect-[4/3] w-full max-h-[310px] overflow-hidden rounded-2xl border border-slate-200/90 bg-white p-2 shadow-xs transition-all duration-300 hover:shadow-md hover:border-emerald-500/40">
                    <div className="relative h-full w-full overflow-hidden rounded-xl bg-slate-100">
                      <img
                        src={STAGE_01.imageSrc}
                        alt={STAGE_01.imageAlt}
                        className="h-full w-full object-cover object-center transition-transform duration-700 ease-out group-hover:scale-[1.03]"
                        loading="lazy"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-slate-950/20 to-transparent pointer-events-none" />
                      <div className="absolute bottom-3 left-3 right-3 text-white text-[11px] space-y-0.5">
                        <div className="flex items-center gap-1.5 font-bold uppercase tracking-wider text-emerald-300 text-[10px]">
                          <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
                          <span>{STAGE_01.imageBadge}</span>
                        </div>
                        <p className="text-slate-200 text-xs line-clamp-2">
                          Geolocated plot boundaries and dialect voice inputs initialize clinical farm memory.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Right Step Cards (01, 02, 03) */}
                <div className="lg:col-span-7 flex flex-col gap-3">
                  {STAGE_01.steps.map((step) => {
                    const Icon = step.icon;
                    const isStepActive = activeStepNumber === step.number;
                    return (
                      <div
                        key={step.number}
                        onClick={() => setActiveStepNumber(step.number)}
                        onMouseEnter={() => setActiveStepNumber(step.number)}
                        className={cn(
                          'group relative rounded-xl border p-3.5 sm:p-4 transition-all duration-200 cursor-pointer flex items-center justify-between gap-4 bg-white shadow-2xs hover:-translate-y-0.5 hover:shadow-xs',
                          isStepActive
                            ? 'border-emerald-500 ring-2 ring-emerald-500/15 bg-emerald-50/20 shadow-xs'
                            : 'border-slate-200/90 hover:border-slate-300'
                        )}
                      >
                        <div className="flex items-center gap-3.5 flex-1">
                          <div
                            className={cn(
                              'flex h-9.5 w-9.5 shrink-0 items-center justify-center rounded-xl transition-all duration-200',
                              isStepActive
                                ? 'bg-emerald-600 text-white shadow-2xs scale-105'
                                : 'bg-emerald-50 text-emerald-700 group-hover:bg-emerald-100 group-hover:text-emerald-800'
                            )}
                          >
                            <Icon className="h-4.5 w-4.5" />
                          </div>

                          <div className="space-y-0.5">
                            <div className="flex items-center gap-2">
                              <span className="font-mono text-[10px] font-bold text-emerald-800 bg-emerald-50 px-1.5 py-0.2 rounded border border-emerald-200/60">
                                Step {step.number}
                              </span>
                              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                                {step.tag}
                              </span>
                            </div>
                            <h4 className="text-sm sm:text-[15px] font-bold text-slate-900 tracking-tight leading-tight">
                              {step.title}
                            </h4>
                            <p className="text-xs text-slate-600 leading-snug">
                              {step.description}
                            </p>
                          </div>
                        </div>

                        <CheckCircle2
                          className={cn(
                            'h-4 w-4 shrink-0 transition-colors hidden sm:block',
                            isStepActive ? 'text-emerald-600' : 'text-slate-300'
                          )}
                        />
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          </ScrollReveal>

          {/* Animated SVG Roadmap Connector: Stage 1 → Stage 2 */}
          <div className="flex items-center justify-center">
            <div className="flex items-center gap-3 px-4 py-1.5 rounded-full border border-dashed border-emerald-300 bg-emerald-50/60 shadow-2xs">
              <div className="flex items-center gap-1.5 text-[11px] font-semibold text-emerald-900">
                <span className="h-2 w-2 rounded-full bg-emerald-600 animate-ping" />
                <span>Telemetry Stream Flows to Multimodal Diagnostic Engine</span>
              </div>
              <ArrowDown className="h-3.5 w-3.5 text-emerald-700" />
            </div>
          </div>

          {/* ============================================================
              STAGE 02: BHOOMI INTELLIGENCE (Left Steps, Right Image)
              ============================================================ */}
          <ScrollReveal>
            <div className="space-y-4">
              {/* Stage Eyebrow Bar */}
              <div className="flex items-center gap-3">
                <span className="font-mono text-xs font-bold px-2.5 py-0.5 rounded-md border bg-teal-50 text-teal-800 border-teal-200/80">
                  STAGE 02
                </span>
                <span className="text-xs font-extrabold uppercase tracking-wider text-teal-900">
                  BHOOMI Intelligence &amp; Confidence Gate
                </span>
                <div className="h-px bg-slate-200 flex-1" />
              </div>

              {/* Alternating Grid: Left Steps, Right Image */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8 items-center">
                {/* Left Step Cards (04, 05, 06) */}
                <div className="lg:col-span-7 flex flex-col gap-3 order-2 lg:order-1">
                  {STAGE_02.steps.map((step) => {
                    const Icon = step.icon;
                    const isStepActive = activeStepNumber === step.number;
                    return (
                      <div
                        key={step.number}
                        onClick={() => setActiveStepNumber(step.number)}
                        onMouseEnter={() => setActiveStepNumber(step.number)}
                        className={cn(
                          'group relative rounded-xl border p-3.5 sm:p-4 transition-all duration-200 cursor-pointer flex items-center justify-between gap-4 bg-white shadow-2xs hover:-translate-y-0.5 hover:shadow-xs',
                          isStepActive
                            ? 'border-teal-500 ring-2 ring-teal-500/15 bg-teal-50/20 shadow-xs'
                            : 'border-slate-200/90 hover:border-slate-300'
                        )}
                      >
                        <div className="flex items-center gap-3.5 flex-1">
                          <div
                            className={cn(
                              'flex h-9.5 w-9.5 shrink-0 items-center justify-center rounded-xl transition-all duration-200',
                              isStepActive
                                ? 'bg-teal-600 text-white shadow-2xs scale-105'
                                : 'bg-teal-50 text-teal-700 group-hover:bg-teal-100 group-hover:text-teal-800'
                            )}
                          >
                            <Icon className="h-4.5 w-4.5" />
                          </div>

                          <div className="space-y-0.5">
                            <div className="flex items-center gap-2">
                              <span className="font-mono text-[10px] font-bold text-teal-800 bg-teal-50 px-1.5 py-0.2 rounded border border-teal-200/60">
                                Step {step.number}
                              </span>
                              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                                {step.tag}
                              </span>
                            </div>
                            <h4 className="text-sm sm:text-[15px] font-bold text-slate-900 tracking-tight leading-tight">
                              {step.title}
                            </h4>
                            <p className="text-xs text-slate-600 leading-snug">
                              {step.description}
                            </p>
                          </div>
                        </div>

                        <CheckCircle2
                          className={cn(
                            'h-4 w-4 shrink-0 transition-colors hidden sm:block',
                            isStepActive ? 'text-teal-600' : 'text-slate-300'
                          )}
                        />
                      </div>
                    );
                  })}
                </div>

                {/* Right Visual Image Anchor */}
                <div className="lg:col-span-5 flex flex-col order-1 lg:order-2">
                  <div className="group relative aspect-[4/3] sm:aspect-[16/10] lg:aspect-[4/3] w-full max-h-[310px] overflow-hidden rounded-2xl border border-slate-200/90 bg-white p-2 shadow-xs transition-all duration-300 hover:shadow-md hover:border-teal-500/40">
                    <div className="relative h-full w-full overflow-hidden rounded-xl bg-slate-100">
                      <img
                        src={STAGE_02.imageSrc}
                        alt={STAGE_02.imageAlt}
                        className="h-full w-full object-cover object-center transition-transform duration-700 ease-out group-hover:scale-[1.03]"
                        loading="lazy"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-slate-950/20 to-transparent pointer-events-none" />
                      <div className="absolute bottom-3 left-3 right-3 text-white text-[11px] space-y-0.5">
                        <div className="flex items-center gap-1.5 font-bold uppercase tracking-wider text-teal-300 text-[10px]">
                          <span className="h-2 w-2 rounded-full bg-teal-400 animate-pulse" />
                          <span>{STAGE_02.imageBadge}</span>
                        </div>
                        <p className="text-slate-200 text-xs line-clamp-2">
                          Diagnostic vision models evaluate field symptoms through Bayesian confidence gates.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </ScrollReveal>

          {/* Animated SVG Roadmap Connector: Stage 2 → Stage 3 */}
          <div className="flex items-center justify-center">
            <div className="flex items-center gap-3 px-4 py-1.5 rounded-full border border-dashed border-teal-300 bg-teal-50/60 shadow-2xs">
              <div className="flex items-center gap-1.5 text-[11px] font-semibold text-teal-900">
                <span className="h-2 w-2 rounded-full bg-teal-600 animate-ping" />
                <span>Uncertainty Triage Routes to KVK Human Extension Specialists</span>
              </div>
              <ArrowDown className="h-3.5 w-3.5 text-teal-700" />
            </div>
          </div>

          {/* ============================================================
              STAGE 03: HUMAN EXPERT & STATE (Left Image, Right Steps)
              ============================================================ */}
          <ScrollReveal>
            <div className="space-y-4">
              {/* Stage Eyebrow Bar */}
              <div className="flex items-center gap-3">
                <span className="font-mono text-xs font-bold px-2.5 py-0.5 rounded-md border bg-blue-50 text-blue-800 border-blue-200/80">
                  STAGE 03
                </span>
                <span className="text-xs font-extrabold uppercase tracking-wider text-blue-900">
                  Human Expert &amp; Regional Surveillance
                </span>
                <div className="h-px bg-slate-200 flex-1" />
              </div>

              {/* Alternating Grid: Left Image, Right Steps */}
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8 items-center">
                {/* Left Visual Image Anchor */}
                <div className="lg:col-span-5 flex flex-col">
                  <div className="group relative aspect-[4/3] sm:aspect-[16/10] lg:aspect-[4/3] w-full max-h-[310px] overflow-hidden rounded-2xl border border-slate-200/90 bg-white p-2 shadow-xs transition-all duration-300 hover:shadow-md hover:border-blue-500/40">
                    <div className="relative h-full w-full overflow-hidden rounded-xl bg-slate-100">
                      <img
                        src={STAGE_03.imageSrc}
                        alt={STAGE_03.imageAlt}
                        className="h-full w-full object-cover object-center transition-transform duration-700 ease-out group-hover:scale-[1.03]"
                        loading="lazy"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-slate-950/20 to-transparent pointer-events-none" />
                      <div className="absolute bottom-3 left-3 right-3 text-white text-[11px] space-y-0.5">
                        <div className="flex items-center gap-1.5 font-bold uppercase tracking-wider text-blue-300 text-[10px]">
                          <span className="h-2 w-2 rounded-full bg-blue-400 animate-pulse" />
                          <span>{STAGE_03.imageBadge}</span>
                        </div>
                        <p className="text-slate-200 text-xs line-clamp-2">
                          Uncertain cases route to KVK agronomists, broadcasting verified containment alerts.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Right Step Cards (07, 08) */}
                <div className="lg:col-span-7 flex flex-col gap-3">
                  {STAGE_03.steps.map((step) => {
                    const Icon = step.icon;
                    const isStepActive = activeStepNumber === step.number;
                    return (
                      <div
                        key={step.number}
                        onClick={() => setActiveStepNumber(step.number)}
                        onMouseEnter={() => setActiveStepNumber(step.number)}
                        className={cn(
                          'group relative rounded-xl border p-3.5 sm:p-4 transition-all duration-200 cursor-pointer flex items-center justify-between gap-4 bg-white shadow-2xs hover:-translate-y-0.5 hover:shadow-xs',
                          isStepActive
                            ? 'border-blue-500 ring-2 ring-blue-500/15 bg-blue-50/20 shadow-xs'
                            : 'border-slate-200/90 hover:border-slate-300'
                        )}
                      >
                        <div className="flex items-center gap-3.5 flex-1">
                          <div
                            className={cn(
                              'flex h-9.5 w-9.5 shrink-0 items-center justify-center rounded-xl transition-all duration-200',
                              isStepActive
                                ? 'bg-blue-600 text-white shadow-2xs scale-105'
                                : 'bg-blue-50 text-blue-700 group-hover:bg-blue-100 group-hover:text-blue-800'
                            )}
                          >
                            <Icon className="h-4.5 w-4.5" />
                          </div>

                          <div className="space-y-0.5">
                            <div className="flex items-center gap-2">
                              <span className="font-mono text-[10px] font-bold text-blue-800 bg-blue-50 px-1.5 py-0.2 rounded border border-blue-200/60">
                                Step {step.number}
                              </span>
                              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                                {step.tag}
                              </span>
                            </div>
                            <h4 className="text-sm sm:text-[15px] font-bold text-slate-900 tracking-tight leading-tight">
                              {step.title}
                            </h4>
                            <p className="text-xs text-slate-600 leading-snug">
                              {step.description}
                            </p>
                          </div>
                        </div>

                        <CheckCircle2
                          className={cn(
                            'h-4 w-4 shrink-0 transition-colors hidden sm:block',
                            isStepActive ? 'text-blue-600' : 'text-slate-300'
                          )}
                        />
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          </ScrollReveal>
        </div>

        {/* ============================================================
            CLOSED-LOOP AGRICULTURAL INTELLIGENCE TRUST FOOTER
            ============================================================ */}
        <ScrollReveal delay={100}>
          <div className="mt-14 sm:mt-18 rounded-3xl border border-slate-200/90 bg-white p-6 sm:p-7 shadow-xs flex flex-col md:flex-row items-center justify-between gap-5">
            <div className="flex items-center gap-4 text-center sm:text-left">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-800 border border-emerald-200">
                <ShieldCheck className="h-6 w-6 text-[#1B5E20]" />
              </div>
              <div>
                <h4 className="text-base font-bold text-slate-900">
                  Closed-Loop Agricultural Intelligence
                </h4>
                <p className="text-xs text-slate-500 max-w-xl">
                  Every field diagnosis updates epidemiological memory, protecting regional crops across Maharashtra through continuous expert verification.
                </p>
              </div>
            </div>

            <div className="flex flex-wrap items-center justify-center gap-2.5">
              <span className="inline-flex items-center gap-1.5 rounded-full bg-slate-100 px-3.5 py-1.5 text-xs font-semibold text-slate-700">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
                <span>Zero AI Hallucination</span>
              </span>
              <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3.5 py-1.5 text-xs font-semibold text-emerald-800 border border-emerald-200">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
                <span>Human-In-The-Loop</span>
              </span>
            </div>
          </div>
        </ScrollReveal>
      </div>
    </section>
  );
}
