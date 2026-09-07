import { Activity, CheckCircle, TrendingUp, ShieldCheck } from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { Card } from '@/components/ui/Card';

interface TreatmentRecord {
  target: string;
  crop: string;
  chemical_formula: string;
  dosage: string;
  cases_treated: number;
  recovery_rate: number;
  avg_days_to_recovery: number;
  adherence_score: number;
}

const TREATMENTS: TreatmentRecord[] = [
  {
    target: 'Paddy Blast',
    crop: 'Paddy / Rice',
    chemical_formula: 'Tricyclazole 75% WP',
    dosage: '0.6 g/L water',
    cases_treated: 42,
    recovery_rate: 94.2,
    avg_days_to_recovery: 5,
    adherence_score: 96,
  },
  {
    target: 'Cotton Pink Bollworm',
    crop: 'Cotton',
    chemical_formula: 'Emamectin Benzoate 5% SG',
    dosage: '0.5 g/L water + Pheromone Traps',
    cases_treated: 28,
    recovery_rate: 91.5,
    avg_days_to_recovery: 7,
    adherence_score: 92,
  },
  {
    target: 'Soybean Yellow Mosaic Virus',
    crop: 'Soybean',
    chemical_formula: 'Thiamethoxam 25% WG (Vector control)',
    dosage: '0.3 g/L water',
    cases_treated: 19,
    recovery_rate: 88.4,
    avg_days_to_recovery: 6,
    adherence_score: 89,
  },
  {
    target: 'Jowar Stem Borer',
    crop: 'Sorghum / Jowar',
    chemical_formula: 'Chlorantraniliprole 18.5% SC',
    dosage: '0.3 ml/L whorl application',
    cases_treated: 31,
    recovery_rate: 96.0,
    avg_days_to_recovery: 4,
    adherence_score: 98,
  },
];

export function TreatmentEfficacyPage() {
  return (
    <div className="flex-1 p-6 pb-20 bg-bhoomi-canvas min-w-0 max-w-[1600px] mx-auto w-full space-y-6">
      {/* Header Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-bhoomi-border pb-5">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-bhoomi-text-primary">
              Treatment Efficacy Tracking
            </h1>
            <Badge variant="primary" size="sm" className="gap-1 font-bold">
              <Activity className="h-3.5 w-3.5" />
              <span>Field Recovery Analytics</span>
            </Badge>
          </div>
          <p className="text-xs text-bhoomi-text-secondary mt-1">
            Real-world post-treatment monitoring, farmer compliance rates, and pesticide response telemetry.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="hidden md:flex items-center gap-1.5 rounded-full border border-bhoomi-border bg-bhoomi-canvas px-3 py-1 text-xs text-bhoomi-text-muted">
            <ShieldCheck className="h-3.5 w-3.5 text-emerald-600" />
            <span className="font-medium text-bhoomi-text-secondary">CIBRC Scientific Formulations</span>
          </div>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <Card className="p-4 rounded-2xl border border-emerald-200 bg-emerald-50/40 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider block">
              AVG RECOVERY RATE
            </span>
            <TrendingUp className="h-4 w-4 text-emerald-600" />
          </div>
          <p className="text-2xl font-bold font-mono text-emerald-900 mt-1">93.8%</p>
          <span className="text-[11px] text-emerald-700 mt-0.5 block">+2.1% improvement this season</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-xs">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            CASES MONITORED
          </span>
          <p className="text-2xl font-bold font-mono text-bhoomi-text-primary mt-1">120</p>
          <span className="text-[11px] text-slate-500 mt-0.5 block">Across 4 key crop varieties</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-blue-200 bg-blue-50/40 shadow-xs">
          <span className="text-[10px] font-bold text-blue-800 uppercase tracking-wider block">
            FARMER COMPLIANCE
          </span>
          <p className="text-2xl font-bold font-mono text-blue-900 mt-1">94.2%</p>
          <span className="text-[11px] text-blue-700 mt-0.5 block">Strict dosage adherence</span>
        </Card>

        <Card className="p-4 rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-xs">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            RESISTANCE FLAGS
          </span>
          <p className="text-2xl font-bold font-mono text-emerald-700 mt-1">0 Active</p>
          <span className="text-[11px] text-slate-500 mt-0.5 block">No pesticide failure reports</span>
        </Card>
      </div>

      {/* Efficacy Details Table */}
      <div className="rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-card overflow-hidden">
        <div className="p-4 border-b border-bhoomi-border flex items-center justify-between">
          <h2 className="text-sm font-bold text-bhoomi-text-primary">
            Efficacy by Target Disease &amp; Prescription
          </h2>
          <span className="text-xs text-bhoomi-text-muted">Updated from automated farmer voice follow-ups</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-[#F8FAFC] border-b border-bhoomi-border text-[10px] uppercase font-bold text-slate-500 tracking-wider">
              <tr>
                <th className="py-3.5 px-4">Target Diagnosis</th>
                <th className="py-3.5 px-4">Prescribed Formulation</th>
                <th className="py-3.5 px-4">Recommended Dosage</th>
                <th className="py-3.5 px-4">Cases Treated</th>
                <th className="py-3.5 px-4">Recovery Rate</th>
                <th className="py-3.5 px-4">Avg Recovery</th>
                <th className="py-3.5 px-4">Compliance</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {TREATMENTS.map((t) => (
                <tr key={t.target} className="hover:bg-[#F8FAFC] transition-colors">
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-slate-900">{t.target}</div>
                    <div className="text-[11px] text-slate-500">{t.crop}</div>
                  </td>
                  <td className="py-3.5 px-4 font-mono font-semibold text-emerald-800">
                    {t.chemical_formula}
                  </td>
                  <td className="py-3.5 px-4 text-slate-600">{t.dosage}</td>
                  <td className="py-3.5 px-4 font-mono font-bold text-slate-800">{t.cases_treated}</td>
                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-emerald-700">{t.recovery_rate}%</span>
                      <div className="h-1.5 w-16 rounded-full bg-slate-200 overflow-hidden">
                        <div
                          className="h-full bg-emerald-600 rounded-full"
                          style={{ width: `${t.recovery_rate}%` }}
                        />
                      </div>
                    </div>
                  </td>
                  <td className="py-3.5 px-4 font-mono text-slate-600">{t.avg_days_to_recovery} days</td>
                  <td className="py-3.5 px-4">
                    <span className="inline-flex items-center gap-1 font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded text-[11px]">
                      <CheckCircle className="h-3 w-3" />
                      {t.adherence_score}%
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
