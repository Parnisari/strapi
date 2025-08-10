FROM node:20-bullseye-slim

ENV NODE_ENV=production
WORKDIR /app

# Installa Yarn 1.22.22 globalmente (bypass Corepack)
RUN rm -f .yarnrc .yarnrc.yml \
 && rm -rf .yarn/ \
 && npm i -g yarn@1.22.22 --force \
 && yarn --version --no-default-rc

# Dipendenze di sistema utili
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates openssl \
 && rm -rf /var/lib/apt/lists/*

# Copia manifest per usare la cache
COPY package.json yarn.lock* ./

# ✅ Installa senza frozen (così può aggiornare il lockfile in image)
RUN yarn install --non-interactive

# Copia il resto del codice
COPY . .

# Build admin
RUN yarn build

# Porta
ENV PORT=8080
EXPOSE 8080

CMD ["yarn", "start"]
