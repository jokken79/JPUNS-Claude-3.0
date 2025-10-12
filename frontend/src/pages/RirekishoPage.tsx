import React from 'react';
import { Link } from 'react-router-dom';

const RirekishoPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      <nav className="bg-indigo-600 text-white p-4">
        <div className="container mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">履歴書システム</h1>
          <Link to="/dashboard" className="text-white hover:text-gray-200">
            ← ダッシュボードに戻る
          </Link>
        </div>
      </nav>

      <div className="container mx-auto p-8">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h2 className="text-2xl font-bold mb-6">履歴書フォーム</h2>

          <div className="mb-6">
            <p className="text-gray-600 mb-4">
              履歴書の印刷システムを使用するには、以下のリンクにアクセスしてください:
            </p>
            <a
              href="/templates/rirekisho.html"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block bg-indigo-600 text-white px-6 py-3 rounded-lg hover:bg-indigo-700 transition-colors"
            >
              📋 履歴書印刷システムを開く
            </a>
          </div>

          <div className="border-t pt-6 mt-6">
            <h3 className="text-lg font-semibold mb-4">システム機能:</h3>
            <ul className="list-disc list-inside space-y-2 text-gray-700">
              <li>OCR 自動読み取り (Azure Computer Vision)</li>
              <li>4つの印刷モード (クラシック、モダン、ハイブリッド、PDF Overlay)</li>
              <li>自動ローマ字→カタカナ変換</li>
              <li>年齢自動計算</li>
              <li>プレビュー機能</li>
              <li>PDF エクスポート</li>
            </ul>
          </div>

          <div className="border-t pt-6 mt-6">
            <h3 className="text-lg font-semibold mb-4">使い方:</h3>
            <ol className="list-decimal list-inside space-y-2 text-gray-700">
              <li>上のボタンをクリックして履歴書システムを開く</li>
              <li>フォームに情報を入力またはOCRで読み取る</li>
              <li>印刷モードを選択 (推奨: モード4 - PDF Overlay)</li>
              <li>プレビューで確認</li>
              <li>PDFとして印刷/保存</li>
            </ol>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RirekishoPage;
