const express = require('express');
const multer = require('multer');
const mysql = require('mysql2/promise');
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

const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'mobile_app',
};

const db = mysql.createConnection(dbConfig);

db.then(() => {
  console.log('MySQL Connected...');
}).catch(err => {
  console.error('MySQL Connection Error:', err);
});

// ---------- User ----------
// Middleware to verify token
function verifyToken(req, res, next) {
  const bearerHeader = req.headers['authorization'];
  if (typeof bearerHeader !== 'undefined') {
    const bearerToken = bearerHeader.split(' ')[1];
    req.token = bearerToken;
    next();
  } else {
    res.sendStatus(403);
  }
}

// Endpoint to get user details
app.get('/user', verifyToken, (req, res) => {
  jwt.verify(req.token, 'secretkey', (err, authData) => {
    if (err) {
      res.sendStatus(403);
    } else {
      const sql = 'SELECT id_users, name, username, email, role, phone, address FROM users WHERE id_users = ?';
      db.then(connection => {
        connection.query(sql, [authData.id], (err, result) => {
          if (err) {
            console.error('Error fetching user details:', err);
            return res.status(500).send('Server error');
          }
          if (result.length > 0) {
            res.json(result[0]);
          } else {
            res.status(404).send('User not found');
          }
        });
      });
    }
  });
});
// ---------- End User ----------

// ---------- Register ----------
app.post('/register', (req, res) => {
  const { name, username, email, password, role, phone, address } = req.body;

  if (!password) {
    return res.status(400).json({ message: 'Password is required' });
  }

  const hashedPassword = bcrypt.hashSync(password, 10);

  const query = `INSERT INTO users (name, username, email, password, role, phone, address) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  db.then(connection => {
    connection.query(query, [name, username, email, hashedPassword, role, phone, address], (err, result) => {
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
  db.then(connection => {
    connection.query(sql, (err, results) => {
      if (err) {
        console.error('Error fetching tables:', err);
        return res.status(500).send('Server error');
      }
      res.json(results);
    });
  });
});

app.post('/tables', async (req, res) => {
  const { number_of_tables } = req.body;

  try {
    const [rows] = await (await db).query('SELECT MAX(table_number) AS maxTableNumber FROM tables');
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
    await (await db).query(insertTablesQuery, [tables]);

    res.status(201).send('Tables added successfully');
  } catch (err) {
    console.error('Error adding tables:', err);
    res.status(500).send('Server error');
  }
});

app.get('/checkqr/:table_qr', async (req, res) => {
  const qrCode = req.params.qrCode;
  const sql = 'SELECT * FROM table_qr WHERE table_qr = ?';
  (await db).query(sql, [qrCode], (err, result) => {
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

// ---------- Login ----------
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const sql = 'SELECT * FROM users WHERE username = ?';
  db.then(connection => {
    connection.query(sql, [username], (err, result) => {
      if (err) {
        console.error('Error fetching user:', err);
        return res.status(500).send('Server error');
      }
      if (result.length > 0) {
        const user = result[0];
        bcrypt.compare(password, user.password, (err, isMatch) => {
          if (err) {
            console.error('Error comparing passwords:', err);
            return res.status(500).send('Server error');
          }
          if (isMatch) {
            const token = jwt.sign({ id: user.id_users }, 'secretkey', { expiresIn: '1h' });
            res.json({ token, user: { id_users: user.id_users, name: user.name, username: user.username, email: user.email, role: user.role, phone: user.phone, address: user.address } });
          } else {
            res.status(400).send('Invalid credentials');
          }
        });
      } else {
        res.status(400).send('User not found');
      }
    });
  });
});
// ---------- End Login ----------

// ---------- Menu ----------
// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'assets/menus/'); // Ensure this directory exists
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Appends the file extension
  },
});

const upload = multer({ storage: storage });

app.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded.');
  }
  
  const fileUrl = `/assets/menus/${req.file.filename}`;
  res.status(200).send(fileUrl);
});

app.post('/menus', upload.single('file'), async (req, res) => {
  try {
    const { name, price, description, category } = req.body;
    const image = req.file ? req.file.filename : null;

    // Save the menu item to the database
    const [result] = await (await db).execute(
      'INSERT INTO menus (name, price, description, category, image) VALUES (?, ?, ?, ?, ?)',
      [name, price, description, category, image]
    );

    res.status(201).json({
      id: result.insertId,
      name,
      price,
      description,
      category,
      image,
    });
  } catch (error) {
    console.error('Error adding menu:', error);
    res.status(500).send('Server error');
  }
});

app.get('/menus', async (req, res) => {
  try {
    const [rows] = await (await db).execute('SELECT * FROM menus');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching menus:', error);
    res.status(500).send('Server error');
  }
});

app.delete('/menus/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await (await db).execute('DELETE FROM menus WHERE id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).send('Menu item not found');
    }

    res.status(200).send('Menu item deleted');
  } catch (error) {
    console.error('Error deleting menu item:', error);
    res.status(500).send('Server error');
  }
});
// ---------- End Menu ----------

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
