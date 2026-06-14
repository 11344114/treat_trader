<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>
<%
    // 強制設定請求端編碼，防範編碼漏洞
    request.setCharacterEncoding("UTF-8");

    // 💡 核心安全機制：從後端 Session 中撈取真實的會員登入 Email
    String currentUserEmail = (String) session.getAttribute("memberEmail");

    // 1. 抓取網址列傳過來的商品編號 (例如：goods.jsp?id=1)，並解析成整數
    String productId = request.getParameter("id");
    int pidInt = -1;
    try { if (productId != null) pidInt = Integer.parseInt(productId); } catch(Exception e) { pidInt = -1; }
    
    // 💡【核心扣減庫存機制】由前端透過網址參數 action=deduct 觸發
    String action = request.getParameter("action");
    if (conn != null && pidInt > 0 && "deduct".equals(action)) {
        // 第一線攔截：如果沒登入，絕對不允許扣除庫存
        if (currentUserEmail == null || currentUserEmail.isEmpty()) {
            out.println("<script>alert('要先登入會員，才能將美味的零食加入購物車喔！'); location.href='login.jsp';</script>");
            return;
        }

        PreparedStatement updatePstmt = null;
        try {
            // 安全更新：庫存大於 0 才扣減，防範超賣
            String updateSql = "UPDATE products SET inventory = inventory - 1 WHERE productId = ? AND inventory > 0";
            updatePstmt = conn.prepareStatement(updateSql);
            updatePstmt.setInt(1, pidInt);
            int rowsAffected = updatePstmt.executeUpdate();
            updatePstmt.close();
            
            String redirectPage = request.getParameter("redirect");
            if (rowsAffected > 0) {
                // 扣減成功，依據前端指示導向對應頁面
                if ("cart".equals(redirectPage)) {
                    response.sendRedirect("cart.jsp");
                } else {
                    response.sendRedirect("goods.jsp?id=" + pidInt + "&status=success");
                }
                return;
            } else {
                out.println("<script>alert('抱歉，該商品已無庫存，無法購買！'); location.href='goods.jsp?id=" + pidInt + "';</script>");
                return;
            }
        } catch (Exception e) {
            out.println("<script>alert('交易處理異常：" + e.getMessage() + "');</script>");
        }
    }

    // 2. 預設商品資訊 (如果找不到商品時顯示)
    String pName = "找不到該商品";
    String pImg = "";
    int pPrice = 0;
    int pInventory = 0; // 初始化全域庫存變數
    String pDesc = "暫無商品說明";
    String pNut = "暫無營養標示";

    // 3. 如果資料庫有連線，且網址有傳遞 id 過來，就去撈最新即時資料
    String prodListJson = "[]"; 
    if (conn != null && pidInt > 0) {
        try {
            // 使用 PreparedStatement 避免 SQL 注入攻擊
            String sql = "SELECT * FROM products WHERE productId = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, pidInt); 
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                pidInt = rs.getInt("productId");
                pName = rs.getString("productName");
                pPrice = rs.getInt("price");
                pImg = rs.getString("img");
                pInventory = rs.getInt("inventory"); // 🎯 每次載入都是從 MySQL 撈出來的「最即時庫存」
                
                ResultSetMetaData md = rs.getMetaData();
                Set<String> cols = new HashSet<String>();
                for (int i = 1; i <= md.getColumnCount(); i++) {
                    cols.add(md.getColumnLabel(i).toLowerCase());
                }
                if (cols.contains("description")) {
                    String v = rs.getString("description");
                    if (v != null && !v.isEmpty()) pDesc = v;
                }
                if (cols.contains("nutrition")) {
                    String v = rs.getString("nutrition");
                    if (v != null && !v.isEmpty()) pNut = v;
                }
            }
            rs.close();
            pstmt.close();

            // 撈其他商品（推薦商品）
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            PreparedStatement pstmt2 = conn.prepareStatement("SELECT productId, productName, price, img FROM products WHERE productId <> ? LIMIT 8");
            pstmt2.setInt(1, pidInt);
            ResultSet rs2 = pstmt2.executeQuery();
            boolean first = true;
            while (rs2.next()) {
                if (!first) sb.append(',');
                first = false;
                int id = rs2.getInt("productId");
                String nm = rs2.getString("productName");
                int pr = rs2.getInt("price");
                String im = rs2.getString("img");
                if (nm == null) nm = "";
                if (im == null) im = "";
                nm = nm.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                im = im.replace("\\", "\\\\").replace("\"", "\\\"");
                sb.append('{')
                  .append("\"id\":").append(id).append(',')
                  .append("\"name\":\"").append(nm).append("\",")
                  .append("\"price\":").append(pr).append(',')
                  .append("\"img\":\"").append(im).append("\"")
                  .append('}');
            }
            rs2.close();
            pstmt2.close();
            sb.append("]");
            prodListJson = sb.toString();

        } catch (Exception e) {
            out.println("");
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pName %> - Treat Trader</title> 
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .product-main {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            margin-bottom: 30px;
        }
        .tab-btn-group { display: flex; gap: 5px; }
        .tab-btn {
            flex: 1;
            padding: 12px;
            background: #FFECB3;
            border: none;
            cursor: pointer;
            font-weight: bold;
            border-radius: 10px 10px 0 0;
        }
        .tab-btn.active { background: #FFD2A6; color: #5C4033; }
        .tab-content {
            background: white;
            padding: 20px;
            display: none;
            border-radius: 0 0 10px 10px;
            margin-bottom: 20px;
        }
        .tab-content.active { display: block; }

        .review-input-area {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .review-input-area textarea {
            width: 100%;
            height: 80px;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .review-input-area textarea:disabled {
            background: #f5f5f5;
            cursor: not-allowed;
        }
        .star-rating-input {
            display: flex;
            gap: 5px;
            font-size: 1.5rem;
            cursor: pointer;
        }
        .star-rating-input span {
            color: #ccc;
            transition: 0.2s;
        }
        .star-rating-input span.active { color: #e2b007; }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 20px;
        }
        .page-num {
            padding: 5px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            user-select: none;
            background: #fff;
        }
        .page-num.active {
            background-color: #5C4033;
            color: white;
            border-color: #5C4033;
        }
        .page-num:hover:not(.active) { background-color: #f0f0f0; }

        .review-card {
            background: #fff;
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 12px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 4px;
            font-size: 0.95rem;
            color: #5C4033;
            font-weight: 600;
        }
        .review-user { margin-right: 8px; }
        .review-date { font-size: 0.85rem; color: #999; }
        .review-rating { margin-bottom: 6px; }
        .review-star { font-size: 1.1rem; margin-right: 2px; }
        .review-star.filled { color: #FFC107; } 
        .review-star.empty { color: #DDD; }     
        .review-content {
            font-size: 0.95rem;
            color: #444;
            line-height: 1.5;
            white-space: pre-line;
        }

        @media (max-width: 768px) {
            .product-main { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 新年回饋祭最高 ｜ 滿 $2500 免運  ✨</div>
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
        <div class="product-main">
            <div id="pImg" class="card" style="height:400px; background:#eee; padding:0; overflow:hidden; display:flex; align-items:center; justify-content:center;">
                <% if(pImg != null && !pImg.isEmpty()) { %>
                    <img src="assets/images/<%= pImg %>" alt="<%= pName %>" style="width:100%; height:100%; object-fit:cover;">
                <% } else { %>
                    <span style="font-size:1.5rem; color:#888;">無圖片</span>
                <% } %>
            </div>
            
            <div>
                <h1 id="pName"><%= pName %></h1>
                <p id="pPrice" style="font-size: 2rem; color: #FF7F50; margin: 15px 0;">$ <%= pPrice %></p>
                
                <% if (pInventory > 0) { %>
                    <p style="color: #666; font-size: 1rem; margin-bottom: 15px;">剩餘庫存：<strong style="color: #27ae60;"><%= pInventory %></strong> 件</p>
                <% } else { %>
                    <p style="color: #95a5a6; font-size: 1rem; margin-bottom: 15px; font-weight: bold;">⚠️ 狀態：已售鑿（補貨中）</p>
                <% } %>
                
                <div id="pRatingDisplay" style="color: #e2b007; font-size: 1.2rem; margin-bottom: 20px;">暫無評分</div>
                
                <div style="display:flex; gap:15px; margin-top: 30px;">
                    <% if (pInventory > 0) { %>
                        <a href="javascript:void(0)" id="addCartBtn-final" class="btn" style="flex:1; padding:15px; font-size:1.1rem; text-align:center; text-decoration:none;" onclick="customAddToCart()">
                            加入購物車
                        </a>
                        
                        <a href="javascript:void(0)" id="buyNowBtn-final" class="btn" style="flex:1; background:#5C4033; padding:15px; font-size:1.1rem; text-align:center; text-decoration:none;" onclick="customBuyNow()">
                            直接購買
                        </a>
                    <% } else { %>
                        <button class="btn" style="flex:1; padding: 15px; font-size:1.1rem; background:#ccc; cursor:not-allowed;" disabled>無法加入購物車</button>
                        <button class="btn" style="flex:1; padding: 15px; font-size:1.1rem; background:#7f8c8d; cursor:not-allowed;" disabled>商品已售鑿</button>
                    <% } %>
                </div>
            </div>
        </div>

        <script>
            // 💡 雙重防禦機制：直接將後端 JSP 認證成功的 Session Email 傳遞給前端 JS 作為唯一合法登入指標
            var userEmailSession = "<%= (currentUserEmail != null) ? currentUserEmail : "" %>";

            // 檢查參數是否有更新成功的狀態彈窗
            window.onload = function() {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('status') === 'success') {
                    alert('商品已成功加入購物車！');
                }
            };

            function checkLoginBeforeAction() {
                if (!userEmailSession || userEmailSession.trim() === "") {
                    alert('要先登入會員，才能將美味的零食加入購物車喔！');
                    window.location.href = 'login.jsp';
                    return false;
                }
                return true;
            }

            // 💡 執行加入購物車：寫入前端暫存 ➡️ 引導至後端資料庫扣除庫存 ➡️ 留在原地刷新
            function customAddToCart() {
                if (!checkLoginBeforeAction()) return;

                let cart = JSON.parse(localStorage.getItem('tt_cart') || '[]');
                let product = {
                    id: <%= pidInt %>,
                    name: '<%= pName.replace("\\", "\\\\").replace("'", "\\'") %>',
                    price: <%= pPrice %>,
                    qty: 1,
                    img: '<%= pImg %>'
                };
                let existingProduct = cart.find(item => item.id === product.id);
                if(existingProduct) {
                    existingProduct.qty++;
                } else {
                    cart.push(product);
                }
                localStorage.setItem('tt_cart', JSON.stringify(cart));

                // 核心對接：跳轉後端扣減庫存，並指示扣完留在此頁面刷新
                window.location.href = 'goods.jsp?id=<%= pidInt %>&action=deduct&redirect=stay';
            }   

            // 💡 執行直接購買：寫入前端暫存 ➡️ 引導至後端資料庫扣除庫存 ➡️ 進入購物車頁面
            function customBuyNow() {
                if (!checkLoginBeforeAction()) return;

                let cart = JSON.parse(localStorage.getItem('tt_cart') || '[]');
                let product = {
                    id: <%= pidInt %>,
                    name: '<%= pName.replace("\\", "\\\\").replace("'", "\\'") %>',
                    price: <%= pPrice %>,
                    qty: 1,
                    img: '<%= pImg %>'
                };  

                let existingProduct = cart.find(item => item.id === product.id);
                if(existingProduct) {
                    existingProduct.qty++;
                } else {
                    cart.push(product);
                }
                localStorage.setItem('tt_cart', JSON.stringify(cart));

                // 核心對接：跳轉後端扣減庫存，並指示扣完直接前往購物車頁面
                window.location.href = 'goods.jsp?id=<%= pidInt %>&action=deduct&redirect=cart';
            }
        </script>

        <div class="tab-btn-group">
            <button class="tab-btn active" onclick="switchTab(event, 'intro')">商品簡介</button>
            <button class="tab-btn" onclick="switchTab(event, 'nutrition')">營養標示</button>
        </div>
        
        <div id="intro" class="tab-content active">
            <h3>商品特色</h3>
            <p id="pDesc"><%= pDesc %></p>
        </div>
        <div id="nutrition" class="tab-content">
            <h3>營養成分</h3>
            <p id="pNut"><%= pNut %></p>
        </div>

        <div class="card" style="margin-bottom: 40px; background: transparent; padding:0; box-shadow: none;">
            <h3 style="margin-bottom: 15px;">商品評價</h3>
            <div id="commentList"></div>
            <div class="pagination"></div>
            <div class="card review-input-area">
                <h4>撰寫評論</h4>
                <div style="margin: 10px 0;">
                    <div class="star-rating-input" id="starContainer">
                        <span onclick="setRating(1)">★</span><span onclick="setRating(2)">★</span><span onclick="setRating(3)">★</span><span onclick="setRating(4)">★</span><span onclick="setRating(5)">★</span>
                    </div>
                </div>
                <textarea id="userReview" placeholder="寫下您對這個商品的看法..."></textarea>
                <button class="btn" id="submitReviewBtn" onclick="submitReview()">送出評論</button>
            </div>
        </div>

        <h3 style="margin: 40px 0 20px;">推薦商品</h3>
        <div id="recList" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px;"></div>
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

    <script>
        var serverProducts = <%= prodListJson %>;
        var serverCurrentProduct = {
            id: <%= pidInt %>,
            name: '<%= pName.replace("\\", "\\\\").replace("'", "\\'") %>',
            price: <%= pPrice %>,
            inventory: <%= pInventory %>, 
            desc: '<%= pDesc.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") %>',
            nutrition: '<%= pNut.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") %>',
            img: '<%= (pImg!=null)?pImg:"" %>'
        };
        <%
            String reviewsJson = "[]";
            if (conn != null && pidInt > 0) {
                try {
                    String q = "SELECT r.reviewId, r.review_userId, r.rating, r.content, r.reviewedAt, u.userName " +
                               "FROM reviews r LEFT JOIN users u ON r.review_userId = u.userId " +
                               "WHERE r.review_productId = ? ORDER BY r.reviewedAt DESC";
                    java.sql.PreparedStatement prs = conn.prepareStatement(q);
                    prs.setInt(1, pidInt);
                    java.sql.ResultSet rrs = prs.executeQuery();
                    StringBuilder rsb = new StringBuilder();
                    rsb.append("[");
                    boolean rf = true;
                    while (rrs.next()) {
                        if (!rf) rsb.append(','); rf = false;
                        int rid = rrs.getInt("reviewId");
                        int ruid = rrs.getInt("review_userId");
                        int rrating = rrs.getInt("rating");
                        String rcontent = rrs.getString("content"); if (rcontent==null) rcontent = "";
                        java.sql.Timestamp rtime = rrs.getTimestamp("reviewedAt");
                        String rdate = (rtime!=null)? new java.text.SimpleDateFormat("yyyy/MM/dd").format(rtime) : "";
                        String uname = rrs.getString("userName"); if (uname==null) uname = "匿名";
                        String escContent = rcontent.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                        String escName = uname.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                        rsb.append('{')
                           .append("\"reviewId\":").append(rid).append(',')
                           .append("\"userId\":").append(ruid).append(',')
                           .append("\"userName\":\"").append(escName).append("\",")
                           .append("\"rating\":").append(rrating).append(',')
                           .append("\"date\":\"").append(rdate).append("\",")
                           .append("\"content\":\"").append(escContent).append("\"")
                           .append('}');
                    }
                    rsb.append("]");
                    reviewsJson = rsb.toString();
                    rrs.close(); prs.close();
                } catch(Exception e) {
                    reviewsJson = "[]";
                }
            }
        %>
        var serverReviews = <%= reviewsJson %>;
    </script>

    <script src="assets/js/goods.js"></script>

</body>
</html>