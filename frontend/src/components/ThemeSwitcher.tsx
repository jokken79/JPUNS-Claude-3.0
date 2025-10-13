import React from 'react';
import { useTheme } from '../context/ThemeContext';

const ThemeSwitcher: React.FC = () => {
  const { theme, setTheme, themes } = useTheme();

  const handleThemeChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const newTheme = event.target.value;
    console.log('ThemeSwitcher: Changing theme to:', newTheme);
    setTheme(newTheme);
  };

  // Debug log to see current theme
  React.useEffect(() => {
    console.log('ThemeSwitcher: Current theme is:', theme);
    console.log('ThemeSwitcher: Available themes:', themes);
  }, [theme, themes]);

  return (
    <div className="flex items-center space-x-2">
      <label htmlFor="theme-switcher" className="text-sm font-medium text-text-muted">
        Tema:
      </label>
      <select
        id="theme-switcher"
        value={theme}
        onChange={handleThemeChange}
        className="block w-full pl-3 pr-10 py-2 text-base border-border-muted rounded-md focus:outline-none focus:ring-primary focus:border-primary sm:text-sm bg-background-highlight text-text-base"
      >
        {Object.entries(themes).map(([themeKey, themeName]) => (
          <option key={themeKey} value={themeKey}>
            {themeName}
          </option>
        ))}
      </select>
    </div>
  );
};

export default ThemeSwitcher;
