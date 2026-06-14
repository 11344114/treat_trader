<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>幫助中心 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* 幫助中心表單樣式 */
        .help-form input, 
        .help-form textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            margin-top: 5px;
            font-family: inherit;
        }
        .help-form textarea {
            resize: vertical;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            font-weight: bold;
            color: #5C4033;
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 我們樂意為您服務，請留下您的寶貴意見 ✨</div>
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
        <div class="card">
            <h2 style="text-align: center; margin-bottom: 20px;">幫助中心</h2>
            <form class="help-form" onsubmit="alert('感謝您的回饋，我們會盡快回覆！'); this.reset(); event.preventDefault();">
                <div class="form-group">
                    <label>姓名</label>
                    <input type="text" required placeholder="請輸入您的姓名">
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" required placeholder="請輸入您的聯絡信箱">
                </div>
                <div class="form-group">
                    <label>問題或建議</label>
                    <textarea required style="height:150px;" placeholder="請描述您遇到的問題或建議..."></textarea>
                </div>
                <button class="btn" style="width:100%;">送出</button>
            </form>
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

    <script src="assets/js/help.js"></script>
</body>
</html>