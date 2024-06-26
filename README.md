# docker-web-apache-solr: 以Docker封裝的Apache Solr教材

A ready-to-use full-text search engine packaged with Docker technology using Apache Solr. It allows users to customize data sources, indexing methods, and the appearance of the web interface.

一套開箱即可用的搜尋全文搜尋引擎。以Docker技術將Apache Solr封裝，並允許使用者調整資料來源、索引形式、以及網頁外觀。

![](https://blogger.googleusercontent.com/img/a/AVvXsEjTME6WwD-5kXlJNKZ8AkVVvJSoXp30VaB0rACLjM1Bczo7XVCQNS7ncG6zgdY702EHYucK_YkCI8QlH5uVs9T8G6onjvT1waRUYrkLElljAerauJPD39X6vrJcX2NrGdm1Mhn8FBQwMFH7NJoVWC686iwBuW2n6-OL-Pf4ggnNft5qRd6y8jLfKQ)

## Technologies

- Apache Solr & Java: 全文檢索引擎以及其使用的程式語言
- Python: 資料前處理使用的程式語言
- Velocity: 前端網頁框架
- Semantic UI: CSS框架

## Instruction

[建置搜尋引擎 - 112-1 資訊儲存與檢索](https://docs.google.com/presentation/d/1Nkzh8yCV4uaQcwX3VaEjtSBPSf2v7SdrRkFhWicNYbc/edit?usp=sharing)

----

## Tool

- Visual Studio Code: https://code.visualstudio.com/download

## Icon

- Flaticon: https://www.flaticon.com/search?word=search&color=gradient&shape=lineal-color&order_by=4
- Resize: https://www.iloveimg.com/resize-image

## Style Framework

- Semantic UI: https://semantic-ui.com/
- Semantic UI Button: https://semantic-ui.com/elements/button.html

----

# How to use

## Environments

1. git: https://git-scm.com/downloads
2. Docker: https://www.docker.com/products/docker-desktop/

## Executable scripts

For Windows 
- Download: https://pulipulichen.github.io/docker-web-Apache-Solr/bin/apache-solr.exe
- Please disable the anti-virus software or add it to white list.
- Problems when handing exe files: https://ppt.cc/f7SzLx


For Linux and Mac OS
- Download: https://pulipulichen.github.io/docker-web-Apache-Solr/bin/apache-solr.sh
- How to use the script in Mac OS: https://docs.google.com/presentation/d/1vJKFhFkHIh00C3lQ-j3rKIp1t-_Oug92Qc12aQ3XRQY/edit?usp=sharing

----

## Online demo

- COLAB: https://colab.research.google.com/drive/1_aTP6n4rQty6P0Ez4q-OtiaJJIwP3fU5?usp=sharing
- Only for demostration, not suitable for practice use.


# Memo

這是為了資訊儲存與檢索課程的教學，將Apache Solr包裝成容易架設與設定的形式。

此配置是建置了Linux Debian bullseye作業系統以及完整的Apache Solr 8.7，並以Docker容器化包裝。教學時不會操作底層，提供有開發者自行探索。
