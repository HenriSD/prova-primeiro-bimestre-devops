# ---------- Stage 1: dependências ----------
FROM node:22-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---------- Stage 2: imagem final ----------
FROM node:22-alpine AS runner

WORKDIR /app

# Cria um usuário/grupo não-root dedicado para rodar a aplicação
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copia apenas as dependências já resolvidas do stage anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia o código da aplicação
COPY package.json ./
COPY src ./src

# Garante que o usuário não-root tenha posse dos arquivos
RUN chown -R appuser:appgroup /app

USER appuser

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "src/server.js"]