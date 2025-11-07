// notificaciones.js
// Función para enviar notificaciones simuladas
function enviarNotificacion(titulo, mensaje) {
    if (!("Notification" in window)) {
        alert("Tu navegador no soporta notificaciones");
    } else if (Notification.permission === "granted") {
        const notificacion = new Notification(titulo, { body: mensaje });
    } else if (Notification.permission !== "denied") {
        Notification.requestPermission().then(permission => {
            if (permission === "granted") {
                const notificacion = new Notification(titulo, { body: mensaje });
            }
        });
    }
}

