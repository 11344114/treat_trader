const API_BASE = "http://localhost:5038/api";

window.onload = function () {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (user) document.getElementById('avatarLink').href = "member.html";
};

function handleRegister(e) {
    e.preventDefault();

    var name = document.getElementById('regName').value.trim();
    var phone = document.getElementById('regPhone').value.trim();
    var email = document.getElementById('regEmail').value.trim();
    var pwd = document.getElementById('regPwd').value;

    if (!name || !email || !pwd) {
        alert("請完整填寫必填欄位");
        return;
    }

    fetch(API_BASE + "/Auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            name: name,
            email: email,
            password: pwd,
            phone: phone,
            address: null
        })
    })
    .then(function (res) {
        if (!res.ok) return res.json().then(function (err) { throw err; });
        return res.json();
    })
    .then(function (user) {
        localStorage.setItem("tt_currentUser", JSON.stringify(user));
        alert("註冊成功！");
        location.href = "member.html";
    })
    .catch(function (err) {
        alert(err.message || "註冊失敗");
    });
}

function handleLogin(e) {
    e.preventDefault();

    var email = document.getElementById('loginEmail').value.trim();
    var pwd = document.getElementById('loginPwd').value;

    if (!email || !pwd) {
        alert("請輸入帳號與密碼");
        return;
    }

    fetch(API_BASE + "/Auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            email: email,
            password: pwd
        })
    })
    .then(function (res) {
        if (!res.ok) return res.json().then(function (err) { throw err; });
        return res.json();
    })
    .then(function (user) {
        localStorage.setItem("tt_currentUser", JSON.stringify(user));
        alert("登入成功！");
        location.href = "member.html";
    })
    .catch(function (err) {
        alert(err.message || "登入失敗，請確認帳號密碼");
    });
}

function showForgetModal() { document.getElementById('forgetModal').style.display = 'flex'; }
function closeForgetModal() { document.getElementById('forgetModal').style.display = 'none'; }

function confirmForget() {
    var email = document.getElementById('forgetEmail').value;
    var phone = document.getElementById('forgetPhone').value;
    if (!email || !phone) { alert("請填寫所有欄位！"); return; }
    alert("這是 demo 網站，請聯絡客服重設密碼 : )");
    closeForgetModal();
}
