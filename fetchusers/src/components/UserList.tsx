type User = {
  id: string | number;
  name: string;
  email: string;
  status?: string;
};

interface UserListProps {
  users: User[];
  loading: boolean;
  onRefresh: () => void;
}

export default function UserList({ users, loading, onRefresh }: UserListProps) {
  if (loading) {
    return <p className="text-center text-gray-600">Carregando usuários...</p>;
  }

  if (users.length === 0) {
    return <p className="text-center text-gray-500">Nenhum usuário encontrado.</p>;
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">Lista de Usuários</h2>
        <button
          onClick={onRefresh}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Atualizar
        </button>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        {users.map(user => (
          <div key={user.id} className="bg-white p-6 rounded-lg shadow border">
            <h3 className="text-lg font-semibold">{user.name}</h3>
            <p className="text-gray-600">{user.email}</p>
            <span className={`inline-block mt-2 px-3 py-1 text-sm rounded-full ${
              user.status === 'active' 
                ? 'bg-green-100 text-green-800' 
                : 'bg-gray-100 text-gray-800'
            }`}>
              {user.status || 'ativo'}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}