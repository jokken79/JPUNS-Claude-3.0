import React, { useState } from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import {
  HomeIcon,
  DocumentTextIcon,
  UserPlusIcon,
  ArrowRightOnRectangleIcon,
  Bars3Icon,
  XMarkIcon,
  ClockIcon,
  UserGroupIcon,
  BuildingOfficeIcon,
  ArrowUpTrayIcon,
  CurrencyYenIcon,
  DocumentIcon
} from '@heroicons/react/24/outline';

const LayoutSimple: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();

  const navigation = [
    { name: 'ダッシュボード', href: '/dashboard', icon: HomeIcon },
    { name: '履歴書管理', href: '/candidates', icon: UserPlusIcon },
    { name: '承認待ち', href: '/pending-approval', icon: ClockIcon },
    { name: '従業員管理', href: '/employees', icon: UserGroupIcon },
    { name: '従業員管理（詳細）', href: '/employees-extended', icon: UserGroupIcon },
    { name: 'データインポート', href: '/import-data', icon: ArrowUpTrayIcon },
    { name: '企業管理', href: '/factories', icon: BuildingOfficeIcon },
    { name: 'タイムカード', href: '/timer-cards', icon: ClockIcon },
    { name: '給与計算', href: '/salary', icon: CurrencyYenIcon },
    { name: '申請管理', href: '/requests', icon: DocumentIcon },
  ];

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'w-64' : 'w-16'} bg-gradient-to-b from-indigo-800 to-purple-900 text-white transition-all duration-300 flex flex-col`}>
        {/* Header */}
        <div className="p-4 border-b border-indigo-700">
          <div className="flex items-center justify-between">
            {sidebarOpen && (
              <h1 className="text-xl font-bold">UNS-ClaudeJP</h1>
            )}
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="p-2 rounded-lg hover:bg-indigo-700 transition-colors"
            >
              {sidebarOpen ? <XMarkIcon className="w-5 h-5" /> : <Bars3Icon className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-2">
          {navigation.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.href;
            
            return (
              <Link
                key={item.name}
                to={item.href}
                className={`flex items-center space-x-3 px-3 py-2 rounded-lg transition-colors ${
                  isActive
                    ? 'bg-indigo-600 text-white'
                    : 'text-indigo-100 hover:bg-indigo-700 hover:text-white'
                }`}
              >
                <Icon className="w-5 h-5 flex-shrink-0" />
                {sidebarOpen && <span>{item.name}</span>}
              </Link>
            );
          })}
        </nav>

        {/* Logout */}
        <div className="p-4 border-t border-indigo-700">
          <button
            onClick={handleLogout}
            className="flex items-center space-x-3 px-3 py-2 rounded-lg text-indigo-100 hover:bg-red-600 hover:text-white transition-colors w-full"
          >
            <ArrowRightOnRectangleIcon className="w-5 h-5 flex-shrink-0" />
            {sidebarOpen && <span>ログアウト</span>}
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top bar */}
        <header className="bg-white shadow-sm border-b border-gray-200 px-6 py-4">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-semibold text-gray-900">
              {navigation.find(item => item.href === location.pathname)?.name || 'UNS-ClaudeJP 2.5'}
            </h2>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-500">版 2025.10.12</span>
              <div className="w-8 h-8 bg-indigo-600 rounded-full flex items-center justify-center">
                <UserPlusIcon className="w-4 h-4 text-white" />
              </div>
            </div>
          </div>
        </header>

        {/* Content */}
        <main className="flex-1 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default LayoutSimple;