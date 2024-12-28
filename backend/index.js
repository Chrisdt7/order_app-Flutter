const express = require('express');
const fileUpload = require('express-fileupload');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const qr = require('qrcode');
const fs = require('fs');
const path = require('path');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use('/assets/table_qr', express.static(path.join(__dirname, 'assets/table_qr')));
app.use('/assets/menus', express.static(path.join(__dirname, 'assets/menus')));

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'mobile_app'
});

db.connect(err => {
  if (err) {
    throw err;
  }
  console.log('MySQL Connected...');
});

// ---------- User ----------
// Middleware to verify token
function verifyToken(req, res, next) {
  const bearerHeader = req.headers["authorization"];
  console.log("Authorization Header:", bearerHeader); // Log the Authorization header

  if (typeof bearerHeader !== "undefined") {
    const bearerToken = bearerHeader.split(" ")[1];
    console.log("Extracted Bearer Token:", bearerToken); // Log the extracted token

    jwt.verify(bearerToken, "secretkey", (err, authData) => {
      if (err) {
        console.error("JWT verification failed:", err);
        return res.sendStatus(403);
       }
      console.log("Decoded authData:", authData);
      req.authData = authData; // Pass decoded data to the request object
      next();
    });
  } else {
    res.sendStatus(403); // Unauthorized
  }
}

// Endpoint to get user details
app.get("/user", verifyToken, (req, res) => {
  const sql = "SELECT id_users, name, username, email, role, phone, address FROM users WHERE id_users = ?";
  db.query(sql, [req.authData.id], (err, result) => {
    if (err) {
      console.error("Error fetching user details:", err);
      return res.status(500).send("Server error");
    }
    if (result.length > 0) {
      res.json(result[0]);
    } else {
      res.status(404).send("User not found");
    }
  });
});

// ---------- Login ----------
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT * FROM users WHERE username = ?";
  db.query(sql, [username], (err, result) => {
    if (err) {
      console.error("Error fetching user:", err);
      return res.status(500).send("Server error");
    }
    if (result.length > 0) {
      const user = result[0];
      console.log("User fetched from DB:", user); // Log the fetched user object
      bcrypt.compare(password, user.password, (err, isMatch) => {
        if (err) {
          console.error("Error comparing passwords:", err);
          return res.status(500).send("Server error");
        }
        if (isMatch) {
          const token = jwt.sign({ id: user.id_users, role: user.role }, "secretkey", { expiresIn: "1h" }); // Include role in token
          console.log("Generated Token:", token); // Log the generated token
          res.json({ token, user: { id_users: user.id_users, name: user.name, username: user.username, email: user.email, role: user.role, phone: user.phone, address: user.address } });
        } else {
          res.status(400).send("Invalid credentials");
        }
      });
    } else {
      res.status(400).send("User not found");
    }
  });
});
// ---------- End Login ----------

// ---------- End User ----------

// ---------- Register ----------
app.post('/register', (req, res) => {
  const { name, username, email, password, role, phone, address } = req.body;

  if (!password) {
    return res.status(400).json({ message: 'Password is required' });
  }

  const hashedPassword = bcrypt.hashSync(password, 10);

  const query = `INSERT INTO users (name, username, email, password, role, phone, address) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  db.query(query, [name, username, email, hashedPassword, role, phone, address], (err, result) => {
    if (err) {
      console.error('Error inserting user:', err);
      return res.status(500).json({ message: 'Failed to register' });
    }

    const userId = result.insertId;
    const newUser = {
      id_users: userId,
      name,
      username,
      email,
      role,
      phone,
      address,
    };

    res.status(201).json(newUser); // Change to 201 status for successful creation
  });
});
// ---------- End Register ----------

// ---------- Tables ----------
async function generateQRCodeLimited(text) {
  try {
    const qrCodeData = await qr.toDataURL(text, { width: 200, errorCorrectionLevel: 'H' });
    return qrCodeData;
  } catch (err) {
    console.error('Error generating QR code:', err);
    throw err;
  }
}

const saveDirectory = path.join(__dirname, '..', 'assets', 'table_qr');
if (!fs.existsSync(saveDirectory)) {
  fs.mkdirSync(saveDirectory, { recursive: true });
}

async function saveQRCodeAsImage(tableNumber, qrCodeData) {
  const imageData = qrCodeData.replace(/^data:image\/png;base64,/, '');
  const filePath = path.join(saveDirectory, `table_${tableNumber}.png`);

  try {
    await fs.promises.writeFile(filePath, imageData, 'base64');
    console.log(`QR code saved as table_${tableNumber}.png`);
    return `assets/table_qr/table_${tableNumber}.png`; // Return relative path
  } catch (err) {
    console.error('Error saving QR code image:', err);
    throw err;
  }
}

app.get('/tables', (req, res) => {
  const sql = 'SELECT table_number, table_qr FROM tables';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching tables:', err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});

app.post('/tables', async (req, res) => {
  const { number_of_tables } = req.body;

  try {
    const [rows] = await db.promise().query('SELECT MAX(table_number) AS maxTableNumber FROM tables');
    const maxTableNumber = rows[0].maxTableNumber || 0;

    const tables = [];
    for (let i = 1; i <= number_of_tables; i++) {
      const tableNumber = maxTableNumber + i;
      const tableQrText = `http://10.0.2.2:3000/table/${tableNumber}`;

      const qrCodeData = await generateQRCodeLimited(tableQrText);
      const relativePath = await saveQRCodeAsImage(tableNumber, qrCodeData); // Get relative path

      tables.push([tableNumber, relativePath]);
    }

    const insertTablesQuery = 'INSERT INTO tables (table_number, table_qr) VALUES ?';
    await db.promise().query(insertTablesQuery, [tables]);

    res.status(201).send('Tables added successfully');
  } catch (err) {
    console.error('Error adding tables:', err);
    res.status(500).send('Server error');
  }
});

app.get('/checkqr/:table_qr', async (req, res) => {
  const qrCode = req.params.qrCode;
  const sql = 'SELECT * FROM tables WHERE table_qr = ?';
  db.query(sql, [qrCode], (err, result) => {
    if (err) {
      console.error('Error checking QR code:', err);
      return res.status(500).send('Server error');
    }
    if (result.length > 0) {
      res.status(200).send('QR code valid');
    } else {
      res.status(404).send('QR code not found');
    }
  });
});

// ---------- End Tables ----------

// ---------- Menu ----------
app.use(fileUpload({
  createParentPath: true
}));

const uploadDir = path.join(__dirname, '..', 'assets', 'menus');
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

app.get('/menus', (req, res) => {
  const sql = 'SELECT * FROM menus';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching menus:', err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});

app.post('/menus', (req, res) => {
  const { name, price, description, category, image } = req.body;

  const query = 'INSERT INTO menus (name, price, description, category, image) VALUES (?, ?, ?, ?, ?)';
  db.query(query, [name, price, description, category, image], (err, result) => {
    if (err) {
      console.error('Error inserting menu:', err);
      return res.status(500).json({ message: 'Failed to create menu' });
    }
    res.status(201).json({ message: 'Menu created successfully' });
  });
});

app.post('/upload', (req, res) => {
  if (!req.files || Object.keys(req.files).length === 0) {
    return res.status(400).send('No files were uploaded.');
  }

  let uploadedFile = req.files.file;
  let uploadPath = path.join(__dirname, '..', 'assets', 'menus', uploadedFile.name);

  uploadedFile.mv(uploadPath, (err) => {
    if (err) {
      console.error('Error uploading file:', err);
      return res.status(500).send(err);
    }

    res.json({ filename: uploadedFile.name });
  });
});  

app.put('/menus/:id', async (req, res) => {
  try {
    const menuId = req.params.id;
    const { name, price, description, category, image } = req.body;

    const updatedMenu = {
      name,
      price,
      description,
      category,
      image: image,
    };

    const sql = 'UPDATE menus SET name=?, price=?, description=?, category=?, image=? WHERE id_menus=?';
    const params = [updatedMenu.name, updatedMenu.price, updatedMenu.description, updatedMenu.category, updatedMenu.image, menuId];

    db.query(sql, params, (err, result) => {
      if (err) {
        console.error('Error updating menu:', err);
        return res.status(500).json({ message: 'Failed to update menu' });
      }
      res.status(200).json({ message: 'Menu updated successfully' });
    });
  } catch (error) {
    console.error('Error updating menu:', error);
    res.status(500).json({ message: 'Failed to update menu' });
  }
});

// Delete Menu
app.delete('/menus/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM menus WHERE id_menus = ?';
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Error deleting menu:', err);
      return res.status(500).send('Server error');
    }
    res.send('Menu deleted...');
  });
});
// ---------- End Menu ----------

// ---------- Order ----------
app.post('/orders', async (req, res) => {
  const { id_tables, id_users, total, status, payment } = req.body;

  // Check if the user exists
  const userQuery = 'SELECT * FROM users WHERE id_users = ?';
  db.query(userQuery, [id_users], (err, userResult) => {
    if (err) {
      console.error('Error checking user:', err);
      return res.status(500).json({ message: 'Failed to check user' });
    }

    if (userResult.length === 0) {
      return res.status(400).json({ message: 'User does not exist' });
    }

    // If user exists, insert the order
    const orderQuery = 'INSERT INTO orders (id_tables, id_users, total, status, payment) VALUES (?, ?, ?, ?, ?)';
    db.query(orderQuery, [id_tables, id_users, total, status, payment], (err, orderResult) => {
      if (err) {
        console.error('Error creating order:', err);
        return res.status(500).json({ message: 'Failed to create order' });
      }
      res.status(201).json({ message: 'Order created successfully', orderId: orderResult.insertId });
    });
  });
});

app.get('/orders', (req, res) => {
  const sql = 'SELECT * FROM orders';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching orders:', err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});

app.get('/orders/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'SELECT * FROM orders WHERE id_orders = ?';
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Error fetching order:', err);
      return res.status(500).send('Server error');
    }
    if (result.length > 0) {
      res.json(result[0]);
    } else {
      res.status(404).send('Order not found');
    }
  });
});

app.put('/orders/:id', (req, res) => {
  const { id } = req.params;
  const { id_tables, id_users, total, status, payment } = req.body;

  const query = 'UPDATE orders SET id_tables = ?, id_users = ?, total = ?, status = ?, payment = ? WHERE id_orders = ?';
  db.query(query, [id_tables, id_users, total, status, payment, id], (err, result) => {
    if (err) {
      console.error('Error updating order:', err);
      return res.status(500).json({ message: 'Failed to update order' });
    }
    res.status(200).json({ message: 'Order updated successfully' });
  });
});

app.delete('/orders/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM orders WHERE id_orders = ?';
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Error deleting order:', err);
      return res.status(500).send('Server error');
    }
    res.status(200).json({ message: 'Order deleted successfully' });
  });
});
// ---------- End Order ----------

// ---------- Order Detail ----------
app.post('/orderdetails', (req, res) => {
  const { id_orders, id_menus, quantity, note, subtotal } = req.body;
  const query = `INSERT INTO order_details (id_orders, id_menus, quantity, note, subtotal) VALUES (?, ?, ?, ?, ?)`;
  db.query(query, [id_orders, id_menus, quantity, note, subtotal], (err, result) => {
    if (err) {
      console.error('Error inserting order detail:', err);
      return res.status(500).json({ message: 'Failed to create order detail' });
    }
    const newOrderDetail = { id_order_details: result.insertId, id_orders, id_menus, quantity, note, subtotal };
    res.status(201).json(newOrderDetail);
  });
});

app.get('/orders/:orderId/details', (req, res) => {
  const orderId = req.params.orderId;
  const query = 'SELECT * FROM order_details WHERE id_orders = ?';
  db.query(query, [orderId], (err, results) => {
    if (err) {
      console.error('Error fetching order details:', err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});

app.put('/orderdetails/:id', (req, res) => {
  const id = req.params.id;
  const { id_orders, id_menus, quantity, note, subtotal } = req.body;
  const query = `UPDATE order_details SET id_orders = ?, id_menus = ?, quantity = ?, note = ?, subtotal = ? WHERE id_order_details = ?`;
  db.query(query, [id_orders, id_menus, quantity, note, subtotal, id], (err, result) => {
    if (err) {
      console.error('Error updating order detail:', err);
      return res.status(500).json({ message: 'Failed to update order detail' });
    }
    res.status(200).send('Order detail updated successfully');
  });
});

app.delete('/orderdetails/:id', (req, res) => {
  const id = req.params.id;
  const query = `DELETE FROM order_details WHERE id_order_details = ?`;
  db.query(query, [id], (err, result) => {
    if (err) {
      console.error('Error deleting order detail:', err);
      return res.status(500).json({ message: 'Failed to delete order detail' });
    }
    res.status(200).send('Order detail deleted successfully');
  });
});
// ---------- End Order Detail ----------

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});