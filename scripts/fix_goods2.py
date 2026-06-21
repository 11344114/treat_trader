import sys
filepath = r"c:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\ROOT\treat_trader\goods.jsp"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

a = "alert('商品已成功加入購物車！');"
b = "fetch('goods.jsp?action=decreaseInventory&id=<%= pidInt %>').then(r=>r.json()).then(d=>{if(d.success){alert('商品已成功加入購物車！');location.reload();}else{alert(d.message);}}).catch(e=>alert(e));"

content = content.replace(a, b)

c = "window.location.href = 'cart.jsp';"
d = "fetch('goods.jsp?action=decreaseInventory&id=<%= pidInt %>').then(r=>r.json()).then(d=>{if(d.success){window.location.href = 'cart.jsp';}else{alert(d.message);}}).catch(e=>alert(e));"

content = content.replace(c, d)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)
