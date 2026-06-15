window.onload = function() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if(user) document.getElementById('avatarLink').href = "member.jsp";

    // 幫助中心表單處理：若登入則自動填入隱藏 userId 與 email；若未登入也允許提交
    var form = document.getElementById('helpForm');
    if (form) {
        form.addEventListener('submit', function(e){
            var user = JSON.parse(localStorage.getItem('tt_currentUser'));
            var hid = document.getElementById('help_center_userId');
            var emailInput = document.getElementById('help_email');
            var nameInput = document.getElementById('help_name');
            if (user && hid) hid.value = user.id;
            if (user && emailInput && user.email) emailInput.value = user.email;
            // 不阻擋提交，讓未登入者也能送出表單
        });
    }
};

function handleEnter(e) { if(e.key === 'Enter') siteSearch(); }

function siteSearch() {
    var val = document.getElementById('globalSearch').value.trim();
    if(!val) return;
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.includes(val); });
        if(matches.length === 0) alert("沒有搜尋到相關商品！");
        else location.href = "allgoods.jsp?keyword=" + encodeURIComponent(val);
    });
}

function handleSearchInput(input) {
    var val = input.value.toLowerCase();
    var box = document.getElementById('searchSuggestions');
    if(val.length < 1) { box.style.display = 'none'; return; }
    fetch('products.json').then(function(r){ return r.json() }).then(function(data){
        var matches = data.filter(function(p){ return p.name.toLowerCase().includes(val); });
        if(matches.length > 0) {
            box.innerHTML = matches.map(function(p){ return '<div onclick="location.href=\'goods.jsp?id='+p.id+'\'">'+p.name+'</div>'; }).join('');
            box.style.display = 'block';
        } else { box.style.display = 'none'; }
    });
}
