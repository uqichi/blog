---
title: "    
Nodeを使ってcron処理してみる"
date: 2014-08-07T04:42:27+09:00
draft: false
toc: false
images:
tags: 
  - nodejs
---

調べてみたらOSがもっているcronを使わずにnodeだけで定期処理できそうなのでいまからやってみます。

参考URL

- http://dev.classmethod.jp/server-side/cron/
- http://memo.yomukaku.net/entries/HxtZxeG

使用するnpm

- node-cron
- time

環境

構成

```
.
├── cron.js
└── node_modules
    ├── cron
        └── time
```

ファイル作成
まずは動作確認したいのでお試し用にディレクトリ作成。

```bash
$ mkdir crontest
$ cd crontest
```

実行ファイル作ります。

```bash
$ touch cron.js
```

インストール
```bash
$ npm init
$ npm install cron --save
```

さて。

If you want to specify timezones, you'll need to install the time module or place an entry for it in your package.json file.

cronモジュール使用時にタイムゾーンを指定したい場合等にはtimeモジュールが必要らしいのでいっしょにインストール。

```bash
$ npm install time
```

ちなみに複数モジュールインストールはスペース空けでできるみたい。

```bash
$ npm install cron time
```

書いてみる
ソース

[cron.js]

```js
var mycron = require('cron').CronJob;
var job = new mycron({
  cronTime: '* * * * * *', //とりま毎秒実行
  onTick: function() {
    console.log("onTick!!");
  },
  start: false, //newした後即時実行するかどうか
  timeZone: 'Japan/Tokyo'
});
job.start();
```

実行

```bash
$ node cron.js
```

実行すると毎秒コンソール出力されます。

これで定期的にバッチ処理できるね。

もっと詳しくは、https://github.com/ncb000gt/node-cron

CronTimeの設定方法
ちなみに、cronの処理する時間の設定の記述パターンもよく知らなかったのでメモっておく。

```
Seconds: 0-59
Minutes: 0-59
Hours: 0-23
Day of Month: 1-31
Months: 0-11
Day of Week: 0-6
例1. 平日毎日11:30
```

`'00 30 11 * * 1-5'`
例2. 毎30分

`'*/30 * * * *'`
となる。

詳しくはhttp://crontab.org/
