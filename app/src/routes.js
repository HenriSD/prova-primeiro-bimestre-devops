const express = require('express');
const { pool } = require('./db');

const router = express.Router();

const STATUS_VALIDOS = ['pendente', 'confirmada', 'cancelada'];

function validarPayload(body, { parcial = false } = {}) {
  const erros = [];
  const { cliente, data, status } = body;

  if (!parcial || cliente !== undefined) {
    if (!cliente || typeof cliente !== 'string' || !cliente.trim()) {
      erros.push('campo "cliente" é obrigatório e deve ser uma string não vazia');
    }
  }

  if (!parcial || data !== undefined) {
    if (!data || Number.isNaN(Date.parse(data))) {
      erros.push('campo "data" é obrigatório e deve ser uma data válida (YYYY-MM-DD)');
    }
  }

  if (status !== undefined && !STATUS_VALIDOS.includes(status)) {
    erros.push(`campo "status" deve ser um de: ${STATUS_VALIDOS.join(', ')}`);
  }

  return erros;
}

// CREATE
router.post('/reservas', async (req, res) => {
  const erros = validarPayload(req.body);
  if (erros.length) return res.status(400).json({ erros });

  const { cliente, data, status = 'pendente' } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
      [cliente, data, status]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('[POST /reservas]', err.message);
    res.status(500).json({ erro: 'erro ao criar reserva' });
  }
});

// READ (todas)
router.get('/reservas', async (_req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reservas ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('[GET /reservas]', err.message);
    res.status(500).json({ erro: 'erro ao listar reservas' });
  }
});

// READ (por id)
router.get('/reservas/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM reservas WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ erro: 'reserva não encontrada' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('[GET /reservas/:id]', err.message);
    res.status(500).json({ erro: 'erro ao buscar reserva' });
  }
});

// UPDATE
router.put('/reservas/:id', async (req, res) => {
  const { id } = req.params;
  const erros = validarPayload(req.body, { parcial: true });
  if (erros.length) return res.status(400).json({ erros });

  try {
    const existente = await pool.query('SELECT * FROM reservas WHERE id = $1', [id]);
    if (existente.rows.length === 0) {
      return res.status(404).json({ erro: 'reserva não encontrada' });
    }

    const atual = existente.rows[0];
    const cliente = req.body.cliente ?? atual.cliente;
    const data = req.body.data ?? atual.data;
    const status = req.body.status ?? atual.status;

    const result = await pool.query(
      'UPDATE reservas SET cliente = $1, data = $2, status = $3 WHERE id = $4 RETURNING *',
      [cliente, data, status, id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('[PUT /reservas/:id]', err.message);
    res.status(500).json({ erro: 'erro ao atualizar reserva' });
  }
});

// DELETE
router.delete('/reservas/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM reservas WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ erro: 'reserva não encontrada' });
    }
    res.status(204).send();
  } catch (err) {
    console.error('[DELETE /reservas/:id]', err.message);
    res.status(500).json({ erro: 'erro ao remover reserva' });
  }
});

module.exports = router;