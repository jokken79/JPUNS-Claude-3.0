import React from 'react';
import { useTheme } from '../context/ThemeContext';

const ThemeTest: React.FC = () => {
  const { theme, setTheme, themes } = useTheme();

  const handleThemeChange = (newTheme: string) => {
    console.log('ThemeTest: Changing theme to:', newTheme);
    setTheme(newTheme);
  };

  React.useEffect(() => {
    console.log('ThemeTest: Current theme:', theme);
    console.log('ThemeTest: Root classes:', document.documentElement.className);
    
    // Check CSS variables
    const rootStyle = getComputedStyle(document.documentElement);
    console.log('ThemeTest: CSS Variables:');
    console.log('  --color-primary:', rootStyle.getPropertyValue('--color-primary'));
    console.log('  --color-background-base:', rootStyle.getPropertyValue('--color-background-base'));
    console.log('  --color-text-base:', rootStyle.getPropertyValue('--color-text-base'));
  }, [theme]);

  return (
    <div style={{ 
      padding: '20px', 
      margin: '20px', 
      border: '2px solid var(--color-primary, #2563EB)',
      backgroundColor: 'var(--color-background-base, #F9FAFB)',
      color: 'var(--color-text-base, #1F2937)',
      borderRadius: '8px'
    }}>
      <h3 style={{ color: 'var(--color-primary, #2563EB)' }}>
        Prueba de Temas
      </h3>
      <p>Tema actual: <strong>{theme}</strong></p>
      <p>Clases del root: <code>{document.documentElement.className}</code></p>
      
      <div style={{ marginTop: '15px' }}>
        <h4>Seleccionar tema:</h4>
        {Object.entries(themes).map(([themeKey, themeName]) => (
          <button
            key={themeKey}
            onClick={() => handleThemeChange(themeKey)}
            style={{
              margin: '5px',
              padding: '8px 12px',
              backgroundColor: theme === themeKey ? 'var(--color-primary, #2563EB)' : 'var(--color-background-muted, #F3F4F6)',
              color: theme === themeKey ? 'white' : 'var(--color-text-base, #1F2937)',
              border: '1px solid var(--color-border-base, #D1D5DB)',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            {themeName}
          </button>
        ))}
      </div>

      <div style={{ marginTop: '15px', padding: '10px', backgroundColor: 'var(--color-background-muted, #F3F4F6)' }}>
        <h4>Colores del tema actual:</h4>
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <div style={{ 
            width: '60px', 
            height: '30px', 
            backgroundColor: 'var(--color-primary, #2563EB)',
            border: '1px solid #ccc'
          }} title="Primary"></div>
          <div style={{ 
            width: '60px', 
            height: '30px', 
            backgroundColor: 'var(--color-secondary, #4F46E5)',
            border: '1px solid #ccc'
          }} title="Secondary"></div>
          <div style={{ 
            width: '60px', 
            height: '30px', 
            backgroundColor: 'var(--color-accent, #DB2777)',
            border: '1px solid #ccc'
          }} title="Accent"></div>
          <div style={{ 
            width: '60px', 
            height: '30px', 
            backgroundColor: 'var(--color-background-base, #F9FAFB)',
            border: '1px solid #ccc'
          }} title="Background"></div>
          <div style={{ 
            width: '60px', 
            height: '30px', 
            backgroundColor: 'var(--color-text-base, #1F2937)',
            border: '1px solid #ccc'
          }} title="Text"></div>
        </div>
      </div>
    </div>
  );
};

export default ThemeTest;