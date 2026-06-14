<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 設定連線資訊
    String dbURL = "jdbc:mysql://localhost:3306/treat_trader?useSSL=false&serverTimezone=Asia/Taipei&characterEncoding=UTF-8";
    String dbUser = "root"; 
    String dbPassword = "1234"; 
    
    Connection conn = null;
    
    try {
        // 載入驅動程式並建立連線
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        // 注意：這裡我們「不寫」 conn.close()，因為要留著讓其他網頁用！
    } catch (Exception e) {
        out.println("資料庫連線發生問題：" + e.getMessage());
    }
%>