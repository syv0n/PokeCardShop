// backend/src/app.js
const express = require('express');
const cors = require('cors');
//const productRoutes = require('./routes/products');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
//app.use('/api/products', productRoutes);

module.exports = app;