import { useState, useEffect } from 'react';
import {
  UserCheck,
  Mic,
  Database,
  Compass,
  Sparkles,
  HelpCircle,
  TrendingUp,
  Building2,
  ArrowRight,
  CheckCircle2,
} from 'lucide-react';
import { ScrollReveal } from './ScrollReveal';
import { cn } from '@/lib/utils/cn';

interface WorkflowStep {
  number: string;
  title: string;
  stage: 'farmer' | 'intelligence' | 'expert';
  stageName: string;
  stageBadgeClass: string;
  description: string;
  icon: typeof UserCheck;
  tag: string;
}

const STEPS: WorkflowStep[] = [
  {
    number: '01',
    title: 'Farmer Onboarding',
    stage: 'farmer',
    stageName: 'Farmer Input',
    stageBadgeClass: 'bg-emerald-50 text-emerald-800 border-emerald-200/80',
    description: 'Farmer enters BHOOMI with geolocated land boundaries and verified Kharif crops.',
    icon: UserCheck,
    tag: 'Verified Farm Entry',
  },
  {
    number: '02',
    title: 'Voice-First Input',
    stage: 'farmer',
    stageName: 'Farmer Input',
    stageBadgeClass: 'bg-emerald-50 text-emerald-800 border-emerald-200/80',
    description: 'Farmer speaks naturally in local dialect to report observations, symptoms, or queries.',
    icon: Mic,
    tag: 'Dialect Voice AI',
  },
  {
    number: '03',
    title: 'Persistent Farm Profile',
    stage: 'farmer',
    stageName: 'Farmer Input',
    stageBadgeClass: 'bg-emerald-50 text-emerald-800 border-emerald-200/80',
    description: 'BHOOMI builds clinical farm memory across soil, variety, and past seasonal history.',
    icon: Database,
    tag: 'Clinical Case File',
  },
  {
    number: '04',
    title: 'Daily Farm Companion',
    stage: 'intelligence',
    stageName: 'BHOOMI Intelligence',
    stageBadgeClass: 'bg-teal-50 text-teal-800 border-teal-200/80',
    description: 'Delivers micro-climate weather alerts, proactive task guidance, and growth tracking.',
    icon: Compass,
    tag: 'Proactive Advisory',
  },
  {
    number: '05',
    title: 'Case & Intelligence',
    stage: 'intelligence',
    stageName: 'BHOOMI Intelligence',
    stageBadgeClass: 'bg-teal-50 text-teal-800 border-teal-200/80',
    description: 'Farmer submits field photos or symptoms for multi-modal analysis against 26 targets.',
    icon: Sparkles,
    tag: 'Vision Diagnosis',
  },
  {
    number: '06',
    title: 'Doubt Doctor & Gate',
    stage: 'intelligence',
    stageName: 'BHOOMI Intelligence',
    stageBadgeClass: 'bg-teal-50 text-teal-800 border-teal-200/80',
    description: 'When ambiguous, prompts for physical cues rather than producing a wrong answer.',
    icon: HelpCircle,
    tag: 'Confidence Gate',
  },
  {
    number: '07',
    title: 'Follow-Up Progression',
    stage: 'expert',
    stageName: 'Expert & Surveillance',
    stageBadgeClass: 'bg-blue-50 text-blue-800 border-blue-200/80',
    description: 'Monitors symptom progression over time (improved, worsening, no change) to verify recovery.',
    icon: TrendingUp,
    tag: 'Efficacy Tracking',
  },
  {
    number: '08',
    title: 'Expert & Official Escalation',
    stage: 'expert',
    stageName: 'Expert & Surveillance',
    stageBadgeClass: 'bg-blue-50 text-blue-800 border-blue-200/80',
    description: 'Uncertain cases route to KVK agronomists, broadcasting verified containment alerts.',
    icon: Building2,
    tag: 'District Surveillance',
  },
];

export function HowItWorksWorkflow() {
  const [activeStep, setActiveStep] = useState<number>(0);

  useEffect(() => {
    // Subtle periodic step pulse to show live flow
    const interval = setInterval(() => {
      setActiveStep((prev) => (prev + 1) % STEPS.length);
    }, 3200);
    return () => clearInterval(interval);
  }, []);

  return (
    <section id="how-it-works" className="py-16 lg:py-24 border-t border-slate-200 bg-slate-50/50 scroll-mt-16 overflow-hidden">
      <div className="mx-auto max-w-7xl xl:max-w-[1440px] px-4 sm:px-6 lg:px-8">
        {/* Section Heading */}
        <ScrollReveal>
          <div className="text-center max-w-3xl mx-auto space-y-2">
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-300/80 bg-emerald-50 px-3.5 py-1 text-xs font-bold uppercase tracking-wider text-emerald-900 shadow-2xs">
              <span className="flex h-2 w-2 rounded-full bg-emerald-600 animate-pulse" />
              <span>How BHOOMI Works</span>
            </div>
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-extrabold tracking-tight text-slate-900">
              From Farmer Input to Intelligent Farm Support
            </h2>
            <p className="text-sm sm:text-base text-slate-600 leading-relaxed font-normal">
              A closed-loop agricultural intelligence journey connecting voice-first farmer inputs to
              Bayesian case memory, confidence checking, and expert human review.
            </p>
          </div>
        </ScrollReveal>

        {/* 3-Stage Visual Legend Pills */}
        <ScrollReveal delay={60}>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-2 sm:gap-4 text-xs font-semibold">
            <div className="flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50/80 px-3 py-1 text-emerald-800 shadow-2xs">
              <span className="flex h-2 w-2 rounded-full bg-emerald-600" />
              <span>1. Farmer &amp; Field Context (01–03)</span>
            </div>
            <ArrowRight className="hidden sm:block h-3.5 w-3.5 text-slate-400" />
            <div className="flex items-center gap-1.5 rounded-full border border-teal-200 bg-teal-50/80 px-3 py-1 text-teal-800 shadow-2xs">
              <span className="flex h-2 w-2 rounded-full bg-teal-600" />
              <span>2. BHOOMI Intelligence (04–06)</span>
            </div>
            <ArrowRight className="hidden sm:block h-3.5 w-3.5 text-slate-400" />
            <div className="flex items-center gap-1.5 rounded-full border border-blue-200 bg-blue-50/80 px-3 py-1 text-blue-800 shadow-2xs">
              <span className="flex h-2 w-2 rounded-full bg-blue-600" />
              <span>3. Human Expert &amp; State (07–08)</span>
            </div>
          </div>
        </ScrollReveal>

        {/* Desktop Connected Journey Grid (2 Rows of 4 with Flow Connection) */}
        <div className="hidden lg:block mt-12 space-y-6">
          {/* Row 1: Steps 01 to 04 */}
          <div className="grid grid-cols-4 gap-5 relative">
            {STEPS.slice(0, 4).map((step, idx) => {
              const Icon = step.icon;
              const isPulsing = activeStep === idx;

              return (
                <ScrollReveal key={step.number} delay={80 + idx * 60}>
                  <div
                    onMouseEnter={() => setActiveStep(idx)}
                    className={cn(
                      'group relative rounded-2xl border bg-white p-5 shadow-xs transition-all duration-200 ease-out flex flex-col justify-between h-full hover:-translate-y-1 hover:shadow-md',
                      isPulsing
                        ? 'border-emerald-500/80 ring-2 ring-emerald-500/15 shadow-sm'
                        : 'border-slate-200/90 hover:border-emerald-600/40'
                    )}
                  >
                    {/* Top Row: Step # + Stage Badge + Icon */}
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-md border border-emerald-200/60">
                          Step {step.number}
                        </span>
                        <div
                          className={cn(
                            'flex h-9 w-9 items-center justify-center rounded-xl transition-all duration-200',
                            isPulsing
                              ? 'bg-emerald-600 text-white shadow-xs scale-105'
                              : 'bg-emerald-50 text-emerald-700 group-hover:bg-emerald-100 group-hover:text-emerald-800'
                          )}
                        >
                          <Icon className="h-4 w-4" />
                        </div>
                      </div>

                      <div>
                        <h3 className="text-base font-bold text-slate-900 tracking-tight">
                          {step.title}
                        </h3>
                        <p className="mt-1 text-xs text-slate-600 leading-relaxed font-normal">
                          {step.description}
                        </p>
                      </div>
                    </div>

                    {/* Footer tag */}
                    <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                        {step.tag}
                      </span>
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                    </div>

                    {/* Connecting arrow to next item in row */}
                    {idx < 3 && (
                      <div className="absolute -right-3.5 top-1/2 -translate-y-1/2 z-10 hidden xl:flex h-6 w-6 items-center justify-center rounded-full bg-white border border-emerald-200 text-emerald-600 shadow-2xs">
                        <ArrowRight className="h-3 w-3" />
                      </div>
                    )}
                  </div>
                </ScrollReveal>
              );
            })}
          </div>

          {/* Connected Transition Indicator Row between Stage 1/2 and Stage 2/3 */}
          <div className="flex items-center justify-center py-1">
            <div className="inline-flex items-center gap-2 rounded-full border border-dashed border-emerald-300 bg-white/90 px-4 py-1 text-xs font-semibold text-emerald-800 shadow-2xs">
              <span>Automated Intelligence &amp; Physical Cue Verification</span>
              <ArrowRight className="h-3 w-3 text-emerald-600 rotate-90" />
            </div>
          </div>

          {/* Row 2: Steps 05 to 08 */}
          <div className="grid grid-cols-4 gap-5 relative">
            {STEPS.slice(4, 8).map((step, idx) => {
              const actualIdx = idx + 4;
              const Icon = step.icon;
              const isPulsing = activeStep === actualIdx;

              return (
                <ScrollReveal key={step.number} delay={80 + actualIdx * 60}>
                  <div
                    onMouseEnter={() => setActiveStep(actualIdx)}
                    className={cn(
                      'group relative rounded-2xl border bg-white p-5 shadow-xs transition-all duration-200 ease-out flex flex-col justify-between h-full hover:-translate-y-1 hover:shadow-md',
                      isPulsing
                        ? 'border-emerald-500/80 ring-2 ring-emerald-500/15 shadow-sm'
                        : 'border-slate-200/90 hover:border-emerald-600/40'
                    )}
                  >
                    {/* Top Row: Step # + Stage Badge + Icon */}
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span
                          className={cn(
                            'font-mono text-xs font-bold px-2 py-0.5 rounded-md border',
                            step.stage === 'expert'
                              ? 'text-blue-800 bg-blue-50 border-blue-200/60'
                              : 'text-teal-800 bg-teal-50 border-teal-200/60'
                          )}
                        >
                          Step {step.number}
                        </span>
                        <div
                          className={cn(
                            'flex h-9 w-9 items-center justify-center rounded-xl transition-all duration-200',
                            isPulsing
                              ? 'bg-emerald-600 text-white shadow-xs scale-105'
                              : 'bg-emerald-50 text-emerald-700 group-hover:bg-emerald-100 group-hover:text-emerald-800'
                          )}
                        >
                          <Icon className="h-4 w-4" />
                        </div>
                      </div>

                      <div>
                        <h3 className="text-base font-bold text-slate-900 tracking-tight">
                          {step.title}
                        </h3>
                        <p className="mt-1 text-xs text-slate-600 leading-relaxed font-normal">
                          {step.description}
                        </p>
                      </div>
                    </div>

                    {/* Footer tag */}
                    <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                        {step.tag}
                      </span>
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                    </div>

                    {/* Connecting arrow to next item in row */}
                    {idx < 3 && (
                      <div className="absolute -right-3.5 top-1/2 -translate-y-1/2 z-10 hidden xl:flex h-6 w-6 items-center justify-center rounded-full bg-white border border-emerald-200 text-emerald-600 shadow-2xs">
                        <ArrowRight className="h-3 w-3" />
                      </div>
                    )}
                  </div>
                </ScrollReveal>
              );
            })}
          </div>
        </div>

        {/* Tablet & Mobile Connected Vertical Journey Spine */}
        <div className="block lg:hidden mt-10">
          <div className="relative pl-6 sm:pl-8 space-y-4 border-l-2 border-emerald-200">
            {STEPS.map((step, idx) => {
              const Icon = step.icon;

              return (
                <ScrollReveal key={step.number} delay={idx * 50}>
                  <div className="relative group rounded-2xl border border-slate-200/90 bg-white p-4 sm:p-5 shadow-xs hover:border-emerald-600/40 transition-all duration-200">
                    {/* Node marker on the spine */}
                    <div className="absolute -left-[31px] sm:-left-[39px] top-5 flex h-6 w-6 sm:h-7 sm:w-7 items-center justify-center rounded-full bg-emerald-600 text-white text-[10px] font-bold shadow-xs border-2 border-white">
                      {step.number}
                    </div>

                    <div className="flex items-start justify-between gap-3">
                      <div className="space-y-1 flex-1">
                        <div className="flex items-center gap-2">
                          <span
                            className={cn(
                              'text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded border',
                              step.stageBadgeClass
                            )}
                          >
                            {step.stageName}
                          </span>
                          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                            {step.tag}
                          </span>
                        </div>
                        <h3 className="text-sm sm:text-base font-bold text-slate-900">
                          {step.title}
                        </h3>
                        <p className="text-xs text-slate-600 leading-relaxed font-normal">
                          {step.description}
                        </p>
                      </div>

                      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-emerald-50 text-emerald-700">
                        <Icon className="h-4 w-4" />
                      </div>
                    </div>
                  </div>
                </ScrollReveal>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
