
export default function HealthStatus({ healthy }: { healthy: boolean | null }) {
  return (
    <div className={`text-center text-black p-6 rounded-lg border-4 ${
      healthy === null ? 'border-yellow-400 bg-yellow-50' :
      healthy ? 'border-green-500 bg-green-50' : 'border-red-500 bg-red-50'
    }`}>
      <p className="text-2xl font-semibold">
        {healthy === null && "Verificando conexão..."}
        {healthy === true && "Backend conectado e saudável"}
        {healthy === false && "Backend indisponível"}
      </p>
      <p className="text-sm text-gray-600 mt-2">
        Health check a cada 10 segundos
      </p>
    </div>
  );
}