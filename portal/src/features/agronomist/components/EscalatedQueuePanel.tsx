import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Sprout, ChevronRight, MapPin, Clock, ChevronsLeft, ChevronsRight } from 'lucide-react';
import { cn } from '@/lib/utils/cn';
import { formatTargetLabel, formatRelativeTime } from '@/lib/utils/formatters';
import { CaseQueueItem } from '@/types/api';

interface EscalatedQueuePanelProps {
  activeCaseId?: string;
  cases?: CaseQueueItem[];
}

const DEFAULT_CASES: CaseQueueItem[] = [
  {
    case_id: 'case_demo_001',
    problem_id: 'prob_demo_001',
    farm_id: 'farm_demo_001',
    region: 'Pune (Baramati)',
    label: 'paddy_blast',
    status: 'assigned',
    queue_position: 1,
    eta_minutes: 15,
    created_at: '2026-08-31T09:30:00Z',
  },
  {
    case_id: 'case_demo_002',
    problem_id: 'prob_demo_002',
    farm_id: 'farm_demo_002',
    region: 'Nashik (Dindori)',
    label: 'cotton_pink_bollworm',
    status: 'assigned',
    queue_position: 2,
    eta_minutes: 30,
    created_at: '2026-08-31T10:15:00Z',
  },
  {
    case_id: 'case_demo_003',
    problem_id: 'prob_demo_003',
    farm_id: 'farm_demo_003',
    region: 'Kolhapur (Karveer)',
    label: 'soybean_yellow_mosaic_virus',
    status: 'assigned',
    queue_position: 3,
    eta_minutes: 45,
    created_at: '2026-08-31T11:00:00Z',
  },
  {
    case_id: 'case_demo_004',
    problem_id: 'prob_demo_004',
    farm_id: 'farm_demo_004',
    region: 'Sangli (Miraj)',
    label: 'jowar_stem_borer',
    status: 'assigned',
    queue_position: 4,
    eta_minutes: 60,
    created_at: '2026-08-31T11:30:00Z',
  },
];

const CASE_DESCRIPTIONS: Record<string, string> = {
  paddy_blast:
    'Spindle-shaped spots with brownish borders and grayish centers on leaf blades. Few central leaves showing blast lesions...',
  cotton_pink_bollworm:
    'Rosetted flowers and small entry/exit holes in maturing bolls with larval damage across lower fruiting branches...',
  soybean_yellow_mosaic_virus:
    'Irregular yellow and green patches on leaves with severe chlorosis and stunted vegetative canopy...',
  jowar_stem_borer:
    'Dead heart symptoms and pinholes in whorl leaves with tunneling larvae in central shoot stems...',
  paddy_bacterial_leaf_blight:
    'Paddy leaf margins turning yellow with wavy grayish-white drying. Lesions spreading across 40% of tillers...',
  tapioca_mosaic:
    'Severe leaf curling, mosaic mottling, and stunted terminal shoot growth.',
};

export function EscalatedQueuePanel({ activeCaseId, cases }: EscalatedQueuePanelProps) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const displayCases = cases && cases.length > 0 ? cases : DEFAULT_CASES;

  const getStatusBadge = (status: string) => {
    if (status === 'resolved') {
      return (
        <span className="inline-flex items-center rounded-md border border-emerald-200 bg-emerald-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-emerald-700">
          RESOLVED
        </span>
      );
    }
    if (status === 'under_review') {
      return (
        <span className="inline-flex items-center rounded-md border border-blue-200 bg-blue-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-blue-700">
          UNDER REVIEW
        </span>
      );
    }
    return (
      <span className="inline-flex items-center rounded-md border border-amber-200 bg-amber-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-amber-700">
        ASSIGNED
      </span>
    );
  };

  if (isCollapsed) {
    return (
      <aside
        aria-label="Escalated Case Queue"
        className="w-full lg:w-[68px] lg:shrink-0 lg:sticky lg:top-[70px] lg:h-[calc(100vh-70px)] border-b lg:border-b-0 lg:border-r border-bhoomi-border bg-bhoomi-surface p-2.5 flex flex-col items-center overflow-hidden select-none z-10 transition-all duration-200 ease-in-out"
      >
        {/* Shrunk Header with Expand Action */}
        <div className="pb-3 mb-2 border-b border-bhoomi-border shrink-0 flex flex-col items-center gap-1.5 w-full">
          <button
            type="button"
            onClick={() => setIsCollapsed(false)}
            title="Expand queue panel"
            aria-label="Expand queue panel"
            className="flex h-8 w-8 items-center justify-center rounded-xl border border-bhoomi-border bg-bhoomi-canvas hover:bg-emerald-50 hover:border-emerald-300 hover:text-emerald-700 text-slate-600 transition-all shadow-2xs cursor-pointer group"
          >
            <ChevronsRight className="h-4 w-4 group-hover:translate-x-0.5 transition-transform" />
          </button>
          <span className="text-[9px] font-bold text-slate-400 tracking-wider uppercase">
            Queue
          </span>
        </div>

        {/* Shrunk Card List: Compact clickable case icons */}
        <div className="flex-1 overflow-y-auto no-scrollbar flex flex-col items-center gap-2.5 w-full min-h-0 pb-4">
          {displayCases.map((c, idx) => {
            const isActive =
              activeCaseId === c.case_id ||
              (!activeCaseId && idx === 0) ||
              (activeCaseId === 'c_5' && idx === 0);

            const shortId = c.case_id.replace('case_demo_', '');

            return (
              <Link
                key={c.case_id}
                to={`/agronomist/cases/${c.case_id}`}
                title={`${c.case_id} · ${formatTargetLabel(c.label)} (${c.region})`}
                className={cn(
                  'group relative flex flex-col items-center justify-center h-12 w-12 rounded-xl border transition-all duration-150',
                  isActive
                    ? 'border-2 border-emerald-600 bg-[#F4F9F4] text-emerald-800 shadow-xs'
                    : 'border-bhoomi-border bg-bhoomi-surface hover:border-bhoomi-primary/40 hover:bg-[#F8FAFC] text-slate-600'
                )}
              >
                <Sprout
                  className={cn(
                    'h-4 w-4 transition-colors',
                    isActive ? 'text-emerald-700' : 'text-slate-400 group-hover:text-emerald-600'
                  )}
                />
                <span className="font-mono text-[10px] font-bold mt-0.5 leading-none">
                  {shortId}
                </span>
                {/* Status indicator dot */}
                <span
                  className={cn(
                    'absolute top-1 right-1 h-1.5 w-1.5 rounded-full',
                    c.status === 'resolved' ? 'bg-emerald-500' : 'bg-amber-500'
                  )}
                />
              </Link>
            );
          })}
        </div>
      </aside>
    );
  }

  return (
    <aside
      aria-label="Escalated Case Queue"
      className="w-full lg:w-[320px] lg:shrink-0 lg:sticky lg:top-[70px] lg:h-[calc(100vh-70px)] border-b lg:border-b-0 lg:border-r border-bhoomi-border bg-bhoomi-surface p-4 flex flex-col overflow-hidden select-none z-10 transition-all duration-200 ease-in-out"
    >
      {/* Pinned Stable Header */}
      <div className="pb-3 mb-2 border-b border-bhoomi-border shrink-0">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h2 className="text-sm font-bold text-bhoomi-text-primary">
              Escalated Case Queue
            </h2>
            <span className="inline-flex items-center justify-center rounded-full bg-[#DCFCE7] px-2 py-0.5 text-[10px] font-bold text-[#15803D]">
              {displayCases.length} Cases
            </span>
          </div>

          <button
            type="button"
            onClick={() => setIsCollapsed(true)}
            title="Shrink queue panel"
            aria-label="Shrink queue panel"
            className="inline-flex items-center gap-1 rounded-lg border border-bhoomi-border bg-bhoomi-canvas hover:bg-slate-100 hover:border-slate-300 text-slate-500 hover:text-slate-800 px-2 py-1 text-[11px] font-semibold transition-all shadow-2xs cursor-pointer group"
          >
            <ChevronsLeft className="h-3.5 w-3.5 group-hover:-translate-x-0.5 transition-transform" />
            <span>Shrink</span>
          </button>
        </div>
        <p className="text-[11px] text-bhoomi-text-muted mt-0.5">
          Cases requiring KVK agronomist review
        </p>
      </div>

      {/* Independently Scrollable Card List Below Header (hidden scrollbar line) */}
      <div className="flex-1 overflow-y-auto no-scrollbar space-y-2.5 min-h-0 pb-4">
        {displayCases.map((c, idx) => {
          const isActive =
            activeCaseId === c.case_id ||
            (!activeCaseId && idx === 0) ||
            (activeCaseId === 'c_5' && idx === 0);

          const desc =
            (c.label && CASE_DESCRIPTIONS[c.label]) ||
            `Symptoms reported requiring KVK agronomist review for ${formatTargetLabel(c.label)}.`;

          return (
            <Link
              key={c.case_id}
              to={`/agronomist/cases/${c.case_id}`}
              className={cn(
                'group block rounded-2xl border p-3.5 transition-all duration-150',
                isActive
                  ? 'border-2 border-emerald-600 bg-[#F4F9F4] shadow-xs'
                  : 'border-bhoomi-border bg-bhoomi-surface hover:border-bhoomi-primary/40 hover:bg-[#F8FAFC]'
              )}
            >
              {/* Top row: ID + Status + Chevron */}
              <div className="flex items-center justify-between">
                <span className="font-mono text-[11px] font-medium text-slate-500">
                  {c.case_id}
                </span>
                <div className="flex items-center gap-1.5">
                  {getStatusBadge(c.status)}
                  <ChevronRight className="h-3.5 w-3.5 text-slate-400 group-hover:text-bhoomi-primary transition-colors" />
                </div>
              </div>

              {/* Crop & Target Problem with Sprout */}
              <div className="flex items-center gap-1.5 mt-2">
                <Sprout className="h-3.5 w-3.5 shrink-0 text-emerald-600" />
                <h4 className="text-xs font-bold text-bhoomi-text-primary truncate">
                  {formatTargetLabel(c.label)}
                </h4>
              </div>

              {/* Description excerpt */}
              <p className="text-[11px] text-slate-600 line-clamp-2 mt-1 leading-snug">
                {desc}
              </p>

              {/* Footer: Region + ETA / Time */}
              <div className="flex items-center justify-between mt-2.5 pt-2 border-t border-slate-200/60 text-[10px] text-slate-400">
                <span className="inline-flex items-center gap-1 font-medium text-slate-500 truncate max-w-[180px]">
                  <MapPin className="h-3 w-3 text-slate-400 shrink-0" />
                  <span className="truncate">{c.region || 'Maharashtra'}</span>
                </span>
                {c.eta_minutes ? (
                  <span className="inline-flex items-center gap-1 text-slate-400">
                    <Clock className="h-2.5 w-2.5 text-slate-400" />
                    <span>~{c.eta_minutes}m</span>
                  </span>
                ) : (
                  <span>{formatRelativeTime(c.created_at)}</span>
                )}
              </div>
            </Link>
          );
        })}
      </div>
    </aside>
  );
}
