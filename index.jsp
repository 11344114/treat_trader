<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>

<%
    // ===== 訪客計數器核心邏輯 =====
    int visitCounter = 0;
    synchronized(application) {
        Object currentCount = application.getAttribute("visit_counter");
        if (currentCount == null) {
            visitCounter = 0; // 初始值
        } else {
            visitCounter = (Integer) currentCount;
        }
        if (session.isNew()) {
            visitCounter++;
            application.setAttribute("visit_counter", visitCounter);
        }
    }
%>

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

          /* Marquee style: 無縫水平跑馬燈，滑鼠懸停暫停
              使用全域 .marquee-container（與 allgoods 同色與寬度），文字繼承色彩 */
          /* 讓跑馬燈高度與 allgoods 的 .marquee-container 一致 */
          .marquee { display: flex; width: max-content; white-space: nowrap; align-items: center; min-height: 30px; }
          .marquee .marquee-item { display: inline-block; padding: 0 40px; font-weight: 600; color: inherit; line-height: 1.2; font-size:14px; }

          /* 訪客訊息裝飾：卡片式強調，符合網頁風格 */
          .visitor-banner { display: block; width: fit-content; margin: 0 auto; text-align: center; padding: 8px 14px; font-size: 0.95rem; color: #5C4033; font-weight: 700; background: #ffffff; border-radius: 10px; box-shadow: 0 8px 20px rgba(0,0,0,0.06); }
          .visitor-banner .num { display: inline-block; background: #FF7F50; color: #fff; border-radius: 999px; padding: 4px 10px; margin: 0 8px; font-weight: 900; }

          /* 內部 marquee 容器（不使用全域 .container 的垂直 margin） */
          .marquee-inner { max-width: 1200px; margin: 0 auto; padding: 0 20px; }
        .marquee.animate { animation: marqueeAnim 18s linear infinite; }
        .marquee.reverse.animate { animation-direction: reverse; }
        .marquee.animate:hover { animation-play-state: paused; }
        @keyframes marqueeAnim {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }

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
    
    <!-- 第二個跑馬燈：顯示當前總瀏覽人次，方向相反 -->
    
        <div class="marquee-container" aria-hidden="false" style="margin:0; border-radius:0; padding:4px 0; overflow:hidden;">
            <div class="marquee-inner">
                <div id="marqueeTrack" class="marquee animate" style="margin-bottom:0;">
                    <div class="marquee-item">✨ Treat Trader 畢業回饋祭：各國零食滿 $2500 免運！ ✨</div>
                    <div class="marquee-item">✨ Treat Trader 畢業回饋祭：各國零食滿 $2500 免運！ ✨</div>
                </div>
                <div id="marqueeTrack2" class="marquee reverse animate" style="margin-top:0;">
                    <div class="marquee-item">✨ 當前總瀏覽人次：<strong><%= visitCounter %></strong> 人次 ✨</div>
                    <div class="marquee-item">✨ 當前總瀏覽人次：<strong><%= visitCounter %></strong> 人次 ✨</div>
                </div>
            </div>
        </div>

    <script>
        // 處理所有 marquee track（若內容太短則複製以確保無縫）
        (function(){
            try {
                var tracks = document.querySelectorAll('.marquee');
                tracks.forEach(function(track){
                    if (!track) return;
                    if (track.children.length === 1) {
                        var clone = track.children[0].cloneNode(true);
                        track.appendChild(clone);
                    }
                });
            } catch(e) { console.error(e); }
        })();
    </script>
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
                String prodListJson = "[]";
                if (conn != null) {
                    try {
                        Statement stmt = conn.createStatement();
                        // 下達 SQL 指令去 products 表格撈資料
                        ResultSet rs = stmt.executeQuery("SELECT productId, productName, price, img FROM products LIMIT 8");

                        StringBuilder sb = new StringBuilder();
                        sb.append("[");
                        boolean firstJson = true;

                        // 只要資料庫裡還有下一筆商品，就繼續印出 HTML 卡片
                        while(rs.next()) {
                            int pid = rs.getInt("productId");
                            String img = rs.getString("img");
                            String name = rs.getString("productName");
                            int price = rs.getInt("price");
                            
                            if (!firstJson) sb.append(','); firstJson = false;
                            String nm = name==null?"":name.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                            String im = img==null?"":img.replace("\\", "\\\\").replace("\"", "\\\"");
                            sb.append('{')
                              .append("\"id\":").append(pid).append(',')
                              .append("\"name\":\"").append(nm).append("\",")
                              .append("\"price\":").append(price).append(',')
                              .append("\"img\":\"").append(im).append("\"")
                              .append('}');

            %>
                            <div class="card" onclick="location.href='goods.jsp?id=<%= pid %>'">
                                <div class="img-placeholder">
                                    <img src="assets/images/<%= img %>" alt="<%= name %>" style="width: 150px; height: 150px; object-fit: cover;">
                                </div>
                                <h3><%= name %></h3>
                                <p style="color: #e74c3c; font-weight: bold; font-size: 1.2em;">$ <%= price %></p>
                                <button style="padding: 8px 20px; cursor: pointer; background-color: #333; color: white; border: none; border-radius: 4px;">加入購物車</button>
                            </div>
            <%
                        } // 迴圈結束

                        sb.append("]");
                        prodListJson = sb.toString();

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
        <script>
            // 由伺服器在頁面內提供的推薦商品清單
            var serverProducts = <%= prodListJson %>;
        </script>
    </div>

    <div class="scroll-top" onclick="window.scrollTo(0,0)">TOP</div>

    <!-- 單獨顯示訪客計數（位於 footer 上方） -->
    <div class="visitor-banner">
        歡迎光臨～您是本站第 <span class="num"><%= visitCounter %></span> 位客人！
    </div>

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