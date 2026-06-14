<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>會員中心 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .member-layout { display: grid; grid-template-columns: 280px 1fr; gap: 30px; }
        .member-section-title { font-size: 1.5rem; font-weight: bold; color: #5C4033; margin-bottom: 15px; border-bottom: 2px solid #FFECB3; padding-bottom: 10px; }
        .progress-container { background: #FFE4B5; border-radius: 10px; height: 12px; width: 100%; margin: 10px 0; overflow: hidden; }
        .progress-bar { height: 100%; background: #FF7F50; width: 0%; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #FFECB3; padding: 10px; text-align: left; }
        th { background: #FFECB3; }
        @media (max-width: 768px) { .member-layout { grid-template-columns: 1fr; } }

        /* 評論卡片樣式，跟商品頁一致 */
        .review-card {
            background: #FFF7E8;
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
        .review-rating { margin-bottom: 6px; }
        .review-star {
            font-size: 1.1rem;
            margin-right: 2px;
        }
        .review-star.filled { color: #FFC107; } /* 黃星星 */
        .review-star.empty  { color: #DDD; }    /* 灰星星 */
        .review-content {
            font-size: 0.95rem;
            color: #444;
            line-height: 1.5;
            white-space: pre-line;
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 歡迎！查看您的訂單進度與消費紀錄 ✨</div>
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
        <div class="member-layout">
            <div class="card" style="height: fit-content;" id="profileCard">
                <div style="text-align:center; margin-bottom:20px;">
                    <div style="width:80px; height:80px; background:#FFD2A6; border-radius:50%; margin: 0 auto 10px;"></div>
                    <h3 id="mName">訪客</h3>
                </div>
                <div style="padding: 10px 0; border-top: 1px solid #eee;">
                    <p style="margin-bottom: 10px;"><strong>Email:</strong><br><span id="mEmail">請先登入</span></p>
                    <p><strong>電話:</strong><br><span id="mPhone">-</span></p>
                </div>
                <button onclick="logout()" style="width:100%; color:white; background:#d9534f; padding:10px; border-radius:5px; margin-top:20px; border:none; cursor:pointer;">登出</button>
            </div>

            <div class="member-fonts" style="display: flex; flex-direction: column; gap: 20px;">

                <div class="card" id="orderProgressCard" style="display: none;">
                    <h2 class="member-section-title">訂單進度</h2>
                    <div id="orderProgressContent"></div>
                </div>

                <div class="card">
                    <h2 class="member-section-title">歷史消費紀錄</h2>
                    <table>
                        <tr><th>商品</th><th>日期</th><th>金額</th><th>狀態</th></tr>
                        <tr><td>法國巴黎馬卡龍</td><td>2025-12-01</td><td>NT$450</td><td>已完成</td></tr>
                        <tr><td>日本靜岡抹茶蛋糕</td><td>2025-11-20</td><td>NT$350</td><td>已完成</td></tr>
                    </table>
                </div>

                <div class="card">
                    <h2 class="member-section-title">評論與評分紀錄</h2>
                    <div id="myReviews"><p>尚無評論紀錄。</p></div>
                </div>
            </div>
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

    <script src="assets/js/member.js"></script>
</body>
</html>