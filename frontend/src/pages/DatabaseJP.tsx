import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  FiUsers,
  FiBriefcase,
  FiDollarSign,
  FiFileText,
  FiPackage,
  FiRefreshCw,
  FiDownload,
  FiUpload,
  FiPlus,
  FiEdit2,
  FiTrash2,
  FiSearch,
} from 'react-icons/fi';
import { IconType } from 'react-icons';
import { toast } from 'react-hot-toast';
import {
  addData,
  deleteData,
  exportData,
  getData,
  importData,
  updateData,
} from '../services/databaseApi';

interface TableConfig {
  key: TableKey;
  label: string;
  description: string;
  icon: IconType;
}

type TableKey = 'candidates' | 'factories' | 'payroll' | 'contracts' | 'timecards';

type RecordData = Record<string, unknown>;

type ModalMode = 'add' | 'edit';

const TABLES: TableConfig[] = [
  {
    key: 'candidates',
    label: 'Candidates',
    description: 'Applicants and candidate pipeline records.',
    icon: FiUsers,
  },
  {
    key: 'factories',
    label: 'Factories',
    description: 'Partner factories and assignment sites.',
    icon: FiBriefcase,
  },
  {
    key: 'payroll',
    label: 'Payroll',
    description: 'Compensation and payroll history.',
    icon: FiDollarSign,
  },
  {
    key: 'contracts',
    label: 'Contracts',
    description: 'Employment contracts and agreements.',
    icon: FiFileText,
  },
  {
    key: 'timecards',
    label: 'Timecards',
    description: 'Working hours, attendance, and overtime.',
    icon: FiPackage,
  },
];

const DatabaseJP: React.FC = () => {
  const [selectedTable, setSelectedTable] = useState<TableKey>('candidates');
  const [records, setRecords] = useState<RecordData[]>([]);
  const [columns, setColumns] = useState<string[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [actionLoading, setActionLoading] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [modalMode, setModalMode] = useState<ModalMode>('add');
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [formState, setFormState] = useState<RecordData>({});
  const [activeRecord, setActiveRecord] = useState<RecordData | null>(null);
  const [searchValue, setSearchValue] = useState<string>('');
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const primaryKey = useMemo(() => {
    const keyCandidates = ['id', 'ID', 'Id', 'uuid'];
    return columns.find((column) => keyCandidates.includes(column));
  }, [columns]);

  const selectedTableConfig = useMemo(
    () => TABLES.find((table) => table.key === selectedTable) ?? TABLES[0],
    [selectedTable]
  );

  const normalizeRecords = useCallback((data: unknown): RecordData[] => {
    if (Array.isArray(data)) {
      return data as RecordData[];
    }

    if (data && typeof data === 'object') {
      const possibleArrays = ['results', 'data', 'items', 'records'];
      for (const key of possibleArrays) {
        const value = (data as Record<string, unknown>)[key];
        if (Array.isArray(value)) {
          return value as RecordData[];
        }
      }

      return [data as RecordData];
    }

    return [];
  }, []);

  const fetchTableData = useCallback(
    async (table: TableKey) => {
      setLoading(true);
      setErrorMessage(null);

      try {
        const response = await getData(table);
        const fetchedRecords = normalizeRecords(response.data);
        setRecords(fetchedRecords);

        const columnSet = new Set<string>();
        fetchedRecords.forEach((record) => {
          Object.keys(record).forEach((key) => columnSet.add(key));
        });
        setColumns(Array.from(columnSet));
      } catch (error: unknown) {
        console.error('Error fetching table data:', error);
        const message =
          (error as { response?: { data?: { detail?: string }; status?: number } }).response?.data?.detail ||
          'Unable to load data. Please verify your backend connection.';
        setErrorMessage(message);
        toast.error('Failed to load records');
      } finally {
        setLoading(false);
      }
    },
    [normalizeRecords]
  );

  useEffect(() => {
    fetchTableData(selectedTable);
  }, [fetchTableData, selectedTable]);

  const filteredRecords = useMemo(() => {
    if (!searchValue.trim()) {
      return records;
    }

    const lowerSearch = searchValue.toLowerCase();
    return records.filter((record) =>
      columns.some((column) => {
        const value = record[column];
        if (value === null || value === undefined) {
          return false;
        }
        return String(value).toLowerCase().includes(lowerSearch);
      })
    );
  }, [columns, records, searchValue]);

  const openModal = (mode: ModalMode, record?: RecordData) => {
    setModalMode(mode);
    setActiveRecord(record ?? null);

    if (mode === 'edit' && record) {
      setFormState(record);
    } else {
      const initialState: RecordData = {};
      columns
        .filter((column) => column !== primaryKey)
        .forEach((column) => {
          initialState[column] = '';
        });
      setFormState(initialState);
    }

    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setFormState({});
    setActiveRecord(null);
  };

  const handleChange = (column: string, value: string) => {
    setFormState((prev) => ({
      ...prev,
      [column]: value,
    }));
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!selectedTable) return;

    setActionLoading(true);
    try {
      if (modalMode === 'add') {
        const payload = { ...formState };
        if (primaryKey) {
          delete payload[primaryKey];
        }
        await addData(selectedTable, payload);
        toast.success('Record created successfully');
      } else if (modalMode === 'edit' && activeRecord && primaryKey) {
        const recordId = activeRecord[primaryKey];
        if (recordId === undefined || recordId === null) {
          throw new Error('No primary key found for update');
        }
        const payload = { ...formState };
        await updateData(selectedTable, recordId as number | string, payload);
        toast.success('Record updated successfully');
      }

      closeModal();
      fetchTableData(selectedTable);
    } catch (error) {
      console.error('Error saving record:', error);
      toast.error('Unable to save the record');
    } finally {
      setActionLoading(false);
    }
  };

  const handleDelete = async (record: RecordData) => {
    if (!primaryKey) {
      toast.error('Cannot delete record without a primary key');
      return;
    }

    const recordId = record[primaryKey];
    if (recordId === undefined || recordId === null) {
      toast.error('Cannot delete record without an identifier');
      return;
    }

    const confirmDelete = window.confirm('Are you sure you want to delete this record?');
    if (!confirmDelete) return;

    setActionLoading(true);
    try {
      await deleteData(selectedTable, recordId as number | string);
      toast.success('Record deleted');
      fetchTableData(selectedTable);
    } catch (error) {
      console.error('Error deleting record:', error);
      toast.error('Unable to delete the record');
    } finally {
      setActionLoading(false);
    }
  };

  const handleExport = async () => {
    setActionLoading(true);
    try {
      const response = await exportData(selectedTable);
      const blob = new Blob([response.data], { type: 'text/csv;charset=utf-8;' });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `${selectedTable}-export.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
      toast.success('Export completed');
    } catch (error) {
      console.error('Error exporting data:', error);
      toast.error('Unable to export CSV');
    } finally {
      setActionLoading(false);
    }
  };

  const handleImport = () => {
    fileInputRef.current?.click();
  };

  const onFileSelected = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setActionLoading(true);
    try {
      await importData(selectedTable, file);
      toast.success('Import completed');
      fetchTableData(selectedTable);
    } catch (error) {
      console.error('Error importing data:', error);
      toast.error('Unable to import CSV');
    } finally {
      event.target.value = '';
      setActionLoading(false);
    }
  };

  const refresh = () => {
    fetchTableData(selectedTable);
  };

  const renderCellValue = (value: unknown) => {
    if (value === null || value === undefined) {
      return <span className="text-gray-400">—</span>;
    }

    if (typeof value === 'boolean') {
      return value ? 'Yes' : 'No';
    }

    if (typeof value === 'object') {
      try {
        return JSON.stringify(value);
      } catch (error) {
        console.error('Unable to stringify cell value:', error);
        return '[Object]';
      }
    }

    return String(value);
  };

  return (
    <div className="flex h-full min-h-screen bg-slate-50 text-slate-900">
      <aside className="hidden w-72 flex-shrink-0 border-r border-slate-200 bg-white/80 backdrop-blur lg:flex lg:flex-col">
        <div className="border-b border-slate-200 px-6 py-6">
          <h1 className="text-xl font-semibold text-slate-800">HR Database Center</h1>
          <p className="mt-2 text-sm text-slate-500">
            Browse and maintain HR tables with full CRUD control.
          </p>
        </div>
        <nav className="flex-1 overflow-y-auto px-4 py-6">
          <ul className="space-y-2">
            {TABLES.map((table) => {
              const isActive = selectedTable === table.key;
              return (
                <li key={table.key}>
                  <button
                    type="button"
                    onClick={() => setSelectedTable(table.key)}
                    className={`flex w-full items-start gap-4 rounded-xl border px-4 py-3 text-left transition-all ${
                      isActive
                        ? 'border-blue-500 bg-blue-50 text-blue-700 shadow-sm'
                        : 'border-transparent bg-white text-slate-600 hover:border-slate-200 hover:bg-slate-50'
                    }`}
                  >
                    <span
                      className={`flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg text-xl ${
                        isActive ? 'bg-blue-100 text-blue-600' : 'bg-slate-100 text-slate-500'
                      }`}
                    >
                      <table.icon />
                    </span>
                    <span className="flex-1">
                      <span className="block text-sm font-semibold">{table.label}</span>
                      <span className="mt-1 block text-xs text-slate-500">{table.description}</span>
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        </nav>
      </aside>

      <main className="flex-1 overflow-hidden">
        <div className="mx-auto flex h-full max-w-7xl flex-col px-4 py-8 sm:px-6 lg:px-10">
          <header className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <div className="flex items-center gap-3">
                <span className="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-500/10 text-2xl text-blue-600">
                  <selectedTableConfig.icon />
                </span>
                <div>
                  <h2 className="text-2xl font-semibold text-slate-900">
                    {selectedTableConfig.label}
                  </h2>
                  <p className="text-sm text-slate-500">{selectedTableConfig.description}</p>
                </div>
              </div>
            </div>
            <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
              <div className="relative w-full sm:w-64">
                <FiSearch className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                <input
                  type="search"
                  value={searchValue}
                  onChange={(event) => setSearchValue(event.target.value)}
                  placeholder="Search records"
                  className="w-full rounded-lg border border-slate-200 bg-white py-2 pl-10 pr-3 text-sm text-slate-700 shadow-sm outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-200"
                />
              </div>
            </div>
          </header>

          <section className="mb-4 flex flex-wrap items-center gap-3">
            <button
              type="button"
              onClick={refresh}
              className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 shadow-sm transition hover:border-blue-500 hover:text-blue-600"
              disabled={loading || actionLoading}
            >
              <FiRefreshCw className="text-base" /> Refresh
            </button>
            <button
              type="button"
              onClick={handleExport}
              className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 shadow-sm transition hover:border-blue-500 hover:text-blue-600"
              disabled={loading || actionLoading}
            >
              <FiDownload className="text-base" /> Export CSV
            </button>
            <button
              type="button"
              onClick={handleImport}
              className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 shadow-sm transition hover:border-blue-500 hover:text-blue-600"
              disabled={loading || actionLoading}
            >
              <FiUpload className="text-base" /> Import CSV
            </button>
            <button
              type="button"
              onClick={() => openModal('add')}
              className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700"
              disabled={loading || actionLoading || columns.length === 0}
            >
              <FiPlus className="text-base" /> New Record
            </button>
            <input
              ref={fileInputRef}
              type="file"
              accept=".csv"
              className="hidden"
              onChange={onFileSelected}
            />
          </section>

          <section className="flex-1 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
            {errorMessage ? (
              <div className="flex h-full flex-col items-center justify-center gap-2 p-12 text-center">
                <p className="text-lg font-semibold text-slate-700">Connection issue</p>
                <p className="text-sm text-slate-500">{errorMessage}</p>
                <button
                  type="button"
                  onClick={refresh}
                  className="mt-4 inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700"
                >
                  <FiRefreshCw className="text-base" /> Retry
                </button>
              </div>
            ) : (
              <div className="flex h-full flex-col">
                <div className="relative flex-1 overflow-hidden">
                  <div className="absolute inset-0 overflow-auto">
                    <table className="min-w-full divide-y divide-slate-200">
                      <thead className="bg-slate-50">
                        <tr>
                          {columns.map((column) => (
                            <th
                              key={column}
                              scope="col"
                              className="sticky top-0 z-10 whitespace-nowrap px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500"
                            >
                              {column}
                            </th>
                          ))}
                          <th className="sticky top-0 z-10 whitespace-nowrap px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                            Actions
                          </th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100 bg-white">
                        {filteredRecords.length === 0 ? (
                          <tr>
                            <td colSpan={columns.length + 1} className="px-6 py-12 text-center text-sm text-slate-500">
                              {loading ? 'Loading records…' : 'No records found for this table'}
                            </td>
                          </tr>
                        ) : (
                          filteredRecords.map((record, index) => {
                            const rowKey = (primaryKey && record[primaryKey]) || index;
                            return (
                              <tr
                                key={String(rowKey)}
                                className="transition hover:bg-blue-50/50"
                              >
                                {columns.map((column) => (
                                  <td key={column} className="whitespace-nowrap px-4 py-3 text-sm text-slate-600">
                                    {renderCellValue(record[column])}
                                  </td>
                                ))}
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <button
                                      type="button"
                                      onClick={() => openModal('edit', record)}
                                      className="inline-flex items-center justify-center rounded-lg border border-transparent bg-blue-50 p-2 text-blue-600 transition hover:border-blue-200 hover:bg-blue-100"
                                      disabled={actionLoading}
                                    >
                                      <FiEdit2 />
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => handleDelete(record)}
                                      className="inline-flex items-center justify-center rounded-lg border border-transparent bg-red-50 p-2 text-red-600 transition hover:border-red-200 hover:bg-red-100"
                                      disabled={actionLoading}
                                    >
                                      <FiTrash2 />
                                    </button>
                                  </div>
                                </td>
                              </tr>
                            );
                          })
                        )}
                      </tbody>
                    </table>
                  </div>
                  {loading && (
                    <div className="absolute inset-0 flex items-center justify-center bg-white/60 backdrop-blur-sm">
                      <div className="flex items-center gap-3 rounded-full border border-slate-200 bg-white px-4 py-2 shadow-sm">
                        <span className="h-3 w-3 animate-ping rounded-full bg-blue-500" />
                        <span className="text-sm font-medium text-slate-600">Loading data…</span>
                      </div>
                    </div>
                  )}
                </div>
                <footer className="border-t border-slate-200 bg-slate-50 px-6 py-4 text-sm text-slate-500">
                  Showing <span className="font-semibold text-slate-700">{filteredRecords.length}</span> of{' '}
                  <span className="font-semibold text-slate-700">{records.length}</span> records
                </footer>
              </div>
            )}
          </section>
        </div>
      </main>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 px-4 py-10 backdrop-blur-sm">
          <div className="w-full max-w-2xl rounded-2xl bg-white shadow-xl">
            <div className="border-b border-slate-200 px-6 py-4">
              <h3 className="text-lg font-semibold text-slate-800">
                {modalMode === 'add' ? 'Add new record' : 'Edit record'}
              </h3>
              <p className="text-sm text-slate-500">
                {selectedTableConfig.label} · {selectedTableConfig.description}
              </p>
            </div>
            <form onSubmit={handleSubmit} className="max-h-[70vh] overflow-y-auto px-6 py-6">
              <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                {columns
                  .filter((column) => modalMode === 'add' ? column !== primaryKey : true)
                  .map((column) => (
                    <label key={column} className="flex flex-col gap-2 text-sm font-medium text-slate-700">
                      <span>{column}</span>
                      <input
                        type="text"
                        value={(formState[column] as string | number | undefined) ?? ''}
                        onChange={(event) => handleChange(column, event.target.value)}
                        disabled={column === primaryKey && modalMode === 'edit'}
                        className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 shadow-sm outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-200 disabled:cursor-not-allowed disabled:bg-slate-100"
                      />
                    </label>
                  ))}

                {modalMode === 'add' && columns.length === 0 && (
                  <div className="col-span-full rounded-lg border border-dashed border-slate-200 bg-slate-50 p-6 text-center text-sm text-slate-500">
                    No columns detected yet. Add your first record after importing or refreshing data.
                  </div>
                )}
              </div>
              <div className="mt-8 flex flex-col-reverse gap-3 border-t border-slate-200 pt-6 sm:flex-row sm:justify-end">
                <button
                  type="button"
                  onClick={closeModal}
                  className="inline-flex items-center justify-center rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 shadow-sm transition hover:border-slate-300"
                  disabled={actionLoading}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-blue-300"
                  disabled={actionLoading || (modalMode === 'add' && columns.length === 0)}
                >
                  {actionLoading ? 'Saving…' : modalMode === 'add' ? 'Create record' : 'Save changes'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default DatabaseJP;
