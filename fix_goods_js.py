import sys
filepath = r"c:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\ROOT\treat_trader\assets\js\goods.js"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

import re
old_pattern = r"function addToCart\(goCheckout\).*?alert\(\"已加入購物車！\"\);\s*\n\s*\}\s*\n\}"
new_func = """function addToCart(goCheckout) {
    var user = JSON.parse(localStorage.getItem('tt_currentUser'));
    if (!user) {
        alert("請先登入會員後再進行購物！");
        location.href = "login.jsp";
        return;
    }
    if (!currentProduct) return;

    fetch('goods.jsp?action=decreaseInventory&id=' + pid)
    .then(r => r.json())
    .then(data => {
        if(data.success) {
            var cart = getCart();
            var item = cart.find(function (i) { return i.id == pid; });
            if (item) item.qty++;
            else cart.push({ id: pid, qty: 1, name: currentProduct.name, price: currentProduct.price, img: currentProduct.img });

            saveCart(cart);
            if (goCheckout) {
                location.href = 'cart.jsp';
            } else {
                alert("已加入購物車！");
                location.reload();
            }
        } else {
            alert("無法加入購物車：" + (data.message || "庫存不足"));
        }
    })
    .catch(e => alert("系統錯誤，請稍後再試"));
}"""

content = re.sub(old_pattern, new_func, content, flags=re.DOTALL)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)
