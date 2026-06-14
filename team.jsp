<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>關於我們 - Treat Trader</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* 團隊與品牌專用樣式 */
        .brand-intro-title, .team-intro-title {
            text-align: left;
            margin-bottom: 20px;
            font-size: 1.5rem;
            font-weight: bold;
            color: #5C4033;
            border-left: 5px solid #FF7F50;
            padding-left: 15px;
        }
        .team-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }
        .team-card {
            border-radius: 20px;
            padding: 30px 20px;
            text-align: center;
            transition: 0.3s;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .team-card:hover {
            transform: translateY(-5px);
        }
        .team-card:nth-child(1) { background: #FFD2A6; }
        .team-card:nth-child(2) { background: #FFC1A1; }
        .team-card:nth-child(3) { background: #FFECB3; }
        .team-card:nth-child(4) { background: #FFD2A6; }

        .member-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: #fff;
            margin-bottom: 15px;
            border: 3px solid rgba(255,255,255,0.5);
            overflow: hidden;        /* 限制圓形 */
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .brand-logo-place {
            width: 150px;
            height: 150px;
            background: #FFD2A6;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: #5C4033;
        }
        .brand-intro-box {
            text-align: left;
            max-width: 800px;
            margin: 0 auto;
            font-size: 1rem;
            color: #444;
        }
        
        /* RWD */
        @media (max-width: 992px) {
            .team-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 576px) {
            .team-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="marquee-container">✨ 認識我們的團隊 ✨ 致力於為您提供最優質的購物體驗 ✨</div>
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
        <h2 class="brand-intro-title">品牌介紹</h2>
        <div class="card" style="margin-bottom: 40px; text-align: center;">
            <img class="brand-logo-place" src="assets/images/Logo.PNG" alt="Logo">
            
            <h1 style="margin-bottom: 20px; font-size: 1.8rem; color: #FF7F50;">賣國賊 (Treat Trader)</h1>
            <div class="brand-intro-box">
                <p><strong>主題發想：</strong><br>
                我們的專案發想是從一個玩笑般的諧音梗開始的。在討論階段時，有個組員開玩笑地說，如果我們賣的是國家，我們品牌就能叫做賣國賊了。結果我們最後竟然決定要賣各國特色零食，然後品牌名真的就是「賣國賊」！</p>
                <br>
                <p><strong>展望與目標：</strong><br>
                本專案致力於讓世界各地的人能輕鬆透過手機、電腦等3C產品購買世界各國的零食。我們將架設一個B2C的電商網站，讓大家能夠不經過語言隔閡等困擾瀏覽他國的零食，並在線上商城購買。我們相信吃是全人類共同的愛好，通過了解他國零食的美味，能讓地球每個角落的人彼此理解，成為一個真正的地球村！</p>
            </div>
        </div>

        <h2 class="brand-intro-title">組員介紹</h2>
        <div class="team-grid">
            <div class="team-card">
                <img class="member-avatar" src="assets/images/slvia.jpg" alt="李妍庭">
                <h3>資管二甲 李妍庭</h3>
                <p>
                    我曾經在另外一堂課學過如何用.NET做後端，但這是我第一次用jsp來做，這對我來說是一個不小的挑戰。原本以為只要停用舊的前端非同步抓取邏輯、把json的fetchData()徹底拔除，再改用jsp語法就好了，但當我們真正開始將代碼與MySQL資料庫進行串接時，真正的考驗才接踵而至。搜尋欄和評論區能以純jsp後端架構順暢跑出結果的那一刻，那種苦盡甘來的感動真的無法言語。
                    雖然過程把大家折騰到神智不清，但從這次底層代碼的重構中，我學到了如何在高壓的狀態下靈活調整資料庫存取邏輯，這絕對是這學期網頁程式設計最紮實、也最讓我自豪的收穫。
                </p>
            </div>
            <div class="team-card">
                <img class="member-avatar" src="assets/images/Cynth.jpg" alt="丁聖曦">
                <h3>資管二甲 丁聖曦</h3>
                <p>
                    撰寫資料庫的時候，我們是先請一位同學建立好資料庫並分享.sql，但是要使用jsp連結上mysql這部分一直很不熟練，花了很久時間都無法順利連上，最後是一位同學成功連結上我們才能夠繼續進行後續功能的製作。
                   另外因為要控制區域的出現和鎖定，以及計算價格，很多時候都想不出來要怎麼做，我會在網路上搜尋其他人做過的成果，以及把我的需求告訴AI，從中擷取我需要的部分來使用。因為不是很熟悉的內容，有些時候當下看懂到後來就又看不懂了。這時，我會把程式碼再次丟給AI，請它和我解釋用到的內容，直到我熟悉它。我覺得從中認識到很多之前沒有看過、沒有用過的功能，不過有部分都是之前有學習過的內容拼湊起的。
                   其他部分主要是上學期完成的html和css的排版，我們是先各自寫網頁再統一整合，也有使用AI幫助我們整合網頁及建立連結，這讓我們的網頁在開始的時候就有一致的風格，方便後期統一使用Live Shars進行共編。
                </p>
            </div>
            <div class="team-card">
                <img class="member-avatar" src="assets/images/Grace.jpg" alt="焦紫菱">
                <h3>資管二甲 焦紫菱</h3>
                <p>
                    在無數個思緒不清晰的半夜裡，我與 MySQL 資料庫展開了長達數小時的生死決鬥。原本以為把欄位從 products_categoryId 修正為 categorId（甚至一度糾結要不要叫 categoryId）就大功告成了，沒想到直接迎面撞上資料庫地獄。當網頁出現錯誤、商品莫名消失、連留言板都因為外鍵完整性限制把我死卡在畫面上時，我真的差點在半夜三點砸了電腦。
                    我這次最滿意的部分，是我最終沒有向資料庫妥協，而是完美運用了課堂上洪智力老師教的，硬是把一個功能完整的中文留言板與庫存異動直接購買功能給生了出來。
                    作為一個 B2C 電商網站，上次我為了客人的品牌第一印象瘋狂改 RWD；這次我則是為了客人的資料安全與後端穩定度，一直刷Tomcat。現在想來，雖然半夜Debug的過程看起來有點蠢、精神也很衰弱，但看到商品清單和中文評論終於完美依時間排序呈現在網頁上的那一刻，所有的爆肝與外鍵地獄，都變成了我這學期網頁程式設計最踏實的學習成果。
                </p>
            </div>
            <div class="team-card">
                <img class="member-avatar" src="assets/images/tingyu.jpg" alt="張庭瑀">   
                <h3>資管二甲 張庭瑀</h3>
                <p>
                    大網站整合最難的地方，就在於許多後端功能和資料庫欄位是完全共用的。在大家各自修改頁面、對齊資料庫的過程中，只要有一個人的 SQL 語法拼錯，或者欄位名稱在 categoryId 與 categorId 之間沒有對齊好，網頁就會顯示錯誤。我們花了好長一段時間在逐字檢查有沒有多打一個字或少打一個字，最後才揪出錯誤，原來我們order少打了一個r，就是這一個小小的r浪費了我們將近兩小時。
雖然一度抓狂，但也逼得我們坐下來一頁一頁重新理清邏輯。幸好最後我們克服了資料庫的衝突，成功讓網站跑了起來。最後看到網站能夠一鍵順暢運行、商品列表與中文評論完美渲染出來的那一刻，那種終於把大家的功能完美焊在一起的感動，真的比上次還要強烈太多了！這次在 Tomcat 和 MySQL 之間的奮戰，真的讓我們學到了最紮實的後端整合經驗。
                </p>
            </div>
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

    <script src="assets/js/team.js"></script>
</body>
</html>