import React from 'react';

export const StatsGridSkeleton: React.FC = () => (
  <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
    {[...Array(4)].map((_, i) => (
      <div key={i} className="animate-pulse">
        <div className="rounded-3xl border border-white/60 bg-white/40 p-6">
          <div className="h-4 bg-gray-300 rounded w-1/2 mb-2"></div>
          <div className="h-8 bg-gray-300 rounded w-3/4 mb-2"></div>
          <div className="h-3 bg-gray-300 rounded w-1/3"></div>
        </div>
      </div>
    ))}
  </div>
);

export const AlertSkeleton: React.FC = () => (
  <div className="animate-pulse">
    <div className="rounded-3xl border border-white/60 bg-white/40 p-6">
      <div className="h-6 bg-gray-300 rounded w-1/3 mb-4"></div>
      <div className="space-y-3">
        {[...Array(3)].map((_, i) => (
          <div key={i} className="flex items-center space-x-3">
            <div className="h-3 w-3 bg-gray-300 rounded-full"></div>
            <div className="h-4 bg-gray-300 rounded w-3/4"></div>
          </div>
        ))}
      </div>
    </div>
  </div>
);

export const ActivitySkeleton: React.FC = () => (
  <div className="animate-pulse">
    <div className="rounded-3xl border border-white/60 bg-white/40 p-6">
      <div className="h-6 bg-gray-300 rounded w-1/3 mb-4"></div>
      <div className="space-y-4">
        {[...Array(3)].map((_, i) => (
          <div key={i} className="flex items-start space-x-3">
            <div className="h-8 w-8 bg-gray-300 rounded-full"></div>
            <div className="flex-1">
              <div className="h-4 bg-gray-300 rounded w-3/4 mb-1"></div>
              <div className="h-3 bg-gray-300 rounded w-1/2"></div>
            </div>
          </div>
        ))}
      </div>
    </div>
  </div>
);

export const FactoriesTableSkeleton: React.FC = () => (
  <div className="animate-pulse">
    <div className="rounded-3xl border border-white/60 bg-white/40 p-6">
      <div className="h-6 bg-gray-300 rounded w-1/4 mb-4"></div>
      <div className="space-y-3">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="flex items-center justify-between">
            <div className="h-4 bg-gray-300 rounded w-1/3"></div>
            <div className="h-4 bg-gray-300 rounded w-1/4"></div>
            <div className="h-4 bg-gray-300 rounded w-1/6"></div>
          </div>
        ))}
      </div>
    </div>
  </div>
);