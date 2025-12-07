import { useState, useEffect } from 'react';
import api from './api/client';
import HealthStatus from './components/HealthStatus';
import UserList from './components/UserList';

function App() {
  const [backendHealthy, setBackendHealthy] = useState<boolean | null>(null);
  const [users, setUsers] = useState([]);
  const [loadingUsers, setLoadingUsers] = useState(false);

  // Health check a cada 10s
  useEffect(() => {
    const checkHealth = async () => {
      try {
        await api.get('/health');
        setBackendHealthy(true);
        if (users.length === 0) fetchUsers();
      } catch (err) {
        setBackendHealthy(false);
      }
    };

    checkHealth();
    const interval = setInterval(checkHealth, 10000);
    return () => clearInterval(interval);
  }, []);

  const fetchUsers = async () => {
    setLoadingUsers(true);
    try {
      const res = await api.get('/api/users');
      setUsers(res.data);
    } catch (err) {
      console.error('Erro ao carregar usuários', err);
      setUsers([]);
    } finally {
      setLoadingUsers(false);
    }
  };

  return (
    <div className="flex flex-col items-center mx-auto p-6 justify-center">
      <h1 className="text-4xl font-bold text-center mb-8 text-white">
        Health Check
      </h1>

      <HealthStatus healthy={backendHealthy} />

      <div className="w-full max-w-4xl mt-8">
        {backendHealthy ? (
          <UserList users={users} loading={loadingUsers} onRefresh={fetchUsers} />
        ) : (
          <div className="text-center py-12">
            <p className="text-xl text-gray-600">
              Aguardando conexão com o backend...
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;