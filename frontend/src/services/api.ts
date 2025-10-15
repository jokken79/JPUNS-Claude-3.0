import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log('🔐 Request with token:', token ? 'YES' : 'NO');
    return config;
  },
  (error) => {
    console.error('❌ Request error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => {
    console.log('✅ Response success:', response.status);
    return response;
  },
  async (error) => {
    console.error('❌ Response error:', error.response?.status, error.response?.data);
    
    if (error.response?.status === 401) {
      console.log('🔑 Token expired, attempting auto-login...');
      
      try {
        // Intentar login automático
        const loginResponse = await axios.post('/api/auth/login', 
          'username=admin&password=admin123',
          {
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          }
        );
        
        const newToken = loginResponse.data.access_token;
        localStorage.setItem('token', newToken);
        console.log('✅ Auto-login successful, retrying request...');
        
        // Reintentar la petición original con el nuevo token
        error.config.headers.Authorization = `Bearer ${newToken}`;
        return api.request(error.config);
        
      } catch (loginError) {
        console.error('❌ Auto-login failed:', loginError);
        localStorage.removeItem('token');
        window.location.href = '/login';
      }
    }
    
    return Promise.reject(error);
  }
);

// Auth services
export const authService = {
  login: async (username: string, password: string) => {
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);
    
    const response = await api.post('/api/auth/login', formData, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    return response.data;
  },
  
  logout: () => {
    localStorage.removeItem('token');
    window.location.href = '/login';
  },
  
  getCurrentUser: async () => {
    const response = await api.get('/api/auth/me');
    return response.data;
  }
};

// Employee services
export const employeeService = {
  getEmployees: async (params?: any) => {
    const response = await api.get('/api/employees/', { params });
    return response.data;
  },
  
  getEmployee: async (id: string) => {
    const response = await api.get(`/api/employees/${id}/`);
    return response.data;
  },
  
  createEmployee: async (data: any) => {
    const response = await api.post('/api/employees/', data);
    return response.data;
  },
  
  updateEmployee: async (id: string, data: any) => {
    const response = await api.put(`/api/employees/${id}/`, data);
    return response.data;
  },
  
  deleteEmployee: async (id: string) => {
    const response = await api.delete(`/api/employees/${id}/`);
    return response.data;
  }
};

// Candidate services
export const candidateService = {
  getCandidates: async (params?: any) => {
    const response = await api.get('/api/candidates/', { params });
    return response.data;
  },
  
  getCandidate: async (id: string) => {
    const response = await api.get(`/api/candidates/${id}/`);
    return response.data;
  },
  
  createCandidate: async (data: any) => {
    const response = await api.post('/api/candidates/', data);
    return response.data;
  }
};

// Dashboard services
export const dashboardService = {
  getStats: async () => {
    const response = await api.get('/api/dashboard/stats');
    return response.data;
  }
};

export default api;