<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品總覽 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
            justify-items: center;
            align-items: center;
        }
        .product-card {
            cursor: pointer;
            text-align: center;
            transition: 0.3s;
            padding: 15px;
            border: 1px solid #eee;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            background-color: white;
            width: 100%;
            box-sizing: border-box;
        }
        .product-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.1);
        }
        .img-placeholder {
            height: 150px;
            width: 100%;
            border-radius: 10px;
            margin: 0 auto 10px;
            display: block;
            object-fit: cover;
        }
        .rating-stars {
            color: #ccc;
            font-size: 0.9rem;
            margin-top: 5px;
            margin-bottom: 10px;
        }
        .rating-stars .active {
            color: #e2b007;
        }
        
        .mid-filter { 
            background: white; 
            padding: 20px; 
            border-radius: 15px; 
            box-shadow: 0 4px 10px rgba(0,0,0,0.05); 
            margin-bottom: 30px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            flex-wrap: wrap; 
            gap: 15px; 
        }

        .filter-left { 
            display: flex; 
            flex: 1; 
            min-width: 250px; 
        }

        .filter-left input { 
            flex: 1; 
            padding: 10px; 
            border: 1px solid #ddd; 
            border-radius: 5px 0 0 5px; 
            border-right: none; 
            outline: none; 
        }

        .filter-left button { 
            border-radius: 0 5px 5px 0;
            padding: 10px 20px; 
            background-color: #333;
            color: white;
            border: 1px solid #333;
            cursor: pointer;
        }

        .filter-right { 
            flex: 0.5; 
            min-width: 200px; 
        }

        .filter-right select { 
            width: 100%; 
            padding: 10px; 
            border: 1px solid #ddd; 
            border-radius: 5px; 
            outline: none; 
            cursor: pointer; 
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 新年回饋祭滿 $2500 免運 ✨</div>
    <header>
        <div class="logo" onclick="location.href='index.jsp'">
            <img src="assets/images/Logo.PNG" alt="Logo">
            Treat Trader
        </div>

        <nav class="main-nav">
            <a href="index.jsp">首頁</a>
            <a href="allgoods.jsp">商品總覽</a>
            <a href="member.jsp">會員資料</a>
            <a href="team.jsp">關於我們</a>
        </nav>

        <div class="header-icons">
            <a href="cart.jsp"><i class="fa-solid fa-cart-shopping"></i></a>
            <a href="login.jsp" id="avatarLink"><i class="fa-solid fa-circle-user"></i></a>
        </div>
    </header>

    <div class="container">
        <div class="mid-filter">
            <div class="filter-left">
                <input type="text" id="midSearch" placeholder="商品關鍵字快速搜尋" onkeypress="handleEnterFilter(event)">
                <button class="btn" onclick="filterProducts()">搜尋</button>
            </div>
            <div class="filter-right">
                <select id="midCategory" onchange="filterProducts()">
                    <option value="all">所有類別</option>
                    <option value="japan">日本 (Japan)</option>
                    <option value="france">法國 (France)</option>
                    <option value="germany">德國 (Germany)</option>
                    <option value="belgium">比利時 (Belgium)</option>
                    <option value="italy">義大利 (Italy)</option>
                    <option value="usa">美國 (USA)</option>
                    <option value="uk">英國 (UK)</option>
                    <option value="korea">韓國 (Korea)</option>
                    <option value="taiwan">台灣 (Taiwan)</option>
                </select>
            </div>
        </div>
        
        <h2>全部商品</h2>
        
        <div id="productList" class="product-grid">
            <%
                if (conn != null) {
                    try {
                        Statement stmt = conn.createStatement();
                        // 這裡一樣先撈出 products 表格裡的所有商品
                        ResultSet rs = stmt.executeQuery("SELECT * FROM products");

                        while(rs.next()) {
            %>
                            <div class="product-card">
                                <img class="img-placeholder" src="assets/images/<%= rs.getString("img") %>" alt="<%= rs.getString("productName") %>">
                                
                                <h3><%= rs.getString("productName") %></h3>
                                
                                <div class="rating-stars">
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                </div>
                                
                                <p style="color: #e74c3c; font-weight: bold; font-size: 1.2em;">$ <%= rs.getInt("price") %></p>
                                
                                <button style="width: 100%; padding: 8px 0; margin-top: 10px; cursor: pointer; background-color: #333; color: white; border: none; border-radius: 4px;">加入購物車</button>
                            </div>
            <%
                        } // 迴圈結束
                        rs.close();
                        stmt.close();
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>商品載入失敗：" + e.getMessage() + "</p>");
                    }
                } else {
                    out.println("<p style='color:red;'>資料庫連線失敗，請檢查 db.jsp！</p>");
                }
            %>
        </div>
        </div>

    <div class="scroll-top" onclick="window.scrollTo(0,0)">TOP</div>

    <footer>
        <div class="footer-socials">
            <a href="https://reurl.cc/xKA8ae" target="_blank">
                <i class="fa-brands fa-instagram"></i></a>
            <a href="https://reurl.cc/Vmlo9A" target="_blank">
                <i class="fa-brands fa-threads"></i></a>
            <a href="https://reurl.cc/9ba94j" target="_blank">
                <i class="fa-brands fa-line"></i></a>
            <a href="mailto:service@example.com">
                <i class="fa-solid fa-envelope"></i></a>
        </div>
        <div class="footer-links"><a href="help.jsp">幫助中心</a> | <a href="question.jsp">常見問題</a></div>
        <p class="copyright">© COPYRIGHT 807dorm</p>
    </footer>

    <script src="assets/js/allgoods.js"></script>
</body>
</html>