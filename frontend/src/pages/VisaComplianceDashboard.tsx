import { useEffect, useState } from 'react';
import { ChartBarIcon, ExclamationTriangleIcon, ShieldCheckIcon } from '@heroicons/react/24/outline';

import LayoutSimple from '../components/LayoutSimple';
import VisaAlert from '../components/VisaAlert';
import { fetchVisaComplianceSummary, VisaComplianceSummary } from '../services/visaComplianceService';

const SummaryCard = ({
  title,
  value,
  subtitle,
  icon: Icon,
  accent,
}: {
  title: string;
  value: string;
  subtitle: string;
  icon: typeof ChartBarIcon;
  accent: string;
}) => (
  <div className={`rounded-xl border border-slate-200 bg-gradient-to-br p-6 shadow-sm ${accent}`}>
    <div className="flex items-center justify-between">
      <div>
        <h3 className="text-sm font-medium text-slate-600">{title}</h3>
        <p className="mt-2 text-3xl font-bold text-slate-900">{value}</p>
        <p className="mt-1 text-xs text-slate-500">{subtitle}</p>
      </div>
      <div className="rounded-full bg-slate-100 p-3 text-slate-500">
        <Icon className="h-6 w-6" />
      </div>
    </div>
  </div>
);

const VisaComplianceDashboard = () => {
  const [summary, setSummary] = useState<VisaComplianceSummary | null>(null);

  useEffect(() => {
    fetchVisaComplianceSummary().then(setSummary);
  }, []);

  return (
    <LayoutSimple title="ビザ・コンプライアンスダッシュボード" subtitle="在留カードの有効期限とリスクを一元管理">
      <div className="space-y-8">
        <div className="grid gap-6 md:grid-cols-3">
          <SummaryCard
            title="更新期限が近いビザ"
            value={`${summary?.expiring.days30 ?? 0} / ${summary?.expiring.days60 ?? 0} / ${summary?.expiring.days90 ?? 0}`}
            subtitle="30日 / 60日 / 90日"
            icon={ExclamationTriangleIcon}
            accent="from-red-50 to-white"
          />
          <SummaryCard
            title="就労制限のある従業員"
            value={`${summary?.restrictions.restrictedAssignments ?? 0}`}
            subtitle={`${summary?.restrictions.outOfPolicyAssignments ?? 0} 件が配置見直しを要します`}
            icon={ShieldCheckIcon}
            accent="from-amber-50 to-white"
          />
          <SummaryCard
            title="申請ステータス"
            value={`${summary?.pendingApplications ?? 0} pending`}
            subtitle={`成功: ${summary?.successfulRenewals ?? 0} / 拒否: ${summary?.rejectedRenewals ?? 0}`}
            icon={ChartBarIcon}
            accent="from-emerald-50 to-white"
          />
        </div>

        <section className="rounded-2xl border border-slate-200 bg-white/80 p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-slate-800">在留期限アラート</h2>
          <p className="mt-1 text-sm text-slate-500">90/60/30日で自動通知。ImmigrationTrackingService と連携予定。</p>
          <div className="mt-4 space-y-3">
            {summary?.upcomingAlerts.map((alert) => (
              <div
                key={alert.employeeId}
                className="flex items-center justify-between rounded-xl border border-slate-100 bg-slate-50/60 p-4"
              >
                <div>
                  <p className="text-sm font-semibold text-slate-800">{alert.name}</p>
                  <p className="text-xs text-slate-500">{alert.visaType}</p>
                </div>
                <VisaAlert expiryDate={alert.expiryDate} />
              </div>
            ))}
          </div>
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white/80 p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-slate-800">更新履歴</h2>
          <p className="mt-1 text-sm text-slate-500">成功率の推移を追跡し、拒否理由を記録。</p>
          <div className="mt-4 grid gap-4 md:grid-cols-2">
            <div className="rounded-xl border border-emerald-100 bg-emerald-50/80 p-4">
              <p className="text-sm font-medium text-emerald-700">成功した更新</p>
              <p className="mt-2 text-3xl font-bold text-emerald-900">{summary?.successfulRenewals ?? 0}</p>
              <p className="mt-1 text-xs text-emerald-700">Immigration Services Agency との連携による自動計測</p>
            </div>
            <div className="rounded-xl border border-rose-100 bg-rose-50/80 p-4">
              <p className="text-sm font-medium text-rose-700">拒否された更新</p>
              <p className="mt-2 text-3xl font-bold text-rose-900">{summary?.rejectedRenewals ?? 0}</p>
              <p className="mt-1 text-xs text-rose-700">AI OCR による事前検証で再申請を最適化</p>
            </div>
          </div>
        </section>
      </div>
    </LayoutSimple>
  );
};

export default VisaComplianceDashboard;
