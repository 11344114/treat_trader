<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<%
    // 從後端 Session 抓取登入狀態
    String cartUserEmail = (String) session.getAttribute("memberEmail");

    // 如果抓不到 Email，代表這個人沒登入
    if (cartUserEmail == null || cartUserEmail.isEmpty()) {
        // 用 Java 強制把他踢回 login.jsp
        out.println("<script>alert('要先登入才能使用購物車喔！'); window.location.href='login.jsp';</script>");
        return; // 阻止底下的網頁繼續載入
    }
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>購物車 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    
    <style>
        /* 購物車專用版面配置 */
        .cart-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            /* 靠上對齊 */
            align-items: start;
        }

        .cart-list-container {
            transition: 0.3s;
        }

        .cart-list-container.locked {
            opacity: 0.6;
            pointer-events: none;
            filter: grayscale(0.5);
        }

        .checkout-container {
            display: none;
            opacity: 0;
            transition: opacity 0.5s;
        }

        .checkout-container.active {
            display: block;
            opacity: 1;
        }
        
        /* 購物車商品項目樣式 */
        .cart-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            border-bottom: 1px solid #eee;
            background: #fff;
            border-radius: 8px;
            margin-bottom: 10px;
            position: relative;
        }

        .delete-btn {
            position: absolute;
            top: -10px;
            left: -10px;
            background: #ff4d4d;
            color: white;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            text-align: center;
            line-height: 24px;
            font-size: 14px;
            cursor: pointer;
            font-weight: bold;
            z-index: 5;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        .qty-control {
            display: flex;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: fit-content;
            margin-top: 5px;
        }

        .qty-control button {
            border: none;
            background: #FFECB3;
            padding: 2px 8px;
            cursor: pointer;
        }

        .qty-control span {
            padding: 2px 10px;
            min-width: 30px;
            text-align: center;
            background: white;
        } 

        /* 結帳表單區塊樣式 */
        .form-section {
            margin-bottom: 20px;
            border: 1px solid #eee;
            padding: 15px;
            border-radius: 10px;
            background: #fff;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .section-title {
            font-weight: bold;
            color: #FF7F50;
        }
        
        /* 選項按鈕群組 (單選) */
        .selection-group {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }

        .select-btn {
            padding: 8px 16px;
            border: 1px solid #FFD2A6;
            background: white;
            border-radius: 20px;
            cursor: pointer;
            transition: 0.2s;
            color: #5C4033;
        }

        .select-btn.active {
            background: #FF7F50;
            color: white;
            border-color: #FF7F50;
            font-weight: bold;
        }
        
        /* 動態顯示區塊 */
        .dynamic-field {
            display: none;
            margin-top: 10px;
        }

        .dynamic-field.show {
            display: block;
        }

        .container input[type="text"], 
        .container input[type="tel"], 
        .container input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            margin-bottom: 10px;
            outline: none;
        }

        .container input[type="text"]:focus, 
        .container input[type="tel"]:focus, 
        .container input[type="email"]:focus {
            border-color: #FF7F50;
        }

        .btn-checkout-nav {
            width: 100%;
            padding: 15px;
            font-size: 1.2rem;
            border-radius: 10px;
            cursor: pointer;
            border: none;
            font-weight: bold;
            color: white;
            background: #FF7F50;
            text-align: center;
            margin-top: 15px;
            transition: 0.3s;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .btn-checkout-nav:hover {
            background: #e06030;
            transform: translateY(-2px);
        }

        .btn-checkout-nav.back {
            background: #5C4033;
        }

        .btn-submit {
            width: 100%;
            padding: 15px;
            font-size: 1.2rem;
            border-radius: 10px;
            cursor: pointer;
            border: none;
            font-weight: bold;
            color: white;
            background: #5C4033;
            text-align: center;
            margin-top: 20px;
            transition: 0.3s;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .btn-submit:hover {
            background: #3e2b22;
            transform: translateY(-2px);
        }

        /* Map 樣式 - Leaflet 需要較高的 z-index 以正確顯示控制項 */
        #googleMap {
            width: 100%;
            height: 300px;
            border-radius: 10px;
            margin-bottom: 10px;
            border: 1px solid #ddd;
            z-index: 1; 
        }
        
        /* 門市選擇按鈕 */
        .store-btn-group {
            display: flex;
            gap: 10px;
            margin-top: 10px;
            flex-wrap: wrap;
        }

        .store-btn {
            padding: 5px 10px;
            background: #FFF8E7;
            border: 1px solid #FFD2A6;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            color: #5C4033;
            transition: 0.2s;
        }

        .store-btn:hover {
            background: #FF7F50;
            color: white;
        }
        
        @media (max-width: 768px) {
            .cart-layout {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 滿 $2500 免運 ✨</div>
    
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

    <div class="container cart-layout">
        <aside class="left-col">
            <div class="cart-list-container" id="cartListContainer">
                <h2 style="margin-bottom:20px;">購物車</h2>
                
                <div id="cartItems">
                    </div>

                <div class="card" style="margin-top:20px; text-align:right; font-weight:bold; font-size:1.2rem;">
                    總金額 <span id="cartTotal" style="color:#FF7F50;">$0</span>
                </div>
            </div>
            <button class="btn-checkout-nav" id="toCheckoutBtn" onclick="toggleCheckout(true)">前往結帳</button>
        </aside>

        <main class="right-col checkout-container" id="checkoutContainer">
            <h2 style="margin-bottom:20px;">結帳</h2>
            
            <div class="form-section">
                <div class="section-header">
                    <span class="section-title">收件資訊</span>
                </div>
                <div>
                    <input type="text" id="recvName" placeholder="姓名">
                    <input type="tel" id="recvPhone" placeholder="電話號碼">
                    <input type="email" id="recvEmail" placeholder="Email">
                </div>
            </div>

            <div class="form-section">
                <div class="section-header">
                    <span class="section-title">付款方式</span>
                </div>
                
                <div class="selection-group" id="payGroup">
                    <button class="select-btn active" onclick="selectOption('payGroup', this, 'card')">信用卡</button>
                    <button class="select-btn" onclick="selectOption('payGroup', this, 'transfer')">轉帳</button>
                    <button class="select-btn" onclick="selectOption('payGroup', this, 'epay')">電子支付</button>
                </div>
                <input type="hidden" id="payMethodValue" value="card">

                <div id="payInput" class="dynamic-field show">
                    <input type="text" placeholder="請輸入信用卡號或轉帳後五碼">
                </div>
                <div id="payQR" class="dynamic-field" style="text-align:center;">
                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=https://itouch.cycu.edu.tw/active_project/cycu1500h_01/donate/" alt="Scan to Pay">
                    <p style="font-size:0.8rem; color:#888;">請掃描 QR Code 付款</p>
                </div>
            </div>

            <div class="form-section">
                <div class="section-header">
                    <span class="section-title">收貨方式</span>
                </div>
                
                <div class="selection-group" id="shipGroup">
                    <button class="select-btn active" onclick="selectOption('shipGroup', this, 'delivery')">宅配</button>
                    <button class="select-btn" onclick="selectOption('shipGroup', this, 'store')">便利商店</button>
                </div>
                <input type="hidden" id="shipMethodValue" value="delivery">

                <div id="shipAddress" class="dynamic-field show">
                    <input type="text" placeholder="請輸入宅配地址">
                </div>
                <div id="shipMap" class="dynamic-field">
                    <div id="googleMap"></div>
                    <div class="store-btn-group">
                        <button class="store-btn" onclick="selectStore('7-ELEVEN 中原門市', 24.9575, 121.241)">7-ELEVEN 中原門市</button>
                        <button class="store-btn" onclick="selectStore('全家便利商店 中原門市', 24.9565, 121.239)">全家 中原門市</button>
                        <button class="store-btn" onclick="selectStore('萊爾富 中壢中原店', 24.958, 121.238)">萊爾富 中原店</button>
                    </div>
                    <input type="text" id="storeNameInput" placeholder="請選擇門市或輸入門市名稱..." style="margin-top: 10px;">
                </div>
            </div>

            <div class="form-section">
                <div class="section-header">
                    <span class="section-title">開立發票</span>
                </div>
                
                <div class="selection-group" id="invGroup">
                    <button class="select-btn active" onclick="selectOption('invGroup', this, 'mobile')">載具</button>
                    <button class="select-btn" onclick="selectOption('invGroup', this, 'company')">統編</button>
                    <button class="select-btn" onclick="selectOption('invGroup', this, 'donate')">捐贈</button>
                </div>
                <input type="text" placeholder="請輸入載具 / 統編 / 捐贈碼">
            </div>

            <div class="form-section">
                <div class="section-header">
                    <span class="section-title">訂單明細</span>
                </div>
                <div id="checkoutItemsList"></div>
                <div style="border-top: 1px solid #ddd; margin-top: 10px; padding-top: 5px; display:flex; justify-content:space-between;">
                    <span>運費</span><span id="shippingFeeDisplay">$60</span>
                </div>
                <div style="text-align:right; margin-top:10px; font-weight:bold; color:#FF7F50; font-size:1.2rem;">
                    總金額 <span id="checkoutTotal">$0</span>
                </div>
            </div>
            
            <button class="btn-submit" onclick="submitOrder()">送出訂單</button>
        </main>
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

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    <script src="assets/js/cart.js"></script>
</body>
</html>