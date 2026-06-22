<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<%
        // 如果已經有登入（session 裡有 memberEmail），直接導向會員頁面
    if (session.getAttribute("memberEmail") != null) {
        response.sendRedirect("member.jsp");
        return;
    }


    String message = ""; 

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action"); 
        
        if (conn != null && action != null) {
            try {
                // ==================== 1. 會員登入邏輯 ====================
                if ("login".equals(action)) {
                    String loginEmail = request.getParameter("loginEmail");
                    String loginPwd = request.getParameter("loginPwd");
                    
                    String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
                    PreparedStatement pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, loginEmail);
                    pstmt.setString(2, loginPwd);
                    ResultSet rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        session.setAttribute("memberEmail", rs.getString("email"));
                        session.setAttribute("memberName", rs.getString("userName"));
                        session.setAttribute("memberPhone", rs.getString("phone"));
                        
                        // 🟢 橋樑：讓 Java 印出一段 Script，同時滿足前端 JS 的要求並跳轉
                        out.println("<script>");
                        out.println("localStorage.setItem('isLoggedIn', 'true');");
                        out.println("localStorage.setItem('userName', '" + rs.getString("userName") + "');");
                        out.println("window.location.href='member.jsp';");
                        out.println("</script>");
                        return;
                    }else {
                        message = "<script>alert('帳號或密碼錯誤！');</script>";
                    }
                    rs.close();
                    pstmt.close();
                } 
                
                // ==================== 2. 新會員註冊邏輯 ====================
                else if ("register".equals(action)) {
                    String regName = request.getParameter("regName");
                    String regPhone = request.getParameter("regPhone");
                    String regEmail = request.getParameter("regEmail");
                    String regPwd = request.getParameter("regPwd");
                    
                    // 檢查 Email 是否已經被註冊過
                    String checkSql = "SELECT email FROM users WHERE email = ?";
                    PreparedStatement checkPstmt = conn.prepareStatement(checkSql);
                    checkPstmt.setString(1, regEmail);
                    ResultSet checkRs = checkPstmt.executeQuery();
                    
                    if (checkRs.next()) {
                        message = "<script>alert('該 Email 已經被註冊過了！');</script>";
                    } else {
                        // 🟢 完全對應你的資料表結構，並給予 address 空字串避免報錯
                        String insertSql = "INSERT INTO users (userName, email, password, phone, address) VALUES (?, ?, ?, ?, ?)";
                        PreparedStatement insertPstmt = conn.prepareStatement(insertSql);
                        insertPstmt.setString(1, regName);
                        insertPstmt.setString(2, regEmail);
                        insertPstmt.setString(3, regPwd);
                        insertPstmt.setString(4, regPhone);
                        insertPstmt.setString(5, ""); // 表單沒有地址，所以填入空字串
                        
                        int row = insertPstmt.executeUpdate();
                        if (row > 0) {
                            message = "<script>alert('註冊成功！請直接登入。');</script>";
                        }
                        insertPstmt.close();
                    }
                    checkRs.close();
                    checkPstmt.close();
                }
                // ==================== 3. 管理者登入（開發用，硬編碼驗證） ====================
                else if ("adminLogin".equals(action)) {
                    String adminEmail = request.getParameter("adminEmail");
                    String adminPwd = request.getParameter("adminPwd");
                    if ("admin@treattrader.com".equals(adminEmail) && "admin123".equals(adminPwd)) {
                        session.setAttribute("isAdmin", true);
                        out.println("<script>window.location.href='admin.jsp';</script>");
                        return;
                    } else {
                        message = "<script>alert('管理者帳號或密碼錯誤！');</script>";
                    }
                }
            } catch (Exception e) {
                // 如果電話重複 (UQ) 觸發錯誤，也會在這裡顯示
                message = "<script>alert('系統出錯：" + e.getMessage().replace("'", "\\'") + "');</script>";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登入 / 註冊 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .login-container { height: 100%; }
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: none;
            justify-content: center; align-items: center; z-index: 2000;
        }
        .modal-box {
            background: white; padding: 30px; border-radius: 10px;
            width: 90%; max-width: 400px; text-align: center;
        }
        /* 鎖頭按鈕與 admin panel 樣式 */
        .lock-btn { position: absolute; top: 12px; right: 12px; background: #e74c3c; color: #fff; border: none; border-radius: 6px; padding: 6px 8px; cursor: pointer; box-shadow: 0 8px 18px rgba(0,0,0,0.08); font-size: 14px; }
        .lock-btn i { margin-right: 0; }
        .lock-btn.unlocked { background: #FF7F50; }
        .admin-locked { filter: grayscale(100%) opacity(0.6); pointer-events: none; }
        .admin-panel { transition: filter 0.25s ease, opacity 0.25s ease; }
        @media (max-width: 1200px) {
            .container { grid-template-columns: 1fr 1fr !important; }
        }
        @media (max-width: 768px) {
            .container { grid-template-columns: 1fr !important; }
        }
    </style>
</head>
<body>
    <%= message %>

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

    <div class="container" style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 40px;">
        
        <div class="card login-container">
            <h2>會員登入</h2>
            <form style="margin-top: 20px;" method="POST" action="login.jsp">
                <input type="hidden" name="action" value="login">
                
                <input type="email" id="loginEmail" name="loginEmail" placeholder="帳號 (Email)" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="password" id="loginPwd" name="loginPwd" placeholder="密碼" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                
                <div style="text-align:right; margin-bottom:15px;">
                    <a href="#" onclick="showForgetModal()" style="color:#FF7F50; font-size:0.9rem;">忘記密碼？</a>
                </div>
                <button type="submit" class="btn" style="width:100%; font-size:1.1rem;">登入</button>
            </form>
        </div>

        <div class="card login-container">
            <h2>新會員註冊</h2>
            <form style="margin-top: 20px;" method="POST" action="login.jsp">
                <input type="hidden" name="action" value="register">
                
                <input type="text" id="regName" name="regName" placeholder="姓名" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="tel" id="regPhone" name="regPhone" placeholder="電話號碼" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="email" id="regEmail" name="regEmail" placeholder="Email" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                <input type="password" id="regPwd" name="regPwd" placeholder="密碼" required style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ccc; border-radius:5px;">
                
                <button type="submit" class="btn" style="width:100%; background:#5C4033; font-size:1.1rem;">註冊</button>
            </form>
        </div>

        <div class="card login-container" style="position:relative;">
            <!-- 鎖頭按鈕：初始紅色，按下後變為橘色(解鎖) -->
            <button id="adminLockBtn" class="lock-btn" aria-pressed="false" title="按下以解鎖並填寫管理者登入資訊"><i class="fa-solid fa-lock"></i></button>

            <div id="adminPanel" class="admin-panel admin-locked">
                <h2 style="color: #5C4033;">管理者登入</h2>
                <p style="font-size: 0.9rem; color: #666; margin-bottom: 20px;">Treat Trader 管理系統</p>
                <form style="margin-top: 20px;" action="login.jsp" method="POST">
                    <input type="hidden" name="action" value="adminLogin">

                    <input type="email" id="adminEmail" name="adminEmail" placeholder="管理者帳號 (Email)" required disabled style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ddd; border-radius:5px;">
                    <input type="password" id="adminPwd" name="adminPwd" placeholder="密碼" required disabled style="width:100%; padding:12px; margin-bottom:15px; border:1px solid #ddd; border-radius:5px;">

                    <button type="submit" id="adminSubmit" class="btn" disabled style="width:100%; font-size:1.1rem;">登入管理系統</button>

                    <div style="margin-top: 15px; padding: 10px; background: #FFF8E7; border:1px solid #FFD2A6; border-radius: 5px; font-size: 0.85rem; color: #555;">
                        Email：admin@treattrader.com<br>
                        密碼：admin123
                    </div>
                </form>
            </div>
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
            <a href="https://reurl.cc/xKA8ae" target="_blank"><i class="fa-brands fa-instagram"></i></a>
            <a href="https://reurl.cc/Vmlo9A" target="_blank"><i class="fa-brands fa-threads"></i></a>
            <a href="https://reurl.cc/9ba94j" target="_blank"><i class="fa-brands fa-line"></i></a>
            <a href="mailto:service@example.com"><i class="fa-solid fa-envelope"></i></a>
        </div>
        <div class="footer-links"><a href="help.jsp">幫助中心</a> | <a href="question.jsp">常見問題</a></div>
        <p class="copyright">© COPYRIGHT 807dorm</p>
    </footer>

    <script src="assets/js/login.js?v=3"></script>
    <script>
        (function(){
            try {
                var lockBtn = document.getElementById('adminLockBtn');
                var panel = document.getElementById('adminPanel');
                if (!lockBtn || !panel) return;
                var inputs = panel.querySelectorAll('input:not([type=hidden]), button[type=submit]');

                // 初始狀態：disabled 已在 HTML 設定
                lockBtn.addEventListener('click', function(e){
                    e.preventDefault();
                    var isUnlocked = lockBtn.classList.toggle('unlocked');
                    if (isUnlocked) {
                        panel.classList.remove('admin-locked');
                        lockBtn.innerHTML = '<i class="fa-solid fa-lock-open"></i>';
                        inputs.forEach(function(el){ el.disabled = false; });
                        lockBtn.setAttribute('aria-pressed','true');
                    } else {
                        panel.classList.add('admin-locked');
                        lockBtn.innerHTML = '<i class="fa-solid fa-lock"></i>';
                        inputs.forEach(function(el){ el.disabled = true; });
                        lockBtn.setAttribute('aria-pressed','false');
                    }
                });
            } catch(e){ console.error(e); }
        })();
    </script>
</body>
</html>