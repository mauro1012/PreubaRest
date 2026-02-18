require('dotenv').config();
const axios = require('axios');

// Si pruebas localmente, usa localhost. En AWS usaremos la IP de la instancia.
const API_URL = process.env.API_URL || 'http://localhost:3000/api/notificar';

const enviarNotificacion = async () => {
    console.log("Iniciando envio de notificacion...");

    const nuevaAlerta = {
        usuario: "Mauricio Correa",
        mensaje: "Prueba de sistema de notificaciones REST v1",
        prioridad: "Alta"
    };

    try {
        const response = await axios.post(API_URL, nuevaAlerta);
        
        console.log("\n==========================================");
        console.log("       RESPUESTA DEL SERVIDOR REST        ");
        console.log("==========================================");
        console.log(`Estado:    ${response.data.status}`);
        console.log(`Mensaje:   ${response.data.message}`);
        console.log(`ID Notif:  ${response.data.id}`);
        console.log(`Fecha:     ${response.data.timestamp}`);
        console.log("==========================================\n");

    } catch (error) {
        console.error("Error al conectar con la API:");
        if (error.response) {
            console.error(`Status: ${error.response.status}`);
            console.error(`Detalle: ${JSON.stringify(error.response.data)}`);
        } else {
            console.error(error.message);
        }
    }
};

// Ejecutar el envio
enviarNotificacion();