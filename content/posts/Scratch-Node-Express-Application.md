---
title: "ゼロからのNodeJS Expressアプリケーション構築"
date: 2014-08-07T04:38:48+09:00
draft: false
toc: false
images:
tags: 
  - nodejs
  - express
---

「はじめてのNode.js」を参考に進める。 参考書は3.0.3だが、最新のExpress4を使う。

Node環境

Node と npm

homebrewを入れている場合は

```
$ brew install node
```

nodeとともにnpmもインストールされる。

グローバルに管理されるnodeモジュールの場所は、/usr/local/lib/node_modules

プロジェクト環境

プロジェクトを進めていくディレクトリを作成します。

```
$ mkdir myapp
$ cd myapp
```

Express環境

expressをインストール

```
$ npm install express
```

node_modules/expressが作成されている。

スケルトンコードを作成する

※スケルトンコードとは? アプリケーションの骨組み。これをベースに肉付けしてく。(ちなみにスケルトンは骸骨の意)

expressコマンドを実行。

```
$ ./node_modules/.bin/express
```

デフォルトではテンプレートエンジンはjade、cssはピュアなcssファイルとなるが、オプションをつけることで変更もできる。

今回は、stylusを使ってみようと思うので、以下のようにする。(オプションはここでみれる)

```
$ ./node_modules/.bin/express --css stylus
```

./binがnode_modulesに作成されない場合

express 4 から、express-generatorという違うパッケージに分かれているみたい。 なので、別個インストール。

```
$ npm install express-generator
```

expressスクリプトを実行するとなにやらファイルとかたくさんできる。これをベースとしてやってく。

依存モジュールを入れる
package.jsonのdependenciesに依存モジュールが記述されている。これをインストルする。

```
$ npm install
```

アプリケーションを実行

```
// express3.xの場合
$ node app.js

// express4.xの場合
$ node bin/www
```

3.xと4.xでは構成(スケルトンコード)がだいぶ異なるよう。ソースの中身もけっこう違う…。 （あるいはexpress-generatorで作る構成が異なるのかもしれない。未確認）

実行を確認
ブラウザで http://localhost:3000 にアクセスして画面が表示されていれば成功。

expressの使い方

app.js

expressアプリケーションのメインスクリプト

モジュールを読み込む

```js
var routes = require('./routes/index');
```

appオブジェクトを作成

```js
var app = express();
```

ミドルウェアを登録

```js
app.use([path], function)

app.use('/', routes);
```

pathとはリクエストURLのこと。

pathを省略した場合、「/」。つまり全てのリクエストに対して、指定したミドルウェアが使用される。

expressの設定

設定方法

```js
app.set(key, value)
app.get(key, value)
```

true, falseの設定の場合以下も可能

```js
app.enable(key) //set
app.enabled //get

app.disable(key) //set
app.disabled //get
```

expressがデフォルトで参照する設定(キー名)

```
env, trust proxy, jsonp callback name, json replacer, json spaces, case sensitive routing, strict routing, view cache, view engine, views
```

環境によって設定を切り替える

```js
app.configure([env], callback)

```

※express4のスケルトンコードはなぜかif (app.get('env') === 'development') のようになってる。

HTTPによる待ち受けを開始する

```js
app.set('port', process.env.PORT || 3000);
app.listen(app.get('port'));

```

仕様は

```js
app.listen(port, [hostname], [backlog], [callback])
```

リクエストに関する情報を取得する

Expressのオブジェクト。

GETで送信された値

req.queryプロパティ

※そういえば、純粋なreqオブジェクト(http.ServerRequest)だと以下のようになる。

```js
var obj = url.parse(req.url, true);↲
obj.queryプロパティ。
```

obj.query.fruitとかobj.query.vegというように値を取得する。

POSTで送信された値

req.bodyプロパティ

レスポンスを返す

Expressのresオブジェクト。

いろいろあるよ。

```js
res.send([status], [body]) //本文として送信

res.json([status], [body]) //JSONデータとして送信 

res.jsonp([status], [body]) //JSONPデータとして送信 

res.render(view, [locals], [callback]) //レン」ダリング結果を送信
```

Grunt, Bowerを導入

ここからは、参考書の範囲はずれるよー。

grunt-cli, bowerをグローバルインストール

まずnpmでグローバルインストールしたものを確認してみる。

```
$ ls /usr/local/lib/node_modules
```

なければ、

-g オプションでグローバルインストールできる。 グローバルで管理すべきものは、各プロジェクトに依存しないようなモジュールであるべし(?)

```
$ npm install grunt-cli -g
$ npm install bower -g
```

依存モジュールを追加
package.jsonのdependenciesに以下のように追記する。 [package.json]

```json
"dependencies": {
    "express": "~4.2.0",
    "static-favicon": "~1.0.0",
    "morgan": "~1.0.0",
    "cookie-parser": "~1.0.1",
    "body-parser": "~1.0.0",
    "debug": "~0.7.4",
    "jade": "~1.3.0",
    "stylus": "0.42.3",
    // ここから追記
    "grunt": "~0.4.2",
    "load-grunt-tasks": "^0.4.0",
    "grunt-bower-install": "~1.0.0"
}
```

※カンマ忘れないように。エラーなります。

記述したらインストールしる。

```
$ npm install
```

[追記] こんなめんどいことしなくても以下で済みます

```
$ npm install grunt load-grunt-tasks grunt-bower-install --save
```

Gruntfile.jsを作成
https://www.npmjs.org/package/grunt-bower-installを参考にして以下のように書いた。

[Gruntfile.js]

```js
module.exports = function(grunt) {
    require('load-grunt-tasks')(grunt);
    grunt.initConfig({
        bowerInstall: {
            target: {
                src: ['views/*.jade']
            }
        }
    });
    grunt.registerTask('default', ['bowerInstall']);
};
```

bower初期化

```
$ bower init
```

勝手にbower.jsonという設定ファイルが作成されます。これもpackage.jsonと同様、プロジェクトの依存関係をまとめたファイル。

何かインストールしてみる。ということでjqueryをしてみる。

まず探してみる。

```
$ bower search jquery
```

jqueryという文字列を含むものが一覧できる。

ということでインストールする。--save オプションを付与するとbower.jsonに自動で追記してくれる。これはnpmでも同様 to package.json。

```
$ bower install jquery --save
```

するとbower_components/jqueryが作成された。

この後、このライブラリをhtmlファイルもしくはテンプレートファイルで読み込む(linkタグやscriptタグを挿入する)のだが、ここで便利なのがgrunt-bower-install。 これ使うと、依存ライブラリを指定箇所に勝手に挿入してくれます。

.jadeファイルに挿入箇所を記述
[views/layout.jade]

```
doctype html
    html
    head
        title= title
        // bower:css
        // endbower

        // bower:js
        // endbower
    body
        block content
// bower:css と // endbower で挟まれた部分に自動挿入される。jsは // bower:js で同様に。
```

htmlファイルの場合は、\ \ のようにすればOK。

grunt-bower-installを実行

gruntタスクを実行する。

```
$ grunt bowerInstall
```

views/layout.jadeを確認したら、挿入されてるはずです。

また、grunt bowerInstallしたときに実行時エラーになるのがたまにあるが、これはそのbowerモジュール配下にbower.jsonがないため。

最新版のbower.jsonがあるやつをインストールするか、自分でbower.jsonに追記してやるか、あきらめてファイルに直接タグを挿入してやるか。

ちなみにライブラリファイルのパスは、node_modules/XXXXX/bower.jsonのmainキーに指定されているよう。

[TODO] :挿入されるパスは相対パスになる。現環境の設定だと、静的ファイルのルートパスがpublic/なので、../public/bower_components/XXXXX と挿入されるとパスが違う。どうにか/bower_components/XXXXXとなるようにしたい、あとで。

[追記] 解決した。

```js
grunt.initConfig({
    bowerInstall: {
        target: {
            src: ['views/*.jade'],
            ignorePath: '../public'
        }
    }
});
```

とすればok。調べてもよくわからなかったのでオプションてきとーに試してたらできた。笑。ignorePathで指定した文字列が切り取られて挿入されれる
