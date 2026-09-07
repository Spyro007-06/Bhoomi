import { DashboardHeader } from '../components/DashboardHeader';
import { HotspotPreview } from '../components/HotspotPreview';
import { AccuracyPreview } from '../components/AccuracyPreview';
import { QueuePreview } from '../components/QueuePreview';

export function OfficialsDashboardPage() {
  return (
    <div className="flex-1 p-6 pb-20 bg-bhoomi-canvas min-w-0 max-w-[1600px] mx-auto w-full space-y-6">
      <DashboardHeader 
        title="Agriculture Officials Dashboard" 
        subtitle="Operational overview of outbreak intelligence and model performance."
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-stretch">
        <section className="lg:col-span-2 flex flex-col">
          <HotspotPreview />
        </section>
        
        <section className="lg:col-span-1 flex flex-col">
          <AccuracyPreview />
        </section>

        <section className="lg:col-span-3">
          <QueuePreview />
        </section>
      </div>
    </div>
  );
}
