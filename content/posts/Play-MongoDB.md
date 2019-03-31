---
title: "mongoDBで遊ぶ"
date: 2014-08-07T04:40:30+09:00
draft: false
toc: false
images:
tags: 
  - mongodb
---

いまやってるプロジェクトで、なにかしらストレージ使う必要性がでてきたので、mongoDB使ってみます。

いままでmysqlとredisしか使った事がないですが、今回やりたいことがRSSで取得した記事情報(jsonオブジェクト)を溜め込んでいきたいということで、

mongoDBはjsonと相性がいいというのを聞いたことがあったので今回は好機！テーブル定義とかとくにないらしくポンポンjsonオブジェクト登録できる(?)

「はじめてのNode.js」第8章を参考に進める。

MongoDBの特徴

以下拾った情報まとめ

- ドキュメント志向DB。
- データ＝ドキュメント
- ドキュメントの集合をコレクションとして管理
- 各ドキュメントは任意の構造をもつことができ、スキーマの束縛がない
- RDBSとKVSの特徴を併せ持っている
- ドキュメントとしてBSONというJSON互換の形式を使用する。だからjsとの親和性がたかい。
- データベース内でjavascriptをいろいろ実行できる。

mongoDBを使う

インストール
homebrewでmongoDBをインストールします。

```
$ brew install mongodb
```

現時点で最新版は2.6.0だそうな。

起動

```
$ mongod
```

しかし、以下のエラー…。

```
*********************************************************************
 ERROR: dbpath (/data/db) does not exist.
Create this directory or give existing directory in --dbpath.
See http://dochub.mongodb.org/core/startingandstoppingmongo
*********************************************************************
```

デフォルトでは /data/db/ にデータベースを作成する設定になっているらしいので、作ってやる。

```
$ sudo mkdir -p /data/db
```

ちなみに -p オプションを使用するとディレクトリを含んだディレクトリを複数作成できる。はじめて知ったよ。これからはmkdirを何回も叩く必要はない。

```
$ mongod
```

これで起動できました。

ちなみに指定したディレクトリにデータベースをつくることも可能。

```
$ mongod --dbpath ./mongodb
```

なお、デフォルト設定ではユーザー・パスワードによる認証は無効なってる。

mongodbのセキュリティに関しては、http://docs.mongodb.org/manual/administration/security/

mongoシェルからアクセス

mongodbには、データベースに対話的な操作が出来る　mongoシェルというのが用意されている。

アクセスするには、

```
$ mongo [option] [database] [exec-file]
```

mysqlのmysqlコマンドに相当。

sampledbというデータベースにアクセスする。存在しないデータベースの場合自動的に空のデータベースが作成される。

```
$ mongo sampledb
```

デフォルトでは27017ポートで待ち受けるが、他を使いたい場合は

```
$ mongo hostname[:port]/database
```

でおk。mongo sampledbは内部的にはmongo 127.0.0.1[:27017]/sampledbをやってることになるね。

mongoシェルからdb操作

とりあえずなにかinsertしてみる。

```
> var hogehoge = {
>   name: 'yukichi',
>   old: 24
> };
> db.topics.insert(hogehoge);
```

入った！このtopicsに当たるものはコレクションと呼ぶらしい。mysqlでいうTABLEにあたるぽい。

コレクションが存在しない場合は勝手に作成されます。

次は入ったデータを取得して確認してみる。使うのはfind。

`db.topic.find();`

ちゃんとあるね！

findの引数に条件queryを与えることで検索してしゅとくもできる。たとえば

`db.topic.find({name:'yukichi'});`

他にもいろいろあるが、割愛。mongodbけっこう柔軟にいろいろできるのでたのしいかも。

Node.jsからMongoDBを使う

環境

```
.
├── access.js
├── node_modules
│   └── mongodb
└── package.json
```

まずディレクトリを作る。

```
$ mkdir mongodbtest
$ cd mongodbtest
```

実行ファイルを作成

```
$ touch access.js
```

npm管理下に。package.jsonが作成される。

```
$ npm init
```

npmインストール

```
$ npm install mongodb --save
```

Node.jsからdb操作

さきほどと同様に、insertしてfindしてみた。以下ソース。 [acccess.js]

```js
var mongodb = require('mongodb');

var server = new mongodb.Server('localhost', 27017);
var db = new mongodb.Db('sampledb', server, {safe: true});

db.open(function(err, db) {
  if (err) {
    throw err;
  }

  var collection = db.collection('topics');

  // insert
  var topic1 = {
    id: 12,
    title: 'たいとるううううううう',
    text: 'あああああてきすとです',
    date: new Date(),
    postBy: 'saiki daisuke'
  };
  collection.insert(topic1, function(err, result) {
    if (err)
      throw err;
      console.log(result.length + '件のデータをinsertしました！！');
      console.log(result);
  });
  // find
  var cursor = collection.find();
  cursor.each(function(err, doc) {
    if (err)
    throw err;
    console.log(doc);
  });
});

```

上の、

```js
var db = new mongodb.Db('sampledb', server, {safe: true});
```

は、操作を実行した際に正常に終了したかどうかをドライバー側に通知するためのオプション。デフォルトではfalseなので設定しといたほうがいい。

以上。これ以上の使い方は調べながらやっていくことにする。
