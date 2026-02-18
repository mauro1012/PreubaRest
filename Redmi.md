# Proyecto API & Sender (Infraestructura AWS)

Este repositorio contiene la configuración para una arquitectura de microservicios compuesta por una API (Express, Redis, S3) y un servicio Sender (Axios), automatizada con Terraform.

## Requisitos Previos

1. Tener configurado Terraform en tu entorno.
2. Credenciales de AWS activas.
3. Node.js y npm instalados.

---

## Configuración de Infraestructura (Terraform)

Antes de iniciar los servicios de Node.js, asegúrate de desplegar el bucket de S3:

1. Revisa el nombre del bucket en variables.tf:
   ```hcl
   variable "bucket_name" {
     default = "nombre-de-tu-bucket-aqui"
   }

```

2. Ejecuta el despliegue:
```bash
terraform init
terraform apply

```



---

## Instalación de Dependencias

### 1. Carpeta API

Servicio principal encargado de la lógica, conexión con Redis y gestión de archivos en S3.

```bash
cd api
npm init -y
npm install express redis @aws-sdk/client-s3 dotenv cors

```

### 2. Carpeta Sender

Servicio encargado de la comunicación y envío de peticiones.

```bash
cd ../sender
npm init -y
npm install axios dotenv

```

---

## Variables de Entorno (.env)

Es fundamental que el nombre del bucket en la API coincida con el creado por Terraform.

Archivo api/.env:

```env
PORT=3000
AWS_REGION=us-east-1
S3_BUCKET_NAME=nombre-de-tu-bucket-aqui  # Debe coincidir con variables.tf
REDIS_URL=redis://localhost:6379

```

Archivo sender/.env:

```env
API_URL=http://localhost:3000

```

---

## Ejecución

Para iniciar los servicios en modo desarrollo:

```bash
# En la carpeta api
node index.js

# En la carpeta sender
node index.js

```

---

## Tecnologías utilizadas

* Backend: Node.js, Express
* Base de Datos/Cache: Redis
* Cloud: AWS (S3)
* IaC: Terraform
* Comunicación: Axios, CORS

```

¿Deseas que te ayude con la configuración de GitHub Actions para automatizar este flujo?

```