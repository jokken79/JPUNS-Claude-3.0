import React from 'react';
import { useTheme } from '../context/ThemeContext';

const ThemeDemo: React.FC = () => {
  const { theme, setTheme, themes } = useTheme();

  return (
    <div className="p-6 rounded-2xl border-2 border-border-base bg-background-base text-text-base">
      <h2 className="text-2xl font-bold text-primary mb-4">Demostración de Temas con Tailwind</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <div className="p-4 rounded-lg bg-background-muted border border-border-muted">
          <h3 className="text-lg font-semibold text-primary mb-2">Tarjeta 1</h3>
          <p className="text-text-muted">Esta tarjeta usa clases de Tailwind con variables CSS</p>
          <button className="mt-3 px-4 py-2 bg-primary text-text-inverted rounded-lg hover:opacity-80 transition">
            Botón Primario
          </button>
        </div>
        
        <div className="p-4 rounded-lg bg-background-muted border border-border-muted">
          <h3 className="text-lg font-semibold text-secondary mb-2">Tarjeta 2</h3>
          <p className="text-text-muted">Otra tarjeta con el mismo sistema de temas</p>
          <button className="mt-3 px-4 py-2 bg-secondary text-text-inverted rounded-lg hover:opacity-80 transition">
            Botón Secundario
          </button>
        </div>
      </div>

      <div className="p-4 rounded-lg bg-accent/10 border border-accent/30">
        <h3 className="text-lg font-semibold text-accent mb-2">Resaltado con Accent</h3>
        <p className="text-text-base">Este área usa el color acento del tema</p>
      </div>

      <div className="mt-6 flex flex-wrap gap-2">
        {Object.entries(themes).map(([themeKey, themeName]) => (
          <button
            key={themeKey}
            onClick={() => setTheme(themeKey)}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              theme === themeKey 
                ? 'bg-primary text-text-inverted' 
                : 'bg-background-muted text-text-base border border-border-muted hover:bg-background-highlight'
            }`}
          >
            {themeName}
          </button>
        ))}
      </div>

      <div className="mt-4 p-3 bg-background-highlight rounded-lg border border-border-muted">
        <p className="text-sm text-text-muted">
          Tema actual: <span className="font-mono font-bold text-primary">{theme}</span>
        </p>
      </div>
    </div>
  );
};

export default ThemeDemo;