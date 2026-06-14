<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<%
    // 1. 從後端 Session 抓取剛剛登入時存入的會員資料
    String mName = (String) session.getAttribute("memberName");
    String mEmail = (String) session.getAttribute("memberEmail");
    String mPhone = (String) session.getAttribute("memberPhone");

    // 2. 防護機制：如果抓不到 Email，代表這個人根本沒登入，或者是直接偷打網址進來的
    if (mEmail == null || mEmail.isEmpty()) {
        // 用 Java 強制把他踢回正確的 login.jsp，而不是 html
        out.println("<script>alert('請先登入！'); window.location.href='login.jsp';</script>");
        return; // ⚠️ 非常重要：這行會立刻停止載入下面的網頁內容
    }
%>
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
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #FFECB3; padding: 10px; text-align: left; }
        th { background: #FFECB3; }
        @media (max-width: 768px) { .member-layout { grid-template-columns: 1fr; } }
        .review-card { background: #FFF7E8; border-radius: 12px; padding: 12px 16px; margin-bottom: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
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
                    <h3 id="mName"><%= mName %></h3>
                </div>
                <div style="padding: 10px 0; border-top: 1px solid #eee;">
                    <p style="margin-bottom: 10px;"><strong>Email:</strong><br><span id="mEmail"><%= mEmail %></span></p>
                    <p><strong>電話:</strong><br><span id="mPhone"><%= mPhone %></span></p>
                </div>
                <button onclick="logout()" style="width:100%; color:white; background:#d9534f; padding:10px; border-radius:5px; margin-top:20px; border:none; cursor:pointer;">登出</button>
            </div>

            <div class="member-fonts" style="display: flex; flex-direction: column; gap: 20px;">

                <div class="card">
                    <h2 class="member-section-title">歷史消費紀錄</h2>
                    <table>
                        <tr><th>訂單編號</th><th>日期</th><th>金額</th><th>狀態</th><th>付款方式</th></tr>
                        <%
                            // 🟢 自動去 orders 表格撈取這個人的訂單！
                            if (conn != null) {
                                try {
                                    // 透過 JOIN 語法，用 Email 對應 users 表，再去找 orders 表的訂單
                                    String orderSql = "SELECT o.orderId, o.orderDate, o.total, o.status, o.payment " +
                                                      "FROM orders o JOIN users u ON o.orders_userId = u.userId " +
                                                      "WHERE u.email = ? ORDER BY o.orderDate DESC";
                                    PreparedStatement pstmt = conn.prepareStatement(orderSql);
                                    pstmt.setString(1, mEmail);
                                    ResultSet rs = pstmt.executeQuery();
                                    
                                    boolean hasOrder = false;
                                    while(rs.next()) {
                                        hasOrder = true;
                                        out.println("<tr>");
                                        out.println("<td>#" + rs.getInt("orderId") + "</td>");
                                        // 擷取日期前面的部分 (YYYY-MM-DD)
                                        String dateStr = rs.getString("orderDate");
                                        if(dateStr != null && dateStr.length() >= 10) dateStr = dateStr.substring(0, 10);
                                        out.println("<td>" + dateStr + "</td>");
                                        out.println("<td>NT$" + rs.getInt("total") + "</td>");
                                        out.println("<td>" + rs.getString("status") + "</td>");
                                        out.println("<td>" + rs.getString("payment") + "</td>");
                                        out.println("</tr>");
                                    }
                                    
                                    // 如果迴圈跑完還是 false，代表他還沒買過東西
                                    if(!hasOrder) {
                                        out.println("<tr><td colspan='5' style='text-align:center;'>尚無訂單紀錄，快去逛逛吧！</td></tr>");
                                    }
                                    rs.close();
                                    pstmt.close();
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='5' style='color:red;'>無法讀取訂單：" + e.getMessage() + "</td></tr>");
                                }
                            }
                        %>
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
            <a href="https://reurl.cc/xKA8ae" target="_blank"><i class="fa-brands fa-instagram"></i></a>
            <a href="https://reurl.cc/Vmlo9A" target="_blank"><i class="fa-brands fa-threads"></i></a>
            <a href="https://reurl.cc/9ba94j" target="_blank"><i class="fa-brands fa-line"></i></a>
            <a href="mailto:service@example.com"><i class="fa-solid fa-envelope"></i></a>
        </div>
        <div class="footer-links"><a href="help.jsp">幫助中心</a> | <a href="question.jsp">常見問題</a></div>
        <p class="copyright">© COPYRIGHT 807dorm</p>
    </footer>

    <script>
        function logout() {
            if(confirm("確定要登出嗎？")) {
                // 導向專屬的登出處理頁面
                window.location.href = "logout.jsp"; 
            }
        }
    </script>
</body>
</html>