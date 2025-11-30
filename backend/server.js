import db from './db.js';
import express from 'express';
import cors from 'cors';
import mysql from 'mysql2';


const app = express();
app.use(cors());
app.use(express.json());

setInterval(() => {
  db.query('SELECT 1', (err) => {
    if (err) {
      console.error('[Heartbeat] Error manteniendo conexión DB:', err.message);
    } else {
      console.log('[Heartbeat] Ping a DB exitoso (Server activo)');
    }
  });
}, 5 * 60 * 1000);
// ...
db.connect((err) => {
  if (err) {
    console.error('❌ Error al conectar con la base de datos:', err); // <--- CAMBIO AQUÍ
    return;
  }
  console.log('✅ Conexión a la base de datos exitosa.');
});
// ============================================
// ENDPOINTS DE PRODUCTOS
// ============================================

app.get('/api/products', (req, res) => {
  const query = `
    SELECT 
      p.id_producto as id,
      p.nombre_producto as name,
      c.nombre_categoria as category,
      p.precio_venta as price,
      p.stock_actual as stock,
      p.stock_minimo,
      pr.nombre_proveedor as provider,
      p.precio_compra,
      CASE 
        WHEN p.stock_actual = 0 THEN 'Crítico'
        WHEN p.stock_actual <= p.stock_minimo THEN 'Bajo'
        WHEN p.stock_actual > 40 THEN 'Sobrestock'
        ELSE 'Óptimo'
      END as status
    FROM productos p
    LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
    LEFT JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
    ORDER BY p.id_producto DESC
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('Error:', err);
      res.status(500).json({ error: err.message });
    } else {
      res.json(results);
    }
  });
});

app.get('/api/products/:id', (req, res) => {
  const { id } = req.params;
  const query = `
    SELECT 
      p.id_producto as id,
      p.nombre_producto as name,
      c.nombre_categoria as category,
      p.precio_venta as price,
      p.stock_actual as stock,
      p.stock_minimo,
      pr.nombre_proveedor as provider,
      p.precio_compra
    FROM productos p
    LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
    LEFT JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
    WHERE p.id_producto = ?
  `;
  
  db.query(query, [id], (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else if (results.length === 0) {
      res.status(404).json({ error: 'Producto no encontrado' });
    } else {
      res.json(results[0]);
    }
  });
});

app.post('/api/products', (req, res) => {
  const { name, category, price, stock, stock_minimo, provider, precio_compra } = req.body;
  
  db.query('SELECT id_categoria FROM categorias WHERE nombre_categoria = ?', [category], (err, catResults) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    let id_categoria = catResults.length > 0 ? catResults[0].id_categoria : null;
    
    const insertCategory = (callback) => {
      if (!id_categoria) {
        db.query('INSERT INTO categorias (nombre_categoria) VALUES (?)', [category], (err, result) => {
          if (err) return callback(err);
          id_categoria = result.insertId;
          callback(null);
        });
      } else {
        callback(null);
      }
    };
    
    insertCategory((err) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      db.query('SELECT id_proveedor FROM proveedores WHERE nombre_proveedor = ?', [provider], (err, provResults) => {
        if (err) {
          res.status(500).json({ error: err.message });
          return;
        }
        
        let id_proveedor = provResults.length > 0 ? provResults[0].id_proveedor : null;
        
        const insertProvider = (callback) => {
          if (!id_proveedor) {
            db.query('INSERT INTO proveedores (nombre_proveedor) VALUES (?)', [provider], (err, result) => {
              if (err) return callback(err);
              id_proveedor = result.insertId;
              callback(null);
            });
          } else {
            callback(null);
          }
        };
        
        insertProvider((err) => {
          if (err) {
            res.status(500).json({ error: err.message });
            return;
          }
          
          const query = `
            INSERT INTO productos 
            (nombre_producto, id_categoria, id_proveedor, stock_actual, stock_minimo, precio_compra, precio_venta) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
          `;
          
          db.query(query, [name, id_categoria, id_proveedor, stock || 0, stock_minimo || 5, precio_compra || price, price], (err, result) => {
            if (err) {
              res.status(500).json({ error: err.message });
            } else {
              res.status(201).json({ 
                id: result.insertId, 
                message: 'Producto agregado exitosamente' 
              });
            }
          });
        });
      });
    });
  });
});
// --- OBTENER HISTORIAL DE VENTAS (Últimos 7 días) ---
app.get('/api/stats/history', (req, res) => {
  const userOffset = '-05:00'; // Hora Perú
  
  // Esta consulta agrupa las ventas por FECHA
  const query = `
    SELECT 
      DATE_FORMAT(CONVERT_TZ(s.fecha, '+00:00', '${userOffset}'), '%d/%m') as fecha,
      COALESCE(SUM(s.cantidad * p.precio_venta), 0) as total
    FROM salidas s
    JOIN productos p ON s.id_producto = p.id_producto
    WHERE s.fecha >= DATE_SUB(NOW(), INTERVAL 7 DAY) -- Últimos 7 días
    GROUP BY DATE(CONVERT_TZ(s.fecha, '+00:00', '${userOffset}'))
    ORDER BY s.fecha ASC;
  `;

  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      // Devuelve: [{ "fecha": "24/11", "total": 150.00 }, ...]
      res.json(results);
    }
  });
});
app.put('/api/products/:id', (req, res) => {
  const { id } = req.params;
  const { name, category, price, stock, stock_minimo, provider, precio_compra } = req.body;
  
  db.query('SELECT id_categoria FROM categorias WHERE nombre_categoria = ?', [category], (err, catResults) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    let id_categoria = catResults.length > 0 ? catResults[0].id_categoria : null;
    
    const insertCategory = (callback) => {
      if (!id_categoria) {
        db.query('INSERT INTO categorias (nombre_categoria) VALUES (?)', [category], (err, result) => {
          if (err) return callback(err);
          id_categoria = result.insertId;
          callback(null);
        });
      } else {
        callback(null);
      }
    };
    
    insertCategory((err) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      db.query('SELECT id_proveedor FROM proveedores WHERE nombre_proveedor = ?', [provider], (err, provResults) => {
        if (err) {
          res.status(500).json({ error: err.message });
          return;
        }
        
        let id_proveedor = provResults.length > 0 ? provResults[0].id_proveedor : null;
        
        const insertProvider = (callback) => {
          if (!id_proveedor) {
            db.query('INSERT INTO proveedores (nombre_proveedor) VALUES (?)', [provider], (err, result) => {
              if (err) return callback(err);
              id_proveedor = result.insertId;
              callback(null);
            });
          } else {
            callback(null);
          }
        };
        
        insertProvider((err) => {
          if (err) {
            res.status(500).json({ error: err.message });
            return;
          }
          
          const query = `
            UPDATE productos 
            SET nombre_producto=?, id_categoria=?, id_proveedor=?, 
                stock_actual=?, stock_minimo=?, precio_compra=?, precio_venta=?
            WHERE id_producto=?
          `;
          
          db.query(query, [name, id_categoria, id_proveedor, stock, stock_minimo || 5, precio_compra || price, price, id], (err) => {
            if (err) {
              res.status(500).json({ error: err.message });
            } else {
              res.json({ message: 'Producto actualizado exitosamente' });
            }
          });
        });
      });
    });
  });
});

app.delete('/api/products/:id', (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM productos WHERE id_producto = ?', [id], (err) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json({ message: 'Producto eliminado exitosamente' });
    }
  });
});
// ============================================
// ENDPOINT DE VENTAS (SALIDAS)
// ============================================

app.post('/api/salidas', (req, res) => {
  // Obtenemos el ID del producto y la cantidad
  const { id_producto, cantidad } = req.body;

  if (!id_producto || !cantidad) {
    return res.status(400).json({ error: 'Faltan id_producto o cantidad' });
  }

  // Convertimos cantidad a número
  const cantNum = parseInt(cantidad, 10);
  if (cantNum <= 0) {
    return res.status(400).json({ error: 'La cantidad debe ser mayor a 0' });
  }

  // 1. Insertamos la salida en la tabla 'salidas'
  // (Asumimos que id_cliente e id_usuario son nulos por ahora)
  const queryInsert = 'INSERT INTO salidas (id_producto, cantidad) VALUES (?, ?)';
  
  db.query(queryInsert, [id_producto, cantNum], (err, result) => {
    if (err) {
      console.error('Error al insertar salida:', err);
      return res.status(500).json({ error: 'Error al registrar la salida' });
    }

    // ✅ Éxito. El trigger de la BD se encargará del stock.
    res.status(201).json({ message: 'Venta registrada' });
  });
});
// ============================================
// ENDPOINTS DE CATEGORÍAS
// ============================================

app.get('/api/categories', (req, res) => {
  const query = 'SELECT nombre_categoria FROM categorias ORDER BY nombre_categoria ASC';
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      // Devolvemos un array de strings (nombres)
      res.json(results.map(c => c.nombre_categoria));
    }
  });
});

app.post('/api/categories', (req, res) => {
  const { name } = req.body;
  db.query('INSERT INTO categorias (nombre_categoria) VALUES (?)', [name], (err, result) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.status(201).json({ id: result.insertId, message: 'Categoría agregada' });
    }
  });
});

// ============================================
// ENDPOINTS DE PROVEEDORES
// ============================================

app.get('/api/providers', (req, res) => {
  const query = 'SELECT nombre_proveedor FROM proveedores ORDER BY nombre_proveedor ASC';
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      // Devolvemos un array de strings (nombres)
      res.json(results.map(p => p.nombre_proveedor));
    }
  });
});

app.post('/api/providers', (req, res) => {
  const { nombre_proveedor, telefono, correo, direccion } = req.body;
  const query = 'INSERT INTO proveedores (nombre_proveedor, telefono, correo, direccion) VALUES (?, ?, ?, ?)';
  db.query(query, [nombre_proveedor, telefono, correo, direccion], (err, result) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.status(201).json({ id: result.insertId, message: 'Proveedor agregado' });
    }
  });
});

// ============================================
// ENDPOINTS DE AUTENTICACIÓN
// ============================================

app.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  db.query('SELECT * FROM usuarios WHERE correo = ? AND contraseña = ?', [email, password], (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else if (results.length > 0) {
      const user = results[0];
      res.json({ 
        success: true, 
        user: {
          id: user.id_usuario,
          name: user.nombre_usuario,
          email: user.correo,
          role: user.rol
        }
      });
    } else {
      res.status(401).json({ success: false, message: 'Credenciales incorrectas' });
    }
  });
});

app.post('/api/register', (req, res) => {
  const { name, email, password } = req.body;
  const query = 'INSERT INTO usuarios (nombre_usuario, correo, contraseña, rol) VALUES (?, ?, ?, ?)';
  
  db.query(query, [name, email, password, 'empleado'], (err, result) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        res.status(400).json({ success: false, message: 'El correo ya está registrado' });
      } else {
        res.status(500).json({ error: err.message });
      }
    } else {
      res.status(201).json({ 
        success: true, 
        id: result.insertId, 
        message: 'Usuario registrado exitosamente' 
      });
    }
  });
});

// ============================================
// ENDPOINTS DE ESTADÍSTICAS
// ============================================

app.get('/api/stats/sales', (req, res) => {
  const periodo = req.query.periodo || 'dia'; 
  
  // ✅ PRUEBA 1: ¿Está llegando la petición?
  console.log(`[SERVER] Petición de ventas recibida para: ${periodo}`);

  const userOffset = '-05:00';
  let whereClause = '';

  const nowInUserTZ = `CONVERT_TZ(NOW(), '+00:00', '${userOffset}')`;
  const fechaInUserTZ = `CONVERT_TZ(s.fecha, '+00:00', '${userOffset}')`;

  switch (periodo.toLowerCase()) {
    case 'semana':
      whereClause = `WHERE YEARWEEK(${fechaInUserTZ}, 1) = YEARWEEK(${nowInUserTZ}, 1)`;
      break;
    case 'mes':
      whereClause = `WHERE MONTH(${fechaInUserTZ}) = MONTH(${nowInUserTZ}) AND YEAR(${fechaInUserTZ}) = YEAR(${nowInUserTZ})`;
      break;
    case 'dia':
    default:
      whereClause = `WHERE DATE(${fechaInUserTZ}) = DATE(${nowInUserTZ})`;
  }

  const query = `
    SELECT 
      COALESCE(SUM(s.cantidad * p.precio_venta), 0) as totalVentas
    FROM salidas s
    JOIN productos p ON s.id_producto = p.id_producto
    ${whereClause}; 
  `;
  
  // ✅ PRUEBA 2: ¿Qué consulta estamos ejecutando?
  console.log('[SERVER] Ejecutando SQL:', query.trim().replace(/\s+/g, ' ')); // Lo limpiamos para verlo en 1 línea

  db.query(query, (err, results) => {
    if (err) {
      console.error('[SERVER] Error en la consulta:', err); // Log del error
      res.status(500).json({ error: err.message });
    } else {
      // ✅ PRUEBA 3: ¿Qué está devolviendo la BD?
      console.log('[SERVER] Resultado de la BD:', results[0]);
      res.json({ totalVentas: results[0].totalVentas }); 
    }
  });
});

app.get('/api/stats/total-stock', (req, res) => {
  db.query('SELECT SUM(stock_actual) as total FROM productos', (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json({ total: results[0].total || 0 });
    }
  });
});

app.get('/api/stats/low-stock', (req, res) => {
  db.query('SELECT COUNT(*) as count FROM productos WHERE stock_actual <= stock_minimo', (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json({ count: results[0].count });
    }
  });
});

app.get('/api/stats/categories-distribution', (req, res) => {
  const query = `
    SELECT 
      c.nombre_categoria as name,
      COUNT(p.id_producto) as count
    FROM categorias c
    JOIN productos p ON c.id_categoria = p.id_categoria
    GROUP BY c.id_categoria, c.nombre_categoria
    HAVING count > 0;
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json(results);
    }
  });
});
app.get('/api/stats/rotation', (req, res) => {
  
  const userOffset = '-05:00'; // Zona horaria de Lima
  const nowInUserTZ = `CONVERT_TZ(NOW(), '+00:00', '${userOffset}')`;
  const fechaInUserTZ = (dateField) => `CONVERT_TZ(${dateField}, '+00:00', '${userOffset}')`;

  // Consulta con dos sub-consultas para obtener ambos valores
  const query = `
    SELECT
      (SELECT COALESCE(SUM(cantidad), 0) 
       FROM salidas 
       WHERE YEARWEEK(${fechaInUserTZ('fecha')}, 1) = YEARWEEK(${nowInUserTZ}, 1)
      ) as totalSoldThisWeek,
      
      (SELECT COALESCE(SUM(stock_actual), 0) 
       FROM productos
      ) as totalCurrentStock;
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('[SERVER] Error en /api/stats/rotation:', err);
      return res.status(500).json({ error: err.message });
    }
    
    // Obtenemos los dos números
    const sold = parseFloat(results[0].totalSoldThisWeek);
    const stock = parseFloat(results[0].totalCurrentStock);
    
    // Calculamos el porcentaje
    const totalInventory = sold + stock;
    const rotation = (totalInventory === 0) ? 0 : (sold / totalInventory) * 100;
    
    console.log(`[SERVER] Rotación calculada: ${sold} vendidos / (${sold} + ${stock}) stock = ${rotation}%`);
    
    // Devolvemos el porcentaje final
    res.json({ rotationPercentage: rotation });
  });
});
// ============================================
// SERVIDOR
// ============================================
app.get('/api/sales-history/:product', (req, res) => {
  const product = req.params.product;

  const query = `
    SELECT 
      DATE(s.fecha) AS fecha,
      SUM(s.cantidad) AS cantidad
    FROM salidas s
    JOIN productos p ON s.id_producto = p.id_producto
    WHERE p.nombre_producto = ?
    GROUP BY DATE(s.fecha)
    ORDER BY fecha ASC;
  `;

  db.query(query, [product], (err, results) => {
    if (err) {
      console.error('❌ Error en sales-history:', err);
      return res.status(500).json({ error: err.message });
    }

    res.json(results);
  });
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
  console.log(`📡 API disponible en http://localhost:${PORT}/api`);
});

