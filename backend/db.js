// config/db.js
import mysql from 'mysql2';
import dotenv from 'dotenv';
dotenv.config();

const db = mysql.createPool({
  host: process.env.DB_HOST,       // Lo leerá de Render
  user: process.env.DB_USER,       // Lo leerá de Render
  password: process.env.DB_PASSWORD, // Lo leerá de Render
  database: process.env.DB_NAME,   // Lo leerá de Render
  port: process.env.DB_PORT || 4000, // Importante el 4000
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  // ⚠️ ESTO ES OBLIGATORIO PARA TiDB:
  ssl: {
    rejectUnauthorized: true
  }
});
/*const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'sistema_inventario',
  port: process.env.DB_PORT || 3306
});
connection.connect(err => {
  if (err) {
    console.error('❌ Error al conectar con la base de datos:', err.message);
  } else {
    console.log('✅ Conexión a la base de datos exitosa.');
  }
});
*/
export default db; // 👈 ESTA LÍNEA ES LA CLAVE
