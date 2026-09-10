import { CheckCircle2, Edit3, HelpCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';

interface CaseActionBarProps {
  onConfirmClick: () => void;
  onCorrectClick: () => void;
  onRequestInfoClick: () => void;
  isPending: boolean;
  isResolved?: boolean;
}

export function CaseActionBar({
  onConfirmClick,
  onCorrectClick,
  onRequestInfoClick,
  isPending,
  isResolved,
}: CaseActionBarProps) {
  if (isResolved) {
    return (
      <div className="shrink-0 border-t border-bhoomi-primary/30 bg-bhoomi-primary-dark px-6 py-3.5 text-white shadow-md z-20">
        <div className="max-w-[1400px] mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2 text-xs font-semibold">
            <CheckCircle2 className="h-4 w-4 text-emerald-400" />
            <span>This case has been resolved and confirmed in the central database.</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="shrink-0 border-t border-bhoomi-border bg-bhoomi-surface px-6 py-3.5 shadow-md z-20">
      <div className="max-w-[1400px] mx-auto flex flex-col sm:flex-row items-center justify-between gap-3">
        <div className="text-xs text-bhoomi-text-secondary hidden sm:block">
          <span className="font-bold text-bhoomi-text-primary">Agronomist Action:</span> Choose a decision after reviewing all field evidence.
        </div>

        <div className="flex items-center gap-3 w-full sm:w-auto justify-end">
          {/* Request Info Button */}
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={onRequestInfoClick}
            disabled={isPending}
            className="gap-1.5 text-xs flex-1 sm:flex-initial"
          >
            <HelpCircle className="h-4 w-4 text-blue-600" />
            <span>Request Information</span>
          </Button>

          {/* Correct Button */}
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={onCorrectClick}
            disabled={isPending}
            className="gap-1.5 text-xs flex-1 sm:flex-initial border-amber-400 text-amber-900 hover:bg-amber-50"
          >
            <Edit3 className="h-4 w-4 text-amber-600" />
            <span>Correct Diagnosis</span>
          </Button>

          {/* Confirm Button */}
          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={onConfirmClick}
            disabled={isPending}
            className="gap-1.5 text-xs flex-1 sm:flex-initial shadow-sm font-semibold"
          >
            <CheckCircle2 className="h-4 w-4" />
            <span>Confirm Diagnosis</span>
          </Button>
        </div>
      </div>
    </div>
  );
}
