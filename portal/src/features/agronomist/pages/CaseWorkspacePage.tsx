import { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, SearchX, AlertCircle, RefreshCw } from 'lucide-react';
import { useCase, useConfirmCase, useRequestInfo } from '../hooks';
import { CaseHeader } from '../components/CaseHeader';
import { FarmContext } from '../components/FarmContext';
import { ProblemSummary } from '../components/ProblemSummary';
import { HypothesesPanel } from '../components/HypothesesPanel';
import { GateSummary } from '../components/GateSummary';
import { EvidenceGallery } from '../components/EvidenceGallery';
import { FieldObservations } from '../components/FieldObservations';
import { TreatmentsTried } from '../components/TreatmentsTried';
import { LabelChecks } from '../components/LabelChecks';
import { FollowupTrend } from '../components/FollowupTrend';
import { CaseActionBar } from '../components/CaseActionBar';
import { EscalatedQueuePanel } from '../components/EscalatedQueuePanel';
import { ConfirmCaseDialog } from '../components/ConfirmCaseDialog';
import { CorrectCaseDialog } from '../components/CorrectCaseDialog';
import { RequestInfoDialog } from '../components/RequestInfoDialog';
import { ResolutionSuccessModal } from '../components/ResolutionSuccessModal';
import { Skeleton } from '@/components/ui/Skeleton';
import { ErrorState } from '@/components/feedback/ErrorState';
import { isBhoomiApiError } from '@/lib/api/errors';
import { CaseConfirmRequest, CaseConfirmResponse, CaseRequestInfoRequest } from '@/types/api';

export function CaseWorkspacePage() {
  const { caseId = '' } = useParams<{ caseId: string }>();

  // Dialog & Resolution state
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [isCorrectOpen, setIsCorrectOpen] = useState(false);
  const [isRequestInfoOpen, setIsRequestInfoOpen] = useState(false);
  const [resolutionResult, setResolutionResult] = useState<CaseConfirmResponse | null>(null);

  // Queries & Mutations
  const { data: caseBundle, isLoading, isError, error, refetch } = useCase(caseId);
  const confirmMutation = useConfirmCase(caseId);
  const requestInfoMutation = useRequestInfo(caseId);

  const isPending = confirmMutation.isPending || requestInfoMutation.isPending;

  // Handlers
  const handleConfirmSubmit = async (payload: CaseConfirmRequest) => {
    try {
      const response = await confirmMutation.mutateAsync(payload);
      setIsConfirmOpen(false);
      setResolutionResult(response);
    } catch {
      // Error is captured in confirmMutation.error and presented in dialog
    }
  };

  const handleCorrectSubmit = async (payload: CaseConfirmRequest) => {
    try {
      const response = await confirmMutation.mutateAsync(payload);
      setIsCorrectOpen(false);
      setResolutionResult(response);
    } catch {
      // Error is captured in confirmMutation.error and presented in dialog
    }
  };

  const handleRequestInfoSubmit = async (payload: CaseRequestInfoRequest) => {
    try {
      await requestInfoMutation.mutateAsync(payload);
      setIsRequestInfoOpen(false);
    } catch {
      // Error is captured in requestInfoMutation.error and presented in dialog
    }
  };

  // Loading Skeleton State
  if (isLoading) {
    return (
      <div className="flex-1 flex flex-col lg:flex-row bg-bhoomi-canvas min-w-0">
        <div className="w-full lg:w-[320px] lg:shrink-0 border-r border-bhoomi-border bg-bhoomi-surface p-4 space-y-3">
          <Skeleton className="h-10 w-full rounded-xl" />
          <Skeleton className="h-32 w-full rounded-2xl" />
          <Skeleton className="h-32 w-full rounded-2xl" />
          <Skeleton className="h-32 w-full rounded-2xl" />
        </div>
        <div className="flex-1 p-6 space-y-5">
          <div className="flex items-center justify-between border-b border-bhoomi-border pb-4">
            <Skeleton className="h-8 w-64 rounded-xl" />
            <Skeleton className="h-6 w-32 rounded-full" />
          </div>
          <Skeleton className="h-36 rounded-2xl" />
          <Skeleton className="h-44 rounded-2xl" />
          <Skeleton className="h-72 rounded-2xl" />
        </div>
      </div>
    );
  }

  // Error States (404, 403, 5xx, Network)
  if (isError || !caseBundle) {
    if (isBhoomiApiError(error) && error.isNotFound()) {
      return (
        <div className="flex flex-col items-center justify-center p-12 text-center rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-card space-y-4 my-8 max-w-lg mx-auto">
          <div className="flex h-14 w-14 items-center justify-center rounded-full bg-amber-100 text-amber-800 border border-amber-300">
            <SearchX className="h-7 w-7" />
          </div>
          <div className="space-y-1">
            <h2 className="text-xl font-bold text-bhoomi-text-primary">Case Not Found</h2>
            <p className="text-xs text-bhoomi-text-muted max-w-sm">
              The case identifier <span className="font-mono font-semibold text-bhoomi-text-secondary">{caseId}</span> does not exist or has been archived.
            </p>
          </div>
          <Link
            to="/agronomist/cases"
            className="inline-flex items-center gap-2 rounded-xl bg-bhoomi-primary px-4 py-2.5 text-xs font-semibold text-white hover:bg-bhoomi-primary-dark transition-colors shadow-sm"
          >
            <ArrowLeft className="h-4 w-4" />
            <span>Back to Case Queue</span>
          </Link>
        </div>
      );
    }

    const isForbidden = isBhoomiApiError(error) && error.isForbidden();
    return (
      <div className="p-6">
        <ErrorState
          error={error}
          title={isForbidden ? 'Access Restricted' : 'Error Loading Case Bundle'}
          onRetry={() => refetch()}
        />
      </div>
    );
  }

  const isResolved =
    caseBundle.status === 'resolved' ||
    (resolutionResult !== null && resolutionResult.case_id === caseBundle.case_id);

  return (
    <div className="flex-1 flex flex-col lg:flex-row bg-bhoomi-canvas min-w-0 lg:h-[calc(100vh-70px)] lg:overflow-hidden">
      {/* Column 2: Escalated Case Queue List (Middle Column) */}
      <EscalatedQueuePanel activeCaseId={caseId || caseBundle.case_id} />

      {/* Column 3: Case Workspace / Detail Pane (Right Column) */}
      <div className="flex-1 flex flex-col min-w-0 h-full overflow-hidden">
        {/* Scrollable Detail Content Area */}
        <div className="flex-1 overflow-y-auto custom-scrollbar p-6 space-y-5">
          <div className="max-w-[1400px] mx-auto space-y-5">
            {/* Header */}
            <CaseHeader
              caseId={caseBundle.case_id}
              status={caseBundle.status}
              openedAt={caseBundle.problem.opened_at}
              isResolved={isResolved}
            />

            {/* Farm Context */}
            <FarmContext farm={caseBundle.farm} />

            {/* Farm Health & Treatment Response Banner (State / Network retry) */}
            {caseBundle.gate?.outcome === 'clarify' && (
              <div className="flex items-center justify-between rounded-2xl border border-amber-200 bg-amber-50/70 p-4 shadow-xs text-xs">
                <div className="flex items-center gap-2 text-amber-800 font-semibold">
                  <AlertCircle className="h-4 w-4 text-amber-600" />
                  <span>Farm Health &amp; Treatment Response</span>
                </div>
                <button
                  type="button"
                  onClick={() => refetch()}
                  className="inline-flex items-center gap-1.5 rounded-lg border border-amber-300 bg-white px-3 py-1 text-xs font-bold text-amber-800 hover:bg-amber-50 transition-colors shadow-2xs"
                >
                  <RefreshCw className="h-3 w-3" />
                  <span>Retry</span>
                </button>
              </div>
            )}

            {/* Problem Summary (FARMER STATED PROBLEM) */}
            <ProblemSummary problem={caseBundle.problem} />

            {/* Uploaded Field Media (Evidence Gallery) */}
            <EvidenceGallery images={caseBundle.images} />

            {/* Two-Column Detail Section for Hypotheses and Observations */}
            <div className="grid grid-cols-1 xl:grid-cols-12 gap-5 items-start">
              {/* Left Sub-column: Observations & Field History */}
              <div className="xl:col-span-7 space-y-5">
                {/* Doubt Doctor Field Observations */}
                <FieldObservations observations={caseBundle.field_observations} />

                {/* Treatments Tried */}
                <TreatmentsTried treatments={caseBundle.treatments_tried} />

                {/* Pesticide Label Checks */}
                <LabelChecks labelChecks={caseBundle.label_checks} />

                {/* Follow-up Trend */}
                <FollowupTrend
                  trend={caseBundle.followup_trend}
                  spokenSummary={caseBundle.spoken_summary}
                />
              </div>

              {/* Right Sub-column: AI Hypotheses & Gate Context */}
              <div className="xl:col-span-5 space-y-5">
                {/* Model Hypotheses */}
                <HypothesesPanel hypotheses={caseBundle.model_hypotheses} />

                {/* Decision Gate */}
                <GateSummary gate={caseBundle.gate} />
              </div>
            </div>
          </div>
        </div>

        {/* Stable Docked Action Bar at the Bottom — NEVER moves, ZERO space below */}
        <CaseActionBar
          onConfirmClick={() => setIsConfirmOpen(true)}
          onCorrectClick={() => setIsCorrectOpen(true)}
          onRequestInfoClick={() => setIsRequestInfoOpen(true)}
          isPending={isPending}
          isResolved={isResolved}
        />
      </div>

      {/* Action Dialogs */}
      <ConfirmCaseDialog
        isOpen={isConfirmOpen}
        onClose={() => setIsConfirmOpen(false)}
        onConfirm={handleConfirmSubmit}
        caseId={caseBundle.case_id}
        targetLabel={caseBundle.problem.label}
        isPending={confirmMutation.isPending}
        error={confirmMutation.error as Error | null}
      />

      <CorrectCaseDialog
        isOpen={isCorrectOpen}
        onClose={() => setIsCorrectOpen(false)}
        onCorrect={handleCorrectSubmit}
        caseId={caseBundle.case_id}
        currentLabel={caseBundle.problem.label}
        isPending={confirmMutation.isPending}
        error={confirmMutation.error as Error | null}
      />

      <RequestInfoDialog
        isOpen={isRequestInfoOpen}
        onClose={() => setIsRequestInfoOpen(false)}
        onRequestInfo={handleRequestInfoSubmit}
        caseId={caseBundle.case_id}
        isPending={requestInfoMutation.isPending}
        error={requestInfoMutation.error as Error | null}
      />

      {/* Resolution Success Modal */}
      <ResolutionSuccessModal
        isOpen={resolutionResult !== null}
        resolution={resolutionResult}
        onClose={() => setResolutionResult(null)}
      />
    </div>
  );
}
