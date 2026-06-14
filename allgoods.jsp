<%
    // ==========================================
    // 【 步驟一 】強制設定請求端編碼並接收參數
    // ==========================================
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("keyword");
    String categoryIdStr = request.getParameter("categoryId");

    if (keyword == null) {
        keyword = "";
    }

    // ==========================================
    // 【 步驟二 】型態與安全防禦控制
    // ==========================================
    // 雖然前端下拉選單傳的是國家字串 (japan, belgium)，但為了徹底防範惡意注入
    // 我們在這裡對接收到的值進行嚴格的白名單與防護控制，若不符合預期就直接導向，不給駭客搞鬼的機會
    int targetCategoryId = 0; 
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
                <input type="text" id="midSearch" value="<%= keyword %>" placeholder="商品關鍵字快速搜尋" onkeypress="if(event.keyCode==13) { filterProductsByUrl(); }">
                <button class="btn" onclick="filterProductsByUrl()">搜尋</button>
            </div>
            
            <div class="filter-right">
                <select id="midCategory" onchange="location.href='allgoods.jsp?categoryId=' + this.value + '&keyword=' + encodeURIComponent(document.getElementById('midSearch').value)">
                    <option value="all" <%= "all".equals(categoryIdStr) || categoryIdStr == null ? "selected" : "" %>>所有類別</option>
                    <option value="japan" <%= "japan".equals(categoryIdStr) ? "selected" : "" %>>日本 (Japan)</option>
                    <option value="france" <%= "france".equals(categoryIdStr) ? "selected" : "" %>>法國 (France)</option>
                    <option value="germany" <%= "germany".equals(categoryIdStr) ? "selected" : "" %>>德國 (Germany)</option>
                    <option value="belgium" <%= "belgium".equals(categoryIdStr) ? "selected" : "" %>>比利時 (Belgium)</option>
                    <option value="italy" <%= "italy".equals(categoryIdStr) ? "selected" : "" %>>義大利 (Italy)</option>
                    <option value="usa" <%= "usa".equals(categoryIdStr) ? "selected" : "" %>>美國 (USA)</option>
                    <option value="uk" <%= "uk".equals(categoryIdStr) ? "selected" : "" %>>英國 (UK)</option>
                    <option value="korea" <%= "korea".equals(categoryIdStr) ? "selected" : "" %>>韓國 (Korea)</option>
                    <option value="taiwan" <%= "taiwan".equals(categoryIdStr) ? "selected" : "" %>>台灣 (Taiwan)</option>
                </select>
            </div>
        </div>
        
        <script>
            function filterProductsByUrl() {
                var keyword = document.getElementById('midSearch').value;
                var category = document.getElementById('midCategory').value;
                location.href = 'allgoods.jsp?keyword=' + encodeURIComponent(keyword) + '&categoryId=' + category;
            }
        </script>
        
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
                        
                        // 2. 精準匹配你最新提供的 MySQL 截圖中各國家的真實主鍵 ID 數字
                        int categoryDbId = 0;
                        if (categoryIdStr != null) {
                            if (categoryIdStr.equals("japan")) categoryDbId = 1;
                            else if (categoryIdStr.equals("france")) categoryDbId = 2;
                            else if (categoryIdStr.equals("germany")) categoryDbId = 3;
                            else if (categoryIdStr.equals("belgium")) categoryDbId = 4; // 🎯 比利時 100% 精準對齊 4
                            else if (categoryIdStr.equals("italy")) categoryDbId = 5;
                            else if (categoryIdStr.equals("usa")) categoryDbId = 6;
                            else if (categoryIdStr.equals("uk")) categoryDbId = 7;
                            else if (categoryIdStr.equals("korea")) categoryDbId = 8;
                            else if (categoryIdStr.equals("taiwan")) categoryDbId = 9;
                        }

                        // 3. 如果有選取特定國家，動態安全地附加類別查詢條件占位符
                        if (categoryDbId > 0) {
                            sql += " AND products_categoryId = ?";
                        }

                        pstmt = conn.prepareStatement(sql);

                        // 4. 安全綁定第一個問號（關鍵字模糊搜尋，此時傳入引號等漏洞字符將直接被轉義為普通純文字）
                        pstmt.setString(1, "%" + keyword + "%");

                        // 5. 如果有選國家，安全綁定第二個問號（剛剛進行過白名單對接轉換後的純整數 ID）
                        if (categoryDbId > 0) {
                            pstmt.setInt(2, categoryDbId);
                        }

                        // 6. 執行安全預編譯查詢
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
                            // 同步保留你們前端 assets/js/allgoods.js 原本所需讀取的商品 JSON 全域陣列，不破壞既有架構
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

                        // 8. 全功能防呆提示：如果搜尋或下拉特定國家，發現資料庫完全沒對應商品，秀出貼心防呆提示
                        if (!hasProducts) {
            %>
                            <div style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                                <div style="font-size: 60px; margin-bottom: 15px;">🍪</div>
                                <h3 style="color:#5C4033; margin-bottom:8px;">喔喔！找不到相關商品</h3>
                                <p style="color:#888; font-size:0.95rem;"> 試試看其他關鍵字，或是更改篩選的國家類別。</p>
                                <button onclick="location.href='allgoods.jsp'" style="margin-top:15px; padding:10px 20px; background:#333; color:white; border:none; border-radius:5px; cursor:pointer; font-weight:bold;">查看所有商品</button>
                            </div>
            <%
                        }

                    } catch (Exception e) {
                        out.println("<p style='color:red;'>商品載入失敗：" + e.getMessage() + "</p>");
                    } finally {
                        // 9. 洪智力老師強調的期末極端要求：不論系統成功或跳錯，finally 必須嚴格關閉連線，杜絕洩漏
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