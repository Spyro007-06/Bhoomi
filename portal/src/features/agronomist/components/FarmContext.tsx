import { Sprout, MapPin } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/Card';
import { FarmSummary } from '@/types/api';

interface FarmContextProps {
  farm: FarmSummary;
}

const FARMER_NAMES_BY_FARM: Record<string, string> = {
  farm_demo_001: 'Lakshmi Narayanan',
  farm_demo_002: 'Sopanrao Deshmukh',
  farm_demo_003: 'Babasaheb Patil',
  farm_demo_004: 'Hanmantrao Shinde',
};

export function FarmContext({ farm }: FarmContextProps) {
  // Farmer display name
  const farmerName =
    'farmer_name' in farm && typeof (farm as Record<string, unknown>).farmer_name === 'string'
      ? ((farm as Record<string, unknown>).farmer_name as string)
      : FARMER_NAMES_BY_FARM[farm.id] || 'Lakshmi Narayanan';

  return (
    <Card className="rounded-2xl border border-bhoomi-border bg-bhoomi-surface p-5 shadow-card overflow-hidden">
      {/* Header with Verified Land Badge */}
      <div className="flex items-center justify-between pb-4 border-b border-bhoomi-border/60">
        <div className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-emerald-50 text-emerald-700">
            <Sprout className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-bhoomi-text-primary">Farm Context</h3>
        </div>

        <span className="inline-flex items-center rounded-full border border-[#86EFAC] bg-[#DCFCE7] px-3 py-0.5 text-[10px] font-extrabold uppercase tracking-wider text-[#15803D]">
          VERIFIED LAND
        </span>
      </div>

      {/* 4 Stat Boxes Horizontal Grid */}
      <CardContent className="p-0 pt-4 grid grid-cols-2 gap-3 sm:grid-cols-4">
        {/* Farmer Name */}
        <div className="rounded-xl bg-[#F8FAFC] border border-bhoomi-border/70 p-3">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            FARMER NAME
          </span>
          <p className="text-xs font-bold text-bhoomi-text-primary mt-1 truncate">
            {farmerName}
          </p>
          <span className="text-[10px] font-mono text-slate-400 mt-0.5 block">{farm.id}</span>
        </div>

        {/* Crop & Variety */}
        <div className="rounded-xl bg-[#F8FAFC] border border-bhoomi-border/70 p-3">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            CROP &amp; VARIETY
          </span>
          <p className="text-xs font-bold text-bhoomi-text-primary capitalize mt-1 truncate">
            {farm.crop}
            {farm.variety ? ` (${farm.variety})` : ''}
          </p>
        </div>

        {/* Growth Stage */}
        <div className="rounded-xl bg-[#F8FAFC] border border-bhoomi-border/70 p-3">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            GROWTH STAGE
          </span>
          <p className="text-xs font-bold text-bhoomi-text-primary capitalize mt-1 truncate">
            {farm.growth_stage}
          </p>
        </div>

        {/* Location */}
        <div className="rounded-xl bg-[#F8FAFC] border border-bhoomi-border/70 p-3">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
            LOCATION
          </span>
          <p className="text-xs font-bold text-bhoomi-text-primary mt-1 flex items-center gap-1 truncate">
            <MapPin className="h-3 w-3 shrink-0 text-slate-400" />
            <span className="truncate">{farm.region || 'Thanjavur, Tamil Nadu'}</span>
          </p>
        </div>
      </CardContent>
    </Card>
  );
}
