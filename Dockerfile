# ---------- Etapa builder: compilar Angular ----------
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
# Salida real de Angular 17: dist/casino-frontend/browser/

# ---------- Etapa runtime: servir con Nginx ----------
FROM nginx:alpine AS runtime

# 1) Limpiar la imagen base:
#    - Borramos el index.html "Welcome to nginx" que viene por defecto
#      en /usr/share/nginx/html (sino lo veriamos en pantalla).
#    - Borramos el default.conf que viene en /etc/nginx/conf.d/ para
#      que no choque con el que nuestro template va a generar.
RUN rm -rf /usr/share/nginx/html/* \
 && rm -f /etc/nginx/conf.d/default.conf

# 2) Template de Nginx. La imagen oficial nginx:alpine corre envsubst
#    sobre archivos en /etc/nginx/templates/*.template al arrancar el
#    contenedor y los emite como /etc/nginx/conf.d/<mismoNombre>.conf.
COPY default.conf.template /etc/nginx/templates/default.conf.template

# 3) Estaticos de Angular. El "/." final es CRITICO: fuerza a copiar
#    el CONTENIDO de browser/ a /usr/share/nginx/html/ y NO la carpeta
#    browser entera. Sin el "/.", podriamos terminar con
#    /usr/share/nginx/html/browser/index.html y se serviria el index
#    default de Nginx.
COPY --from=builder /app/dist/casino-frontend/browser/. /usr/share/nginx/html/

EXPOSE 80