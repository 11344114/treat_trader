# scripts

此資料夾放置專案的維護/修補腳本（一次性或重複使用）。

包含：

- `fix_goods.py` - 修改 `goods.jsp`，將 AJAX 減庫存伺服端片段加入 JSP。
- `fix_goods2.py` - 將 `goods.jsp` 中部分 alert/redirect 轉成使用 `fetch` 的前端請求。
- `fix_goods_cache.py` - 在 `goods.jsp` 中為 `assets/js/goods.js` 加上版本參數以避免快取問題。
- `fix_goods_js.py` - 修改 `assets/js/goods.js` 中的 `addToCart` 函式，使其利用 `fetch` 呼叫後端減庫存並處理回傳結果。

- `insert_default_reviews.sql` - SQL 程式，用於在資料庫中建立系統帳號與系統訂單，並為每個 `products.productId` 新增一筆「官方預設評論」。此檔僅在初始化或重建測試/示範資料時需要執行。

建議：

- 若這些修改已經寫入專案並透過版本控制，建議將腳本保留於此資料夾作為參考或備份。
- 若你需要在其他環境重複套用，請先確認腳本中路徑是否符合目標環境，或改為更通用的參數化腳本。
