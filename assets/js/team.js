window.onload = function() {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if(user) document.getElementById('avatarLink').href = "member.html";
};

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
