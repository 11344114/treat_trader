<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登入 / 註冊 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .login-container {
            height: 100%;
        }
        
        /* 彈窗樣式 */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 2000;
        }

        .modal-box {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 400px;
            text-align: center;
        }
        
        @media (max-width: 768px) {
            .container {
                grid-template-columns: 1fr !important;
            }
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 歡慶開幕：下單滿額立即免運，配送到家超便利 📦</div>
    
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

    <div class="container" style="display: grid; grid-template-columns: 1fr 1fr; gap: 40px;">
        <div class="card login-container">
            <h2>會員登入</h2>
            <form style="margin-top: 20px;" onsubmit="handleLogin(event)">
                <input type="email" id="loginEmail" placeholder="帳號 (Email)" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="password" id="loginPwd" placeholder="密碼" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <div style="text-align:right; margin-bottom:15px;">
                    <a href="#" onclick="showForgetModal()" style="color:#FF7F50; font-size:0.9rem;">忘記密碼？</a>
                </div>
                <button class="btn" style="width:100%; font-size:1.1rem;">登入</button>
            </form>
        </div>

        <div class="card login-container">
            <h2>新會員註冊</h2>
            <form style="margin-top: 20px;" onsubmit="handleRegister(event)">
                <input type="text" id="regName" placeholder="姓名" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="tel" id="regPhone" placeholder="電話號碼" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="email" id="regEmail" placeholder="Email" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="password" id="regPwd" placeholder="密碼" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <button class="btn" style="width:100%; background:#5C4033; font-size:1.1rem;">註冊</button>
            </form>
        </div>
    </div>

    <div id="forgetModal" class="modal-overlay">
        <div class="modal-box">
            <h3>找回密碼</h3>
            <p style="margin:10px 0;">請輸入您的 Email 與電話。</p>
            <input type="email" id="forgetEmail" placeholder="Email" style="width:100%; padding:10px; margin-bottom:10px; border:1px solid #ddd; border-radius:5px;">
            <input type="tel" id="forgetPhone" placeholder="電話號碼" style="width:100%; padding:10px; margin-bottom:20px; border:1px solid #ddd; border-radius:5px;">
            <button class="btn" onclick="confirmForget()">確認</button>
            <button class="btn" style="background:#aaa; margin-left:10px;" onclick="closeForgetModal()">取消</button>
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

    <script src="assets/js/login.js"></script>

</body>
</html>