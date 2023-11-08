# data

設定在 data.csv 的資料，會在啟動docker-web-apache-solr的時候自動更新到系統裡面。不在原本資料集裡面的資料會被刪除。

設定時有兩種模式：
- csv模式：以csv的資料匯入。第一列會是欄位名稱，第二列之後才是要匯入的資料。要注意資料集本身的換行，編碼必須是utf8。
- 網址模式：程式會嘗試去下載遠端網址，並將之轉換成csv格式，然後用csv模式匯入。

## id

欄位必須要有id。Solr會用id來判斷要資料的新增、更新或移除。

如果你沒有設定id，程式會根據資料的內容，臨時計算一筆id。

## 二進制檔案

二進制檔案 (binary file)是指非純文字的檔案類型。包括了記錄文件的Open Office檔案格式、Microsoft Office檔案格式。

Apache Solr結合Apache Tika後可以從二進制檔案取得純文字的內容，並以此進行索引。但目前docker-web-apache-solr的未實作此功能，有需要的人請自行研究。

----

# example

此資料夾的csv檔案是可用的範例。

## csv模式

- data-google-scholar.csv ： 從Google Scholar匯出的資料。
- data-tku.csv ： 從淡江覺生圖書館OPAC匯出的資料。
- data-worldcat.csv ： 從WorldCat匯出的資料。

## 網址模式

- url-crawler.csv ： 匯入網頁爬蟲資料。目標網址是CSV格式。
- url-stock.csv ： 匯入每日股票趨勢資料。目標網址是CSV格式。
- url-stock-json.csv ： 匯入每日股票趨勢資料。目標網址是JSON格式。
- url-google-sheet-500.csv ： 匯入Google Sheet的資料。目標網址是CSV格式。
- url-google-sheet-2000.csv ： 匯入Google Sheet的資料。目標網址是CSV格式。
