require('dotenv').config();
const express = require('express');
const redis = require('redis');
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const cors = require('cors');

const app = express();

// Middlewares
app.use(express.json());
app.use(cors());

// Configuración de variables de entorno
const PORT = process.env.PORT || 3000;
const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const BUCKET_NAME = process.env.BUCKET_NAME;

// 1. Configuración del Cliente S3 (AJUSTADO PARA USAR TUS VARIABLES DEL .ENV)
const s3 = new S3Client({ 
    region: "us-east-1",
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        sessionToken: process.env.AWS_SESSION_TOKEN // Requerido para AWS Academy
    }
});

// 2. Configuración de Redis (Se mantiene igual)
const redisClient = redis.createClient({ 
    url: `redis://${REDIS_HOST}:6379` 
});

redisClient.on('error', (err) => console.error('Error en Redis:', err));
redisClient.connect().then(() => console.log('Conectado a Redis con exito.'));

// 3. Endpoint Principal: Recibir Notificación
app.post('/api/notificar', async (req, res) => {
    const { usuario, mensaje, prioridad } = req.body;

    if (!usuario || !mensaje) {
        return res.status(400).json({ error: "Faltan campos obligatorios: usuario y mensaje." });
    }

    const timestamp = Date.now();
    const notificationId = `notif-${timestamp}`;

    try {
        const data = { usuario, mensaje, prioridad: prioridad || 'normal', fecha: new Date() };
        
        // A. Guardar en Redis
        await redisClient.set(notificationId, JSON.stringify(data));
        console.log(`[Redis] Notificacion guardada: ${notificationId}`);

        // B. Guardar en S3
        if (BUCKET_NAME) {
            const s3Params = {
                Bucket: BUCKET_NAME,
                Key: `alertas/${notificationId}.json`,
                Body: JSON.stringify(data, null, 2),
                ContentType: "application/json"
            };
            await s3.send(new PutObjectCommand(s3Params));
            console.log(`[S3] Archivo de auditoria creado en bucket: ${BUCKET_NAME}`);
        }

        res.status(201).json({
            status: "SUCCESS",
            message: "Notificacion procesada y archivada correctamente.",
            id: notificationId,
            timestamp: new Date().toISOString()
        });

    } catch (error) {
        console.error('Error procesando la solicitud:', error);
        res.status(500).json({
            status: "ERROR",
            message: "Fallo interno en el procesamiento de la notificacion.",
            details: error.message
        });
    }
});

// 4. Endpoint de Salud
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.listen(PORT, () => {
    console.log(`Servidor REST activo y escuchando en puerto ${PORT}`);
});