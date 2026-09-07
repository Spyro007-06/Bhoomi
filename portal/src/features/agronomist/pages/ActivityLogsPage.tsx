import { useState } from 'react';
import { Link } from 'react-router-dom';
import { History, CheckCircle2, AlertTriangle, MessageSquare, Radio, Search, Clock, ArrowRight } from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';

interface ActivityLogItem {
  id: string;
  type: 'confirm' | 'correct' | 'request_info' | 'alert_broadcast';
  case_id: string;
  agronomist: string;
  timestamp: string;
  description: string;
  details: string;
}

const INITIAL_LOGS: ActivityLogItem[] = [
  {
    id: 'log_001',
    type: 'confirm',
    case_id: 'case_demo_001',
    agronomist: 'Dr. S. Sundaram',
    timestamp: '2026-08-31T14:45:00Z',
    description: 'Confirmed Paddy Blast diagnosis and issued advisory prescription.',
    details: 'Prescribed Tricyclazole 75% WP @ 0.6 g/L. Auto-triggered 14 neighboring farmer advisories.',
  },
  {
    id: 'log_002',
    type: 'request_info',
    case_id: 'case_kvk_702',
    agronomist: 'Dr. S. Sundaram',
    timestamp: '2026-08-31T12:10:00Z',
    description: 'Requested higher resolution image of tillering node lesions.',
    details: 'Farmer notified via Tamil voice prompt to capture close-up under sunlight.',
  },
  {
    id: 'log_003',
    type: 'correct',
    case_id: 'case_demo_004',
    agronomist: 'Dr. S. Sundaram',
    timestamp: '2026-08-30T16:20:00Z',
    description: 'Corrected automated model diagnosis from Shoot Fly to Stem Borer.',
    details: 'Updated model training pool with agronomist annotations and corrected chemical to Cartap Hydrochloride.',
  },
  {
    id: 'log_004',
    type: 'alert_broadcast',
    case_id: 'case_demo_002',
    agronomist: 'Dr. S. Sundaram',
    timestamp: '2026-08-30T10:05:00Z',
    description: 'Broadcasted Pink Bollworm regional spore warning.',
    details: 'Alert dispatched to 48 certified farms within 5 km buffer radius in Nashik.',
  },
  {
    id: 'log_005',
    type: 'confirm',
    case_id: 'case_kvk_703',
    agronomist: 'Dr. S. Sundaram',
    timestamp: '2026-08-20T11:30:00Z',
    description: 'Confirmed Tapioca Mosaic Virus and vector management protocol.',
    details: 'Advised rogueing of diseased plants and whitefly chemical spray.',
  },
];

export function ActivityLogsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState<string>('all');
  const [logs] = useState<ActivityLogItem[]>(INITIAL_LOGS);

  const filtered = logs.filter((log) => {
    const matchesSearch =
      log.case_id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      log.agronomist.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesType = filterType === 'all' || log.type === filterType;
    return matchesSearch && matchesType;
  });

  const getActionBadge = (type: string) => {
    switch (type) {
      case 'confirm':
        return (
          <Badge variant="primary" size="sm" className="font-bold text-[10px] gap-1">
            <CheckCircle2 className="h-3 w-3" />
            <span>CONFIRMED</span>
          </Badge>
        );
      case 'correct':
        return (
          <Badge variant="warning" size="sm" className="font-bold text-[10px] gap-1">
            <AlertTriangle className="h-3 w-3" />
            <span>CORRECTED</span>
          </Badge>
        );
      case 'request_info':
        return (
          <Badge variant="neutral" size="sm" className="font-bold text-[10px] gap-1">
            <MessageSquare className="h-3 w-3" />
            <span>INFO REQUEST</span>
          </Badge>
        );
      case 'alert_broadcast':
      default:
        return (
          <Badge variant="danger" size="sm" className="font-bold text-[10px] gap-1">
            <Radio className="h-3 w-3" />
            <span>ALERT BROADCAST</span>
          </Badge>
        );
    }
  };

  return (
    <div className="flex-1 p-6 pb-20 bg-bhoomi-canvas min-w-0 max-w-[1600px] mx-auto w-full space-y-6">
      {/* Header Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-bhoomi-border pb-5">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-bhoomi-text-primary">
              Agronomist Activity Logs
            </h1>
            <Badge variant="neutral" size="sm" className="gap-1 font-bold">
              <History className="h-3.5 w-3.5" />
              <span>{logs.length} Actions Logged</span>
            </Badge>
          </div>
          <p className="text-xs text-bhoomi-text-secondary mt-1">
            Immutable audit record of expert diagnostic confirmations, dosage modifications, and farmer notices.
          </p>
        </div>
      </div>

      {/* Filter Chips & Search Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="max-w-md w-full">
          <Input
            type="text"
            placeholder="Search by Case ID or action description..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            icon={<Search className="h-4 w-4 text-bhoomi-text-muted" />}
            className="h-9 text-xs"
          />
        </div>

        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
          {[
            { id: 'all', label: 'All Activities' },
            { id: 'confirm', label: 'Confirmations' },
            { id: 'correct', label: 'Corrections' },
            { id: 'request_info', label: 'Info Requests' },
            { id: 'alert_broadcast', label: 'Alerts' },
          ].map((tab) => (
            <button
              key={tab.id}
              type="button"
              onClick={() => setFilterType(tab.id)}
              className={`rounded-xl px-3 py-1.5 text-xs font-semibold transition-colors ${
                filterType === tab.id
                  ? 'bg-[#1B5E20] text-white shadow-xs'
                  : 'bg-bhoomi-surface border border-bhoomi-border text-slate-600 hover:bg-[#F8FAFC]'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Timeline List */}
      <div className="space-y-3">
        {filtered.map((item) => (
          <Card
            key={item.id}
            className="p-4 rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-xs hover:border-bhoomi-primary/40 transition-all space-y-2.5"
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
              <div className="flex items-center gap-2.5">
                {getActionBadge(item.type)}
                <span className="font-mono text-xs font-bold text-slate-900">{item.case_id}</span>
                <span className="text-xs text-slate-500">· by {item.agronomist}</span>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-[11px] text-slate-400 flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  {new Date(item.timestamp).toLocaleString()}
                </span>
                <Link
                  to={`/agronomist/cases/${item.case_id}`}
                  className="inline-flex items-center gap-1 text-xs font-bold text-emerald-700 hover:text-emerald-800"
                >
                  <span>View</span>
                  <ArrowRight className="h-3 w-3" />
                </Link>
              </div>
            </div>

            <p className="text-xs font-bold text-slate-800 leading-snug">{item.description}</p>
            <p className="text-[11px] text-slate-600 leading-relaxed bg-[#F8FAFC] p-2.5 rounded-xl border border-slate-100">
              {item.details}
            </p>
          </Card>
        ))}
      </div>
    </div>
  );
}
