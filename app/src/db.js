const { Pool } = require('pg');

// Conexão via variáveis de ambiente — funciona tanto no Docker Compose
// (apontando para o serviço "db") quanto na AWS (apontando para o endpoint do RDS).
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'reservas',
  max: 10,
  idleTimeoutMillis: 30000,
  // RDS exige conexão SSL por padrão. Localmente (Compose) não precisa.
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Cria a tabela de reservas caso ainda não exista.
// Evita depender de um passo manual de migration para rodar local ou na nuvem.
async function initDb() {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS reservas (
      id SERIAL PRIMARY KEY,
      cliente VARCHAR(255) NOT NULL,
      data DATE NOT NULL,
      status VARCHAR(50) NOT NULL DEFAULT 'pendente',
      criado_em TIMESTAMP NOT NULL DEFAULT NOW()
    );
  `;

  // Retry simples: no Compose, a API pode subir levemente antes do Postgres
  // aceitar conexões mesmo com healthcheck configurado corretamente.
  const maxRetries = 10;
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await pool.query(createTableQuery);
      console.log('[db] tabela "reservas" verificada/criada com sucesso.');
      return;
    } catch (err) {
      console.log(`[db] tentativa ${attempt}/${maxRetries} falhou: ${err.message}`);
      if (attempt === maxRetries) throw err;
      await new Promise((resolve) => setTimeout(resolve, 3000));
    }
  }
}

module.exports = { pool, initDb };