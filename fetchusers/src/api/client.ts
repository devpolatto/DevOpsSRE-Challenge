import axios from 'axios';

let API_URL = 'http://localhost:3000'; // fallback

// Carrega config em runtime
fetch('/config.json')
  .then(r => r.json())
  .then(config => {
    API_URL = config.apiUrl || API_URL;
  })
  .catch(() => console.warn('config.json não encontrado'));

const api = axios.create({
  baseURL: API_URL,
  timeout: 8000,
});

export default api;