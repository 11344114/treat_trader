function handleEnter(e) { if(e.key === 'Enter') siteSearch(); }
function siteSearch() {
    var val = document.getElementById('globalSearch').value.trim();
    if(!val) return;
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.includes(val); });
        if(matches.length === 0) alert("沒有搜尋到相關商品！");
        else location.href = "allgoods.html?search=" + encodeURIComponent(val);
    });
}

// --- 廣告輪播功能 ---
var ads = [
    { text: "🇯🇵 日本抹茶蛋糕：第二件半價", id: 1, image: "Matcha.jpg" }, 
    { text: "🇫🇷 法國馬卡龍：浪漫直送到家", id: 3, image: "Macaron.jpg" }, 
    { text: "🇺🇸 紐約起司蛋糕：濃郁登場", id: 7, image: "CheeseCake.jpg" },
    { text: "🇹🇼 台灣精選零食：經典在地美味", id: 12, image: "Pineapple.jpg" }
];

function clickAd() { 
    if (currentAdId) {
        location.href = "goods.html?id=" + currentAdId; 
    }
}

// img preload
ads.forEach(ad => {
    const img = new Image();
    img.src = `assets/images/${ad.image}`;
});

var adIdx = 0;
var currentAdId = 1;

function updateAd() { 
    const heroSlider = document.getElementById("heroSlider");
    const heroText = document.getElementById("heroText");
    if (!heroSlider || !heroText) return;

    const currentAd = ads[adIdx];

    // img transition
    heroSlider.style.backgroundImage = `linear-gradient(rgba(0,0,0,0.2), rgba(0,0,0,0.2)), url('assets/images/${currentAd.image}')`;
    
    // animation
    heroText.style.animation = 'none';
    heroText.offsetHeight; 
    heroText.style.animation = 'coolShow 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards';

    heroText.innerText = currentAd.text; 
    currentAdId = currentAd.id; 
    adIdx = (adIdx + 1) % ads.length; 
}

// onload
document.addEventListener('DOMContentLoaded', function() {
    // 搬過來的會員判斷邏輯
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if(user) document.getElementById('avatarLink').href = "member.html";

    // 啟動廣告
    updateAd();
    setInterval(updateAd, 5000);
});

// --- 商品載入功能 ---
fetch('products.json').then(function(res) { return res.json(); }).then(function(data) { 
    renderProducts(data.slice(0, 8)); // 抓前 8 個當推薦
});

function renderProducts(list) {
    var container = document.getElementById("recommendList");
    if (!container) return;
        
    if (!list || list.length === 0) {
        container.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: white; border-radius: 15px;">
                <i class="fa-solid fa-cookie-bite" style="font-size: 4rem; color: #FFD2A6; margin-bottom: 20px;"></i>
                <h3 style="color: #5C4033;">喔喔！找不到相關商品</h3>
                <button onclick="location.href='allgoods.html'" class="btn">查看所有商品</button>
            </div>`;
        return;
    }

    container.innerHTML = list.map(function(p){
        return '<div class="card" onclick="location.href=\'goods.html?id='+p.id+'\'">' +
            '<div class="img-placeholder">' + 
            '<img src="assets/images/' + p.img + '" alt="' + p.name + '" style="width:100%; height:100%; object-fit:cover;">' + 
            '</div>' +
            '<h4>' + p.name + '</h4>' +
            '<p style="color:#FF7F50; font-weight:bold;">$' + p.price + '</p></div>';
    }).join("");
}

// 自動隱藏搜尋建議
document.addEventListener('click', function(e) {
    var box = document.getElementById('searchSuggestions');
    var input = document.getElementById('globalSearch');
    if (box && input && e.target !== box && e.target !== input) { box.style.display = 'none'; }
});
