import React, { useState } from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { Switch } from '@headlessui/react';
import clsx from 'clsx';
import {
  HomeIcon,
  UserGroupIcon,
  BuildingOfficeIcon,
  ClockIcon,
  CurrencyYenIcon,
  DocumentTextIcon,
  UserPlusIcon,
  ArrowRightOnRectangleIcon,
  Bars3Icon,
  XMarkIcon,
  ArrowUpTrayIcon
} from '@heroicons/react/24/outline';
import { PageKey, usePageVisibility } from '../context/PageVisibilityContext';

type NavigationItem = {
  key: PageKey;
  name: string;
  href: string;
  icon: typeof HomeIcon;
};

const Layout: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();
  const { isPageVisible, togglePage } = usePageVisibility();

  const navigation: NavigationItem[] = [
    { key: 'dashboard', name: 'ダッシュボード', href: '/dashboard', icon: HomeIcon },
    { key: 'candidates', name: '履歴書管理', href: '/candidates', icon: UserPlusIcon },
    { key: 'pendingApproval', name: '承認待ち', href: '/pending-approval', icon: ClockIcon },
    { key: 'employees', name: '従業員管理', href: '/employees', icon: UserGroupIcon },
    {
      key: 'employeesExtended',
      name: '従業員管理（詳細）',
      href: '/employees-extended',
      icon: UserGroupIcon,
    },
    { key: 'importData', name: 'データインポート', href: '/import-data', icon: ArrowUpTrayIcon },
    { key: 'factories', name: '企業管理', href: '/factories', icon: BuildingOfficeIcon },
    { key: 'timerCards', name: 'タイムカード', href: '/timer-cards', icon: ClockIcon },
    { key: 'salary', name: '給与計算', href: '/salary', icon: CurrencyYenIcon },
    { key: 'requests', name: '申請管理', href: '/requests', icon: DocumentTextIcon },
  ];

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <div className="relative min-h-screen overflow-hidden" style={{ background: 'var(--color-background-base)' }}>
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute -left-32 -top-40 h-72 w-72 rounded-full blur-3xl" style={{ background: 'var(--color-primary)', opacity: '0.15' }} />
        <div className="absolute right-[-18%] top-1/3 h-[28rem] w-[28rem] rounded-full blur-[120px]" style={{ background: 'var(--color-secondary)', opacity: '0.2' }} />
        <div className="absolute bottom-[-20%] left-1/4 h-96 w-96 rounded-full blur-[120px]" style={{ background: 'var(--color-accent)', opacity: '0.15' }} />
      </div>

      {/* Top Navigation */}
      <nav className="fixed inset-x-0 top-0 z-40 px-4 pt-4 sm:px-6 lg:px-10">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between rounded-2xl border px-4 shadow-lg backdrop-blur" style={{
          backgroundColor: 'var(--color-background-highlight)',
          borderColor: 'var(--color-border-base)',
          boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)'
        }}>
          <div className="flex items-center gap-4">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              aria-label={sidebarOpen ? 'サイドバーを閉じる' : 'サイドバーを開く'}
              className="flex h-11 w-11 items-center justify-center rounded-xl border transition hover:opacity-80 focus:outline-none focus:ring-2 focus:ring-offset-2"
              style={{
                backgroundColor: 'var(--color-background-highlight)',
                borderColor: 'var(--color-border-muted)',
                color: 'var(--color-text-muted)',
                '--hover-color': 'var(--color-primary)',
                '--focus-ring-color': 'var(--color-primary)',
                '--focus-ring-offset-color': 'var(--color-background-highlight)'
              } as React.CSSProperties}
            >
              {sidebarOpen ? (
                <XMarkIcon className="h-6 w-6" />
              ) : (
                <Bars3Icon className="h-6 w-6" />
              )}
            </button>
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center">
                <img
                  src="/uns-logo.gif"
                  alt="UNS Logo"
                  className="h-12 w-auto object-contain"
                />
              </div>
              <div>
                <p className="text-lg font-semibold" style={{ color: 'var(--color-text-base)' }}>UNS-ClaudeJP 3.0</p>
                <p className="text-xs" style={{ color: 'var(--color-text-muted)' }}>人材管理インテリジェンスプラットフォーム</p>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-3 ml-auto">
            <div className="hidden text-right sm:flex sm:flex-col">
              <span className="text-xs font-semibold uppercase tracking-[0.2em]" style={{ color: 'var(--color-text-muted)' }}>ログイン中</span>
              <span className="text-sm font-semibold" style={{ color: 'var(--color-text-base)' }}>管理者</span>
            </div>
            <button
              onClick={handleLogout}
              className="inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-semibold shadow-md transition hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-offset-1"
              style={{
                background: 'var(--color-danger)',
                color: 'var(--color-text-inverted)',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
                '--focus-ring-color': 'var(--color-danger)',
                '--focus-ring-offset-color': 'var(--color-background-highlight)'
              } as React.CSSProperties}
            >
              <ArrowRightOnRectangleIcon className="h-4 w-4" />
              ログアウト
            </button>
          </div>
        </div>
      </nav>

      {/* Sidebar & Main */}
      <div className="relative z-10 flex pt-24">
        <div
          className={`${sidebarOpen ? 'w-56' : 'w-0'} transition-all duration-500 ease-in-out`}
        >
          <aside
            className={`pointer-events-auto fixed top-24 bottom-4 left-4 right-auto z-30 flex h-[calc(100vh-7rem)] w-56 flex-col overflow-hidden rounded-3xl border p-3 shadow-2xl backdrop-blur transition-transform duration-500 ease-[cubic-bezier(0.4,0,0.2,1)] ${
              sidebarOpen ? 'translate-x-0 opacity-100' : '-translate-x-[120%] opacity-0'
            } sm:left-4 lg:left-6`}
            style={{
              backgroundColor: 'var(--color-background-highlight)',
              borderColor: 'var(--color-border-base)',
              boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)'
            }}
          >
            <div className="flex items-center justify-between pb-4">
              <p className="text-xs font-semibold uppercase tracking-[0.25em]" style={{ color: 'var(--color-text-muted)' }}>Navigation</p>
              <span className="rounded-full px-3 py-1 text-[0.65rem] font-semibold" style={{
                backgroundColor: 'var(--color-background-muted)',
                color: 'var(--color-text-muted)'
              }}>HR Suite</span>
            </div>
            <nav className="flex flex-1 flex-col gap-1.5 overflow-y-auto pr-1">
              {navigation.map((item) => {
                const isActive =
                  location.pathname === item.href || location.pathname.startsWith(item.href + '/');
                const isVisible = isPageVisible(item.key);

                return (
                  <div
                    key={item.key}
                    className={clsx(
                      'group relative flex items-center gap-2 rounded-xl px-3 py-2.5 text-sm font-semibold transition-all duration-300',
                      isVisible
                        ? isActive
                          ? 'shadow-md ring-1'
                          : 'hover:shadow-sm'
                        : 'border border-dashed shadow-none'
                    )}
                    style={{
                      backgroundColor: isVisible
                        ? isActive
                          ? 'var(--color-primary)'
                          : 'transparent'
                        : 'var(--color-warning)',
                      color: isVisible
                        ? isActive
                          ? 'var(--color-text-inverted)'
                          : 'var(--color-text-base)'
                        : 'var(--color-text-base)',
                      borderColor: isVisible
                        ? 'transparent'
                        : 'var(--color-warning)',
                      boxShadow: isVisible
                        ? isActive
                          ? `0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)`
                          : '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)'
                        : 'none',
                      ringColor: isVisible
                        ? isActive
                          ? 'var(--color-primary)'
                          : 'transparent'
                        : 'transparent'
                    } as React.CSSProperties}
                  >
                    <Link
                      to={item.href}
                      onClick={(event) => {
                        if (!isVisible) {
                          event.preventDefault();
                        }
                      }}
                      aria-disabled={!isVisible}
                      tabIndex={isVisible ? 0 : -1}
                      className="flex flex-1 items-center gap-2.5 min-w-0 focus:outline-none"
                    >
                      <span
                        className={clsx(
                          'flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-lg border transition',
                          isVisible
                            ? isActive
                              ? ''
                              : 'group-hover:opacity-80'
                            : ''
                        )}
                        style={{
                          backgroundColor: isVisible
                            ? isActive
                              ? 'var(--color-background-highlight)'
                              : 'var(--color-background-muted)'
                            : 'var(--color-background-highlight)',
                          borderColor: isVisible
                            ? isActive
                              ? 'var(--color-primary)'
                              : 'var(--color-border-muted)'
                            : 'var(--color-warning)',
                          color: isVisible
                            ? isActive
                              ? 'var(--color-primary)'
                              : 'var(--color-text-muted)'
                            : 'var(--color-warning)'
                        } as React.CSSProperties}
                      >
                        <item.icon className="h-5 w-5" />
                      </span>
                      <span className="truncate text-sm">{item.name}</span>
                    </Link>
                    <Switch
                      checked={isVisible}
                      onChange={() => togglePage(item.key)}
                      className={clsx(
                        'relative inline-flex h-5 w-9 flex-shrink-0 cursor-pointer items-center rounded-full border-2 transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:ring-offset-1 focus:ring-offset-white',
                        isVisible
                          ? 'border-indigo-300 bg-indigo-500'
                          : 'border-gray-300 bg-gray-200'
                      )}
                    >
                      <span className="sr-only">Cambiar visibilidad de {item.name}</span>
                      <span
                        aria-hidden="true"
                        className={clsx(
                          'inline-block h-4 w-4 transform rounded-full bg-white shadow-sm ring-0 transition-transform duration-200 ease-in-out',
                          isVisible ? 'translate-x-4' : 'translate-x-0'
                        )}
                      />
                    </Switch>
                    {isActive && isVisible && (
                      <span className="absolute inset-y-1 left-0.5 w-1 rounded-full" aria-hidden="true" style={{ backgroundColor: 'var(--color-primary)' }} />
                    )}
                  </div>
                );
              })}
            </nav>
            <div className="mt-6 rounded-2xl border border-dashed p-4 text-xs font-medium" style={{
              backgroundColor: 'var(--color-background-muted)',
              borderColor: 'var(--color-border-muted)',
              color: 'var(--color-text-muted)'
            }}>
              卓越した人材エクスペリエンスを実現するためのインサイトを提供します。
            </div>
          </aside>
        </div>

        <main
          className={`flex-1 px-4 pb-8 transition-all duration-500 sm:px-6 lg:px-8 ${
            sidebarOpen ? 'md:ml-50' : 'md:ml-0'
          }`}
        >
          <div className="mx-auto w-full max-w-5xl space-y-4 pl-2">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};

export default Layout;
