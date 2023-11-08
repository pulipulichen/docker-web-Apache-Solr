# conf說明

以下說明這些檔案的用途。

以下檔案皆可用純文字編輯器來修改。建議使用Visual Studio Code編輯。

----

## data.csv

設定在 data.csv 的資料，會在啟動docker-web-apache-solr的時候自動更新到系統裡面。不在原本資料集裡面的資料會被刪除。

關於data.csv的設定，請看以下網址。

https://github.com/pulipulichen/docker-web-Apache-Solr/example/data/

----

## managed-schema

控制匯入資料的欄位跟索引的方法。

詳情可以閱讀這篇文章：
https://blog.csdn.net/yerenyuan_pku/article/details/105679097

與manage-schema緊密相關的還有以下檔案：

### stopwords.txt

不會被列入索引的停用字。

請注意，這僅限於最終被會列入索引的詞彙，而不是以原始的來考慮。以StandardTokenizerFactory標準斷詞器來說，「淡江大學」會被分解成「淡」、「江」、「大」、「學」四個字。此時停用字必須一一列入這四個字才能發揮效果，只列入「淡江大學」不會生效。

中英文停用字的範例可以參考以下檔案：

https://github.com/pulipulichen/docker-web-Apache-Solr/example/stopwords/

### synonyms.txt

同義詞列表。可以多詞轉換成同一個詞彙，或是一個詞彙轉換成多個詞彙。

### protwords.txt

防止被詞幹化 (stemming) 的列表。

-----

## solrconfig.xml

控制Solr運作的細節。包含排序方式、層面搜尋等等。跟最終呈現的網頁有緊密關聯。欄位名稱需要跟managed-schema配合。

以下是基本搜尋網頁Velocity的相關檔案：

### velocity_display_fields.vm

控制velocity要顯示的欄位、可進階檢索的欄位。

欄位名稱需要跟managed-schema配合。