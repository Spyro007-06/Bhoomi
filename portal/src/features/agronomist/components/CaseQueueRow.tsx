import { useNavigate } from 'react-router-dom';
import { CaseQueueItem } from '@/types/api';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { TableRow, TableCell } from '@/components/ui/Table';
import { formatTargetLabel, formatRelativeTime } from '@/lib/utils/formatters';
import { ArrowRight, Clock, MapPin, Sprout } from 'lucide-react';

export interface CaseQueueRowProps {
  item: CaseQueueItem;
}

export function CaseQueueRow({ item }: CaseQueueRowProps) {
  const navigate = useNavigate();

  const handleOpenCase = () => {
    navigate(`/agronomist/cases/${item.case_id}`);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTableRowElement>) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleOpenCase();
    }
  };

  return (
    <TableRow
      tabIndex={0}
      onKeyDown={handleKeyDown}
      className="group cursor-pointer transition-all duration-150 hover:bg-[#F8FAFC] hover:border-l-4 hover:border-emerald-600 focus:bg-emerald-50 focus:outline-none select-none border-b border-slate-200/70"
      onClick={handleOpenCase}
      aria-label={`Open case ${item.case_id}`}
    >
      {/* 1. Server-authoritative Queue Position */}
      <TableCell className="w-20 font-semibold text-bhoomi-text-primary py-3.5">
        {item.queue_position !== null && item.queue_position !== undefined ? (
          <span className="inline-flex items-center justify-center px-2.5 py-0.5 rounded-lg bg-[#DCFCE7] text-[#15803D] text-xs font-bold border border-[#86EFAC] shadow-xs">
            #{item.queue_position}
          </span>
        ) : (
          <span className="text-bhoomi-text-muted text-xs">—</span>
        )}
      </TableCell>

      {/* 2. Case Identity */}
      <TableCell className="w-36 min-w-[140px] py-3.5">
        <span
          className="font-mono text-xs font-bold text-slate-800 group-hover:text-emerald-700 transition-colors"
          title={item.case_id}
        >
          {item.case_id}
        </span>
      </TableCell>

      {/* 3. Target Problem & Crop */}
      <TableCell className="py-3.5 min-w-[200px]">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-200">
            <Sprout className="h-4 w-4" />
          </div>
          <div>
            <p className="text-xs font-bold text-slate-900 leading-tight">
              {formatTargetLabel(item.label)}
            </p>
            {item.eta_minutes !== null && item.eta_minutes !== undefined && (
              <p className="text-[11px] text-slate-500 mt-0.5">
                Est. review: ~{item.eta_minutes}m
              </p>
            )}
          </div>
        </div>
      </TableCell>

      {/* 4. Region */}
      <TableCell className="w-44 text-xs text-slate-600 py-3.5">
        <div className="flex items-center gap-1.5">
          <MapPin className="h-3.5 w-3.5 text-slate-400 shrink-0" />
          <span className="truncate">{item.region || 'Maharashtra'}</span>
        </div>
      </TableCell>

      {/* 5. Status */}
      <TableCell className="w-28 py-3.5">
        <Badge
          variant={item.status === 'assigned' ? 'warning' : 'neutral'}
          size="sm"
          className="capitalize font-semibold text-[11px]"
        >
          {item.status}
        </Badge>
      </TableCell>

      {/* 6. Arrival & Time Context */}
      <TableCell className="w-40 text-xs text-slate-500 whitespace-nowrap py-3.5">
        <span className="inline-flex items-center gap-1.5">
          <Clock className="h-3.5 w-3.5 text-slate-400" />
          <span>{formatRelativeTime(item.created_at)}</span>
        </span>
      </TableCell>

      {/* 7. Action Button */}
      <TableCell className="w-28 text-right py-3.5">
        <Button
          size="sm"
          variant="ghost"
          onClick={(e) => {
            e.stopPropagation();
            handleOpenCase();
          }}
          className="gap-1.5 text-emerald-700 hover:text-emerald-800 hover:bg-emerald-50 font-bold text-xs"
          aria-label={`Review case ${item.case_id}`}
        >
          <span>Review</span>
          <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
        </Button>
      </TableCell>
    </TableRow>
  );
}
