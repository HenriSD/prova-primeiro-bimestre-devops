const express = require('express');
const { initDb } = require('./db');
const reservasRouter = require('./routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check — usado pelo healthcheck do Docker Compose e por monitoramento na AWS.
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use(reservasRouter);

// Handler simples para rota não encontrada.
app.use((_req, res) => {
  res.status(404).json({ erro: 'rota não encontrada' });
});

async function start() {
  try {
    await initDb();
    app.listen(PORT, () => {
      console.log(`[server] API de Reservas rodando na porta ${PORT}`);
    });
  } catch (err) {
    console.error('[server] falha ao iniciar — não foi possível conectar ao banco:', err.message);
    process.exit(1);
  }
}

start();