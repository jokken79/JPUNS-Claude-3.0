module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        secondary: 'var(--color-secondary)',
        accent: 'var(--color-accent)',
        
        'background-base': 'var(--color-background-base)',
        'background-muted': 'var(--color-background-muted)',
        'background-highlight': 'var(--color-background-highlight)',

        'text-base': 'var(--color-text-base)',
        'text-muted': 'var(--color-text-muted)',
        'text-inverted': 'var(--color-text-inverted)',

        'border-base': 'var(--color-border-base)',
        'border-muted': 'var(--color-border-muted)',

        success: 'var(--color-success)',
        warning: 'var(--color-warning)',
        danger: 'var(--color-danger)',
      },
    },
  },
  plugins: [],
}
