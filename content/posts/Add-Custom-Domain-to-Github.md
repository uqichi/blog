---
title: "Github Pagesにカスタムドメインを追加する"
date: 2018-08-25T22:38:16+09:00
tags: ["github","homepage","dns","domain"]
categories: [""]
draft: false
---

# 必要なこと
やるべきことは、三つ。

1. ドメインの取得
2. Github Pagesに取得したドメインを追加
3. DNSレコードの設定

https://help.github.com/articles/using-a-custom-domain-with-github-pages/

を読みつつ進めていく。

# ドメインを取得する
王道のお名前.comで取得しました。正味値段はどこもそんなに変わらない。

一般的な`.com`がだいたい ¥1,200/年 って感じ。

https://www.onamae.com/service/d-price/ に基本料金が掲載されてあります。

## ドメイン料金の落とし穴
安い！に突進してはいけません。

ドメインを撮る際に落とし穴となるのが、**初年度料金と更新料金の差**です。更新料はこちら https://www.onamae.com/service/d-renew/price.html

お名前.comなんかは年中キャンペーンをやっています。中でも目立つのが **30円** とか **99円** とかの安いドメイン。

例えば、

- 汎用性のたかそうな`.site`
- 技術サービスやブログは需要ありそうな`.tech`
- LINEなども取得しており最近人気の出てきてる`.me`

これらは、**初年度は安いけど更新料は高くなる点に注意してください**。

## Github Pagesでサポートしているドメイン
https://help.github.com/articles/about-supported-custom-domains/

## その他の注意点
### WHOIS代行サービスの登録
ドメイン取得時に、オプションとしてWHOIS代行に無料登録できますが、この時に登録しておかないと無料にならないようなので登録し忘れのないようにしましょう。

### ドメイン更新料の自動更新設定
また、ドメインの更新料金の支払いはデフォルトで自動更新となっています。気づかぬうちに何年も使ってないドメインの更新料を支払い続けていた...とならないように注意してください。

とりあえず1年様子見という場合は自動更新を解除しておきましょう。

逆に、それをした場合の注意点としては、ドメインを1年以上使い続ける場合にはきちんと香辛料を払わないと失効します。ので、忘れないように注意！

# Github Pagesに取得したドメインを追加する
https://help.github.com/articles/adding-or-removing-a-custom-domain-for-your-github-pages-site/

>Before setting up or modifying your custom domain with your DNS provider, you should add or 
remove the custom domain on GitHub.

先に、当該レポジトリの「Settings」から**取得したドメイン名**を入力して更新しておきます。

この順序の理由としては、

https://help.github.com/articles/quick-start-setting-up-a-custom-domain/
>Configuring your custom domain with your DNS provider without adding your custom domain to GitHub could result in someone being able to host a site on one of your subdomains.

DNSの設定に入る前にこの作業をしておかないと、赤の他人がGithubであんたのサブドメイン悪用する可能性あるよ。

ってことですね。

# DNSレコードの設定する

お名前.comにはDNSのサービスがあるので、今回このままここを利用する。

AWSなどにNSを登録してネームサーバーを変更しそっちで管理しても良い。

## レコードを追加
どんなドメインでサイト運営するかですが、二つあります。

- [apex domain](https://help.github.com/articles/setting-up-an-apex-domain/) エイペックスと読む。つまりルートドメインのこと。 e.g. `xxxxx.com`
- [custome subdomain](https://help.github.com/articles/setting-up-a-custom-subdomain/) 任意のサブドメイン。 e.g. `blog.xxxxx.com`

僕はapex domainで設定します。

DNSプロバイダ（今回の場合はお名前.com）の管理画面にて、DNSレコード設定画面を開き、`A`レコードを追加します。

GithubサーバーのIPは4つあります。 https://help.github.com/articles/setting-up-an-apex-domain/ に書いてますね。

![](https://www.dropbox.com/temp_thumb_from_token/s/a1uqv6swfjfr56a?size_mode=4&preserve_transparency=true&size=1600x1200)

上のように登録。DNSの反映までは結構時間かかります。24H~72H？

ターミナルでwatchして気長に待ちましょう。

`watch dig +noall +answer xxxxx.com`

以下のような出力が得られれば反映完了です。

```
xxxxx.com.		2105	IN	A	185.199.110.153
xxxxx.com.		2105	IN	A	185.199.111.153
xxxxx.com.		2105	IN	A	185.199.108.153
xxxxx.com.		2105	IN	A	185.199.109.153
```

ちなみにname serverも変わりますので、暇だったらこちらも覗いてみると良いかも。

`nslookup -type=ns xxxxx.com`

これで、取得したドメインにアクセスしてください。Github Pageサイトが見れるはず。

# その他しておくべき設定

## SSL対応
今回ドメインを変えたのでhttpsでみるように変更しておく。

「Settings」のEnforce HTTPSにチェックを入れるだけ。

ただ、アラートとhelpページを見ればわかるんですが、まず一度Custom domainを消す必要があります。

そして、再び同じものを入力して更新。すると、以下のようなステータスに変わります。

![](https://www.dropbox.com/temp_thumb_from_token/s/ttvyrhf7cvu4jb4?size_mode=4&preserve_transparency=true&size=1600x1200)

しばらくしたらhttpsで見れる。

## wwwサブドメでもアクセスできるようにする
https://help.github.com/articles/setting-up-an-apex-domain-and-www-subdomain/

おなじみの`www`でもページが見られるようにします。

https://help.github.com/articles/setting-up-a-www-subdomain/
>Follow your DNS provider's instructions to create a CNAME record that points to your default pages domain, such as YOUR-GITHUB-USERNAME.github.io to your subdomain.

Aレコードの時と同じように、レジストラ（お名前.com）のDNS設定で、`CNAME`レコードを追加します。

![](https://www.dropbox.com/temp_thumb_from_token/s/aybl0dxzp0qjhtk?size_mode=4&preserve_transparency=true&size=1600x1200)

これまた羽根井までに、時間かかるので気長に待ちます。

`watch dig www.xxxxx.com +nostats +nocomments +nocmd`

以下のような出力が得られれば反映完了です。

```xxxxx
; <xxxxx.com<>> DiG 9.10.6 <<>> www.xxxxx.com +nostats +nocomments +nocmd
;; global options: +cmd
;www.xxxxx.com.			IN	A
www.xxxxx.com.		3566	IN	CNAME	xxxxx.github.io.
xxxxx.github.io.	277	IN	CNAME	sni.github.map.fastly.net.
sni.github.map.fastly.net. 2795	IN	A	185.199.111.153
sni.github.map.fastly.net. 2795	IN	A	185.199.108.153
sni.github.map.fastly.net. 2795	IN	A	185.199.109.153
sni.github.map.fastly.net. 2795	IN	A	185.199.110.153
```

www.xxxxx.comにアクセスすると、ちゃんとhttps://xxxxx.comにリダイレクトされています。

ちなみにこのリダイレクトはどうやってるかというと[Githubのサーバが自動でよしなにやってくれてます](https://help.github.com/articles/setting-up-an-apex-domain-and-www-subdomain/)。

# おわりに
これで、ひとまずブログ作成が全て完了しました。

それよりサイトの修正やソースコード周りのスクリプト作ったりするの優先しそうな予感。

そういう方が楽しいんだなー。ブログ書くって大変だー。