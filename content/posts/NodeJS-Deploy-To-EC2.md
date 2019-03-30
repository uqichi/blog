---
title: "NodeアプリケーションをAmazon EC2にデプロイ"
date: 2014-08-07T04:45:02+09:00
draft: false
toc: false
images:
tags: 
  - nodejs
  - ec2
  - aws
---

Node(Express) × MongoDB(Mongoose)アプリケーションをAWS EC2にデプロイして公開します。

AWS EC2 セットアップ
このへんはぱぱっとメモしておきます。

AWSアカウント登録（http://aws.amazon.com/jp/）

最小サイズのAmazon EC2 Micro Instanceの使用は、1年間 750h/月まで無料で利用できます。(2014/8時点)

サインイン

Amazon EC2のダッシュボードを開き、メニューのInstancesをクリック
担当サーバーの地域を変更

右上のUSなんたらとなっているのをAsia Pacific(Tokyo)に変更。

Launch Instanceを押して新たにインスタンスを作成

wap, dbそれぞれのインスタンスを作成
wap, dbそれぞれのSecurity Groupを変更
wap: Inbound > Edit > Add Rule > Type:All TCP, Source:Anywhere > Save
db: Inbound > Edit > Add Rule > Type:HTTP, Source:Anywhere > Save
以上でサーバーが完成しました。

wap, dbそれぞれへのアクセス方法は同ページのConnectボタンをクリックすると詳しく記述されてます。(以下抜粋)

To access your instance:

Open an SSH client. (find out how to connect using PuTTY)

Locate your private key file (aws_key_tokyo.pem). The wizard automatically detects the key you used to launch the instance.

Your key must not be publicly viewable for SSH to work. Use this command if needed:

chmod 400 aws_key_tokyo.pem

Connect to your instance using its Public IP:

54.92.70.194

Example:

ssh -i aws_key_tokyo.pem ec2-user@54.92.70.194

Please note that in most cases the username above will be correct, however please ensure that you read your AMI usage instructions to ensure that the AMI owner has not changed the default AMI username.

If you need any assistance connecting to your instance, please see our connection documentation.

では、

wap, db各サーバーにアクセスしてデプロイしていきます。

DBサーバー セットアップ
参考
http://docs.mongodb.org/ecosystem/platforms/amazon-ec2/
http://kaworu.jpn.org/kaworu/2012-12-29-1.php
mongodbインストール
yumでmongodb-org-serverとmongodb-org-shellをインストール。

$ sudo yum -y update

$ echo "[MongoDB]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
gpgcheck=0
enabled=1" | sudo tee -a /etc/yum.repos.d/mongodb.repo

$ sudo yum install -y mongodb-org-server mongodb-org-shell
インストールしたらさっそく起動。

$ sudo service mongod start
コンソール立ち上げてみる。

$ mongo
起動を確認できたら次は、nodeアプリから接続してみる。ただし、そのままだとホストがバインドされているのでアクセスできません。設定していきます。

接続設定
設定ファイル/etc/mongod.confを書き換える。

$ sudo vi /etc/mongod.conf
接続可能なホストを設定
デフォルトの設定だと、接続可能なホストがローカルホストにバインドされている。とりあえずコメントアウトしてホストの制限を解除。

bind_ip=127.0.0.1
↓
# bind_ip=127.0.0.1
ポートを指定
# port=27017
↓
port=27017
以上二点。変更したら再起動。再起動しないと設定は反映されない。

$ sudo service mongod restart
これで外部からDBサーバーのmongodbにアクセスできるようになった。

アプリ側のURLを変更
これまでローカル開発してきたなかでURLは以下のようになっていたはず。

mongoose.connect('mongodb://localhost/sampledb');
or
mongoose.connect('mongodb://127.0.0.1/sampledb');
以下のような感じで書き換えればOK。

mongoose.connect('mongodb://sample.com/sampledb');
こんなかんじで、アプリと外部に設置したmongodbを連携することができるようになった。

次は、認証かけます。

認証設定
ユーザーを追加
続けてDBさーばーで作業します。コンソールに入る。

$ mongo DB名
ユーザー作ります。

> db.addUser("user", "pass");
認証を有効にする
デフォルトでは認証が無効になっています。さきほどと同様/etc/mongod.confを書き換えます。

# auth=true
↓
auth=true
再起動。

$ sudo service mongod restart
接続してみる。

// mongoシェル起動時に認証
$ mongo -u user -p pass DB名

// mongoシェル内で認証
> db.auth('user', 'pass');
ちなみに、

$ mongo DB名
でシェル内には入れるけど、ちゃんと認証しないと情報はみれません。

アプリ側のURLを変更
認証をかけたので、アプリ側のURLにも認証情報を追記しないといけません。

以下のようなかんじ。

mongoose.connect('mongodb://user:pass@sample.com/sampledb')
WEBサーバー セットアップ
参考
http://qiita.com/you21979@github/items/4efd9fc4363573191b5c
ポート番号の書き換え
いままでローカルで開発してきたので、プログラムのportをHTTP(80)に変更する必要があります。

node, npmインストール
$ sudo yum -y update
$ sudo yum -y install nodejs npm --enablerepo=epel
gitインストール
今回githubのレポジトリからアプリケーションをもってくるのでgit入れます。

$ sudo yum -y install git
デプロイ(仮)
とりあえずホームディレクトリにアプリをクローン。

$ mkdir app
$ cd app

$ git clone レポジトリURL
そしたら、nodeモジュールとかbowerライブラリとか入れましょう。

$ cd アプリケーションディレクトリ

$ npm install
$ npm install -g bower
$ bower install
あとはアプリを立ち上げればOK。とりあえず永続化は置いておいて、nodeコマンドで起動してwebからアクセスしてみたらよし。いけた。

デプロイ(永続化) = リリース
nodejsはコマンドアプリケーションのため、コンソール閉じるとアプリが終了してしまいます。

そのため、永続的に起動するには、コンソールからnodejsを切り離す。

やり方としては

nohupコマンド
foreverパッケージを利用
があるみたい。今回はforeverでやる。https://github.com./nodejitsu/forever

foreverはハンドルされていない例外が発生してプログラムが停止した場合自動で再起動やってくれる。一応プログラムがエラーで勝手に止まっちゃう心配はなし。

foreverをインストール
$ sudo npm install -g forever
foreverめも
書式
forever [options] [action] SCRIPT [script-options]
よく使いそうなaction
// プログラムを実行
forever start SCRIPT

// 実行中のプロセスを確認. ここで表示されるログファイルなどチェック
forever list

// プログラムを停止. プロセス番号はforever listで確認
forever stop プロセス番号

// プログラムを再起動. プロセス番号はforever listで確認
forever restart プロセス番号
プログラムの実行権限の変更
UNIX系OSの場合、1023番以下のポートで待ち受けを行うにはroot権限が必要となる。

そのためHTTP(80)やHTTPS(443)で待ち受けるには、アプリケーションをroot権限で動作させる必要がある。

しかしそうなると、攻撃されたときなど被害が拡大する恐れがある。

ので、root権限で実行して必要処理が終わり次第、一般ユーザーに権限変更する処理を行う。

ユーザーとグループの追加
$ sudo groupadd node
$ sudo useradd -g node -s /sbin/nologin node
process.setuid()
アプリケーションの実行スクリプトのlistenメソッドのコールバック関数内に追記します。

var server = app.listen(app.get('port'), function() {
        /* >>> 追記 >>>*/
            if (process.getuid() == 0) {
                        process.setgid('node');
                                process.setuid('node');
                                    }
                                        /* <<<<<<<<<<<*/
                                            debug('Express server listening on port ' + server.address().port);
});
以下rootで実行したらnodeユーザー権限で実行されることがわかります。

// 一般ユーザーで実行
$ node SCRIPT
$ ps aux | grep www
出力結果:

root 7280 0.0 0.2 182436 2632 pts/0 S+ 08:40 0:00 sudo node bin/www

root 7281 0.6 3.9 1031540 40504 pts/0 Sl+ 08:40 0:00 node bin/www

ec2-user 7316 0.0 0.0 114496 892 pts/1 S+ 08:41 0:00 grep www

// rootユーザーで実行
$ sudo node SCRIPT
$ ps aux | grep www
出力結果:

root 7430 0.0 0.2 182436 2636 pts/0 S+ 08:47 0:00 sudo node bin/www

node 7431 1.3 3.9 1031680 40540 pts/0 Sl+ 08:47 0:00 node bin/www

ec2-user 7438 0.0 0.0 114496 888 pts/1 S+ 08:47 0:00 grep www

永続化デプロイを実行
満を持してやってみます

$ sudo -s
# forever start SCRIPT
ログ監視してみます。

# forever list
でログファイルの場所を確認。

# tail -f LOGFILE
ちゃんとログ吐いています！

プログラムを修正してデプロイし直す場合はforever restart 0とかやればいいですね。
