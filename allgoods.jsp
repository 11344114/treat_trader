<%
    // 強制設定請求端編碼，防範編碼漏洞與中文亂碼
    request.setCharacterEncoding("UTF-8");

    // 接收搜尋關鍵字與類別編號
    String keyword = request.getParameter("keyword");
    String categoryIdStr = request.getParameter("categoryId");

    if (keyword == null) {
        keyword = "";
    }

    int targetCategoryId = 0; // 0 代表不篩選類別（查詢全部）
    if (categoryIdStr != null && !categoryIdStr.equals("")) {
        try {
            // 如果輸入的不是純數字，這裡會直接噴出 NumberFormatException，達到第一線防禦
            targetCategoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            // 發現惡意注入字串，直接強制重定向回安全頁面
            response.sendRedirect("allgoods.jsp");
            return;
        }
    }
%>

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
                String prodListJson = "[]";
                if (conn != null) {
                    PreparedStatement pstmt = null; 
                    ResultSet rs = null;

                    try {
                        // 1. 建立安全的預編譯基礎 SQL 語句
                        String sql = "SELECT productId, productName, price, img FROM products WHERE productName LIKE ?";
                        
                        // 💡 由於你前端下拉選單傳的是字串 (例如 "belgium", "japan")，我們在這裡做個安全的轉換對接
                        int categoryDbId = 0;
                        if (categoryIdStr != null) {
                            if (categoryIdStr.equals("japan")) categoryDbId = 1;
                            else if (categoryIdStr.equals("france")) categoryDbId = 2;
                            else if (categoryIdStr.equals("germany")) categoryDbId = 3;
                            else if (categoryIdStr.equals("belgium")) categoryDbId = 4;
                            else if (categoryIdStr.equals("italy")) categoryDbId = 5;
                            else if (categoryIdStr.equals("usa")) categoryDbId = 6;
                            else if (categoryIdStr.equals("uk")) categoryDbId = 7;
                            else if (categoryIdStr.equals("korea")) categoryDbId = 8;
                            else if (categoryIdStr.equals("taiwan")) categoryDbId = 9;
                        }

                        // 2. 如果選了特定國家，動態安全串接類別預編譯條件
                        if (categoryDbId > 0) {
                            sql += " AND products_categoryId = ?";
                        }

                        pstmt = conn.prepareStatement(sql);

                        // 3. 安全綁定第一個問號（關鍵字模糊搜尋，自動跳脫任何惡意隱碼字元）
                        pstmt.setString(1, "%" + keyword + "%");

                        // 4. 如果有選國家，安全綁定第二個問號（轉換後的純整數 ID）
                        if (categoryDbId > 0) {
                            pstmt.setInt(2, categoryDbId);
                        }

                        // 5. 執行安全查詢
                        rs = pstmt.executeQuery();

                        StringBuilder sb = new StringBuilder();
                        sb.append("[");
                        boolean first = true;
                        boolean hasProducts = false;

                        while(rs.next()) {
                            hasProducts = true;
                            int pid = rs.getInt("productId");
                            String img = rs.getString("img");
                            String name = rs.getString("productName");
                            int price = rs.getInt("price");
            %>
                            <div class="product-card" onclick="location.href='goods.jsp?id=<%= pid %>'">
                                <img class="img-placeholder" src="assets/images/<%= img %>" alt="<%= name %>">
                                <h3><%= name %></h3>
                                <div class="rating-stars">
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star active"></i>
                                    <i class="fa-solid fa-star"></i>
                                </div>
                                <p style="color: #e74c3c; font-weight: bold; font-size: 1.1em;">$ <%= price %></p>
                            </div>
            <%
                            if (!first) sb.append(','); first = false;
                            String nm = name==null?"":name.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                            String im = img==null?"":img.replace("\\", "\\\\").replace("\"", "\\\"");
                            sb.append('{')
                              .append("\"id\":").append(pid).append(',')
                              .append("\"name\":\"").append(nm).append("\",")
                              .append("\"price\":").append(price).append(',')
                              .append("\"img\":\"").append(im).append("\"")
                              .append('}');

                        } // 迴圈結束
                        sb.append("]");
                        prodListJson = sb.toString();

                        // 6. 畫出防呆：如果搜尋或類別點下去都查無資料，直接給出找不到商品的提示
                        if (!hasProducts) {
            %>
                            <div style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                                <img src="assets/images/cookie_cookie.png" alt="無商品" style="width:100px; margin-bottom:15px; opacity:0.7;">
                                <h3 style="color:#5C4033; margin-bottom:8px;">喔喔！找不到相關商品</h3>
                                <p style="color:#888; font-size:0.95rem;"> 試試看其他關鍵字，或是更改篩選的國家類別。</p>
                                <button onclick="location.href='allgoods.jsp'" style="margin-top:15px; padding:10px 20px; background:#FF7F50; color:white; border:none; border-radius:25px; cursor:pointer; font-weight:bold;">查看所有商品</button>
                            </div>
            <%
                        }

                    } catch (Exception e) {
                        out.println("<p style='color:red;'>商品載入失敗：" + e.getMessage() + "</p>");
                    } finally {
                        if(rs != null) rs.close();
                        if(pstmt != null) pstmt.close();
                    }
                } else {
                    out.println("<p style='color:red;'>資料庫連線失敗，請檢查 db.jsp！</p>");
                }
            %>
        </div>
        <script>var serverProducts = <%= prodListJson %>;</script>

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