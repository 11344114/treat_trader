import sys
filepath = r"c:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\ROOT\treat_trader\goods.jsp"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

old = """<%
    // 強制設定請求端編碼，防範編碼漏洞
    request.setCharacterEncoding("UTF-8");

    // 💡 從 Session 中撈取會員登入狀態，用來在商品頁進行第一線防禦
    String currentUserEmail = (String) session.getAttribute("memberEmail");"""

new = """<%
    // 強制設定請求端編碼，防範編碼漏洞
    request.setCharacterEncoding("UTF-8");

    // 處理 AJAX 減少庫存請求
    if ("decreaseInventory".equals(request.getParameter("action"))) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            int targetId = Integer.parseInt(request.getParameter("id"));
            if (conn != null) {
                String sql = "UPDATE products SET inventory = inventory - 1 WHERE productId = ? AND inventory >= 1";
                java.sql.PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, targetId);
                int rows = pstmt.executeUpdate();
                pstmt.close();
                if (rows > 0) {
                    out.print("{\\"success\\": true}");
                } else {
                    out.print("{\\"success\\": false, \\\"message\\\": \\\"庫存不足或商品不存在\\"}");
                }
            } else {
                out.print("{\\"success\\": false, \\\"message\\\": \\\"資料庫連線失敗\\"}");
            }
        } catch (Exception e) {
            out.print("{\\"success\\": false, \\\"message\\\": \\\"例外錯誤\\"}");
        }
        return; // AJAX 請求結束，不渲染後續 HTML
    }

    // 💡 從 Session 中撈取會員登入狀態，用來在商品頁進行第一線防禦
    String currentUserEmail = (String) session.getAttribute("memberEmail");"""

content = content.replace(old, new)
with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)
