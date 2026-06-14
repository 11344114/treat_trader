const API_BASE = "http://localhost:5038/api";

var urlParams = new URLSearchParams(window.location.search);
var pid = urlParams.get('id') || '1';
var currentProduct = null;
var currentRating = 5;

var currentPage = 1;
var reviewsPerPage = 2;

window.onload = function () {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (user) {
        var avatar = document.getElementById('avatarLink');
        if (avatar) avatar.href = "member.html";
    } else {
        var reviewInput = document.getElementById('userReview');
        var submitBtn = document.getElementById('submitReviewBtn');
        if (reviewInput) {
            reviewInput.disabled = true;
            reviewInput.placeholder = "請先登入會員以撰寫評論";
        }
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.innerText = "請先登入";
        }
        var starCont = document.getElementById('starContainer');
        if (starCont) {
            starCont.style.pointerEvents = 'none';
            starCont.style.opacity = '0.5';
        }
    }

    setRating(5);

    fetch('products.json')
        .then(function (res) { return res.json(); })
        .then(function (data) {
            currentProduct = data.find(function (p) { return p.id == pid; });
            if (currentProduct) {
                document.getElementById('pName').innerText = currentProduct.name;
                document.getElementById('pPrice').innerText = '$' + currentProduct.price;
                document.getElementById('pDesc').innerText = currentProduct.desc;
                document.getElementById('pNut').innerText = currentProduct.nutrition;

                var imgContainer = document.getElementById('pImg');
                var imagePath = "assets/images/" + currentProduct.img;
                var imgHtml = '<img src="' + imagePath + '" alt="' + currentProduct.name + '" style="width:100%; height:100%; object-fit:cover; border-radius:10px;">';
                imgContainer.innerHTML = imgHtml;
                imgContainer.style.background = "none";

                loadReviews();
                loadRecs(data);
            }
        });
};

function loadRecs(all) {
    var recs = all.filter(function (p) { return p.id != pid; }).slice(0, 4);
    var recList = document.getElementById("recList");
    if (!recList) return;

    recList.innerHTML = recs.map(function (p) {
        var recImgPath = "assets/images/" + p.img;
        return '' +
            '<div class="card" style="text-align:center; cursor:pointer;" onclick="location.href=\'goods.html?id=' + p.id + '\'">' +
                '<div style="height:150px; margin-bottom:10px; overflow:hidden; border-radius:10px; background:#f9f9f9;">' +
                    '<img src="' + recImgPath + '" style="width:100%; height:100%; object-fit:cover;" onerror="this.style.display=\'none\'">' +
                '</div>' +
                '<h4>' + p.name + '</h4>' +
                '<p style="color:#FF7F50; font-weight:bold;">$' + p.price + '</p>' +
            '</div>';
    }).join('');
}

function getCartKey() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    return user ? 'tt_cart_user_' + user.id : 'tt_cart';
}

function getCart() {
    var cart = JSON.parse(localStorage.getItem(getCartKey()) || '[]');
    if (!cart.length) {
        var fallback = JSON.parse(localStorage.getItem('tt_cart') || '[]');
        if (fallback.length) {
            cart = fallback;
            localStorage.setItem(getCartKey(), JSON.stringify(cart));
        }
    }
    return cart;
}

function saveCart(cart) {
    localStorage.setItem(getCartKey(), JSON.stringify(cart));
}

function addToCart(goCheckout) {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (!user) {
        alert("請先登入會員後再進行購物！");
        location.href = "login.html";
        return;
    }
    if (!currentProduct) return;

    var cart = getCart();
    var item = cart.find(function (i) { return i.id == pid; });
    if (item) item.qty++;
    else cart.push({ id: pid, qty: 1, name: currentProduct.name, price: currentProduct.price });

    saveCart(cart);
    if (goCheckout) location.href = 'cart.html';
    else alert("已加入購物車！");
}

function setRating(val) {
    currentRating = val;
    var starContainer = document.getElementById('starContainer');
    if (!starContainer) return;

    var stars = starContainer.children;
    for (var i = 0; i < stars.length; i++) {
        if (i < val) stars[i].classList.add('active');
        else stars[i].classList.remove('active');
    }
}

function getFakeReviewsForProduct() {
    return [
        { userName: "柳葉瑜", rating: 5, date: "2025/12/20", content: "出貨速度超級快，包裝也很完整！下次一定會再回購，大推！" },
        { userName: "陳淑美", rating: 4, date: "2026/01/01", content: "整體來說很滿意，但是物流稍微慢了一點點，扣一顆星。食物本身沒問題，很好粗。" },
        { userName: "丁希望", rating: 5, date: "2025/12/25", content: "這是我最喜歡的零食，台灣能買到真的太好了。客服人員也非常親切有耐心。" },
        { userName: "潔西卡比獸", rating: 3, date: "2025/01/10", content: "跟圖片實物有點誤差，不過還可以接受。" },
        { userName: "強哥", rating: 5, date: "2026/01/05", content: "幫家人買的，他們都很喜歡吃。" }
    ];
}

function updateProductRatingFromReviews(reviews) {
    var display = document.getElementById('pRatingDisplay');
    if (!display) return;

    reviews = reviews || [];
    if (reviews.length === 0) {
        display.innerHTML = '暫無評分';
        return;
    }

    var sum = 0;
    var count = 0;

    reviews.forEach(function (r) {
        var rating = Number(r.rating);
        if (!isNaN(rating) && rating > 0) {
            sum += rating;
            count++;
        }
    });

    if (count === 0) {
        display.innerHTML = '暫無評分';
        return;
    }

    var avg = (sum / count).toFixed(1);
    var rounded = Math.round(avg);

    var stars = '';
    for (var i = 1; i <= 5; i++) {
        stars += (i <= rounded) ? '★' : '☆';
    }

    display.innerHTML = stars + ' (' + avg + ')';
}

function loadReviews() {
    fetch(API_BASE + "/Reviews/product/" + pid + "?page=1&pageSize=9999")
        .then(function (res) { return res.json(); })
        .then(function (data) {
            var realReviews = data.items || [];
            var allReviews = getFakeReviewsForProduct().concat(realReviews);

            updateProductRatingFromReviews(allReviews);

            allReviews.sort(function (a, b) {
                var da = new Date(a.date);
                var db = new Date(b.date);
                return db - da;
            });

            var totalPages = Math.ceil(allReviews.length / reviewsPerPage);
            if (totalPages === 0) totalPages = 1;
            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            var start = (currentPage - 1) * reviewsPerPage;
            var end = start + reviewsPerPage;
            var pageReviews = allReviews.slice(start, end);

            var container = document.getElementById('commentList');
            if (!container) return;

            if (pageReviews.length === 0) {
                container.innerHTML = '<p style="padding:10px;">目前尚無評論，快來當第一個評論的人！</p>';
            } else {
                container.innerHTML = pageReviews.map(function (r) {
                    var stars = '';
                    var rating = r.rating || 0;
                    for (var i = 0; i < 5; i++) {
                        var cls = (i < rating) ? 'filled' : 'empty';
                        stars += '<span class="review-star ' + cls + '">★</span>';
                    }
                    return '' +
                        '<div class="review-card">' +
                            '<div class="review-header">' +
                                '<span class="review-user">' + (r.userName || '匿名') + '</span>' +
                                '<span class="review-date">' + (r.date || '') + '</span>' +
                            '</div>' +
                            '<div class="review-rating">' + stars + '</div>' +
                            '<div class="review-content">' + (r.content || '') + '</div>' +
                        '</div>';
                }).join('');
            }

            renderPagination(totalPages);
        })
        .catch(function (err) {
            console.error("讀取評論失敗", err);
        });
}

function renderPagination(totalPages) {
    var container = document.querySelector('.pagination');
    if (!container) return;

    if (!totalPages || totalPages <= 1) {
        container.innerHTML = "";
        return;
    }

    var html = "";

    if (currentPage > 1) {
        html += '<div class="page-num" onclick="changePage(' + (currentPage - 1) + ')">&lt;</div>';
    }

    for (var i = 1; i <= totalPages; i++) {
        var activeClass = (i === currentPage) ? "active" : "";
        html += '<div class="page-num ' + activeClass + '" onclick="changePage(' + i + ')">' + i + '</div>';
    }

    if (currentPage < totalPages) {
        html += '<div class="page-num" onclick="changePage(' + (currentPage + 1) + ')">&gt;</div>';
    }

    container.innerHTML = html;
}

function changePage(page) {
    currentPage = page;
    loadReviews();
}

function submitReview() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (!user) {
        alert("請先登入會員再評論！");
        location.href = "login.html";
        return;
    }

    var contentInput = document.getElementById('userReview');
    if (!contentInput) return;

    var content = contentInput.value.trim();
    if (!content) {
        alert("請輸入評論內容");
        return;
    }

    fetch(API_BASE + "/Reviews", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            productId: parseInt(pid),
            userId: user.id,
            userName: user.name,
            rating: currentRating,
            content: content
        })
    })
    .then(function (res) {
        if (!res.ok) return res.json().then(function (err) { throw err; });
        return res.json();
    })
    .then(function () {
        alert("評論已送出！");
        contentInput.value = "";
        currentPage = 1;
        loadReviews();
    })
    .catch(function (err) {
        alert(err.message || "評論送出失敗");
        console.error(err);
    });
}

function switchTab(e, id) {
    var tabs = document.querySelectorAll('.tab-btn');
    var contents = document.querySelectorAll('.tab-content');
    for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('active');
    for (var j = 0; j < contents.length; j++) contents[j].classList.remove('active');
    e.currentTarget.classList.add('active');
    document.getElementById(id).classList.add('active');
}

function handleEnter(e) {
    if (e.key === 'Enter') siteSearch();
}

function siteSearch() {
    var input = document.getElementById('globalSearch');
    if (!input) return;

    var val = input.value.trim();
    if (!val) return;

    fetch('products.json')
        .then(function (r) { return r.json(); })
        .then(function (data) {
            var matches = data.filter(function (p) { return p.name.includes(val); });
            if (matches.length === 0) alert("沒有搜尋到相關商品！");
            else location.href = "allgoods.html?search=" + encodeURIComponent(val);
        });
}

function handleSearchInput(input) {
    var val = input.value.toLowerCase();
    var box = document.getElementById('searchSuggestions');
    if (!box) return;

    if (val.length < 1) {
        box.style.display = 'none';
        return;
    }

    fetch('products.json')
        .then(function (r) { return r.json(); })
        .then(function (data) {
            var matches = data.filter(function (p) {
                return p.name.toLowerCase().includes(val);
            });
            if (matches.length > 0) {
                box.innerHTML = matches.map(function (p) {
                    return '<div onclick="location.href=\'goods.html?id=' + p.id + '\'">' + p.name + '</div>';
                }).join('');
                box.style.display = 'block';
            } else {
                box.style.display = 'none';
            }
        });
}
