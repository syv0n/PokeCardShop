-- Enable strict mode for better data integrity
SET sql_mode = 'STRICT_TRANS_TABLES';

-- 1. Users Table
CREATE TABLE users (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) NOT NULL,
  stripe_customer_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_users_email (email),
  INDEX idx_users_stripe (stripe_customer_id)
) ENGINE=InnoDB;

-- 2. Products Table (with escaped 'condition' column)
CREATE TABLE products (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  type ENUM('single', 'pack_rip') NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url VARCHAR(255),
  `condition` ENUM('NM', 'LP', 'MP', 'HP') DEFAULT 'NM',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_products_type (type),
  INDEX idx_products_active (is_active),
  INDEX idx_products_price (price)
) ENGINE=InnoDB;

-- 3. Orders Table
CREATE TABLE orders (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  stripe_payment_id VARCHAR(255),
  status ENUM('paid', 'shipped', 'refunded', 'processing') DEFAULT 'processing',
  total DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_orders_user (user_id),
  INDEX idx_orders_status (status),
  INDEX idx_orders_created (created_at)
) ENGINE=InnoDB;

-- 4. Order Items Table
CREATE TABLE order_items (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  order_id CHAR(36) NOT NULL,
  product_id CHAR(36) NOT NULL,
  quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  price_at_purchase DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_order_items_order (order_id),
  INDEX idx_order_items_product (product_id)
) ENGINE=InnoDB;

-- 5. Queue Entries Table
CREATE TABLE queue_entries (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  product_id CHAR(36) NOT NULL,
  status ENUM('pending', 'live', 'completed', 'cancelled') DEFAULT 'pending',
  position INT NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  handled_at TIMESTAMP NULL,
  twitch_chat_username VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_queue_status (status),
  INDEX idx_queue_position (position),
  INDEX idx_queue_product (product_id),
  
  -- MySQL-compatible version of conditional uniqueness
  UNIQUE KEY uniq_user_product_pending (user_id, product_id, status)
) ENGINE=InnoDB;

-- 6. Videos Table
CREATE TABLE videos (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  youtube_id VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  product_id CHAR(36) NOT NULL,
  stream_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_videos_product (product_id),
  UNIQUE KEY uniq_youtube_id (youtube_id)
) ENGINE=InnoDB;

-- 7. Twitch Streams Table
CREATE TABLE twitch_streams (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  stream_id VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  is_live BOOLEAN DEFAULT FALSE,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ended_at TIMESTAMP NULL,
  INDEX idx_twitch_live (is_live),
  INDEX idx_twitch_timing (started_at, ended_at),
  UNIQUE KEY uniq_stream_id (stream_id)
) ENGINE=InnoDB;

-- 8. Audit Log (Recommended)
CREATE TABLE audit_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  action ENUM('create', 'update', 'delete') NOT NULL,
  table_name VARCHAR(50) NOT NULL,
  record_id CHAR(36) NOT NULL,
  old_values JSON,
  new_values JSON,
  performed_by CHAR(36),
  performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_audit_table (table_name),
  INDEX idx_audit_record (table_name, record_id),
  INDEX idx_audit_timing (performed_at)
) ENGINE=InnoDB;
