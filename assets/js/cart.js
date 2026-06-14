var map;

// 1. 簡化版的購物車存取 (不再依賴前端的 tt_currentUser)
function getCart() {
    return JSON.parse(localStorage.getItem('tt_cart') || '[]');
}

function saveCart(cart) {
    localStorage.setItem('tt_cart', JSON.stringify(cart));
}

window.onload = function() {
    renderCart();
    initMap();
};

// --- 地圖與結帳 UI 邏輯保持不變 ---
function selectStore(name, lat, lng) {
    document.getElementById('storeNameInput').value = name;
    if(map && lat && lng) {
        map.setView([lat, lng], 18);
        L.popup().setLatLng([lat, lng]).setContent(name).openOn(map);
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
            setTimeout(function(){ if(map) { map.invalidateSize(); map.setView([24.957, 121.240], 16); } }, 200);
        } else {
            addrDiv.classList.add('show');
            mapDiv.classList.remove('show');
        }
    }
}

// --- 購物車渲染 ---
function renderCart() {
    var cart = getCart();
    var container = document.getElementById('cartItems');
    var total = 0;

    if(!container) return; // 防止在其他頁面報錯

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

// 結帳介面切換
function toggleCheckout(show) {
    var cartCol = document.getElementById('cartListContainer');
    var checkCol = document.getElementById('checkoutContainer');
    var btn = document.getElementById('toCheckoutBtn');
    var cartItems = getCart();

    if(show) {
        if(cartItems.length === 0) return;
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
        row.innerHTML = '<span>' + item.name + ' (x' + item.qty + ')</span><span>$' + sub + '</span>';
        list.appendChild(row);
    });
    var shipping = total > 2500 ? 0 : 60;
    document.getElementById('shippingFeeDisplay').innerText = shipping === 0 ? "免運費" : "$60";
    document.getElementById('checkoutTotal').innerText = '$' + (total + shipping);
}

// 這裡我們把結帳改成直接提交表單，而不是 fetch
function submitOrder() {
    alert("訂單已提交！(請確保已將結帳邏輯寫入 orderAction.jsp)");
    // 這裡以後可以改成：
    // document.getElementById('yourForm').submit();
    saveCart([]); // 清空購物車
    window.location.href = 'member.jsp';
}

function initMap() {
    var cycu = [24.957, 121.240];
    try {
        map = L.map('googleMap').setView(cycu, 16);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap'
        }).addTo(map);
        // ... 地圖 marker 邏輯 ...
    } catch (e) { console.log(e); }
}