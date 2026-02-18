# 1. Usamos una imagen ligera de Node.js
FROM node:18-slim

# 2. Creamos el directorio de trabajo dentro del contenedor
WORKDIR /app

# 3. Copiamos solo los archivos de dependencias para aprovechar el cache de Docker
COPY package*.json ./

# 4. Instalamos las dependencias
RUN npm install --production

# 5. Copiamos el resto del código de la carpeta api
COPY . .

# 6. Informamos que el contenedor usará el puerto 3000
EXPOSE 3000

# 7. Comando para arrancar la aplicación
CMD ["node", "index.js"]