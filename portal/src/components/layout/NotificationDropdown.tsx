import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Bell,
  CheckCheck,
  AlertTriangle,
  FileText,
  Radio,
  Clock,
  ArrowRight,
  ExternalLink,
} from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { useAuth } from '@/features/auth/hooks';

export interface NotificationItem {
  id: string;
  title: string;
  description: string;
  time: string;
  unread: boolean;
  type: 'escalation' | 'alert' | 'clarification' | 'accuracy';
  link: string;
}

export function NotificationDropdown() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const isAgronomist = user?.role === 'agronomist';

  const defaultNotifications: NotificationItem[] = isAgronomist
    ? [
        {
          id: 'notif_1',
          title: 'New Escalated Case: Paddy Blast',
          description: 'High severity spindle lesions reported in Thanjavur. SLA: < 15m.',
          time: '5m ago',
          unread: true,
          type: 'escalation',
          link: '/agronomist/cases/case_demo_001',
        },
        {
          id: 'notif_2',
          title: 'Clarification Photo Received',
          description: 'Farmer uploaded sunlight close-up for case_kvk_702.',
          time: '25m ago',
          unread: true,
          type: 'clarification',
          link: '/agronomist/under-review',
        },
        {
          id: 'notif_3',
          title: 'Pink Bollworm Regional Warning',
          description: 'Spore cloud simulation active for 48 farms in Nashik buffer.',
          time: '1h ago',
          unread: false,
          type: 'alert',
          link: '/agronomist/logs',
        },
      ]
    : [
        {
          id: 'notif_4',
          title: 'New Hotspot Cluster Confirmed',
          description: '14 confirmed Paddy Blast cases in Baramati cluster.',
          time: '10m ago',
          unread: true,
          type: 'alert',
          link: '/official/hotspots',
        },
        {
          id: 'notif_5',
          title: 'High Confidence Confirmation',
          description: 'Cotton Pink Bollworm flagged with 92% confidence in Dindori.',
          time: '35m ago',
          unread: true,
          type: 'escalation',
          link: '/official/queue',
        },
        {
          id: 'notif_6',
          title: 'Diagnostic Accuracy Bulletin',
          description: 'Monthly model accuracy verified at 93.3% across Maharashtra.',
          time: '2h ago',
          unread: false,
          type: 'accuracy',
          link: '/official/accuracy',
        },
      ];

  const [notifications, setNotifications] = useState<NotificationItem[]>(defaultNotifications);

  const unreadCount = notifications.filter((n) => n.unread).length;

  // Handle outside click to close
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, unread: false })));
  };

  const handleNotificationClick = (item: NotificationItem) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === item.id ? { ...n, unread: false } : n))
    );
    setIsOpen(false);
    navigate(item.link);
  };

  const getIcon = (type: NotificationItem['type']) => {
    switch (type) {
      case 'escalation':
        return <FileText className="h-4 w-4 text-emerald-600" />;
      case 'clarification':
        return <AlertTriangle className="h-4 w-4 text-amber-600" />;
      case 'accuracy':
        return <ExternalLink className="h-4 w-4 text-blue-600" />;
      case 'alert':
      default:
        return <Radio className="h-4 w-4 text-red-600" />;
    }
  };

  return (
    <div className="relative" ref={dropdownRef}>
      {/* Bell Button */}
      <button
        type="button"
        aria-label="Notifications"
        aria-expanded={isOpen}
        onClick={() => setIsOpen(!isOpen)}
        className="relative flex h-9 w-9 items-center justify-center rounded-full text-bhoomi-text-secondary hover:bg-bhoomi-canvas hover:text-bhoomi-text-primary transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-bhoomi-primary"
      >
        <Bell className="h-5 w-5" />
        {unreadCount > 0 && (
          <span className="absolute top-2 right-2 flex h-2.5 w-2.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500 ring-2 ring-white" />
          </span>
        )}
      </button>

      {/* Notification Dropdown Card */}
      {isOpen && (
        <div className="absolute right-0 mt-2.5 w-84 sm:w-96 rounded-2xl border border-bhoomi-border bg-bhoomi-surface shadow-xl z-50 overflow-hidden animate-in fade-in zoom-in-95 duration-150">
          {/* Dropdown Header */}
          <div className="flex items-center justify-between p-4 border-b border-bhoomi-border bg-[#F8FAFC]">
            <div className="flex items-center gap-2">
              <span className="font-bold text-sm text-bhoomi-text-primary">Notifications</span>
              {unreadCount > 0 && (
                <Badge variant="primary" size="sm" className="font-bold text-[10px] px-2 py-0.5">
                  {unreadCount} New
                </Badge>
              )}
            </div>

            {unreadCount > 0 && (
              <button
                type="button"
                onClick={markAllAsRead}
                className="flex items-center gap-1 text-xs font-semibold text-emerald-700 hover:text-emerald-800 transition-colors"
              >
                <CheckCheck className="h-3.5 w-3.5" />
                <span>Mark all as read</span>
              </button>
            )}
          </div>

          {/* Notifications List */}
          <div className="max-h-[380px] overflow-y-auto divide-y divide-slate-100">
            {notifications.length === 0 ? (
              <div className="p-8 text-center text-xs text-bhoomi-text-muted">
                No notifications right now.
              </div>
            ) : (
              notifications.map((item) => (
                <div
                  key={item.id}
                  onClick={() => handleNotificationClick(item)}
                  className={`flex items-start gap-3 p-3.5 cursor-pointer transition-colors hover:bg-[#F8FAFC] ${
                    item.unread ? 'bg-emerald-50/30' : ''
                  }`}
                >
                  <div
                    className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-xl border mt-0.5 ${
                      item.unread
                        ? 'bg-emerald-50 border-emerald-200'
                        : 'bg-slate-50 border-slate-200'
                    }`}
                  >
                    {getIcon(item.type)}
                  </div>

                  <div className="flex-1 min-w-0 space-y-1">
                    <div className="flex items-center justify-between gap-1">
                      <p
                        className={`text-xs truncate ${
                          item.unread
                            ? 'font-bold text-slate-900'
                            : 'font-semibold text-slate-700'
                        }`}
                      >
                        {item.title}
                      </p>
                      {item.unread && (
                        <span className="h-2 w-2 shrink-0 rounded-full bg-emerald-500" />
                      )}
                    </div>

                    <p className="text-[11px] text-slate-600 line-clamp-2 leading-relaxed">
                      {item.description}
                    </p>

                    <div className="flex items-center justify-between pt-1 text-[10px] text-slate-400">
                      <span className="flex items-center gap-1">
                        <Clock className="h-3 w-3" />
                        {item.time}
                      </span>
                      <span className="font-semibold text-emerald-700 flex items-center gap-0.5">
                        View <ArrowRight className="h-2.5 w-2.5" />
                      </span>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Footer */}
          <div className="p-2.5 bg-[#F8FAFC] border-t border-bhoomi-border text-center">
            <span className="text-[11px] text-slate-500 font-medium">
              BHOOMI Live Crop Health Notification Feed
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
