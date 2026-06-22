Treat Trader - 簡介

這是 Treat Trader 的後端與前端原始碼（JSP + 原生 JavaScript），部署於 Tomcat（webapps/ROOT/treat_trader）。下列 README 以中文說明專案結構、重要檔案行為、localStorage 規格、常見問題與未來待解決項目。

目標
- 提供商品瀏覽、購物車、本地/伺服器評論、會員系統與管理後台。

快速上手
- 將資料夾放到 Tomcat 的 `webapps/ROOT/treat_trader`。
- 啟動 Tomcat（Windows：執行 `bin\\startup.bat` 或啟用服務）。
- 瀏覽：`http://localhost:8080/treat_trader/`。

資料庫
- 使用 MySQL，資料庫名稱建議為 `treat_trader`。
- 匯入範例 schema + 測試資料：[assets/db/treat_trader.sql](assets/db/treat_trader.sql)
- 連線設定位於 `db.jsp`（請務必修改預設帳密）。

重要檔案（逐檔說明）

下列說明會列到專案中所有主要檔案（以專案根目錄與 assets、scripts、WEB-INF 為主），每一項包含用途、關鍵行為、localStorage 交互與修改注意事項。

- `index.jsp`
  - 用途：站點首頁，通常顯示熱門商品、類別入口與導覽。
  - 關鍵行為：載入前端資源、導向 `allgoods.jsp` / `goods.jsp`。
  - 修改注意：不要在此直接執行耗時 DB 查詢；以 AJAX 或分頁載入改善效能。

- `allgoods.jsp`
  - 用途：商品列表頁（可包含分頁、排序或篩選）。
  - 關鍵行為：從 `products` 撈取簡短欄位（id、name、price、img）並渲染為卡片或表格。
  - 修改注意：若添加篩選參數，需同時處理 SQL 注入風險（PreparedStatement）。

- `goods.jsp`
  - 用途：單一商品詳細頁，顯示圖片、描述、評論與加入購物車功能。
  - 關鍵行為：
    - 伺服器端會 embed serverReviews（JSON）到頁面；`assets/js/goods.js` 會載入並合併 `tt_localReviews`，以 `ts`（或 reviewedAt）排序，最新的在上。
    - `submitReview()` 支援匿名以 localStorage 儲存評論（會加上 `ts`），若登入則可能同步至伺服器（視後端實作）。
    - `addToCart()` / `buyNow()`：通常會處理 `tt_cart` 或 `tt_cart_user_{id}`，加入後應有提示（若無提示，請改寫 `assets/js/goods.js` 加入通知）。
  - 修改注意：保持 serverReviews 的欄位一致（rating, content, reviewedAt, reviewer info），並確保時間解析碼的容錯性。

- `cart.jsp`
  - 用途：購物車檢視與結帳頁。
  - 關鍵行為：
    - 顯示購物車內容（先嘗試讀 `tt_cart_user_{id}`，找不到則 fallback 至 `tt_cart`）。
    - 提供數量增減、刪除、以及結帳表單（payInputField、shipAddressField、invInput 等欄位由 JS 驗證）。
    - 使用 Leaflet 顯示地圖（如有），JS 在 `assets/js/cart.js` 中實作 `initMap()`。
  - localStorage 互動：`getCartKey()`, `getCart()`, `saveCart()` 等 helper 在 `assets/js/cart.js`。結帳會把本地 order 儲入 `tt_orders` 或 `tt_latestOrder`。
  - 修改注意：目前變更數量/刪除不會自動同步到資料庫的 `inventory`；如需同步，需在 submitOrder 時在後端扣庫存。

- `login.jsp`
  - 用途：登入、註冊與忘記密碼的 UI（包含 modal）。
  - 關鍵行為：`assets/js/login.js` 控制 modal 顯示、表單驗證與 AJAX 請求。
  - 修改注意：忘記密碼流程目前去除嚴格前端驗證以避免無法送出的問題；若要重啟驗證，應先保證後端能處理相關欄位。

- `logout.jsp`
  - 用途：終止 session（通常呼叫 session.invalidate() 並導回 `index.jsp`）。
  - 修改注意：確保清除 `tt_currentUser`（若需要）以及 server-side session。

- `member.jsp`
  - 用途：會員中心，顯示訂單、評論與使用者資料。
  - 關鍵行為：
    - 伺服器端列出該會員的訂單（若有），前端同時讀取 `tt_localReviews` 與 `tt_orders`，合併並按 `ts` 排序顯示。
    - 小改動：已移除本機匿名評論旁的「（本機匿名）」標記以使用者要求顯示一致性。
  - 修改注意：若 localStorage 中的 review schema 與 server 不一致，請以轉換函式做 mapping。

- `admin.jsp`
  - 用途：管理後台（商品 CRUD、訂單總覽）。
  - 關鍵行為：
    - 伺服器端 POST 處理 `addProduct`、`updateProduct`、`deleteProduct`（使用 PreparedStatement）。
    - 商品表單已加入 `categoryId` 下拉以避免 `products_categoryId` 為 NULL 的錯誤。
    - 前端會讀 `tt_orders` 並將 local orders 插入訂單表格，提供狀態下拉選單並將變更儲回 localStorage。
  - 修改注意：新增時會把 `adminMessage` 存入 session 並 redirect，頁面頂部會顯示 flash 訊息供除錯。

- `db.jsp`
  - 用途：建立資料庫連線（載入 MySQL driver 並建立 `conn`）。
  - 關鍵行為：在 JSP 中呼叫 `Class.forName("com.mysql.cj.jdbc.Driver")` 並使用 DriverManager 連線。
  - 修改注意：生產環境不要在檔案中放明碼帳密，應改為環境變數或外部設定檔；若連線失敗，頁面會輸出錯誤訊息以利排查。

- `help.jsp` / `question.jsp`
  - 用途：客服/問題回報頁面，允許使用者提交問題或查看回覆。`question.jsp` 與 `help.jsp` 可能在專案中功能重疊。
  - 關鍵行為：表單送出建立 help_center ticket（若後端有實作），或顯示常見問題。

- `team.jsp` / `member.jsp`（介紹頁面）
  - 用途：展示團隊資訊或會員專屬資訊（視檔案內容）。靜態頁面修改風險低。

- `assets/css/style.css`
  - 用途：站台共用樣式。
  - 修改注意：小幅度樣式調整應兼顧響應式與現有 class 名稱。

- `assets/db/treat_trader.sql`
  - 用途：資料庫 schema 與示範資料（匯入至 MySQL 以建立資料表與初始資料）。
  - 關鍵行為：定義 tables（products, orders, users, reviews, category 等）。編輯時注意 foreign key 與 NOT NULL 約束。

- `assets/images/` 
  - 用途：存放商品與 UI 圖檔；商品頁以檔名參照。
  - 修改注意：檔名需與資料庫 `img` 欄位一致，若啟用圖片上傳需執行儲存策略與安全檢查。

- `assets/js/allgoods.js`
  - 用途：若存在，負責 `allgoods.jsp` 的前端互動（過濾、分頁或按鈕事件）。

- `assets/js/cart.js`
  - 用途：購物車頁面行為（渲染 cart、更新數量、submitOrder、checkout 檢查）。
  - 關鍵函式：`getCartKey()`, `getCart()`, `saveCart()`, `renderCart()`, `updateCheckoutList()`, `submitOrder()`。
  - 注意事項：`submitOrder()` 會在 local 儲存訂單（`tt_orders` / `tt_latestOrder`），但不會自動同步 DB 庫存。

- `assets/js/goods.js`
  - 用途：商品詳情互動（載入 reviews、提交評論、計算評分、加入購物車）。
  - 關鍵行為：允許匿名評論、將本機評論寫入 `tt_localReviews`，並以 `ts` 排序顯示最新評論。

- `assets/js/help.js`, `index.js`, `login.js`, `member.js`, `question.js`, `team.js`
  - 用途：分別對應各頁面的前端互動邏輯（modal 控制、按鈕事件、AJAX、表單驗證等）。
  - 特別說明：`login.js` 的 `confirmForget()` 已改為不強制驗證 email/phone，以避免使用者無法送出忘記密碼請求。

- `scripts/`（fix_goods_cache.py, fix_goods_js.py, fix_goods.py, fix_goods2.py, insert_default_reviews.sql, README.md）
  - 用途：輔助開發或資料修正的腳本。通常用來從 CSV/DB 生成商品 JS 或修正快取檔案。
  - 使用注意：修改腳本前先備份相對應的資源檔案（images、assets/js）。

- `WEB-INF/lib/`
  - 用途：放置 JDBC driver 與其他需要由伺服器端載入的 jar 檔。
  - 修改注意：新增 jar 後需重啟 Tomcat 以載入新資源。

localStorage 鍵（詳細說明）

- `tt_cart`：匿名購物車（陣列）；格式不一定一致，各處有容錯讀取。
- `tt_cart_user_{id}`：特定登入使用者的購物車（陣列）。
- `tt_currentUser`：當前使用者資訊（JSON 字串，包含 id、email、name 等）。
- `tt_localReviews`：本機保存的評論陣列，每筆建議欄位：{ reviewId, productId, userId?, userEmail?, userName?, rating, content, ts }
- `tt_orders`：本機（這台瀏覽器）儲存的訂單陣列，用於展示與測試（admin 現已讀取並可編輯狀態）。
- `tt_latestOrder`：最新建立的本地訂單資訊，用作快速導向或顯示。

測試與驗證建議
- 在本機啟動 MySQL 並匯入 `assets/db/treat_trader.sql` 作為快速測試資料庫。
- 測試流程建議：
  1. 匯入 SQL，啟動 Tomcat，開啟 `index.jsp`。
  2. 建立/登入測試帳號（若需要），加入商品到購物車並結帳。
  3. 檢查 `localStorage` 中的 `tt_orders` 與 `tt_localReviews` 是否如預期產生。
  4. 以管理者登入 `admin.jsp`，確認 local orders 是否會列出並能修改狀態。

如何貢獻
- 直接修改 JSP 或 `assets/js`，測試後提交補丁。
- 若修改 DB schema，請同步更新 `assets/db/treat_trader.sql` 並註明 migration 步驟。

未來解決問題（待辦清單）
- [ ] 部分頁面可直接輸入網址進入，不安全
- [ ] 訂單紀錄及評論分紀錄目前只存在local端(不分帳號)，需要改存在db
- [ ] 購物車頁面的刪除及數量增減不會同步到庫存
- [ ] 忘記密碼頁面及結帳頁面不需要填寫資料即可送出，需要增加驗證
- [ ] 商品頁面的評論不需要登入即可撰寫，需要增加驗證
- [ ] 按下商品頁面的加入購物車沒有提示通知，體驗不佳
- [ ] 管理系統頁面商品資料填寫錯誤不會跳提示通知，會直接取消，體驗不佳

- [ ] 註冊後不會自動登入
- [ ] 結帳頁面的收件資訊不會自動填寫
- [ ] 先登入會員帳號時不能夠同時登入管理者帳號

聯絡與下一步
- 若要我執行第 1 項（同步 local orders 至伺服器）或第 5 項（localStorage 格式標準化），我可以繼續實作 API、前端同步按鈕與 migration 腳本。

檔案：README.md
更新時間：2026-06-22
