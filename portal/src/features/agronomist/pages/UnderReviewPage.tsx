import { useState } from 'react';
import { Link } from 'react-router-dom';
import { AlertTriangle, Clock, Sprout, MapPin, ArrowRight, RefreshCw, Search } from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { formatTargetLabel } from '@/lib/utils/formatters';

interface UnderReviewCase {
  case_id: string;
  label: string;
  crop: string;
  region: string;
  farmer_name: string;
  assigned_to: string;
  started_at: string;
  sla_minutes_remaining: number;
  status: 'under_review';
  notes: string;
}

const INITIAL_CASES: UnderReviewCase[] = [
  {
    case_id: 'case_kvk_702',
    label: 'paddy_blast',
    crop: 'Kuruvai Paddy (ADT 43)',
    region: 'Thanjavur, Tamil Nadu',
    farmer_name: 'Lakshmi Narayanan',
    assigned_to: 'Dr. S. Sundaram',
    started_at: '2026-09-07T14:15:00Z',
    sla_minutes_remaining: 12,
    status: 'under_review',
    notes: 'Awaiting farmer image clarification for leaf blast lesions vs brown spot.',
  },
  {
    case_id: 'case_demo_002',
    label: 'cotton_pink_bollworm',
    crop: 'Cotton (BT-II)',
    region: 'Nashik (Dindori)',
    farmer_name: 'Suresh Patil',
    assigned_to: 'Dr. S. Sundaram',
    started_at: '2026-09-07T14:30:00Z',
    sla_minutes_remaining: 24,
    status: 'under_review',
    notes: 'Evaluating boll damage percentage for pheromone trap vs chemical intervention.',
  },
];

export function UnderReviewPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [cases] = useState<UnderReviewCase[]>(INITIAL_CASES);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const handleRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => setIsRefreshing(false), 500);
  };

  const filtered = cases.filter(
    (c) =>
      c.case_id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.label.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.farmer_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.region.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex-1 p-6 pb-20 bg-bhoomi-canvas min-w-0 max-w-[1600px] mx-auto w-full space-y-6">
      {/* Header Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-bhoomi-border pb-5">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-bhoomi-text-primary">
              Under Review Cases
            </h1>
            <Badge variant="warning" size="sm" className="gap-1 font-bold">
              <AlertTriangle className="h-3.5 w-3.5" />
              <span>{cases.length} in Progress</span>
            </Badge>
          </div>
          <p className="text-xs text-bhoomi-text-secondary mt-1">
            Cases currently undergoing diagnostic review, farmer clarification, or secondary dosage validation.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="hidden md:flex items-center gap-1.5 rounded-full border border-bhoomi-border bg-bhoomi-canvas px-3 py-1 text-xs text-bhoomi-text-muted">
            <Clock className="h-3.5 w-3.5 text-amber-600" />
            <span className="font-medium text-bhoomi-text-secondary">&lt; 30 Min Target Window</span>
          </div>

          <Button
            variant="outline"
            size="sm"
            onClick={handleRefresh}
            disabled={isRefreshing}
            className="gap-2 text-xs"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isRefreshing ? 'animate-spin text-bhoomi-primary' : ''}`} />
            <span>{isRefreshing ? 'Refreshing...' : 'Refresh'}</span>
          </Button>
        </div>
      </div>

      {/* KPI Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="p-4 rounded-2xl border border-amber-200 bg-amber-50/40 shadow-xs">
          <span className="text-[10px] font-bold text-amber-800 uppercase tracking-wider block">
            CASES IN REVIEW
          </span>
          <p className="text-2xl font-bold font-mono text-amber-900 mt-1">{cases.length}</p>
          <span className="text-[11px] text-amber-700 mt-0.5 block">Active agronomist desk triage</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-xs">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            AVERAGE REVIEW TIME
          </span>
          <p className="text-2xl font-bold font-mono text-bhoomi-text-primary mt-1">8.4m</p>
          <span className="text-[11px] text-slate-500 mt-0.5 block">Well within 30m SLA threshold</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-emerald-200 bg-emerald-50/40 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider block">
            CLARIFICATIONS AWAITING
          </span>
          <p className="text-2xl font-bold font-mono text-emerald-900 mt-1">1</p>
          <span className="text-[11px] text-emerald-700 mt-0.5 block">Follow-up sent to farmer</span>
        </Card>
      </div>

      {/* Filter / Search Bar */}
      <div className="flex items-center justify-between gap-4">
        <div className="max-w-md w-full">
          <Input
            type="text"
            placeholder="Search by Case ID, farmer, or diagnosis..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            icon={<Search className="h-4 w-4 text-bhoomi-text-muted" />}
            className="h-9 text-xs"
          />
        </div>
        <div className="hidden sm:flex items-center gap-2 text-xs text-bhoomi-text-muted">
          <Clock className="h-3.5 w-3.5" />
          <span>Sorted by urgency &amp; remaining SLA</span>
        </div>
      </div>

      {/* Case List */}
      <div className="space-y-3">
        {filtered.map((item) => (
          <div
            key={item.case_id}
            className="rounded-2xl border border-bhoomi-border bg-bhoomi-surface p-4 shadow-card hover:border-bhoomi-primary/50 transition-all space-y-3"
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-amber-50 text-amber-700 border border-amber-200">
                  <Sprout className="h-5 w-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold text-slate-800">{item.case_id}</span>
                    <Badge variant="warning" size="sm" className="font-bold text-[10px]">
                      UNDER REVIEW
                    </Badge>
                  </div>
                  <h3 className="text-sm font-bold text-bhoomi-text-primary mt-0.5">
                    {formatTargetLabel(item.label)} · <span className="font-normal text-slate-600">{item.crop}</span>
                  </h3>
                </div>
              </div>

              <div className="flex items-center gap-2 sm:self-center">
                <span className="text-[11px] font-mono text-amber-700 bg-amber-50 border border-amber-200 px-2.5 py-1 rounded-lg font-bold">
                  ⏱ {item.sla_minutes_remaining}m SLA remaining
                </span>
                <Link
                  to={`/agronomist/cases/${item.case_id}`}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-[#1B5E20] hover:bg-[#2E7D32] text-white px-3.5 py-1.5 text-xs font-bold shadow-xs transition-colors"
                >
                  <span>Open Workspace</span>
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs text-slate-600">
              <div>
                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">FARMER</span>
                <span className="font-semibold text-slate-800">{item.farmer_name}</span>
              </div>
              <div>
                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">LOCATION</span>
                <span className="flex items-center gap-1 text-slate-800">
                  <MapPin className="h-3.5 w-3.5 text-slate-400 shrink-0" />
                  {item.region}
                </span>
              </div>
              <div>
                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">REVIEW NOTE</span>
                <span className="text-slate-600 line-clamp-1">{item.notes}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
