// alertas.js
// Función para mostrar alertas al usuario
function mostrarAlerta(mensaje, tipo) {
    // tipo puede ser 'exito', 'error', 'info'
    const alertContainer = document.createElement('div');
    alertContainer.className = `alerta ${tipo}`;
    alertContainer.innerText = mensaje;
    
    // Estilo básico de la alerta
    alertContainer.style.position = 'fixed';
    alertContainer.style.top = '10px';
    alertContainer.style.right = '10px';
    alertContainer.style.padding = '15px';
    alertContainer.style.backgroundColor = tipo === 'exito' ? 'green' : tipo === 'error' ? 'red' : 'blue';
    alertContainer.style.color = 'white';
    alertContainer.style.borderRadius = '5px';
    alertContainer.style.zIndex = '1000';

    document.body.appendChild(alertContainer);

    // Desaparece después de 3 segundos
    setTimeout(() => {
        alertContainer.remove();
    }, 3000);
}

// Ejemplo de uso
// mostrarAlerta('Operación exitosa', 'exito');
