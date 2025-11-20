# --- ETAPA 1: Construcción (Builder) ---
FROM node:lts-alpine AS builder

WORKDIR /app

# Copiamos los archivos de dependencias
COPY package.json package-lock.json ./

# Instalamos dependencias (usamos ci para entornos automatizados)
RUN npm ci

# Copiamos el resto del código
COPY . .

# Construimos el sitio (Genera la carpeta /dist)
RUN npm run build

# --- ETAPA 2: Servidor Web (Nginx) ---
FROM nginx:alpine AS runtime

# Copiamos la configuración de Nginx (crearemos este archivo en el paso 2)
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos los archivos estáticos generados en la etapa anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponemos el puerto 80
EXPOSE 80

# Iniciamos Nginx
CMD ["nginx", "-g", "daemon off;"]