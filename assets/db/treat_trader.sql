-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: treat_trader
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `categoryId` int NOT NULL,
  `categoryName` varchar(45) NOT NULL,
  PRIMARY KEY (`categoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'日本'),(2,'法國'),(3,'德國'),(4,'比利時'),(5,'義大利'),(6,'美國'),(7,'英國'),(8,'韓國'),(9,'台灣');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `help_center`
--

DROP TABLE IF EXISTS `help_center`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `help_center` (
  `ticketId` int NOT NULL AUTO_INCREMENT,
  `help_center_userId` int NOT NULL,
  `email` varchar(255) NOT NULL,
  `question` text NOT NULL,
  `reply` text,
  `status` varchar(20) NOT NULL DEFAULT '待處理',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ticketId`),
  KEY `userId_idx` (`help_center_userId`),
  CONSTRAINT `help_center_userId` FOREIGN KEY (`help_center_userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `help_center`
--

LOCK TABLES `help_center` WRITE;
/*!40000 ALTER TABLE `help_center` DISABLE KEYS */;
/*!40000 ALTER TABLE `help_center` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_details`
--

DROP TABLE IF EXISTS `order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_details` (
  `details_orderId` int NOT NULL,
  `details_productId` int NOT NULL,
  `orderAmount` int NOT NULL,
  `price` int NOT NULL,
  PRIMARY KEY (`details_orderId`,`details_productId`),
  KEY `details_productId_idx` (`details_productId`),
  CONSTRAINT `details_orderId` FOREIGN KEY (`details_orderId`) REFERENCES `orders` (`orderId`),
  CONSTRAINT `details_productId` FOREIGN KEY (`details_productId`) REFERENCES `products` (`productId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_details`
--

LOCK TABLES `order_details` WRITE;
/*!40000 ALTER TABLE `order_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `orderId` int NOT NULL AUTO_INCREMENT,
  `orders_userId` int NOT NULL,
  `total` int NOT NULL,
  `payment` varchar(20) NOT NULL,
  `shippingMethod` varchar(20) NOT NULL,
  `invoiceMethod` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `orderDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`orderId`),
  KEY `oders_userId_idx` (`orders_userId`),
  CONSTRAINT `oders_userId` FOREIGN KEY (`orders_userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `productId` int NOT NULL AUTO_INCREMENT,
  `productName` varchar(50) NOT NULL,
  `price` int NOT NULL,
  `products_categoryId` int NOT NULL,
  `inventory` int NOT NULL DEFAULT '0',
  `description` text,
  `nutrition` text,
  `img` varchar(255) NOT NULL,
  PRIMARY KEY (`productId`),
  KEY `categoryId_idx` (`products_categoryId`),
  CONSTRAINT `products_categoryId` FOREIGN KEY (`products_categoryId`) REFERENCES `category` (`categoryId`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'本靜岡抹茶蛋糕',350,1,1000,'來自日本靜岡的濃郁抹茶香蛋糕，口感綿密，因為特殊的抹茶口味讓人只想一口接著一口，完全停不下來，如果你也想不出國就品嘗到來自日本的抹茶蛋糕一定要加入購物車。','熱量: 350大卡 | 蛋白質: 5g','Matcha.jpg'),(2,'美國重磅巧克力餅乾',150,6,1000,'美式經典代表作。每一塊餅乾皆採用厚實份量製作，外層烘烤至金黃酥脆，輕咬瞬間能感受到細緻的酥香口感，隨即轉為內部柔軟濕潤的餅乾體，層次分明。嚴選高品質巧克力豆，經高溫烘焙後在餅乾內部完美融化，入口即爆漿，濃郁巧克力如瀑布般在口中流淌，甜而不膩、香氣十足。','熱量: 450大卡 | 糖: 30g','Cookie.jpg'),(3,'法國巴黎馬卡龍',450,2,1000,'源自法式甜點工藝的經典之作。外殼以蛋白霜精準打發並低溫烘焙，呈現細緻光滑的表面與輕盈酥脆的口感，入口瞬間微裂，隨即化開。內層夾餡柔滑細膩，濕潤不黏膩，與外殼形成完美對比，層次豐富且平衡。色彩繽紛、外型精緻，是視覺與味覺兼具的代表甜點。適合作為下午茶點心、節慶禮盒或送禮首選，也非常適合搭配咖啡、花茶或香檳享用，提升整體品味體驗。法國巴黎馬卡龍，不只是甜點，更是一種細膩、優雅且值得細細品嚐的生活風格。','熱量: 200大卡 | 糖: 40g','Macaron.jpg'),(4,'英國皇家伯爵茶餅',280,7,1000,'選用高品質伯爵茶葉，融合清新佛手柑天然香氣，茶香溫潤而優雅，入口即散發出細緻而持久的芳香，展現英倫甜點一貫的低調奢華。餅體口感細緻紮實，外層輕酥不乾，內部濕潤柔軟，茶香與奶香相互交融，層次平衡、不甜膩。每一口都能感受到伯爵茶特有的清爽回甘，讓甜味不再厚重，反而更顯成熟與耐吃。無論是搭配熱紅茶、牛奶、咖啡，或作為午後時光的精緻點心，都能完美襯托風味。適合偏好茶香系甜點、追求質感與優雅風味的消費者，也是送禮與下午茶組合中的理想選擇。','熱量: 150大卡 | 脂肪: 10g','TeaBiscuit.jpg'),(5,'韓國起司夾心餅',120,8,1000,'靈感來自韓國人氣甜點風格，將濃郁起司風味與細緻餅乾完美結合。外層餅乾酥香輕脆，入口後散發淡淡奶香，內層夾入滑順濃厚的起司內餡，鹹甜交織，風味層次分明且不膩口。嚴選高品質起司製作，口感柔滑綿密，帶有自然乳香與微微鹹度，恰到好處地平衡餅乾的甜味。輕咬一口即可感受到起司餡在口中慢慢化開，香氣濃而不厚，耐吃度極高。','熱量: 300大卡 | 鈉: 200mg','Cheese.jpg'),(6,'日本白色戀人',480,1,1000,'是日本伴手禮文化中最具代表性的存在之一。嚴選高品質小麥粉與奶香原料，將餅乾烘焙至薄脆輕盈，入口即化，口感細緻而不乾硬。中間夾入柔滑濃郁的白巧克力內餡，甜度溫和、奶香純淨，與酥脆餅乾形成完美對比。白巧克力在口中慢慢融化，散發出淡雅而持久的香氣，帶來柔和細膩的甜味層次，令人回味無窮。整體風味清爽不膩，適合各年齡層享用。無論搭配熱茶、咖啡，或作為午後點心與節慶禮盒，都能展現日式甜點一貫的細膩與用心。','熱量: 250大卡 | 糖: 15g','WhiteLover.jpg'),(7,'紐約起司蛋糕',320,6,1000,'重乳酪風味，濃郁化口，甜而不膩最適合配著一杯熱紅茶食用。','熱量: 400大卡 | 脂肪: 25g','CheeseCake.jpg\"'),(8,'法國檸檬塔',160,2,1000,'酸甜清爽，法式甜點代表，在心情不好時吃上一小塊就會讓人忘卻煩惱。','熱量: 220大卡 | 糖: 18g','LemonTart.jpg'),(9,'德國黑森林蛋糕',500,3,1000,'酒漬櫻桃與巧克力的完美結合，覆蓋黑色陰影的黑森林，看似可怕但卻有甜美的內心。','熱量: 450大卡 | 酒精: 微量','Cake.jpg'),(10,'義大利提拉米蘇',380,5,1000,'帶我走，享受微醺的咖啡香，經典就是經得起時間的考驗。','熱量: 380大卡 | 咖啡因: 有','Tiramisu.jpg'),(11,'比利時巧克力',250,4,1000,'頂級可可，絲滑柔順。','熱量: 550大卡 | 可可脂: 高','Choco.jpg'),(12,'台灣鳳梨酥',200,9,1000,'在地土鳳梨，酸甜適中。','熱量: 180大卡 | 纖維: 2g','Pineapple.jpg');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `reviewId` int NOT NULL AUTO_INCREMENT,
  `review_productId` int NOT NULL,
  `review_userId` int NOT NULL,
  `rating` tinyint NOT NULL,
  `content` text NOT NULL,
  `reviewedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `review_orderId` int NOT NULL,
  PRIMARY KEY (`reviewId`),
  KEY `productId_idx` (`review_productId`),
  KEY `userId_idx` (`review_userId`),
  KEY `review_orderId_idx` (`review_orderId`),
  CONSTRAINT `review_orderId` FOREIGN KEY (`review_orderId`) REFERENCES `orders` (`orderId`),
  CONSTRAINT `review_productId` FOREIGN KEY (`review_productId`) REFERENCES `products` (`productId`),
  CONSTRAINT `review_userId` FOREIGN KEY (`review_userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `userName` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `address` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `phone_UNIQUE` (`phone`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-15  4:23:15
