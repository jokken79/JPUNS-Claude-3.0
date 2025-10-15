import { describe, expect, it, beforeEach, afterEach, vi } from 'vitest';
import { render, screen } from '@testing-library/react';

import { VisaAlert } from '../VisaAlert';

describe('VisaAlert', () => {
  const baseDate = new Date('2025-01-01T00:00:00+09:00');

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(baseDate);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('muestra placeholder cuando no hay fecha', () => {
    render(<VisaAlert expiryDate={null} />);
    expect(screen.getByText('-')).toBeInTheDocument();
  });

  it('indica estado crítico cuando faltan 5 días', () => {
    const expiry = new Date('2025-01-06T00:00:00+09:00').toISOString();
    render(<VisaAlert expiryDate={expiry} />);
    expect(screen.getByText('5日')).toBeInTheDocument();
    expect(screen.queryByText(/期限切れ/)).not.toBeInTheDocument();
  });

  it('marca como vencido cuando la fecha ya pasó', () => {
    const expiry = new Date('2024-12-01T00:00:00+09:00').toISOString();
    render(<VisaAlert expiryDate={expiry} />);
    expect(screen.getByText('期限切れ')).toBeInTheDocument();
  });
});
