import { CaseQueueItem } from '@/types/api';
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from '@/components/ui/Table';
import { Skeleton } from '@/components/ui/Skeleton';
import { CaseQueueRow } from './CaseQueueRow';

export interface CaseQueueTableProps {
  cases: CaseQueueItem[];
  isLoading?: boolean;
}

export function CaseQueueTable({ cases, isLoading }: CaseQueueTableProps) {
  return (
    <div className="rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-card overflow-hidden transition-all">
      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow className="bg-[#F8FAFC] hover:bg-[#F8FAFC] border-b border-bhoomi-border">
              <TableHead className="w-20 font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Queue #
              </TableHead>
              <TableHead className="w-36 min-w-[140px] font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Case ID
              </TableHead>
              <TableHead className="min-w-[200px] font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Target Problem
              </TableHead>
              <TableHead className="w-44 font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Region
              </TableHead>
              <TableHead className="w-28 font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Status
              </TableHead>
              <TableHead className="w-40 font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Received
              </TableHead>
              <TableHead className="w-28 text-right font-bold text-slate-500 text-[11px] uppercase tracking-wider py-3.5">
                Action
              </TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {isLoading ? (
              Array.from({ length: 5 }).map((_, index) => (
                <TableRow key={`skeleton-row-${index}`}>
                  <TableCell>
                    <Skeleton className="h-6 w-10 rounded-lg" />
                  </TableCell>
                  <TableCell>
                    <Skeleton className="h-4 w-28 rounded-md" />
                  </TableCell>
                  <TableCell>
                    <Skeleton className="h-5 w-48 rounded-md" />
                  </TableCell>
                  <TableCell>
                    <Skeleton className="h-4 w-24 rounded-md" />
                  </TableCell>
                  <TableCell>
                    <Skeleton className="h-5 w-16 rounded-full" />
                  </TableCell>
                  <TableCell>
                    <Skeleton className="h-4 w-24 rounded-md" />
                  </TableCell>
                  <TableCell className="text-right">
                    <Skeleton className="h-8 w-16 ml-auto rounded-xl" />
                  </TableCell>
                </TableRow>
              ))
            ) : (
              cases.map((caseItem) => (
                <CaseQueueRow key={caseItem.case_id} item={caseItem} />
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
