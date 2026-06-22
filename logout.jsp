<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1) 清除 Java 後端的 Session 記憶
    session.invalidate();
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body>
    <script>
        // 2) 清除前端 JavaScript 的記憶
        localStorage.removeItem("isLoggedIn");
        localStorage.removeItem("userName");
        
        // 3) 提示並回到首頁
        alert("您已成功登出！期待您再次光臨。");
        window.location.href = "index.jsp";
    </script>
</body>
</html>