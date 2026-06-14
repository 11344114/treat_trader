-- insert_default_reviews.sql
-- 在 treat_trader 資料庫中建立系統用戶與系統訂單（若不存在），
-- 然後對每個 products.productId 插入一筆「官方預設評論」，若該系統用戶已對該商品評論則跳過。

USE treat_trader;

-- 1) 建系統使用者（若已存在相同 email 則不重複）
INSERT INTO users (userName, email, password, phone, address)
SELECT 'system_user','system@example.com','', '0000000000','system'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='system@example.com');

SET @sys_user_id = (SELECT userId FROM users WHERE email='system@example.com' LIMIT 1);

-- 2) 建系統訂單（供 reviews.review_orderId 使用）
INSERT INTO orders (userId, userName, userEmail, totalAmount, paymentMethod, shippingMethod, status)
SELECT @sys_user_id, 'system_user', 'system@example.com', 0, 'none', 'none', 'completed'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE userId=@sys_user_id AND status='completed' LIMIT 1);

SET @sys_order_id = (SELECT orderId FROM orders WHERE userId=@sys_user_id LIMIT 1);

-- 3) 為每個產品插入一筆預設評論（rating 與 content 可自行調整），若該系統帳號已對該商品有評論則跳過
INSERT INTO reviews (review_productId, review_userId, rating, content, review_orderId, reviewedAt)
SELECT p.productId, @sys_user_id, 4, '官方預設評論：值得一試', @sys_order_id, NOW()
FROM products p
WHERE NOT EXISTS (
  SELECT 1 FROM reviews r
  WHERE r.review_productId = p.productId
    AND r.review_userId = @sys_user_id
);

-- 說明：
-- * 若要修改預設評分或評論內容，編輯上方 INSERT 中的 rating 與 content 欄位。
-- * 若要僅對特定 productId 插入，將 FROM products p 改為
--   SELECT * FROM products p WHERE p.productId IN (1,2,3)（以逗號分隔的 productId 列表）。
