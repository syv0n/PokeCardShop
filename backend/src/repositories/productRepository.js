const pool = require('../../db');

exports.findActive = async () => {
  const [products] = await pool.query(`
    SELECT * FROM products 
    WHERE is_active = TRUE
  `);
  return products;
};

exports.create = async (productData) => {
  const [result] = await pool.query(
    `INSERT INTO products SET ?`,
    [productData]
  );
  return { id: result.insertId, ...productData };
};