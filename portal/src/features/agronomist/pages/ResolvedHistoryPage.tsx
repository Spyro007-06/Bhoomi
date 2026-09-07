import { useState } from 'react';
import { Link } from 'react-router-dom';
import { CheckCircle2, Search, ArrowRight, ShieldCheck, Clock, MapPin, FileCheck } from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { formatTargetLabel } from '@/lib/utils/formatters';

interface ResolvedCase {
  case_id: string;
  verdict: 'confirmed' | 'corrected';
  original_label: string;
  confirmed_label: string;
  crop: string;
  farmer_name: string;
  region: string;
  resolved_at: string;
  prescribed_treatment: string;
  alerts_issued: number;
}

const RESOLVED_CASES: ResolvedCase[] = [
  {
    case_id: 'case_kvk_703',
    verdict: 'confirmed',
    original_label: 'tapioca_mosaic',
    confirmed_label: 'tapioca_mosaic',
    crop: 'Tapioca / Cassava',
    farmer_name: 'P. Sengottaiyan',
    region: 'Salem, Tamil Nadu',
    resolved_at: '2026-08-20T11:30:00Z',
    prescribed_treatment: 'Rouge out infected plants. Spray Dimethoate 30% EC @ 1.7 ml/L for whitefly vector management.',
    alerts_issued: 8,
  },
  {
    case_id: 'case_demo_001',
    verdict: 'confirmed',
    original_label: 'paddy_blast',
    confirmed_label: 'paddy_blast',
    crop: 'Paddy (Indrayani)',
    farmer_name: 'Ramesh Jadhav',
    region: 'Pune (Baramati)',
    resolved_at: '2026-08-31T14:45:00Z',
    prescribed_treatment: 'Foliar spray of Tricyclazole 75% WP @ 0.6 g/L water at early tillering.',
    alerts_issued: 14,
  },
  {
    case_id: 'case_demo_004',
    verdict: 'corrected',
    original_label: 'jowar_shoot_fly',
    confirmed_label: 'jowar_stem_borer',
    crop: 'Sorghum / Jowar (Maldandi)',
    farmer_name: 'Anand Shinde',
    region: 'Sangli (Miraj)',
    resolved_at: '2026-08-30T16:20:00Z',
    prescribed_treatment: 'Cartap Hydrochloride 4G application in leaf whorls @ 8 kg/ha. Avoid synthetic pyrethroids.',
    alerts_issued: 6,
  },
];

export function ResolvedHistoryPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [cases] = useState<ResolvedCase[]>(RESOLVED_CASES);

  const filtered = cases.filter(
    (c) =>
      c.case_id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.confirmed_label.toLowerCase().includes(searchQuery.toLowerCase()) ||
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
              Resolved Case History
            </h1>
            <Badge variant="primary" size="sm" className="gap-1 font-bold">
              <CheckCircle2 className="h-3.5 w-3.5" />
              <span>{cases.length} Cases Resolved</span>
            </Badge>
          </div>
          <p className="text-xs text-bhoomi-text-secondary mt-1">
            Complete audit record of diagnostic confirmations, agronomist corrections, and field advisories.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="hidden md:flex items-center gap-1.5 rounded-full border border-bhoomi-border bg-bhoomi-canvas px-3 py-1 text-xs text-bhoomi-text-muted">
            <ShieldCheck className="h-3.5 w-3.5 text-emerald-600" />
            <span className="font-medium text-bhoomi-text-secondary">Official ICAR-KVK Audit Trail</span>
          </div>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <Card className="p-4 rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-xs">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            TOTAL RESOLVED
          </span>
          <p className="text-2xl font-bold font-mono text-bhoomi-text-primary mt-1">{cases.length}</p>
          <span className="text-[11px] text-slate-500 mt-0.5 block">100% resolution completion</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-emerald-200 bg-emerald-50/40 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider block">
            CONFIRMED ACCURACY
          </span>
          <p className="text-2xl font-bold font-mono text-emerald-900 mt-1">93.3%</p>
          <span className="text-[11px] text-emerald-700 mt-0.5 block">Model matched agronomist verdict</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-amber-200 bg-amber-50/40 shadow-xs">
          <span className="text-[10px] font-bold text-amber-800 uppercase tracking-wider block">
            FIELD CORRECTIONS
          </span>
          <p className="text-2xl font-bold font-mono text-amber-900 mt-1">1</p>
          <span className="text-[11px] text-amber-700 mt-0.5 block">Scientific label corrected</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-blue-200 bg-blue-50/40 shadow-xs">
          <span className="text-[10px] font-bold text-blue-800 uppercase tracking-wider block">
            SPREAD ALERTS ISSUED
          </span>
          <p className="text-2xl font-bold font-mono text-blue-900 mt-1">28</p>
          <span className="text-[11px] text-blue-700 mt-0.5 block">Neighboring farms notified</span>
        </Card>
      </div>

      {/* Filter / Search Bar */}
      <div className="flex items-center justify-between gap-4">
        <div className="max-w-md w-full">
          <Input
            type="text"
            placeholder="Search by Case ID, crop, or diagnosis..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            icon={<Search className="h-4 w-4 text-bhoomi-text-muted" />}
            className="h-9 text-xs"
          />
        </div>
      </div>

      {/* Table / List */}
      <div className="space-y-3">
        {filtered.map((item) => (
          <div
            key={item.case_id}
            className="rounded-2xl border border-bhoomi-border bg-bhoomi-surface p-4 shadow-card hover:border-bhoomi-primary/50 transition-all space-y-3"
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-200">
                  <FileCheck className="h-5 w-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold text-slate-800">{item.case_id}</span>
                    <Badge
                      variant={item.verdict === 'confirmed' ? 'primary' : 'warning'}
                      size="sm"
                      className="font-bold text-[10px] uppercase"
                    >
                      {item.verdict}
                    </Badge>
                  </div>
                  <h3 className="text-sm font-bold text-bhoomi-text-primary mt-0.5">
                    {formatTargetLabel(item.confirmed_label)} · <span className="font-normal text-slate-600">{item.crop}</span>
                  </h3>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <span className="text-[11px] text-slate-500 flex items-center gap-1">
                  <Clock className="h-3.5 w-3.5 text-slate-400" />
                  {new Date(item.resolved_at).toLocaleDateString()}
                </span>
                <Link
                  to={`/agronomist/cases/${item.case_id}`}
                  className="inline-flex items-center gap-1.5 rounded-xl border border-bhoomi-border bg-[#F8FAFC] hover:bg-[#DCFCE7] hover:text-[#15803D] hover:border-[#86EFAC] px-3 py-1.5 text-xs font-bold text-slate-700 shadow-2xs transition-colors"
                >
                  <span>View Case</span>
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
                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">PRESCRIBED TREATMENT</span>
                <span className="text-slate-700 font-medium line-clamp-1">{item.prescribed_treatment}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
