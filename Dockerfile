# ---------- Etapa builder: compilar Angular ----------
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
# Salida real de Angular 17: dist/casino-frontend/browser/

# ---------- Etapa runtime: servir con Nginx ----------
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
COPY --from=builder --chown=nginx:nginx /app/build-output/ /usr/share/nginx/html/
COPY --chown=nginx:nginx nginx.conf /etc/nginx/templates/default.conf.template
USER nginx
EXPOSE 8080