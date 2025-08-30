FROM node:18-alpine AS builder

WORKDIR /app

# Copia arquivos de configuração do projeto
COPY package*.json tsconfig.json ./

# Instala dependências
RUN npm install --legacy-peer-deps

# Copia todo o código-fonte
COPY src/ ./src/

# Constrói o projeto
RUN npm run build

# Imagem final - multi-plataforma
FROM node:18-alpine

# Metadados da imagem
LABEL maintainer="Gabriel Augusto (@oaugustosgabriel)"
LABEL org.g2ntech.name="G2N MCP Google Calendar SSE"
LABEL org.g2ntech.description="Servidor MCP para Google Calendar usando SSE"
LABEL org.g2ntech.version="1.1.0"
LABEL org.g2ntech.github.repo="https://github.com/gabriel-g2n/g2n-mcp-gcal-sse"

WORKDIR /app

# Copia arquivos de configuração
COPY package*.json ./

# Instala apenas dependências de produção
RUN npm install --omit=dev --legacy-peer-deps && \
    npm cache clean --force

# Copia código compilado
COPY --from=builder /app/build ./build

# Cria diretório para armazenar tokens
RUN mkdir -p /app/data && \
    chown -R node:node /app/data && \
    chmod 755 /app/data

# Criar diretório de logs e ajustar permissões
RUN mkdir -p /usr/src/app/logs && \
    chown -R node:node /usr/src/app/logs

# Expõe a porta configurada ou 3001 como padrão
EXPOSE ${PORT:-3001}

# Mudar para o usuário node
USER node

# Define comando de inicialização
CMD ["node", "build/index.js"] 
