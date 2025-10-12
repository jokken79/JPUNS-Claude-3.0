import React from 'react';

const Dashboard: React.FC = () => {
  return (
    <div className="p-8 min-h-screen bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100">
      {/* Header Simple */}
      <div className="bg-white/80 backdrop-blur rounded-3xl p-8 shadow-xl mb-8">
        <h1 className="text-4xl font-bold text-slate-900">🎯 Dashboard Moderno</h1>
        <p className="text-slate-600 mt-2">Sistema funcionando correctamente desde el backup</p>
        <div className="mt-4 text-sm text-green-600 font-medium">
          ✅ Compilado exitosamente - Versión 2025.10.12
        </div>
      </div>

      {/* Grid de prueba */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-white/80 backdrop-blur rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all">
          <div className="text-3xl mb-2">👥</div>
          <h3 className="font-semibold text-slate-900">Total Empleados</h3>
          <p className="text-2xl font-bold text-indigo-600">156</p>
        </div>
        <div className="bg-white/80 backdrop-blur rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all">
          <div className="text-3xl mb-2">✅</div>
          <h3 className="font-semibold text-slate-900">Activos</h3>
          <p className="text-2xl font-bold text-green-600">142</p>
        </div>
        <div className="bg-white/80 backdrop-blur rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all">
          <div className="text-3xl mb-2">🏭</div>
          <h3 className="font-semibold text-slate-900">Fábricas</h3>
          <p className="text-2xl font-bold text-blue-600">12</p>
        </div>
        <div className="bg-white/80 backdrop-blur rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all">
          <div className="text-3xl mb-2">⏰</div>
          <h3 className="font-semibold text-slate-900">Horas Mes</h3>
          <p className="text-2xl font-bold text-purple-600">24,680</p>
        </div>
      </div>

      {/* Información de diagnóstico */}
      <div className="bg-white/80 backdrop-blur rounded-2xl p-6 shadow-lg">
        <h2 className="text-xl font-bold text-slate-900 mb-4">📊 Estado del Sistema</h2>
        <div className="space-y-2">
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 bg-green-500 rounded-full"></span>
            <span>Frontend React cargando correctamente</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 bg-green-500 rounded-full"></span>
            <span>Diseño del backup aplicado</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 bg-green-500 rounded-full"></span>
            <span>Efectos glassmorphism funcionando</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 bg-yellow-500 rounded-full"></span>
            <span>Navegación en desarrollo</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;