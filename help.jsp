<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<%
    // 處理表單送出 (POST)
    boolean helpSubmitted = false;
    String helpError = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            String userIdStr = request.getParameter("help_center_userId");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String question = request.getParameter("question");

            Integer userId = null;
            try { if (userIdStr != null && !userIdStr.trim().isEmpty()) userId = Integer.valueOf(userIdStr); } catch(Exception ex) { userId = null; }

            if (conn == null) throw new Exception("資料庫連線失敗");

            // 檢查 help_center 是否有 name 欄位
            java.sql.DatabaseMetaData dbmd = conn.getMetaData();
            ResultSet colRs = dbmd.getColumns(null, null, "help_center", "name");
            boolean hasName = colRs.next();
            colRs.close();

            java.sql.PreparedStatement ins = null;
            if (hasName) {
                String insertSql = "INSERT INTO help_center (help_center_userId, name, email, question) VALUES (?, ?, ?, ?)";
                ins = conn.prepareStatement(insertSql);
                if (userId != null) ins.setInt(1, userId); else ins.setNull(1, java.sql.Types.INTEGER);
                ins.setString(2, name != null ? name : "");
                ins.setString(3, email != null ? email : "");
                ins.setString(4, question != null ? question : "");
            } else {
                String insertSql = "INSERT INTO help_center (help_center_userId, email, question) VALUES (?, ?, ?)";
                ins = conn.prepareStatement(insertSql);
                if (userId != null) ins.setInt(1, userId); else ins.setNull(1, java.sql.Types.INTEGER);
                ins.setString(2, email != null ? email : "");
                ins.setString(3, question != null ? question : "");
            }

            ins.executeUpdate();
            ins.close();

            helpSubmitted = true;
        } catch (Exception e) {
            helpError = e.getMessage();
        }
    }
%>
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
            <form id="helpForm" class="help-form" method="post" action="help.jsp">
                <input type="hidden" id="help_center_userId" name="help_center_userId" value="">
                <div class="form-group">
                    <label>姓名</label>
                    <input type="text" id="help_name" name="name" required placeholder="請輸入您的姓名">
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" id="help_email" name="email" required placeholder="請輸入您的聯絡信箱">
                </div>
                <div class="form-group">
                    <label>問題或建議</label>
                    <textarea id="help_question" name="question" required style="height:150px;" placeholder="請描述您遇到的問題或建議..."></textarea>
                </div>
                <button class="btn" style="width:100%">送出</button>
            </form>
            <%
                if (helpSubmitted) {
            %>
                <script>alert('感謝您的回饋，我們已收到，會盡快回覆！');</script>
            <%
                } else if (helpError != null) {
            %>
                <div style="color:red; margin-top:10px;">送出失敗：<%= helpError %></div>
            <%
                }
            %>
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