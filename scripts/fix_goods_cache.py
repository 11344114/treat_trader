import sys
filepath = r"c:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\ROOT\treat_trader\goods.jsp"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("src=\"assets/js/goods.js\"", "src=\"assets/js/goods.js?v=2\"")

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)
