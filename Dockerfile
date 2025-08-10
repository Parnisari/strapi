# Usa Node LTS con Debian (toolchain più completa per build di Strapi)
FROM node:20-bullseye-slim

# Evita prompt interattivi
ENV NODE_ENV=production

# Cartella di lavoro
WORKDIR /app

# --- Forza Yarn 1.22.22 senza Corepack -------------------------------
# Pulisci eventuali configurazioni locali di Yarn e installa yarn classic da npm
RUN rm -f .yarnrc .yarnrc.yml \
 && rm -rf .yarn/ \
 && npm i -g yarn@1.22.22 --force \
 && yarn --version --no-default-rc

# Dipendenze di sistema utili per Strapi/pg (facoltativo ma consigliato)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates openssl \
 && rm -rf /var/lib/apt/lists/*

# Copia solo i manifest per sfruttare il layer cache
COPY package.json yarn.lock* ./

RUN corepack enable && corepack prepare yarn@1.22.22 --activate

# Installa dipendenze (usa yarn classic appena installato)
RUN yarn install --frozen-lockfile

# Copia il resto del codice
COPY . .

# Build dell'admin
RUN yarn build

# Strapi deve ascoltare sulla porta fornita da Railway
ENV PORT=8080
# (Strapi la leggerà se nel tuo config/server.js hai port: env.int('PORT', 1337))
EXPOSE 8080

# Avvia l'app
CMD ["yarn", "start"]
