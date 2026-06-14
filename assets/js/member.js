const API_BASE = "http://localhost:5038/api";

window.onload = function() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (!user) {
        alert("請先登入！");
        window.location.href = 'login.html';
    } else {
        document.getElementById('mName').innerText = user.name;
        document.getElementById('mEmail').innerText = user.email;
        document.getElementById('mPhone').innerText = user.phone || "-";
        document.getElementById('avatarLink').href = "member.html";

        loadMyReviews(user.id);
        loadOrderProgress(user.id);
    }
};

function logout() {
    localStorage.removeItem('tt_currentUser');
    alert("已登出");
    window.location.href = 'login.html';
}

function loadOrderProgress(userId) {
    var card = document.getElementById('orderProgressCard');
    var content = document.getElementById('orderProgressContent');
    if (!card || !content) return;

    var orders = [];
    var rawOrders = localStorage.getItem('tt_orders');
    if (rawOrders) {
        try {
            orders = JSON.parse(rawOrders) || [];
        } catch (e) {
            orders = [];
        }
    }

    if (!orders || orders.length === 0) {
        var rawLatest = localStorage.getItem('tt_latestOrder');
        if (rawLatest) {
            try {
                var latestOrder = JSON.parse(rawLatest);
                if (latestOrder && latestOrder.userId === userId) {
                    orders = [latestOrder];
                }
            } catch (e) {
                orders = [];
            }
        }
    }

    orders = orders.filter(function(order) {
        return order && order.userId === userId;
    });

    orders.sort(function(a, b) {
        return b.orderId.localeCompare(a.orderId);
    });

    if (!orders || orders.length === 0) {
        return;
    }

    card.style.display = 'block';

    content.innerHTML = orders.map(function(order) {
        var orderId = order.orderId || '(尚未產生編號)';
        var productName = order.productName || '訂單商品';
        var statusText = order.statusText || '處理中';
        var progressPercent = order.progressPercent || 30;
        var desc = order.desc || '';

        return (
            '<div style="margin-bottom: 20px; border-bottom: 1px solid #f0e0d8; padding-bottom: 15px;">' +
                '<div class="order-item" style="display:flex; justify-content:space-between; margin-bottom:10px;">' +
                    '<span>訂單 #' + orderId + ' (' + productName + ')</span>' +
                    '<span style="color:blue; font-weight: bold;">' + statusText + '</span>' +
                '</div>' +
                '<div class="progress-container">' +
                    '<div class="progress-bar" style="width: ' + progressPercent + '%;"></div>' +
                '</div>' +
                '<p style="font-size:0.85rem; text-align:right; margin-top: 8px;">' + desc + '</p>' +
            '</div>'
        );
    }).join('');
}

function loadMyReviews(userId) {
    fetch(API_BASE + "/Reviews/user/" + userId)
        .then(function (res) { return res.json(); })
        .then(function (data) {
            var box = document.getElementById('myReviews');
            if (!box) return;

            if (!data || data.length === 0) {
                box.innerHTML = '<p>尚無評論紀錄。</p>';
                return;
            }

            box.innerHTML = data.map(function (r) {
                var stars = '';
                var rating = r.rating || 0;
                for (var i = 1; i <= 5; i++) {
                    var cls = i <= rating ? 'filled' : 'empty';
                    stars += '<span class="review-star ' + cls + '">★</span>';
                }

                var productName = r.productName || ('商品 #' + r.productId);
                return (
                    '<div class="review-card">' +
                        '<div class="review-header">' +
                            '<span class="review-user">' + productName + '</span>' +
                            '<span class="review-date">' + (r.date || '') + '</span>' +
                        '</div>' +
                        '<div class="review-rating">' + stars + '</div>' +
                        '<div class="review-content">' + (r.content || '') + '</div>' +
                    '</div>'
                );
            }).join('');
        })
        .catch(function (err) {
            console.error("載入會員評論失敗", err);
        });
}

function handleEnter(e) { if (e.key === 'Enter') siteSearch(); }
function siteSearch() {
    var input = document.getElementById('globalSearch');
    if (!input) return;

    var val = input.value.trim();
    if (!val) return;
    fetch('products.json')
        .then(function(r){ return r.json(); })
        .then(function(data){
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
    fetch('products.json')
        .then(function(r){ return r.json(); })
        .then(function(data){
            var matches = data.filter(function(p){
                return p.name.toLowerCase().includes(val);
            });
            if(matches.length > 0) {
                box.innerHTML = matches.map(function(p){
                    return '<div onclick="location.href=\'goods.html?id='+p.id+'\'">'+p.name+'</div>';
                }).join('');
                box.style.display = 'block';
            } else {
                box.style.display = 'none';
            }
        });
}
