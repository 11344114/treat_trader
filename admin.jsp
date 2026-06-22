<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<%
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String adminMessage = "";

    // 處理表單動作：addProduct, updateProduct, deleteProduct
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        try {
            if (conn != null && action != null) {
                if ("addProduct".equals(action)) {
                    String name = request.getParameter("productName");
                    String img = request.getParameter("img");
                    String desc = request.getParameter("description");
                        String catS = request.getParameter("categoryId");
                        int catId = (catS != null && !catS.isEmpty()) ? Integer.parseInt(catS) : 1;
                    String priceS = request.getParameter("price");
                    String invS = request.getParameter("inventory");
                    int price = (priceS != null && !priceS.isEmpty()) ? Integer.parseInt(priceS) : 0;
                    int inv = (invS != null && !invS.isEmpty()) ? Integer.parseInt(invS) : 0;
                    String sql = "INSERT INTO products (productName, price, products_categoryId, img, inventory, description) VALUES (?, ?, ?, ?, ?, ?)";
                    PreparedStatement p = conn.prepareStatement(sql);
                    p.setString(1, name);
                    p.setInt(2, price);
                    p.setInt(3, catId);
                    p.setString(4, img);
                    p.setInt(5, inv);
                    p.setString(6, desc);
                    p.executeUpdate();
                    p.close();
                    adminMessage = "新增商品成功";
                } else if ("updateProduct".equals(action)) {
                    String idS = request.getParameter("productId");
                    int id = Integer.parseInt(idS);
                    String name = request.getParameter("productName");
                    String img = request.getParameter("img");
                    String desc = request.getParameter("description");
                    String catS2 = request.getParameter("categoryId");
                    int catId2 = (catS2 != null && !catS2.isEmpty()) ? Integer.parseInt(catS2) : 1;
                    String priceS = request.getParameter("price");
                    String invS = request.getParameter("inventory");
                    int price = (priceS != null && !priceS.isEmpty()) ? Integer.parseInt(priceS) : 0;
                    int inv = (invS != null && !invS.isEmpty()) ? Integer.parseInt(invS) : 0;
                    String sql = "UPDATE products SET productName=?, price=?, products_categoryId=?, img=?, inventory=?, description=? WHERE productId=?";
                    PreparedStatement p = conn.prepareStatement(sql);
                    p.setString(1, name);
                    p.setInt(2, price);
                    p.setInt(3, catId2);
                    p.setString(4, img);
                    p.setInt(5, inv);
                    p.setString(6, desc);
                    p.setInt(7, id);
                    p.executeUpdate();
                    p.close();
                    adminMessage = "商品已更新";
                } else if ("deleteProduct".equals(action)) {
                    String idS = request.getParameter("productId");
                    int id = Integer.parseInt(idS);
                    String sql = "DELETE FROM products WHERE productId=?";
                    PreparedStatement p = conn.prepareStatement(sql);
                    p.setInt(1, id);
                    p.executeUpdate();
                    p.close();
                    adminMessage = "商品已刪除";
                }
            }
        } catch (Exception e) {
            adminMessage = "操作失敗：" + e.getMessage();
        }
        // 將訊息放到 session，完成操作後重新導向避免表單重送
        if (adminMessage != null && !adminMessage.isEmpty()) {
            session.setAttribute("adminMessage", adminMessage);
        }
        response.sendRedirect("admin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理後台 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        /* 管理介面專用按鈕：統一為 inline-flex、固定高度與對齊 */
        .admin-action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            height: 36px;
            min-width: 88px;
            padding: 0 12px;
            line-height: 1;
            font-size: 14px;
            text-align: center;
            border: none;
            background: transparent;
            color: inherit;
            text-decoration: none;
            border-radius: 6px;
            cursor: pointer;
            box-sizing: border-box;
        }
        .admin-action-btn.delete { color: #b00020; }
        .admin-action-btn:active { transform: translateY(1px); }
        /* 動作按鈕容器，統一間距與垂直置中 */
        .action-group { display:flex; gap:8px; align-items:center; justify-content:center; }
        /* 小螢幕微調，確保按鈕尺寸一致 */
        @media (max-width: 600px) {
            .admin-action-btn { min-width: 72px; height:34px; font-size:13px; padding:0 10px; }
            .container { grid-template-columns: 1fr !important; }
        }
        /* 表單區塊提交/取消按鈕：統一尺寸、對齊與字型，底色保留現有設定 */
        .form-action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            height: 40px;
            min-width: 110px;
            padding: 0 14px;
            font-size: 15px;
            line-height: 1;
            border-radius: 8px;
            box-sizing: border-box;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            border: none;
        }
        @media (max-width:600px) {
            .form-action-btn { min-width: 90px; height:36px; font-size:14px; padding:0 10px; }
        }
    </style>
</head>
<body>
    <header>
        <div class="logo" onclick="location.href='index.jsp'">
            <img src="assets/images/Logo.PNG" alt="Logo">
            Treat Trader
        </div>
    </header>

    <%
        // 撈取商品清單
        java.util.List<java.util.Map<String,Object>> products = new java.util.ArrayList<>();
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT productId, productName, price, inventory, img FROM products ORDER BY productId DESC");
            java.sql.ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String,Object> row = new java.util.HashMap<>();
                row.put("productId", rs.getInt("productId"));
                row.put("productName", rs.getString("productName"));
                row.put("price", rs.getInt("price"));
                row.put("inventory", rs.getInt("inventory"));
                row.put("img", rs.getString("img"));
                products.add(row);
            }
            rs.close(); ps.close();
        } catch (Exception e) { }

        // 撈取分類清單
        java.util.List<java.util.Map<String,Object>> categories = new java.util.ArrayList<>();
        try {
            PreparedStatement pcs = conn.prepareStatement("SELECT categoryId, categoryName FROM category ORDER BY categoryId");
            java.sql.ResultSet rcs = pcs.executeQuery();
            while (rcs.next()) {
                java.util.Map<String,Object> c = new java.util.HashMap<>();
                c.put("categoryId", rcs.getInt("categoryId"));
                c.put("categoryName", rcs.getString("categoryName"));
                categories.add(c);
            }
            rcs.close(); pcs.close();
        } catch (Exception e) { }

        // 撈取訂單清單（簡單顯示）
        java.util.List<java.util.Map<String,Object>> orders = new java.util.ArrayList<>();
        try {
            PreparedStatement ps2 = conn.prepareStatement("SELECT orderId, userName, userEmail, totalAmount, status, createdAt FROM orders ORDER BY orderId DESC LIMIT 200");
            java.sql.ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                java.util.Map<String,Object> r = new java.util.HashMap<>();
                r.put("orderId", rs2.getInt("orderId"));
                r.put("userName", rs2.getString("userName"));
                r.put("userEmail", rs2.getString("userEmail"));
                r.put("totalAmount", rs2.getDouble("totalAmount"));
                r.put("status", rs2.getString("status"));
                r.put("createdAt", rs2.getTimestamp("createdAt"));
                orders.add(r);
            }
            rs2.close(); ps2.close();
        } catch (Exception e) { }

        // 如果有 editId，撈取該商品資料用於編輯表單
        String editId = request.getParameter("editId");
        int editPid = -1;
        String e_name="", e_img="", e_desc="";
        int e_price=0, e_inv=0;
        if (editId != null && !editId.isEmpty()) {
            try {
                editPid = Integer.parseInt(editId);
                PreparedStatement pes = conn.prepareStatement("SELECT * FROM products WHERE productId=?");
                pes.setInt(1, editPid);
                java.sql.ResultSet res = pes.executeQuery();
                if (res.next()) {
                    e_name = res.getString("productName");
                    e_img = res.getString("img");
                    e_desc = res.getString("description");
                    e_price = res.getInt("price");
                    e_inv = res.getInt("inventory");
                    try { e_price = res.getInt("price"); } catch(Exception ee) {}
                    try { request.setAttribute("e_cat", res.getInt("products_categoryId")); } catch(Exception ee) {}
                }
                res.close(); pes.close();
            } catch (Exception ex) { }
        }
    %>

    <div class="container" style="display:grid; grid-template-columns: 1fr 1fr; gap:24px;">
        <% String flash = (String) session.getAttribute("adminMessage"); if (flash != null) { %>
        <div style="grid-column:1/-1; background:#fff3cd; padding:10px; border:1px solid #ffeeba; margin-bottom:12px;">
            <strong>系統訊息：</strong> <%= flash %>
        </div>
        <% session.removeAttribute("adminMessage"); } %>
        <div class="card">
            <h3 style="color:#5C4033;">商品管理</h3>

            <div style="margin-top:16px;">
                <form method="POST" action="admin.jsp" style="display:grid; gap:8px;">
                    <input type="hidden" name="action" value="<%= (editPid>0)?"updateProduct":"addProduct" %>">
                    <% if (editPid>0) { %>
                        <input type="hidden" name="productId" value="<%= editPid %>">
                    <% } %>
                    <input name="productName" placeholder="名稱" value="<%= e_name %>" required style="padding:8px;">
                    <select name="categoryId" required style="padding:8px;">
                        <option value="">選擇分類</option>
                        <% for (java.util.Map<String,Object> c : categories) { %>
                            <% int cid = (Integer) c.get("categoryId"); %>
                            <option value="<%= cid %>" <%= (request.getAttribute("e_cat")!=null && ((Integer)request.getAttribute("e_cat")).intValue()==cid)?"selected":"" %>><%= c.get("categoryName") %></option>
                        <% } %>
                    </select>
                    <input name="price" placeholder="整數價格" value="<%= (e_price>0)?e_price:"" %>" style="padding:8px;">
                    <input name="inventory" placeholder="整數庫存" value="<%= (e_inv>0)?e_inv:"" %>" style="padding:8px;">
                    <input name="img" placeholder="圖片檔名 assets/images/" value="<%= e_img %>" style="padding:8px;">
                    <textarea name="description" placeholder="簡介" style="padding:8px;"><%= (e_desc!=null)?e_desc:"" %></textarea>
                    <div style="display:flex; gap:8px;">
                        <button type="submit" class="btn form-action-btn">提交</button>
                        <% if (editPid>0) { %>
                            <a href="admin.jsp" class="btn form-action-btn" style="background:#aaa; display:inline-flex; align-items:center; justify-content:center;">取消</a>
                        <% } %>
                    </div>
                </form>
            </div>

            <hr style="margin:18px 0;">
            <table style="width:100%; border-collapse:collapse;">
                <thead>
                    <tr style="background:#FFECB3;">
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">ID</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">名稱</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">價格</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">庫存</th>
                        <th style="padding:8px; border:1px solid #eee;">操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (java.util.Map<String,Object> p : products) { %>
                        <tr>
                            <td style="padding:8px; border:1px solid #eee;"><%= p.get("productId") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= p.get("productName") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= p.get("price") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= p.get("inventory") %></td>
                            <td style="padding:8px; border:1px solid #eee; text-align:center;">
                                <div class="action-group">
                                    <a class="admin-action-btn" href="admin.jsp?editId=<%= p.get("productId") %>">編輯</a>
                                    <form method="POST" action="admin.jsp" style="display:inline-block; margin:0;" onsubmit="return confirm('確認要刪除該商品？此動作無法還原。');">
                                        <input type="hidden" name="action" value="deleteProduct">
                                        <input type="hidden" name="productId" value="<%= p.get("productId") %>">
                                        <button type="submit" class="admin-action-btn delete">刪除</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="card">
            <h3 style="color:#5C4033;">訂單總覽</h3>

            <table style="width:100%; border-collapse:collapse; margin-top:12px;">
                <thead>
                    <tr style="background:#FFECB3;">
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">訂單編號</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">姓名</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">Email</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">金額</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">狀態</th>
                        <th style="padding:8px; border:1px solid #eee; text-align:left;">建立時間</th>
                    </tr>
                </thead>
                <tbody id="ordersTbody">
                    <% for (java.util.Map<String,Object> o : orders) { %>
                        <tr>
                            <td style="padding:8px; border:1px solid #eee;"><%= o.get("orderId") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= o.get("userName") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= o.get("userEmail") %></td>
                            <td style="padding:8px; border:1px solid #eee;">$<%= o.get("totalAmount") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= o.get("status") %></td>
                            <td style="padding:8px; border:1px solid #eee;"><%= o.get("createdAt") %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
            <script>
                (function(){
                    function parseDate(v){
                        if(!v) return '';
                        var d = new Date(v);
                        if(isNaN(d)){
                            try { d = new Date(parseInt(v)); } catch(e) { return String(v); }
                        }
                        return d.toISOString().substring(0,19).replace('T',' ');
                    }

                    function mapPayment(p){
                        if(!p) return '';
                        p = String(p).toLowerCase();
                        if(p==='card') return '信用卡';
                        if(p==='transfer') return '轉帳';
                        if(p==='epay') return '電子支付';
                        if(p==='cash') return '貨到付款';
                        return p;
                    }

                    var tbody = document.getElementById('ordersTbody');
                    if(!tbody) return;

                    try {
                        var raw = localStorage.getItem('tt_orders');
                        if(!raw) return;
                        var localOrders = JSON.parse(raw || '[]');
                        if(!Array.isArray(localOrders)) return;

                        // 將 local orders 依時間由新到舊插入（顯示在 server orders 之上）
                        localOrders.slice().reverse().forEach(function(o){
                            var tr = document.createElement('tr');
                            tr.style.border = '1px solid #eee';
                            var orderId = o.orderId || o.id || ('L-' + (o.localId||'').toString());
                            var name = o.userName || o.name || o.customer || '';
                            var email = o.userEmail || o.email || '';
                            var amount = o.total || o.totalAmount || o.subtotal || 0;
                            var status = o.status || o.statusText || '';
                            var created = o.createdAt || o.orderDate || o.ts || o.created || '';

                            // 建立狀態下拉選單
                            var sel = document.createElement('select');
                            ['pending','processing','shipped','completed','cancelled'].forEach(function(s){
                                var opt = document.createElement('option');
                                opt.value = s; opt.text = s.charAt(0).toUpperCase()+s.slice(1);
                                if(s === status) opt.selected = true;
                                sel.appendChild(opt);
                            });
                            // 允許自訂文本狀態
                            var otherOpt = document.createElement('option'); otherOpt.value = 'other'; otherOpt.text = '其它';
                            if(['pending','processing','shipped','completed','cancelled'].indexOf(status) === -1){
                                otherOpt.selected = true;
                            }
                            sel.appendChild(otherOpt);

                            sel.addEventListener('change', function(){
                                var newStatus = sel.value;
                                if(newStatus === 'other'){
                                    var custom = prompt('請輸入自訂狀態文字', status || '');
                                    if(custom !== null) {
                                        newStatus = custom;
                                    } else {
                                        // revert
                                        sel.value = status || '';
                                        return;
                                    }
                                }
                                // 更新 localOrders 陣列並寫回 localStorage
                                try {
                                    // 找到此筆的索引
                                    for(var i=0;i<localOrders.length;i++){
                                        var it = localOrders[i];
                                        if(String(it.orderId||it.id||it.localId) === String(o.orderId||o.id||o.localId)){
                                            it.status = newStatus;
                                            break;
                                        }
                                    }
                                    localStorage.setItem('tt_orders', JSON.stringify(localOrders));
                                    // 更新顯示
                                    tdStatus.textContent = newStatus;
                                } catch(e){
                                    console.error('更新 local order 狀態失敗', e);
                                    alert('更新失敗：'+e.message);
                                }
                            });

                            var tdId = document.createElement('td'); tdId.style.padding='8px'; tdId.textContent = orderId;
                            var tdName = document.createElement('td'); tdName.style.padding='8px'; tdName.textContent = name;
                            var tdEmail = document.createElement('td'); tdEmail.style.padding='8px'; tdEmail.textContent = email;
                            var tdAmount = document.createElement('td'); tdAmount.style.padding='8px'; tdAmount.textContent = '$' + amount;
                            var tdStatus = document.createElement('td'); tdStatus.style.padding='8px'; tdStatus.textContent = status;
                            var tdCreated = document.createElement('td'); tdCreated.style.padding='8px'; tdCreated.textContent = parseDate(created);

                            // 用行動作按鈕放置 select
                            var tdAction = document.createElement('td'); tdAction.style.padding='8px';
                            tdAction.appendChild(sel);

                            tr.appendChild(tdId);
                            tr.appendChild(tdName);
                            tr.appendChild(tdEmail);
                            tr.appendChild(tdAmount);
                            tr.appendChild(tdStatus);
                            tr.appendChild(tdCreated);
                            // 插入一個隱藏 action cell 保持 colspan 一致（若需要可移除）
                            // 把 select 放置到狀態 cell 右側：這裡不另外顯示

                            // 將 tr 插入表格（插在最上方的 server rows 之下）
                            if(tbody.firstChild){
                                tbody.insertBefore(tr, tbody.firstChild);
                            } else {
                                tbody.appendChild(tr);
                            }
                        });
                    } catch(e){
                        console.error('載入 local orders 失敗', e);
                    }
                })();
            </script>
        </div>
    </div>

    <footer>
        <p class="copyright">© COPYRIGHT 807dorm</p>
    </footer>
</body>
</html>
