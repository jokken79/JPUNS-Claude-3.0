import React, { Suspense } from 'react';
import useDashboardData from '../hooks/useDashboardData';
import { StatsGridSkeleton, AlertSkeleton, ActivitySkeleton, FactoriesTableSkeleton, } from '../components/skeletons';
import ThemeSwitcher from '../components/ThemeSwitcher';
import ThemeTest from '../components/ThemeTest';
import ThemeDemo from '../components/ThemeDemo';
import { useTheme } from '../context/ThemeContext';

const StatsGrid = React.lazy(() => import('../components/dashboard/StatsGrid'));
const Alerts = React.lazy(() => import('../components/dashboard/Alerts'));
const RecentActivities = React.lazy(() => import('../components/dashboard/RecentActivities'));
const TopFactories = React.lazy(() => import('../components/dashboard/TopFactories'));


const Dashboard: React.FC = () => {
  const { stats, alerts, recentActivities, topFactories, loading } = useDashboardData();
  const { theme } = useTheme();

  // Debug theme in console
  React.useEffect(() => {
    console.log('Dashboard: Current theme is:', theme);
    console.log('Dashboard: Root element classes:', document.documentElement.className);
    
    // Test if CSS variables are working
    const rootStyle = getComputedStyle(document.documentElement);
    console.log('Dashboard: Primary color variable:', rootStyle.getPropertyValue('--color-primary'));
    console.log('Dashboard: Background color variable:', rootStyle.getPropertyValue('--color-background-base'));
  }, [theme]);

  return (
    <div className="space-y-8">
      {/* Header */}
      <section className="relative overflow-hidden rounded-3xl border p-8 shadow-xl backdrop-blur" style={{
        backgroundColor: 'var(--color-background-highlight)',
        borderColor: 'var(--color-border-base)',
        boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
      }}>
        <div className="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.3em]" style={{ color: 'var(--color-primary)' }}>Insight Center</p>
            <h1 className="mt-3 text-4xl font-semibold lg:text-5xl" style={{ color: 'var(--color-text-base)' }}>ダッシュボード</h1>
            <p className="mt-4 max-w-2xl text-base" style={{ color: 'var(--color-text-muted)' }}>
              組織全体のパフォーマンス、重要アラート、最新動向をワンビューで把握。意思決定を加速させるエグゼクティブレベルの分析体験を提供します。
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-4">
            <div className="flex items-center gap-3 rounded-2xl border px-4 py-3 shadow-sm" style={{
              backgroundColor: 'var(--color-background-highlight)',
              borderColor: 'var(--color-border-muted)',
              boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)'
            }}>
              <span className="h-2 w-2 rounded-full animate-pulse" style={{ backgroundColor: 'var(--color-success)' }} />
              <div>
                <p className="text-xs font-semibold" style={{ color: 'var(--color-text-muted)' }}>システムステータス</p>
                <p className="text-sm font-semibold" style={{ color: 'var(--color-text-base)' }}>稼働中 / リアルタイム更新</p>
              </div>
            </div>
            <div className="flex items-center gap-3 rounded-2xl border px-4 py-3 shadow-sm" style={{
              backgroundColor: 'var(--color-background-highlight)',
              borderColor: 'var(--color-border-muted)',
              boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)'
            }}>
              <span className="rounded-full px-3 py-1 text-xs font-semibold" style={{
                backgroundColor: 'var(--color-primary)',
                color: 'var(--color-text-inverted)',
                opacity: 0.15
              }}>HR Excellence</span>
              <div className="text-sm font-semibold" style={{ color: 'var(--color-text-base)' }}>KPI最適化ビュー</div>
            </div>
            <ThemeSwitcher />
            {/* Debug theme info */}
            <div className="text-xs p-2 rounded border" style={{
              color: 'var(--color-text-muted)',
              backgroundColor: 'var(--color-background-highlight)',
              borderColor: 'var(--color-border-muted)'
            }}>
              <div>Tema actual: <span className="font-mono">{theme}</span></div>
              <div>Clases root: <span className="font-mono text-xs">{document.documentElement.className}</span></div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Grid */}
      <Suspense fallback={<StatsGridSkeleton />}>
        {loading ? <StatsGridSkeleton /> : <StatsGrid stats={stats} />}
      </Suspense>


      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Alerts */}
        <Suspense fallback={<AlertSkeleton />}>
            {loading ? <AlertSkeleton /> : <Alerts alerts={alerts} />}
        </Suspense>

        {/* Recent Activities */}
        <Suspense fallback={<ActivitySkeleton />}>
            {loading ? <ActivitySkeleton /> : <RecentActivities recentActivities={recentActivities} />}
        </Suspense>
      </div>

      {/* Top Factories */}
      <Suspense fallback={<FactoriesTableSkeleton />}>
        {loading ? <FactoriesTableSkeleton /> : <TopFactories topFactories={topFactories} />}
      </Suspense>

      {/* Theme Test Component */}
      <ThemeTest />

      {/* Theme Demo Component with Tailwind Classes */}
      <ThemeDemo />
    </div>
  );
};

export default Dashboard;
