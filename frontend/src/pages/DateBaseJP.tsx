import React, { useState, useEffect } from 'react';
import {
  ServerIcon,
  EyeIcon,
  PencilIcon,
  ArrowDownTrayIcon,
  ArrowUpTrayIcon,
  TrashIcon,
  MagnifyingGlassIcon,
  PlusIcon
} from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import '../styles/DateBaseJP.css';

interface TableInfo {
  name: string;
  rowCount: number;
  columns: ColumnInfo[];
}

interface ColumnInfo {
  name: string;
  type: string;
  nullable: boolean;
  default?: string;
}

interface TableData {
  columns: string[];
  rows: Record<string, any>[];
  totalCount: number;
  page: number;
  pageSize: number;
}

const DateBaseJP: React.FC = () => {
  const [tables, setTables] = useState<TableInfo[]>([]);
  const [selectedTable, setSelectedTable] = useState<string>('');
  const [tableData, setTableData] = useState<TableData | null>(null);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [editingCell, setEditingCell] = useState<{rowIndex: number; columnName: string} | null>(null);
  const [editValue, setEditValue] = useState('');
  const [showCreateTable, setShowCreateTable] = useState(false);

  const pageSize = 20;

  useEffect(() => {
    fetchTables();
  }, []);

  useEffect(() => {
    if (selectedTable) {
      fetchTableData(selectedTable, currentPage);
    }
  }, [selectedTable, currentPage]);

  const getAuthHeaders = () => {
    const token = localStorage.getItem('token');
    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
  };

  const fetchTables = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/database/tables', {
        headers: getAuthHeaders()
      });
      if (!response.ok) {
        if (response.status === 401) {
          toast.error('認証が必要です。ログインしてください');
          return;
        }
        throw new Error('Failed to fetch tables');
      }
      const data = await response.json();
      setTables(data);
    } catch (error) {
      toast.error('テーブル一覧の取得に失敗しました');
      console.error('Error fetching tables:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchTableData = async (tableName: string, page: number) => {
    try {
      setLoading(true);
      const offset = (page - 1) * pageSize;
      const response = await fetch(`/api/database/tables/${tableName}/data?limit=${pageSize}&offset=${offset}&search=${searchTerm}`, {
        headers: getAuthHeaders()
      });
      if (!response.ok) throw new Error('Failed to fetch table data');
      const data = await response.json();
      setTableData(data);
    } catch (error) {
      toast.error('テーブルデータの取得に失敗しました');
      console.error('Error fetching table data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleExportTable = async (tableName: string) => {
    try {
      const response = await fetch(`/api/database/tables/${tableName}/export`, {
        headers: getAuthHeaders()
      });
      if (!response.ok) throw new Error('Failed to export table');
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${tableName}_export.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      toast.success('テーブルをエクスポートしました');
    } catch (error) {
      toast.error('テーブルのエクスポートに失敗しました');
      console.error('Error exporting table:', error);
    }
  };

  const handleImportTable = async (tableName: string, file: File) => {
    try {
      const formData = new FormData();
      formData.append('file', file);

      const token = localStorage.getItem('token');
      const response = await fetch(`/api/database/tables/${tableName}/import`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });

      if (!response.ok) throw new Error('Failed to import table');

      toast.success('テーブルをインポートしました');
      fetchTableData(selectedTable, currentPage);
    } catch (error) {
      toast.error('テーブルのインポートに失敗しました');
      console.error('Error importing table:', error);
    }
  };

  const handleDeleteRow = async (tableName: string, rowId: any) => {
    if (!window.confirm('この行を削除してもよろしいですか？')) return;

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/database/tables/${tableName}/rows/${rowId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) throw new Error('Failed to delete row');

      toast.success('行を削除しました');
      fetchTableData(selectedTable, currentPage);
    } catch (error) {
      toast.error('行の削除に失敗しました');
      console.error('Error deleting row:', error);
    }
  };

  const handleEditCell = (rowIndex: number, columnName: string, currentValue: any) => {
    setEditingCell({ rowIndex, columnName });
    setEditValue(currentValue?.toString() || '');
  };

  const handleSaveCell = async () => {
    if (!editingCell || !tableData) return;

    try {
      const row = tableData.rows[editingCell.rowIndex];
      const rowId = row.id; // Assuming there's an id column

      const token = localStorage.getItem('token');
      const response = await fetch(`/api/database/tables/${selectedTable}/rows/${rowId}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          column: editingCell.columnName,
          value: editValue
        })
      });

      if (!response.ok) throw new Error('Failed to update cell');

      toast.success('セルを更新しました');
      setEditingCell(null);
      setEditValue('');
      fetchTableData(selectedTable, currentPage);
    } catch (error) {
      toast.error('セルの更新に失敗しました');
      console.error('Error updating cell:', error);
    }
  };

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file && selectedTable) {
      handleImportTable(selectedTable, file);
    }
  };

  const totalPages = tableData ? Math.ceil(tableData.totalCount / pageSize) : 0;

  return (
    <div className="space-y-6">
      {/* Header */}
      <section className="database-section">
        <div className="header-section">
          <div className="header-title">
            <p className="subtitle">
              Database Management
            </p>
            <h1>
              DateBaseJP
            </h1>
            <p>
              PostgreSQLデータベースの直接管理。テーブルの表示、編集、インポート、エクスポート機能を提供します。
            </p>
          </div>
          <div className="header-actions">
            <button
              onClick={() => setShowCreateTable(!showCreateTable)}
              className="primary-button"
            >
              <PlusIcon className="h-4 w-4" />
              テーブル作成
            </button>
          </div>
        </div>
      </section>

      {/* Tables List */}
      <section className="database-section">
        <h2>
          テーブル一覧
        </h2>
        <div className="tables-grid">
          {tables.map((table) => (
            <div
              key={table.name}
              className={`table-card ${selectedTable === table.name ? 'active' : ''}`}
              onClick={() => {
                setSelectedTable(table.name);
                setCurrentPage(1);
              }}
            >
              <div className="table-card-header">
                <div className="table-card-info">
                  <ServerIcon className="h-5 w-5" />
                  <span className="table-card-name">{table.name}</span>
                </div>
                <span className="table-card-rows">{table.rowCount} rows</span>
              </div>
              <div className="table-card-columns">
                {table.columns.length} columns
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Table Data */}
      {selectedTable && (
        <section className="database-section">
          <div className="table-data-header">
            <h2 className="table-data-title">
              テーブルデータ: {selectedTable}
            </h2>
            <div className="table-data-controls">
              {/* Search */}
              <div className="search-container">
                <MagnifyingGlassIcon className="search-icon" />
                <input
                  type="text"
                  placeholder="検索..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="search-input"
                  aria-label="検索"
                />
              </div>
              
              {/* Import */}
              <label className="action-button import-button">
                <ArrowUpTrayIcon className="h-4 w-4" />
                インポート
                <input
                  type="file"
                  accept=".csv,.xlsx"
                  onChange={handleFileUpload}
                  className="file-input"
                />
              </label>
              
              {/* Export */}
              <button
                onClick={() => handleExportTable(selectedTable)}
                className="action-button export-button"
              >
                <ArrowDownTrayIcon className="h-4 w-4" />
                エクスポート
              </button>
            </div>
          </div>

          {loading ? (
            <div className="loading-container">
              <div className="loading-spinner" />
            </div>
          ) : tableData ? (
            <>
              {/* Data Table */}
              <div className="data-table-container">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>#</th>
                      {tableData.columns.map((column) => (
                        <th key={column}>
                          {column}
                        </th>
                      ))}
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {tableData.rows.map((row, rowIndex) => (
                      <tr key={rowIndex}>
                        <td>
                          {(currentPage - 1) * pageSize + rowIndex + 1}
                        </td>
                        {tableData.columns.map((column) => (
                          <td
                            key={column}
                            className="editable-cell"
                            onClick={() => handleEditCell(rowIndex, column, row[column])}
                          >
                            {editingCell?.rowIndex === rowIndex && editingCell?.columnName === column ? (
                              <input
                                type="text"
                                value={editValue}
                                onChange={(e) => setEditValue(e.target.value)}
                                onBlur={handleSaveCell}
                                onKeyPress={(e) => e.key === 'Enter' && handleSaveCell()}
                                className="cell-edit-input"
                                placeholder="値を入力"
                                aria-label="値を編集"
                                autoFocus
                              />
                            ) : (
                              <div className="cell-content">
                                <span>{row[column]?.toString() || ''}</span>
                                <PencilIcon className="h-3 w-3 opacity-0 group-hover:opacity-50" />
                              </div>
                            )}
                          </td>
                        ))}
                        <td>
                          <button
                            onClick={() => handleDeleteRow(selectedTable, row.id)}
                            className="delete-button"
                            aria-label="削除"
                            title="削除"
                          >
                            <TrashIcon className="h-4 w-4" />
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="pagination-container">
                  <div className="pagination-info">
                    全 {tableData.totalCount} 件中 {(currentPage - 1) * pageSize + 1} - {Math.min(currentPage * pageSize, tableData.totalCount)} 件を表示
                  </div>
                  <div className="pagination-controls">
                    <button
                      onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                      disabled={currentPage === 1}
                      className="pagination-button"
                    >
                      前へ
                    </button>
                    <span className="pagination-current">
                      {currentPage} / {totalPages}
                    </span>
                    <button
                      onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                      disabled={currentPage === totalPages}
                      className="pagination-button"
                    >
                      次へ
                    </button>
                  </div>
                </div>
              )}
            </>
          ) : (
            <div className="empty-state">
              データがありません
            </div>
          )}
        </section>
      )}
    </div>
  );
};

export default DateBaseJP;