<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ include file="db.jsp" %>
<%
    // 1. 抓取網址列傳過來的商品編號 (例如：goods.jsp?id=1)，並解析成整數
    String productId = request.getParameter("id");
    int pidInt = -1;
    try { if (productId != null) pidInt = Integer.parseInt(productId); } catch(Exception e) { pidInt = -1; }
    
    // 2. 預設商品資訊 (如果找不到商品時顯示)
    String pName = "找不到該商品";
    String pImg = "";
    int pPrice = 0;
    String pDesc = "暫無商品說明";
    String pNut = "暫無營養標示";

    // 3. 如果資料庫有連線，且網址有傳遞 id 過來，就去撈資料
    String prodListJson = "[]"; // 由伺服器產生的產品清單（供前端使用，取代 products.json）
    if (conn != null && pidInt > 0) {
        try {
            // 使用 PreparedStatement 避免 SQL 注入攻擊，主鍵欄位使用 productId
            String sql = "SELECT * FROM products WHERE productId = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, pidInt); // 把網址的 id（已解析為整數）塞進問號裡
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // 確認使用 DB 的 productId
                pidInt = rs.getInt("productId");
                // 取固定欄位
                pName = rs.getString("productName");
                pPrice = rs.getInt("price");
                pImg = rs.getString("img");

                // 安全取可選欄位：檢查欄位是否存在再讀取
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

            // 撈其他商品（推薦商品）並把結果序列化成 JSON 字串，供前端使用
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
    <title><%= pName %> - Treat Trader</title> <link rel="stylesheet" href="assets/css/style.css">
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

        /* ===== 評論卡片美化 ===== */
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
        .review-date {
            font-size: 0.85rem;
            color: #999;
        }
        .review-rating {
            margin-bottom: 6px;
        }
        .review-star {
            font-size: 1.1rem;
            margin-right: 2px;
        }
        .review-star.filled { color: #FFC107; } /* 黃色星星 */
        .review-star.empty { color: #DDD; }     /* 灰色星星 */
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
                
                <div id="pRatingDisplay" style="color: #e2b007; font-size: 1.2rem; margin-bottom: 20px;">暫無評分</div>
                <div style="display:flex; gap:15px; margin-top: 30px;">
                    <button class="btn" style="flex:1; padding: 15px; font-size:1.1rem;" onclick="addToCart(false)">加入購物車</button>
                    <button class="btn" style="flex:1; background:#5C4033; padding: 15px; font-size:1.1rem;" onclick="addToCart(true)">直接購買</button>
                </div>
            </div>
        </div>

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
        // 由伺服器端產生的商品清單，取代 products.json
        var serverProducts = <%= prodListJson %>;
        var serverCurrentProduct = {
            id: <%= pidInt %>,
            name: '<%= pName.replace("\\", "\\\\").replace("'", "\\'") %>',
            price: <%= pPrice %>,
            desc: '<%= pDesc.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") %>',
            nutrition: '<%= pNut.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") %>',
            img: '<%= (pImg!=null)?pImg:"" %>'
        };
        <%
            // 由 server 端查詢該商品的 reviews 並輸出為 JSON，供前端立即渲染
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
         // 從 session 注入登入狀態與使用者資料（若存在）
         var isLoggedIn = <%= (session.getAttribute("memberEmail") != null) ? "true" : "false" %>;
         var serverUser = null;
         <% if (session.getAttribute("memberEmail") != null) {
             Object mid = session.getAttribute("memberId");
             String memEmail = (String) session.getAttribute("memberEmail");
             String memName = (String) session.getAttribute("memberName");
         %>
         serverUser = { id: <%= (mid!=null? mid : -1) %>, email: '<%= memEmail.replace("'","\\'") %>', name: '<%= memName.replace("'","\\'") %>' };
         <% } %>
    </script>

    <script src="assets/js/goods.js"></script>

</body>
</html>