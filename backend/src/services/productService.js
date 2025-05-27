const productRepository = require('../repositories/productRepository');

exports.getAllActive = async () => {
  return await productRepository.findActive();
};

exports.create = async (productData) => {
  return await productRepository.create(productData);
};