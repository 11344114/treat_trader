const API_BASE = "http://localhost:5038/api";

var allData = [];
var productRatings = {};

function getDefaultReviewRatings() {
    return [5, 4, 5, 3, 5];
}

function getDefaultAverageRating() {
    var ratings = getDefaultReviewRatings();
    var sum = ratings.reduce(function(acc, value) { return acc + value; }, 0);
    return parseFloat((sum / ratings.length).toFixed(1));
}

window.onload = function() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (user) document.getElementById('avatarLink').href = "member.html";
    fetchData();
};

var urlParams = new URLSearchParams(window.location.search);
var searchKey = urlParams.get('search');

function loadRatingsForProducts(products) {
    var tasks = products.map(function (p) {
        return fetch(API_BASE + "/Reviews/product/" + p.id + "?page=1&pageSize=9999")
            .then(function (res) { return res.json(); })
            .then(function (data) {
                var items = data.items || [];
                var ratings = getDefaultReviewRatings().slice();

                items.forEach(function (r) {
                    var rating = Number(r.rating);
                    if (!isNaN(rating) && rating > 0) {
                        ratings.push(rating);
                    }
                });

                if (ratings.length === 0) {
                    productRatings[p.id] = 0;
                    return;
                }

                var sum = ratings.reduce(function (acc, value) { return acc + value; }, 0);
                productRatings[p.id] = parseFloat((sum / ratings.length).toFixed(1));
            })
            .catch(function () {
                productRatings[p.id] = getDefaultAverageRating();
            });
    });

    return Promise.all(tasks);
}

function fetchData() {
    fetch('products.json')
        .then(function(res){ return res.json(); })
        .then(function(data){
            allData = data;
            
            return loadRatingsForProducts(data).then(function () {
                var displayData = data;
                if (searchKey) {
                    displayData = data.filter(function(p){ return p.name.includes(searchKey); });
                    document.querySelector('h2').innerText = "搜尋結果： " + searchKey;
                    if (document.getElementById('midSearch')) {
                        document.getElementById('midSearch').value = searchKey;
                    }
                }
                renderList(displayData);
            });
        });
}

function calculateAvgRating(pid) {
    return productRatings[pid] || 0;
}

function renderStars(rating) {
    var html = "";
    for (var i = 1; i <= 5; i++) {
        if (i <= Math.round(rating)) html += '<i class="fa-solid fa-star active"></i>';
        else html += '<i class="fa-solid fa-star"></i>';
    }
    if (rating == 0) {
        return html + ' <span style="color:#aaa; font-size: 0.8rem;">(暫無評分)</span>';
    }

    return html + ' <span style="color:#555;">(' + rating.toFixed(1) + ')</span>';
}

function renderList(data) {
    var container = document.getElementById("productList");

    if (!data || data.length === 0) {
        container.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: white; border-radius: 15px;">
                <i class="fa-solid fa-cookie-bite" style="font-size: 4rem; color: #FFD2A6; margin-bottom: 20px;"></i>
                <h3 style="color: #5C4033;">喔喔！找不到相關商品</h3>
                <p style="color: #888; margin-bottom: 20px;">試試看其他關鍵字，或是看看我們的熱門推薦。</p>
                <button onclick="location.href='allgoods.html'" class="btn">查看所有商品</button>
            </div>
        `;
        return;
    }

    container.innerHTML = data.map(function(p) {
        var rating = calculateAvgRating(p.id);
        return '' +
            '<div class="card product-card" onclick="location.href=\'goods.html?id='+p.id+'\'">' +
                '<img class="img-placeholder" src="assets/images/' + p.img + '"></img>' +
                '<h4>' + p.name + '</h4>' +
                '<p style="color:#FF7F50; font-weight:bold;">$' + p.price + '</p>' +
                '<div class="rating-stars">' + renderStars(rating) + '</div>' +
            '</div>';
    }).join("");
}

document.addEventListener('click', function(e) {
    var box = document.getElementById('searchSuggestions');
    var input = document.getElementById('globalSearch');
    if (!box || !input) return;

    if (e.target !== box && e.target !== input) {
        box.style.display = 'none';
    }
});

function handleEnter(e) { if(e.key === 'Enter') siteSearch(); }
function siteSearch() {
    var input = document.getElementById('globalSearch');
    if (!input) return;
    var val = input.value.trim();
    if(!val) return;
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.includes(val); });
        if(matches.length === 0) alert("沒有搜尋到相關商品！");
        else location.href = "allgoods.html?search=" + encodeURIComponent(val);
    });
}

function handleSearchInput(input) {
    var val = input.value.toLowerCase();
    var box = document.getElementById('searchSuggestions');
    if (!box) return;
    if(val.length < 1) { box.style.display = 'none'; return; }
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.toLowerCase().includes(val); });
        if(matches.length > 0) {
            box.innerHTML = matches.map(function(p){ return '<div onclick="location.href=\'goods.html?id='+p.id+'\'">'+p.name+'</div>'; }).join('');
            box.style.display = 'block';
        } else { box.style.display = 'none'; }
    });
}

function handleEnterFilter(e) { if(e.key === 'Enter') filterProducts(); }

function filterProducts() {
    var key = document.getElementById("midSearch").value.toLowerCase();
    var cat = document.getElementById("midCategory").value;
    
    var filtered = allData.filter(function(p){ 
        var matchKey = p.name.toLowerCase().includes(key);
        var matchCat = (cat === "all" || p.category === cat);
        return matchKey && matchCat;
    });
    
    document.querySelector('h2').innerText = (key || cat !== "all") ? "篩選結果" : "全部商品";
    renderList(filtered);
}
