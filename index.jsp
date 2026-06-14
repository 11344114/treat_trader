<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treat Trader - 首頁</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .hero-slider:hover { transform: scale(1.01); }

        @keyframes coolShow {
            from { 
                opacity: 0; 
                transform: translateY(30px) scale(0.9); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0) scale(1); 
            }
        }

        #recommendList .card {
            display: flex;
            flex-direction: column;
            align-items: center;    /* 讓圖片與文字水平居中 */
            justify-content: center;
            text-align: center;     /* 確保多行文字也居中 */
            padding: 20px;
            border: 1px solid #eee; /* 加點邊框讓卡片更立體 */
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        #recommendList .img-placeholder {
            margin-left: auto;
            margin-right: auto;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ Treat Trader 畢業回饋祭：各國零食滿 $2500 免運！ ✨</div>

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
        <div class="hero-slider" id="heroSlider" onclick="clickAd()">
            <div class="slide-content" id="heroText"> Treat Trader：不出國也能吃遍世界！ </div>
        </div>

        <h2>熱門推薦商品</h2>
        <div id="recommendList" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; margin-top: 20px;">
            <%
                // 檢查 db.jsp 有沒有成功建立連線
                if (conn != null) {
                    try {
                        Statement stmt = conn.createStatement();
                        // 下達 SQL 指令去 products 表格撈資料
                        ResultSet rs = stmt.executeQuery("SELECT * FROM products");

                        // 只要資料庫裡還有下一筆商品，就繼續印出 HTML 卡片
                        while(rs.next()) {
            %>
                            <div class="card">
                                <img class="img-placeholder" src="assets/images/<%= rs.getString("img") %>" alt="<%= rs.getString("productName") %>" style="width: 150px; height: 150px; object-fit: cover;">
                                
                                <h3><%= rs.getString("productName") %></h3>
                                
                                <p style="color: #e74c3c; font-weight: bold; font-size: 1.2em;">$ <%= rs.getInt("price") %></p>
                                
                                <button style="padding: 8px 20px; cursor: pointer; background-color: #333; color: white; border: none; border-radius: 4px;">加入購物車</button>
                            </div>
            <%
                        } // 迴圈結束

                        // 養成好習慣：用完把查詢結果關閉
                        rs.close();
                        stmt.close();

                    } catch (Exception e) {
                        out.println("<p style='color:red;'>商品載入失敗：" + e.getMessage() + "</p>");
                    }
                } else {
                    out.println("<p style='color:red;'>無法連線到資料庫，請檢查 db.jsp 設定！</p>");
                }
            %>
        </div>
    </div>

    <div class="scroll-top" onclick="window.scrollTo(0,0)">TOP</div>

    <footer>
        <div class="footer-socials">
            <a href="https://reurl.cc/xKA8ae" target="_blank"><i class="fa-brands fa-instagram"></i></a>
            <a href="https://reurl.cc/Vmlo9A" target="_blank"><i class="fa-brands fa-threads"></i></a>
            <a href="https://reurl.cc/9ba94j" target="_blank"><i class="fa-brands fa-line"></i></a>
            <a href="mailto:service@example.com"><i class="fa-solid fa-envelope"></i></a>
        </div>
        <div class="footer-links"><a href="help.jsp">幫助中心</a> | <a href="question.jsp">常見問題</a></div>
        <p class="copyright">© COPYRIGHT 807dorm</p>
    </footer>
    
    <script src="assets/js/index.js"></script>
</body>
</html>