---
title: "NodeでRSS情報をfbいいね順に取得する"
date: 2014-08-07T04:43:30+09:00
draft: false
toc: false
images:
tags: 
  - nodejs
---

nodeで何か実装する際は、使えそうなapiがないか調べてみるとよい。

たとえば今回、facebookいいねを取得したかったので以下のように検索してみたらでてきた。

$ npm search facebook | grep like
何件かでてきたので、使えそうなもんがあれば使おう。

使用するnpm
google-feed-api -> 各メディアのフィード情報を取得できる
count-shares -> いろんなソーシャルリアクション数を取得できる
とりあえず両npmの動作確認までやります。

API使用方法
[ google-feed-api ]
ref. Google Feed API Developer's Guide

使い方かんたん。一例

var gfeed = require('google-feed-api');

var feed = new gfeed.Feed("http://gamy.jp/feed");

// feed.XMLに載ってないものをGoogleが保存してくれているのでそれも含めて取得する
feed.includeHistoricalEntries() 

// 取得数をセット
feed.setNumEntries(30);

feed.listItems(function(items) {
        // ココでitemsをいじいじ
})
listItems()は配列を返す。しかしこれだとフィードの名前（ここではgamy.jp）とかとれなくて各エントリーの情報しかとれない。

jsonとして受け取るにはload()を使用する

feed.load(callback(result));
こんなかんじでresult.feedとやるとエントリーを配列として持つフィードオブジェクトを操作できる。

わかりにくかったと思うので、以下。

// フィード情報を取得
result.feed.title // -> gamy.jp

// フィードのエントリー(記事)情報を取得
result.feed.entries[0].title // -> 【海外の反応】ロックマンが人気すぎて発狂する人たち
詳細なオブジェクト構造はこちらをみてください。

[ count-shares ]
あるURLに対してのソーシャルリアクション数を取得します。

とりあえず、使い方をどんと載っけちゃいます。

var countShares = require('count-shares');

countShares.get('ページURL', function(err, result) {
        console.log(result.facebook);
            console.log(result.twitter);
                console.log(result.pinterest);
                    console.log(result.linkedin);
});
かんたんですね。

しかし、非同期処理なのに注意！！

このモジュールの用途を考えると同期処理できるようにしてくれてそうなものですが、こちら特にそういったものは用意していないみたいです。残念。

非同期メソッドを同期的に処理するにはいくつか方法がある。

promise, defferedとか使う（あんま覚えてないけど）
再起処理で済ます
他にもあるのかも。がんばってみよう。
