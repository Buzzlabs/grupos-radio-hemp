# ====== BUILD ======
FROM ghcr.io/cirruslabs/flutter:3.35.5 AS build

WORKDIR /app

# copia tudo
COPY . .

# limpa qualquer lixo/caches quebrados
RUN rm -rf /root/.pub-cache
RUN flutter clean

# instala deps
RUN flutter pub get

# build web (SEM wasm pq matrix quebra)
RUN flutter build web --release --no-wasm-dry-run

# ====== SERVE (NGINX) ======
FROM nginx:alpine

# limpa html padrão
RUN rm -rf /usr/share/nginx/html/*

# copia build do flutter
COPY --from=build /app/build/web /usr/share/nginx/html

# expõe porta
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
