import { Link } from 'react-router-dom';
import { Sprout, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/utils/cn';

interface EscalatedQueuePanelProps {
  activeCaseId?: string;
}

export function EscalatedQueuePanel({ activeCaseId }: EscalatedQueuePanelProps) {
  const representativeCases = [
    {
      case_id: 'case_kvk_701',
      label: 'paddy_bacterial_leaf_blight',
      crop: 'Samba Paddy (CR 1009)',
      region: 'Erode, Tamil Nadu',
      status: 'assigned',
      farmer_name: 'Muthusamy K.',
      date: 'Aug 21',
      description:
        'Paddy leaf margins turning yellow with wavy grayish-white drying. Lesions spreading across 40% of tillers...',
    },
    {
      case_id: 'case_kvk_702',
      label: 'paddy_blast',
      crop: 'Kuruvai Paddy (ADT 43)',
      region: 'Thanjavur, Tamil Nadu',
      status: 'assigned',
      farmer_name: 'Lakshmi Narayanan',
      date: 'Aug 21',
      description:
        'Spindle-shaped spots with brownish borders and grayish centers on leaf blades. Few central leaves showing blast lesions...',
    },
    {
      case_id: 'case_kvk_703',
      label: 'tapioca_mosaic',
      crop: 'Tapioca / Cassava',
      region: 'Salem, Tamil Nadu',
      status: 'resolved',
      farmer_name: 'P. Sengottaiyan',
      date: 'Aug 20',
      description:
        'Severe leaf curling, mosaic mottling, and stunted terminal shoot growth.',
    },
  ];

  const getStatusBadge = (status: string, index: number) => {
    if (status === 'resolved' || index === 2) {
      return (
        <span className="inline-flex items-center rounded-md border border-emerald-200 bg-emerald-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-emerald-700">
          RESOLVED
        </span>
      );
    }
    if (index === 1 || status === 'under_review') {
      return (
        <span className="inline-flex items-center rounded-md border border-amber-200 bg-amber-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-amber-700">
          UNDER REVIEW
        </span>
      );
    }
    return (
      <span className="inline-flex items-center rounded-md border border-purple-200 bg-purple-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-purple-700">
        ESCALATED
      </span>
    );
  };

  return (
    <div className="w-full lg:w-[320px] lg:shrink-0 space-y-3 select-none">
      {/* Column Header */}
      <div className="flex items-center justify-between pb-1">
        <div>
          <div className="flex items-center gap-2">
            <h2 className="text-sm font-bold text-bhoomi-text-primary">
              Escalated Case Queue
            </h2>
            <span className="inline-flex items-center justify-center rounded-full bg-[#DCFCE7] px-2 py-0.5 text-[10px] font-bold text-[#15803D]">
              {representativeCases.length}
            </span>
          </div>
          <p className="text-[11px] text-bhoomi-text-muted mt-0.5">
            Cases requiring KVK agronomist review
          </p>
        </div>
      </div>

      {/* Queue Card List */}
      <div className="space-y-2.5">
        {representativeCases.map((c, idx) => {
          const isActive =
            activeCaseId === c.case_id || (idx === 1 && (!activeCaseId || activeCaseId === 'c_5'));

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
                  {getStatusBadge(c.status, idx)}
                  <ChevronRight className="h-3.5 w-3.5 text-slate-400 group-hover:text-bhoomi-primary transition-colors" />
                </div>
              </div>

              {/* Crop & Variety with Sprout */}
              <div className="flex items-center gap-1.5 mt-2">
                <Sprout className="h-3.5 w-3.5 shrink-0 text-emerald-600" />
                <h4 className="text-xs font-bold text-bhoomi-text-primary truncate">
                  {c.crop}
                </h4>
              </div>

              {/* Description excerpt */}
              <p className="text-[11px] text-slate-600 line-clamp-2 mt-1 leading-snug">
                {c.description}
              </p>

              {/* Footer: Farmer Name + Date */}
              <div className="flex items-center justify-between mt-2.5 pt-2 border-t border-slate-200/60 text-[10px] text-slate-400">
                <span className="font-medium text-slate-500 truncate">{c.farmer_name}</span>
                <span>{c.date}</span>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
