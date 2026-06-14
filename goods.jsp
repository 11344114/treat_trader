<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<%
    // 1. 抓取網址列傳過來的商品編號 (例如：goods.jsp?id=1)
    String productId = request.getParameter("id");
    
    // 2. 預設商品資訊 (如果找不到商品時顯示)
    String pName = "找不到該商品";
    String pImg = "";
    int pPrice = 0;
    String pDesc = "暫無商品說明";
    String pNut = "暫無營養標示";

    // 3. 如果資料庫有連線，且網址有傳遞 id 過來，就去撈資料
    if (conn != null && productId != null) {
        try {
            // 使用 PreparedStatement 避免 SQL 注入攻擊 (假設你的主鍵欄位叫做 id)
            String sql = "SELECT * FROM products WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, productId); // 把網址的 id 塞進問號裡
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                pName = rs.getString("productName");
                pPrice = rs.getInt("price");
                pImg = rs.getString("img");
                
                // 💡 注意：如果你的資料庫 products 表格「還沒有」description 和 nutrition 這兩個欄位，
                // 請先把下面這兩行「刪除或加上 // 註解」，以免網頁報錯！等以後加上欄位再打開。
                // pDesc = rs.getString("description");
                // pNut = rs.getString("nutrition");
            }
            rs.close();
            pstmt.close();
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

    <script src="assets/js/goods.js"></script>

</body>
</html>