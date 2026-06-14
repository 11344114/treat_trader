var map;

function getCartKey() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    return user ? 'tt_cart_user_' + user.id : 'tt_cart';
}

function getCart() {
    var key = getCartKey();
    var cart = JSON.parse(localStorage.getItem(key) || '[]');
    if (!cart.length && key !== 'tt_cart') {
        var fallback = JSON.parse(localStorage.getItem('tt_cart') || '[]');
        if (fallback.length) {
            cart = fallback;
            localStorage.setItem(key, JSON.stringify(cart));
        }
    }
    return cart;
}

function saveCart(cart) {
    localStorage.setItem(getCartKey(), JSON.stringify(cart));
}

window.onload = function() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    
    if(!user) {
        alert("請先登入會員！");
        location.href = "login.html";
        return;
    } else {
        document.getElementById('avatarLink').href = "member.html";
    }
    
    renderCart();
    initMap();
};

function selectStore(name, lat, lng) {
    document.getElementById('storeNameInput').value = name;
    if(map && lat && lng) {
        map.setView([lat, lng], 18);
        L.popup()
            .setLatLng([lat, lng])
            .setContent(name)
            .openOn(map);
    }
}

function selectOption(groupId, btn, value) {
    var group = document.getElementById(groupId);
    var btns = group.querySelectorAll('.select-btn');
    btns.forEach(function(b) { b.classList.remove('active'); });
    
    btn.classList.add('active');
    
    if (groupId === 'payGroup') {
        document.getElementById('payMethodValue').value = value;
        var inputDiv = document.getElementById('payInput');
        var qrDiv = document.getElementById('payQR');
        
        if(value === 'epay') {
            inputDiv.classList.remove('show');
            qrDiv.classList.add('show');
        } else {
            inputDiv.classList.add('show');
            qrDiv.classList.remove('show');
        }
    } else if (groupId === 'shipGroup') {
        document.getElementById('shipMethodValue').value = value;
        var addrDiv = document.getElementById('shipAddress');
        var mapDiv = document.getElementById('shipMap');
        
        if(value === 'store') {
            addrDiv.classList.remove('show');
            mapDiv.classList.add('show');
            
            setTimeout(function(){
                if(map) {
                    map.invalidateSize();
                    map.setView([24.957, 121.240], 16);
                }
            }, 200);
        } else {
            addrDiv.classList.add('show');
            mapDiv.classList.remove('show');
        }
    }
}

function initMap() {
    var cycu = [24.957, 121.240];
    
    try {
        map = L.map('googleMap').setView(cycu, 16);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        var stores = [
            { name: "7-ELEVEN 中原門市", loc: [24.9575, 121.241] },
            { name: "全家便利商店 中原門市", loc: [24.9565, 121.239] },
            { name: "萊爾富 中壢中原店", loc: [24.958, 121.238] }
        ];

        stores.forEach(function(store) {
            var marker = L.marker(store.loc).addTo(map);
            marker.bindPopup(store.name);

            marker.on('click', function() {
                document.getElementById("storeNameInput").value = store.name;
            });
        });
    } catch (e) {
        console.log("Map init failed: ", e);
    }
}

function renderCart() {
    var cart = getCart();
    var container = document.getElementById('cartItems');
    var total = 0;

    if(cart.length === 0) {
        container.innerHTML = '<p style="text-align:center; padding:20px; color:#888;">購物車是空的，快去選購吧！</p>';
        document.getElementById('cartTotal').innerText = '$0';
        document.getElementById('toCheckoutBtn').style.display = 'none';
        return;
    }

    document.getElementById('toCheckoutBtn').style.display = 'block';
    var html = "";
    
    cart.forEach(function(item, index) {
        var subtotal = item.price * item.qty;
        total += subtotal;
        html += '<div class="cart-item">' +
                '<div class="delete-btn" onclick="removeItem('+index+')">×</div>' +
                '<div class="item-details">' +
                    '<h4 class="p-name">'+item.name+'</h4>' +
                    '<div class="qty-control">' +
                        '<button onclick="updateQty('+index+', -1)">-</button>' +
                        '<span class="qty-val">'+item.qty+'</span>' +
                        '<button onclick="updateQty('+index+', 1)">+</button>' +
                    '</div>' +
                '</div>' +
                '<div class="item-price" style="margin-left: auto; font-weight: bold;">$'+subtotal+'</div>' +
                '</div>';
    });
    
    container.innerHTML = html;
    document.getElementById('cartTotal').innerText = '$' + total;
}

function updateQty(idx, change) {
    var cart = getCart();
    if(cart[idx].qty + change >= 1) {
        cart[idx].qty += change;
        saveCart(cart);
        renderCart();
    }
}

function removeItem(idx) {
    var cart = getCart();
    cart.splice(idx, 1);
    saveCart(cart);
    renderCart();
}

function toggleCheckout(show) {
    var cartCol = document.getElementById('cartListContainer');
    var checkCol = document.getElementById('checkoutContainer');
    var btn = document.getElementById('toCheckoutBtn');
    var cartItems = getCart();

    if(show) {
        if(cartItems.length === 0) return;
        
        var user = JSON.parse(localStorage.getItem('tt_currentUser'));
        if(user) {
            if(document.getElementById('recvName')) document.getElementById('recvName').value = user.name || "";
            if(document.getElementById('recvPhone')) document.getElementById('recvPhone').value = user.phone || "";
            if(document.getElementById('recvEmail')) document.getElementById('recvEmail').value = user.email || "";
        }

        updateCheckoutList(cartItems);
        cartCol.classList.add('locked');
        checkCol.classList.add('active');
        btn.innerText = "回到購物車";
        btn.classList.add('back');
        btn.onclick = function() { toggleCheckout(false); };
    } else {
        cartCol.classList.remove('locked');
        checkCol.classList.remove('active');
        btn.innerText = "前往結帳";
        btn.classList.remove('back');
        btn.onclick = function() { toggleCheckout(true); };
    }
}

function updateCheckoutList(cart) {
    var list = document.getElementById('checkoutItemsList');
    var total = 0;
    list.innerHTML = '';
    
    cart.forEach(function(item){
        var sub = item.price * item.qty;
        total += sub;
        var row = document.createElement('div');
        row.style.display = 'flex';
        row.style.justifyContent = 'space-between';
        row.style.marginBottom = '5px';
        row.innerHTML = '<span>' + item.name + ' (x' + item.qty + ')</span><span>$' + sub + '</span>';
        list.appendChild(row);
    });
    
    var shipping = 60;
    var shippingText = "$60";
    if (total > 2500) {
        shipping = 0;
        shippingText = "免運費";
    }
    
    document.getElementById('shippingFeeDisplay').innerText = shippingText;
    document.getElementById('checkoutTotal').innerText = '$' + (total + shipping);
}

function submitOrder() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if(!user) {
        alert("請先登入會員！");
        location.href = "login.html";
        return;
    }
    
    var checkoutContainer = document.getElementById('checkoutContainer');
    var inputs = checkoutContainer.querySelectorAll('input');
    var allFilled = true;
    
    for(var i=0; i<inputs.length; i++) {
        if(inputs[i].type !== 'hidden' && inputs[i].offsetParent !== null) {
            if(inputs[i].value.trim() === "") {
                allFilled = false;
                inputs[i].style.borderColor = "red";
            } else {
                inputs[i].style.borderColor = "#ddd";
            }
        }
    }

    var shipMethod = document.getElementById('shipMethodValue').value;
    if (shipMethod === 'store') {
        var storeInput = document.getElementById('storeNameInput');
        if (!storeInput || storeInput.value.trim() === '') {
            allFilled = false;
            if (storeInput) storeInput.style.borderColor = 'red';
        }
    }
    
    if(!allFilled) {
        alert("請確認所有欄位都已填寫完畢！");
        return;
    }

    var cart = JSON.parse(localStorage.getItem('tt_cart') || "[]");
    if (cart.length > 0) {
        var total = 0;
        cart.forEach(function(item) {
            total += item.price * item.qty;
        });

        var shipping = total > 2500 ? 0 : 60;

        var now = new Date();
        var y = now.getFullYear();
        var m = String(now.getMonth() + 1).padStart(2, '0');
        var d = String(now.getDate()).padStart(2, '0');
        var hh = String(now.getHours()).padStart(2, '0');
        var mm = String(now.getMinutes()).padStart(2, '0');
        var ss = String(now.getSeconds()).padStart(2, '0');
        var orderId = y + m + d + hh + mm + ss;

        var firstProductName = cart[0].name;
        var productName;
        if (cart.length === 1) {
            productName = firstProductName;
        } else {
            productName = firstProductName + " 等 " + cart.length + " 項商品";
        }

        var latestOrder = {
            userId: user.id,
            orderId: orderId,
            productName: productName,
            statusText: '出貨中',
            progressPercent: 60,
            desc: '商品準備中'
        };

        var orders = JSON.parse(localStorage.getItem('tt_orders') || '[]');
        orders.push(latestOrder);
        localStorage.setItem('tt_orders', JSON.stringify(orders));
        localStorage.setItem('tt_latestOrder', JSON.stringify(latestOrder));
    }
    
    alert('訂單已送出！感謝您的購買。');
    saveCart([]);
    window.location.href = 'member.html';
}

function handleEnter(e) { if(e.key === 'Enter') siteSearch(); }

function siteSearch() {
    var val = document.getElementById('globalSearch').value.trim();
    if(!val) return;
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.includes(val); });
        if(matches.length === 0) {
            alert("沒有搜尋到相關商品！");
        } else {
            location.href = "allgoods.html?search=" + encodeURIComponent(val);
        }
    });
}

function handleSearchInput(input) {
    var val = input.value.toLowerCase();
    var box = document.getElementById('searchSuggestions');
    if(val.length < 1) { box.style.display = 'none'; return; }
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.toLowerCase().includes(val); });
        if(matches.length > 0) {
            box.innerHTML = matches.map(function(p){ return '<div onclick="location.href=\'goods.html?id='+p.id+'\'">'+p.name+'</div>'; }).join('');
            box.style.display = 'block';
        } else { box.style.display = 'none'; }
    });
}
