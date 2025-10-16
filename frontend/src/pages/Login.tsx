import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { LockClosedIcon, UserIcon, EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';
import { authService } from '../services/api';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const data = await authService.login(username, password);
      localStorage.setItem('token', data.access_token);
      toast.success('ログインに成功しました');
      navigate('/dashboard');
    } catch (error: any) {
      toast.error(error.response?.data?.detail || 'ユーザー名またはパスワードが正しくありません');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen overflow-hidden flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8"
         style={{
           background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)'
         }}>
      {/* Animated Background Shapes */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -left-32 w-96 h-96 rounded-full blur-3xl animate-pulse"
             style={{ background: 'rgba(139, 92, 246, 0.3)' }} />
        <div className="absolute top-1/4 -right-20 w-80 h-80 rounded-full blur-3xl animate-pulse"
             style={{ background: 'rgba(236, 72, 153, 0.3)', animationDelay: '1s' }} />
        <div className="absolute -bottom-40 left-1/4 w-96 h-96 rounded-full blur-3xl animate-pulse"
             style={{ background: 'rgba(59, 130, 246, 0.3)', animationDelay: '2s' }} />
      </div>

      <div className={`relative max-w-md w-full transition-all duration-1000 ${mounted ? 'scale-in' : 'opacity-0'}`}>
        {/* Logo with Glow Effect */}
        <div className="flex justify-center mb-10">
          <div className="relative group">
            <div className="absolute -inset-3 rounded-full blur-2xl opacity-75 group-hover:opacity-100 transition duration-500"
                 style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)' }} />
            <div className="relative w-32 h-32 bg-white rounded-full flex items-center justify-center transform transition-all duration-500 hover:scale-110"
                 style={{ boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)' }}>
              <img
                src="/uns-logo.gif"
                alt="UNS Logo"
                className="w-28 h-28 object-contain"
              />
            </div>
          </div>
        </div>

        {/* Title with Gradient */}
        <div className="text-center mb-10">
          <h1 className="heading-2 gradient-text mb-3"
              style={{
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)',
                WebkitBackgroundClip: 'text',
                backgroundClip: 'text',
                WebkitTextFillColor: 'transparent'
              }}>
            UNS-ClaudeJP 3.0
          </h1>
          <p className="text-lg font-medium text-white drop-shadow-lg">
            人材管理インテリジェンスプラットフォーム
          </p>
        </div>

        {/* Glass Login Card */}
        <div className="card-glass hover:scale-105 transition-all duration-300"
             style={{ padding: '2.5rem' }}>
            <div className="mb-8 text-center">
              <h2 className="heading-3" style={{ color: 'var(--gray-900)' }}>
                ログイン
              </h2>
              <p className="text-small" style={{ color: 'var(--gray-600)', marginTop: '0.5rem' }}>
                アカウント情報を入力してください
              </p>
            </div>

            <form onSubmit={handleSubmit} className="form">
              {/* Username */}
              <div className="form-group">
                <label htmlFor="username" className="form-label">
                  ユーザー名
                </label>
                <div className="form-input-icon-wrapper">
                  <UserIcon className="form-icon form-icon-left" style={{ width: '20px', height: '20px' }} />
                  <input
                    id="username"
                    type="text"
                    required
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    className="form-input form-input-icon-left"
                    placeholder="ユーザー名を入力"
                    autoComplete="username"
                  />
                </div>
              </div>

              {/* Password */}
              <div className="form-group">
                <label htmlFor="password" className="form-label">
                  パスワード
                </label>
                <div className="form-input-icon-wrapper">
                  <LockClosedIcon className="form-icon form-icon-left" style={{ width: '20px', height: '20px' }} />
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="form-input form-input-icon-left form-input-icon-right"
                    placeholder="パスワードを入力"
                    autoComplete="current-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="form-password-toggle"
                    style={{ right: 'var(--space-4)' }}
                  >
                    {showPassword ? (
                      <EyeSlashIcon style={{ width: '20px', height: '20px' }} />
                    ) : (
                      <EyeIcon style={{ width: '20px', height: '20px' }} />
                    )}
                  </button>
                </div>
              </div>

              {/* Remember Me & Forgot Password */}
              <div className="flex items-center justify-between text-sm" style={{ marginBottom: 'var(--space-6)' }}>
                <div className="form-checkbox-wrapper">
                  <input
                    id="remember-me"
                    type="checkbox"
                    className="form-checkbox-custom"
                  />
                  <label htmlFor="remember-me" className="form-checkbox-label" style={{ color: 'var(--gray-700)' }}>
                    ログイン状態を保持
                  </label>
                </div>
                <a href="#" className="font-semibold hover:opacity-80 transition"
                   style={{ color: 'var(--primary-600)' }}>
                  パスワードを忘れた場合
                </a>
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={loading}
                className={`btn btn-accent btn-lg btn-block ${loading ? 'btn-loading' : ''}`}
                style={{
                  background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                  boxShadow: '0 10px 25px -5px rgba(102, 126, 234, 0.5)'
                }}
              >
                {!loading && 'ログイン'}
              </button>
            </form>

            {/* Demo Credentials */}
            <div className="card-warning-subtle" style={{
              marginTop: 'var(--space-8)',
              padding: 'var(--space-4)',
              background: 'linear-gradient(135deg, rgba(245, 158, 11, 0.1) 0%, rgba(251, 191, 36, 0.1) 100%)',
              border: '2px solid rgba(245, 158, 11, 0.3)'
            }}>
              <p className="text-small font-semibold flex items-center gap-2"
                 style={{ color: 'var(--warning-900)', marginBottom: 'var(--space-2)' }}>
                <svg style={{ width: '20px', height: '20px' }} fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                </svg>
                デモアカウント
              </p>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-1)' }}>
                <p className="text-tiny font-medium" style={{ color: 'var(--warning-900)' }}>
                  ユーザー名: <span className="font-mono font-bold">admin</span>
                </p>
                <p className="text-tiny font-medium" style={{ color: 'var(--warning-900)' }}>
                  パスワード: <span className="font-mono font-bold">admin123</span>
                </p>
              </div>
            </div>
        </div>

        {/* Footer */}
        <div style={{ marginTop: 'var(--space-8)', textAlign: 'center' }}>
          <p className="text-small font-medium text-white" style={{ textShadow: '0 2px 4px rgba(0,0,0,0.2)' }}>
            © 2025 UNS企画. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
