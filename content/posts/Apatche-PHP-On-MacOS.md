---
title: "MacでApache+PHPの環境を構築する"
date: 2014-04-15T04:37:26+09:00
draft: false
toc: false
images:
tags: 
  - php
  - apache
  - macos
---

MacでApache+PHPの環境を構築する方法。

参考URL
http://qiita.com/is0me/items/72fcb5d8ac2c8f1c6247
http://stackoverflow.com/questions/10873295/error-message-forbidden-you-dont-have-permission-to-access-on-this-server
http://yoshifumisato.jeez.jp/wordpress/post/programing/949

方法
Apacheの起動
まずはapacheを起動してlocalhostを確認してみます。

sudo /usr/sbin/apachectl start
ちなみに、apachectlコマンドの基本は以下。

# Apacheの起動
sudo /usr/sbin/apachectl start
# Apacheの停止
sudo /usr/sbin/apachectl stop
# Apacheの再起動
sudo /usr/sbin/apachectl restart
Apacheを起動したときにはじめによまれるディレクトリは、どこにある？
ここ。

/etc/apache2/httpd.conf
このなかのDocumentRootという箇所で設定しているディレクトリが基本のドキュメントルートとなる。

DocumentRoot "/Library/WebServer/Documents"
では、http://localhostにアクセスしてみる。


と表示されるはず。

これはさきほどの/Library/WebServer/Documents以下のindex.html.enというファイルの中身である。

これを他のhtmlファイル(index.html)に置き換えればそちらが表示されることになる。




では、複数のWEBサイトをローカルで開発できるようにする。

Apacheの設定
http://qiita.com/is0me/items/72fcb5d8ac2c8f1c6247をみればほぼわかる。
ただ、httpd-vhosts.confの設定がうまくいっていないようなので、調べた。
http://stackoverflow.com/questions/10873295/error-message-forbidden-you-dont-have-permission-to-access-on-this-server

以下のように変更。

<Directory "/Users/is0me/Dev/sandbox">
    Options Indexes FollowSymLinks Includes ExecCGI
    AllowOverride All
    Order deny,allow
    Allow from all
</Directory>
