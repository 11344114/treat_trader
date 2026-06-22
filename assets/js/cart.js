var map;

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

// 支援 user-specific 與 fallback 的 cart key
function getCartKey() {
    try {
        var user = JSON.parse(localStorage.getItem('tt_currentUser'));
        return user && user.id ? 'tt_cart_user_' + user.id : 'tt_cart';
    } catch (e) {
        return 'tt_cart';
    }
}

function getCart() {
    var key = getCartKey();
    var cart = JSON.parse(localStorage.getItem(key) || '[]');
    if (!cart.length) {
        // fallback to legacy key
        try {
            var fb = JSON.parse(localStorage.getItem('tt_cart') || '[]');
            if (fb.length) {
                cart = fb;
                localStorage.setItem(key, JSON.stringify(cart));
            }
        } catch (e) { /* ignore */ }
    }
    return cart;
}

function saveCart(cart) {
    var key = getCartKey();
    localStorage.setItem(key, JSON.stringify(cart));
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
        // 容錯：接受不同屬性名稱並確保數值
        var name = item.name || item.pName || item.title || '未知商品';
        var price = Number(item.price || item.pPrice || item.unitPrice || 0) || 0;
        var qty = Number(item.qty) || 1;
        var subtotal = price * qty;
        total += subtotal;
        html += '<div class="cart-item">' +
                '<div class="delete-btn" onclick="removeItem('+index+')">×</div>' +
                '<div class="item-details">' +
                    '<h4 class="p-name">'+escapeHtml(name)+'</h4>' +
                    '<div class="qty-control">' +
                        '<button onclick="updateQty('+index+', -1)">-</button>' +
                        '<span class="qty-val">'+qty+'</span>' +
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
}
    cart.forEach(function(item){
        var name = item.name || item.pName || item.title || '未知商品';
        var price = Number(item.price || item.pPrice || item.unitPrice || 0) || 0;
        var qty = Number(item.qty) || 1;
        var sub = price * qty;
        total += sub;
        var row = document.createElement('div');
        row.style.display = 'flex';
        row.style.justifyContent = 'space-between';
        row.innerHTML = '<span>' + escapeHtml(name) + ' (x' + qty + ')</span><span>$' + sub + '</span>';
        list.appendChild(row);
    });
    var shipping = total > 2500 ? 0 : 60;
    document.getElementById('shippingFeeDisplay').innerText = shipping === 0 ? "免運費" : "$60";
    document.getElementById('checkoutTotal').innerText = '$' + (total + shipping);
}

// 這裡我們把結帳改成直接提交表單，而不是 fetch，並在提交前驗證必填欄位
function submitOrder() {
    // 驗證結帳欄位
    var recvName = (document.getElementById('recvName') || {}).value || '';
    var recvPhone = (document.getElementById('recvPhone') || {}).value || '';
    var recvEmail = (document.getElementById('recvEmail') || {}).value || '';
    var payMethod = (document.getElementById('payMethodValue') || {}).value || '';
    var payInput = (document.getElementById('payInputField') || {}).value || '';
    var shipMethod = (document.getElementById('shipMethodValue') || {}).value || '';
    var shipAddr = (document.getElementById('shipAddressField') || {}).value || '';
    var storeName = (document.getElementById('storeNameInput') || {}).value || '';
    var invInput = (document.getElementById('invInput') || {}).value || '';

    if (!recvName.trim() || !recvPhone.trim() || !recvEmail.trim()) {
        alert('請完整填寫收件資訊（姓名/電話/Email）');
        return;
    }
    if (!payMethod) {
        alert('請選擇付款方式');
        return;
    }
    if (payMethod !== 'epay' && !payInput.trim()) {
        alert('請輸入付款相關資訊（信用卡號或轉帳後五碼）');
        return;
    }
    if (!shipMethod) {
        alert('請選擇收貨方式');
        return;
    }
    if (shipMethod === 'delivery' && !shipAddr.trim()) {
        alert('請輸入宅配地址');
        return;
    }
    if (shipMethod === 'store' && !storeName.trim()) {
        alert('請選擇或輸入取貨門市');
        return;
    }
    if (!invInput.trim()) {
        alert('請輸入發票資料（載具/統編/捐贈碼）');
        return;
    }

    alert("訂單已提交！系統會將訂單記錄在您的歷史訂單紀錄中。");
    // 建立本地訂單紀錄（localStorage: tt_orders / tt_latestOrder）
    try {
        var cart = getCart();
        if (!cart || cart.length === 0) {
            alert('購物車為空，無法建立訂單');
            return;
        }
        var total = 0;
        cart.forEach(function(i){ total += (Number(i.price || i.pPrice || i.unitPrice || 0) * (Number(i.qty) || 1)); });
        var shipping = total > 2500 ? 0 : 60;
        var grandTotal = total + shipping;

        var user = JSON.parse(localStorage.getItem('tt_currentUser') || 'null');
        var orderId = 'L' + Date.now();
        var now = new Date();

        var orderObj = {
            orderId: orderId,
            userId: user && user.id ? user.id : null,
            userEmail: user && user.email ? user.email : null,
            orderDate: now.toISOString(),
            items: cart,
            subtotal: total,
            shipping: shipping,
            total: grandTotal,
            payment: payMethod,
            status: '處理中',
            statusText: '處理中',
            progressPercent: 10,
            desc: '此訂單為本地儲存的測試訂單'
        };

        var raw = localStorage.getItem('tt_orders');
        var arr = [];
        try { arr = JSON.parse(raw) || []; } catch(e){ arr = []; }
        arr.push(orderObj);
        localStorage.setItem('tt_orders', JSON.stringify(arr));
        localStorage.setItem('tt_latestOrder', JSON.stringify(orderObj));

    } catch(e) { console.error('建立本地訂單失敗', e); }

    // 清空購物車並導向會員中心
    saveCart([]);
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