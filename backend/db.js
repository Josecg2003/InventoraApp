// config/db.js
import mysql from 'mysql2';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  ssl: {
    rejectUnauthorized: true,
    ca: fs.readFileSync('./isrgrootx1.pem')
  }
});

connection.connect(err => {
  if (err) {
    console.error('❌ Error al conectar con TiDB:', err.message);
  } else {
    console.log('✅ Conectado exitosamente a TiDB Cloud.');
  }
});

export default connection;


// config/db.js
/*import mysql from 'mysql2';
import dotenv from 'dotenv';
dotenv.config();

const connection = mysql.createConnection({
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

export default connection; 👈 ESTA LÍNEA ES LA CLAVE*/