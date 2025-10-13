import React, { createContext, useState, useContext, useEffect, useMemo } from 'react';

// Define the shape of the context
interface ThemeContextType {
  theme: string;
  setTheme: (theme: string) => void;
  themes: Record<string, string>;
}

// Create the context
const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Define the available themes
const availableThemes = {
  'theme-default': 'Claro (Default)',
  'theme-dark': 'Oscuro',
  'theme-corporate': 'Corporativo UNS',
  'theme-smarthr': 'Estilo SmartHR',
  'theme-futuristic': 'Futurista',
};

// Create the provider component
export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setThemeState] = useState<string>(() => {
    // Get theme from localStorage or default to 'theme-default'
    const savedTheme = localStorage.getItem('app-theme');
    return savedTheme && savedTheme in availableThemes ? savedTheme : 'theme-default';
  });

  // Effect to update the root element's class and localStorage
  useEffect(() => {
    const root = window.document.documentElement;
    
    // Remove all theme classes
    Object.keys(availableThemes).forEach(themeKey => {
      root.classList.remove(themeKey);
    });
    
    // Add the new theme class
    root.classList.add(theme);
    
    // Save to localStorage
    localStorage.setItem('app-theme', theme);
    
    // Debug logging
    console.log('Theme changed to:', theme);
    console.log('Root classes:', root.className);
  }, [theme]);

  const setTheme = (newTheme: string) => {
    if (newTheme in availableThemes) {
      console.log('Setting theme to:', newTheme);
      setThemeState(newTheme);
    } else {
      console.warn('Invalid theme:', newTheme);
    }
  };

  const contextValue = useMemo(() => ({
    theme,
    setTheme,
    themes: availableThemes,
  }), [theme]);

  return (
    <ThemeContext.Provider value={contextValue}>
      {children}
    </ThemeContext.Provider>
  );
};

// Create a custom hook for easy access to the context
export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};
