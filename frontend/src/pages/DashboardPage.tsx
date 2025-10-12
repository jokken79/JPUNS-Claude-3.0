import React from 'react';
import { Link } from 'react-router-dom';

const DashboardPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Navbar moderno actualizado */}
      <nav className="bg-gradient-to-r from-indigo-600 via-purple-600 to-blue-600 text-white shadow-xl">
        <div className="container mx-auto px-6 py-4">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold tracking-tight">UNS-ClaudeJP 2.5</h1>
              <p className="text-indigo-100 text-sm font-medium">Sistema de Gestión de Personal Temporal</p>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-indigo-100">版 2025.10.12</span>
              <button className="bg-white/20 hover:bg-white/30 px-4 py-2 rounded-lg transition-colors">
                設定
              </button>
            </div>
          </div>
        </div>
      </nav>

      <div className="container mx-auto p-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-2">ダッシュボード</h2>
          <p className="text-gray-600">システム機能を選択してください</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <Link
            to="/rirekisho"
            className="group bg-white p-8 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100"
          >
            <div className="text-indigo-600 text-6xl mb-6 group-hover:scale-110 transition-transform">📋</div>
            <h2 className="text-2xl font-bold mb-3 text-gray-800">履歴書</h2>
            <p className="text-gray-600 leading-relaxed">Rirekisho - Formulario de CV con OCR automático</p>
            <div className="mt-4 text-indigo-600 font-medium group-hover:text-indigo-800">
              開く →
            </div>
          </Link>

          <div className="group bg-white p-8 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100 cursor-pointer">
            <div className="text-green-600 text-6xl mb-6 group-hover:scale-110 transition-transform">👥</div>
            <h2 className="text-2xl font-bold mb-3 text-gray-800">候補者</h2>
            <p className="text-gray-600 leading-relaxed">Gestión completa de candidatos y empleados</p>
            <div className="mt-4 text-green-600 font-medium group-hover:text-green-800">
              近日公開 →
            </div>
          </div>

          <div className="group bg-white p-8 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100 cursor-pointer">
            <div className="text-blue-600 text-6xl mb-6 group-hover:scale-110 transition-transform">🏭</div>
            <h2 className="text-2xl font-bold mb-3 text-gray-800">工場</h2>
            <p className="text-gray-600 leading-relaxed">Administración de fábricas y configuraciones</p>
            <div className="mt-4 text-blue-600 font-medium group-hover:text-blue-800">
              近日公開 →
            </div>
          </div>

          <div className="group bg-white p-8 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100 cursor-pointer">
            <div className="text-yellow-600 text-6xl mb-6 group-hover:scale-110 transition-transform">💰</div>
            <h2 className="text-2xl font-bold mb-3 text-gray-800">給与</h2>
            <p className="text-gray-600 leading-relaxed">Cálculo automático de nóminas y reportes</p>
            <div className="mt-4 text-yellow-600 font-medium group-hover:text-yellow-800">
              近日公開 →
            </div>
          </div>

          <div className="group bg-white p-8 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100 cursor-pointer">
            <div className="text-purple-600 text-6xl mb-6 group-hover:scale-110 transition-transform">📊</div>
            <h2 className="text-2xl font-bold mb-3 text-gray-800">レポート</h2>
            <p className="text-gray-600 leading-relaxed">Estadísticas detalladas y análisis</p>
            <div className="mt-4 text-purple-600 font-medium group-hover:text-purple-800">
              近日公開 →
            </div>
          </div>

          <div className="group bg-white p-8 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100 cursor-pointer">
            <div className="text-red-600 text-6xl mb-6 group-hover:scale-110 transition-transform">⚙️</div>
            <h2 className="text-2xl font-bold mb-3 text-gray-800">設定</h2>
            <p className="text-gray-600 leading-relaxed">Configuración del sistema y preferencias</p>
            <div className="mt-4 text-red-600 font-medium group-hover:text-red-800">
              近日公開 →
            </div>
          </div>
        </div>

        {/* Footer informativo */}
        <div className="mt-16 text-center">
          <div className="bg-white/50 backdrop-blur-sm rounded-2xl p-6 inline-block">
            <p className="text-gray-600 font-medium">
              🚀 Sistema actualizado - Versión 2025.10.12
            </p>
            <p className="text-sm text-gray-500 mt-2">
              Si ves diseños antiguos, usa Ctrl+F5 para refrescar completamente
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
