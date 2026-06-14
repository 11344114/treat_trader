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
                <p>這次專題是我第一次撰寫後端 API，過程比我預期的困難得多，也讓我學到非常多全新的內容。一開始我對後端理解很模糊，只知道它負責資料儲存，但實際開發時才發現，需要處理的事情包含資料庫建立、API 架構設計、資料驗證與錯誤處理等，每一步都會影響整個網站是否能正常運作。
我最大卡關是在資料庫，包含 Migration 不成功、資料表沒建立、SQLite 找不到、新增會員被 UNIQUE 限制錯誤等。為了解決，我學會了刪除資料庫重建、執行 Migration、用 DB Browser 檢查資料內容，以及理解錯誤訊息的意義，這讓我一步步了解資料庫真正的運作方式。
完成 register、login 和新增評論 API 後，當我成功在 Swagger 測試並看到資料寫入資料庫的時候，真的覺得很有成就感。這次專題讓我從完全不懂後端，到能夠讓前端與後端互通，雖然過程充滿錯誤，但也因此學到很多，對開發網站更有信心。</p>
            </div>
            <div class="team-card">
                <img class="member-avatar" src="assets/images/Cynth.jpg" alt="丁聖曦">
                <h3>資官二甲 丁聖曦</h3>
                <p>撰寫購物車的時候需要用很多js，因為要控制區域的出現和鎖定，以及計算價格，很多時候都想不出來要怎麼做，我會在網路上搜尋其他人做過的成果，以及把我的需求告訴AI，從中擷取我需要的部分來使用。因為不是之前上課學過的內容，有時候當下看懂到後期就又看不懂了，我會把程式碼再次丟給AI，請它和我解釋用到的內容，我覺得從中認識到很多之前沒有看過，沒有用過的功能，不過有部分都是之前有學習過的內容拼湊起的。
                    其他部分主要是html和css的排版，我們是先各自寫網頁在統一整合，也有使用AI幫助我們整合網頁及建立連結，這讓我們的網頁在開始的時候就有一致的風格，方便後期統一使用Live Shars進行共編。
                    資料同步的部分原本我只有搜尋到可以透過函式把資料儲存在本地的瀏覽器，達到類似後端的效果，但是後來我們有組員撰寫出後端把所有資料儲存進去，讓我們可以達成只要有資料庫就可以叫出歷史資料，不受限於瀏覽器。</p>
            </div>
            <div class="team-card">
                <img class="member-avatar" src="assets/images/Grace.jpg" alt="焦紫菱">
                <h3>資管二甲 焦紫菱</h3>
                <p>寫動態廣告的時候本來想做SlideShow，展現上課的學習成果，但當時的我想了想又覺得廣告不可或缺的元素是惹人嫌。不討人厭的廣告不能算是真正的廣告，所以最後我決定用HeroSlider寫。請容我解釋我寫程式當下的思考過程（那時半夜，我的思緒不太清晰，看起來不太合理是正常的）首先，我覺得HeroSlider美觀而且名字可愛。再來，我想寫點沒寫過的新玩意兒，學些新知識。最後也是最重要的，HeroSlider沒有翻頁的按鈕，好看的同時兼具不便，簡直是我理想中的廣告。於是我毫不猶豫的選了用它寫廣告，現在想來倒是有點蠢。
                    我最滿意的部分是RWD，我花了不少心力在那上面。畢竟這是個B2C網站，使用者體驗和美觀是我的第一考量，尤其我負責做的是主頁，可以說是電商的臉面。客人對我們品牌的第一印象將取決於我們的主頁，所以我很認真對待RWD這個部分。</p>
            </div>
            <div class="team-card">
                <img class="member-avatar" src="assets/images/tingyu.jpg" alt="張庭瑀">   
                <h3>資管二甲 張庭瑀</h3>
                <p>網站的專案真的很難，除了要從無到有設計一個網站和商品理念外，我覺得最難的地方就是要把所有網站接在一起，因為這是一個大網站然後很多功能會是共用的但是因為不同頁面是不同人寫所以接在一起要，可能會出出現動了一部份就會影響到其他人的部分，尤其是css排版，一動到就會影響其他人網頁的排版，另外因為用了json的功能，在抓需要的id時就需要正確的檔案名稱，而且因為太多程式碼所以到後面有點神智不清，很多時候會不小心出錯還要再花大把時間去debug，不過最後看到網頁能使用並且看起來還可以的時候真的很感動，不過live share真是個好用的功能，雖然剛開始用的時候出現一些小問題，不過後來克服之後發現真的很方便。</p>
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