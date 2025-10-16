import axios from 'axios';

const BASE_URL = 'http://localhost:8000';

const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 15000,
});

const getAuthHeaders = () => {
  const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
  return token
    ? {
        Authorization: `Bearer ${token}`,
      }
    : {};
};

export const getData = (table: string) =>
  apiClient.get(`${table}`, { headers: { ...getAuthHeaders() } });

export const addData = (table: string, payload: unknown) =>
  apiClient.post(`${table}`, payload, { headers: { ...getAuthHeaders() } });

export const updateData = (table: string, id: number | string, payload: unknown) =>
  apiClient.put(`${table}/${id}`, payload, { headers: { ...getAuthHeaders() } });

export const deleteData = (table: string, id: number | string) =>
  apiClient.delete(`${table}/${id}`, { headers: { ...getAuthHeaders() } });

export const importData = (table: string, file: File) => {
  const formData = new FormData();
  formData.append('file', file);

  return apiClient.post(`${table}/import`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
      ...getAuthHeaders(),
    },
  });
};

export const exportData = (table: string) =>
  apiClient.get(`${table}/export`, {
    headers: { ...getAuthHeaders() },
    responseType: 'blob',
  });
