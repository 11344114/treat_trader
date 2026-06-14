<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>常見問題 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* 常見問題專用樣式 */
        .accordion-item {
            border-bottom: 1px solid #FFD2A6;
            margin-bottom: 15px;
            border-radius: 5px;
            overflow: hidden;
        }
        .accordion-header {
            padding: 15px;
            background: #FFD2A6;
            color: #5C4033;
            cursor: pointer;
            font-weight: bold;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background 0.3s;
        }
        .accordion-header:hover {
            background: #ffcba4;
        }
        .accordion-content {
            padding: 20px;
            display: none;
            background: #FFF8E7;
            color: #333;
            line-height: 1.6;
            border-left: 3px solid #FFD2A6;
        }
        .accordion-content.active {
            display: block;
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 疑難雜症看這裡，快速解決您的問題 ✨</div>
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
    
    <div class="container" style="max-width: 800px;">
        <h2 style="text-align: center; margin-bottom: 30px;">常見問題 (FAQ)</h2>
        
        <div class="card">
            <div class="accordion-item">
                <div class="accordion-header" onclick="toggleAcc(this)">Q1: 如何購買各國零食？ <span style="float:right;">+</span></div>
                <div class="accordion-content">A: 請至「商品總覽」挑選您喜歡的商品，加入購物車後進行結帳即可。我們提供世界各地的精選零食。</div>
            </div>
            <div class="accordion-item">
                <div class="accordion-header" onclick="toggleAcc(this)">Q2: 運費如何計算？ <span style="float:right;">+</span></div>
                <div class="accordion-content">A: 全館單筆訂單滿 $2500 免運費，未滿則收取 $60 運費。</div>
            </div>
            <div class="accordion-item">
                <div class="accordion-header" onclick="toggleAcc(this)">Q3: 多久會收到商品？ <span style="float:right;">+</span></div>
                <div class="accordion-content">A: 國內運送約 3-5 個工作天，部分需海外代購商品可能需 7-14 天，我們會盡快讓您品嚐到異國美味。</div>
            </div>
            <div class="accordion-item">
                <div class="accordion-header" onclick="toggleAcc(this)">Q4: 提供哪些付款方式？ <span style="float:right;">+</span></div>
                <div class="accordion-content">A: 我們支援信用卡、ATM 轉帳以及電子支付。</div>
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

    <script src="assets/js/question.js"></script>
</body>
</html>