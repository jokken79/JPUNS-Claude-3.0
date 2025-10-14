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
  ArrowUpTrayIcon,
  ServerIcon
} from '@heroicons/react/24/outline';
import { PageKey, usePageVisibility } from '../context/PageVisibilityContext';
import '../styles/Layout.css';

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
    { key: 'database', name: 'DateBaseJP', href: '/database', icon: ServerIcon },
    { key: 'adminer', name: 'Adminer DBJP', href: '/adminer', icon: ServerIcon },
  ];

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <div className="layout-background">
      <div className="pointer-events-none absolute inset-0">
        <div className="gradient-1" />
        <div className="gradient-2" />
        <div className="gradient-3" />
      </div>

      {/* Top Navigation */}
      <nav className="top-nav">
        <div className="nav-container">
          <div className="flex items-center gap-4">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              aria-label={sidebarOpen ? 'サイドバーを閉じる' : 'サイドバーを開く'}
              className="sidebar-toggle"
            >
              {sidebarOpen ? (
                <XMarkIcon className="h-6 w-6" />
              ) : (
                <Bars3Icon className="h-6 w-6" />
              )}
            </button>
            <div className="logo-section">
              <div className="logo-container">
                <img
                  src="/uns-logo.gif"
                  alt="UNS Logo"
                  className="h-12 w-auto object-contain"
                />
              </div>
              <div className="logo-text">
                <p className="app-title">UNS-ClaudeJP 3.0</p>
                <p className="app-subtitle">人材管理インテリジェンスプラットフォーム</p>
              </div>
            </div>
          </div>
          <div className="user-section">
            <div className="user-info">
              <span className="login-label">ログイン中</span>
              <span className="user-name">管理者</span>
            </div>
            <button
              onClick={handleLogout}
              className="logout-button"
            >
              <ArrowRightOnRectangleIcon className="h-4 w-4" />
              ログアウト
            </button>
          </div>
        </div>
      </nav>

      {/* Sidebar & Main */}
      <div className="main-layout">
        <div className={`sidebar-container ${sidebarOpen ? 'open' : 'closed'}`}>
          <aside className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
            <div className="sidebar-header">
              <p className="sidebar-title">Navigation</p>
              <span className="sidebar-badge">HR Suite</span>
            </div>
            <nav className="sidebar-nav">
              {navigation.map((item) => {
                const isActive =
                  location.pathname === item.href || location.pathname.startsWith(item.href + '/');
                const isVisible = isPageVisible(item.key);

                return (
                  <div
                    key={item.key}
                    className={clsx(
                      'nav-item',
                      isVisible ? 'visible' : 'hidden',
                      isActive && isVisible ? 'active' : ''
                    )}
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
                      className="nav-link"
                    >
                      <span className={clsx(
                        'nav-icon',
                        isVisible && !isActive ? 'group-hover:opacity-80' : ''
                      )}>
                        <item.icon className="h-5 w-5" />
                      </span>
                      <span className="nav-text">{item.name}</span>
                    </Link>
                    <Switch
                      checked={isVisible}
                      onChange={() => togglePage(item.key)}
                      className={clsx(
                        'visibility-toggle',
                        isVisible ? 'checked' : 'unchecked'
                      )}
                    >
                      <span className="sr-only">Cambiar visibilidad de {item.name}</span>
                      <span
                        aria-hidden="true"
                        className={clsx(
                          'toggle-thumb',
                          isVisible ? 'translate-x-4' : 'translate-x-0'
                        )}
                      />
                    </Switch>
                    {isActive && isVisible && (
                      <span className="absolute inset-y-1 left-0.5 w-1 rounded-full" aria-hidden="true" />
                    )}
                  </div>
                );
              })}
            </nav>
            <div className="sidebar-footer">
              卓越した人材エクスペリエンスを実現するためのインサイトを提供します。
            </div>
          </aside>
        </div>

        <main className={`main-content ${sidebarOpen ? 'sidebar-open' : 'sidebar-closed'}`}>
          <div className="content-container">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};

export default Layout;
