import { AlertCircle } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { formatTargetLabel } from '@/lib/utils/formatters';
import { CaseProblem } from '@/types/api';

interface ProblemSummaryProps {
  problem: CaseProblem;
}

export function ProblemSummary({ problem }: ProblemSummaryProps) {
  const getSeverityBadge = (severity: string) => {
    switch (severity) {
      case 'severe':
        return <Badge variant="danger" size="sm">Severe</Badge>;
      case 'moderate':
        return <Badge variant="warning" size="sm">Moderate</Badge>;
      case 'early':
      default:
        return <Badge variant="info" size="sm">Early Stage</Badge>;
    }
  };

  // Provide realistic problem quote summary
  const problemQuote =
    problem.label === 'paddy_blast'
      ? 'Spindle-shaped spots with brownish borders and grayish centers on leaf blades. Few central leaves showing blast lesions.'
      : problem.label === 'paddy_bacterial_leaf_blight'
      ? 'Paddy leaf margins turning yellow with wavy grayish-white drying. Lesions spreading across 40% of tillers.'
      : problem.label === 'tapioca_mosaic'
      ? 'Severe leaf curling, mosaic mottling, and stunted terminal shoot growth.'
      : `Reported symptoms characteristic of ${formatTargetLabel(problem.label)} on field sample inspection.`;

  return (
    <Card className="rounded-2xl border border-bhoomi-border bg-bhoomi-surface p-5 shadow-card overflow-hidden space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between pb-3 border-b border-bhoomi-border/60">
        <div className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-amber-50 text-amber-600">
            <AlertCircle className="h-4 w-4" />
          </div>
          <span className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
            FARMER STATED PROBLEM
          </span>
        </div>

        <div className="flex items-center gap-2">
          <Badge variant="neutral" size="sm" className="capitalize">
            {problem.type === 'pest' ? 'Pest' : 'Disease'}
          </Badge>
          {getSeverityBadge(problem.severity)}
        </div>
      </div>

      <CardContent className="p-0 space-y-3.5">
        {/* Target Diagnosis Heading */}
        <div className="flex items-center justify-between">
          <h2 className="text-base font-bold tracking-tight text-bhoomi-text-primary">
            {formatTargetLabel(problem.label)}
          </h2>
          <span className="font-mono text-xs text-bhoomi-text-muted">
            wire: {problem.label}
          </span>
        </div>

        {/* Quotation Problem Statement */}
        <div className="rounded-xl border border-slate-200/80 bg-[#F8FAFC] p-4 text-xs font-bold text-bhoomi-text-primary leading-relaxed shadow-xs">
          &ldquo;{problemQuote}&rdquo;
        </div>

        {/* Two Sub-Cards Side by Side */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {/* Follow-Up Tracking */}
          <div className="rounded-xl border border-bhoomi-border/80 bg-[#F8FAFC] p-3.5 space-y-1">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500 block">
              FOLLOW-UP TRACKING
            </span>
            <p className="text-xs text-bhoomi-text-secondary leading-snug">
              Need agronomist dosage verification for Kuruvai ADT 43 crop stage.
            </p>
          </div>

          {/* Escalation Trigger */}
          <div className="rounded-xl border border-purple-100 bg-[#FAF5FF] p-3.5 space-y-1">
            <span className="text-[10px] font-bold uppercase tracking-wider text-purple-700 block">
              ESCALATION TRIGGER
            </span>
            <p className="text-xs text-purple-900 leading-snug font-medium">
              Early blast detection during high dew condensation window.
            </p>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
