---
title: "gvm使ってCircleCIでGoのバージョン固定"
date: 2016-12-12T23:57:01+09:00
draft: false
toc: false
images:
tags: 
  - golang
  - circleci
---

## 目的
- バージョンが勝手に変わると、アプリケーション動作の保障ができないので、任意のバージョンのgoをインスコして使う

## 対象環境
- ビルド環境 (CircleCI)
- 実行環境 (AWS EC2)

今回ビルド環境と実行環境を分ける予定であるため、その両方への作業が必要ですが、今回は、ひとつめの、CircleCIでの適用作業をします。

## 利用するライブラリ
gvm: https://github.com/moovweb/gvm

## gvm使ってみる
gvmはgolangのバージョン管理ライブラリです。
あまり気に入ってないけど、他にいいやつあったらおしえてほしいです。

自分のローカルで先にやっても良かったのですが、まだVM環境になってないので、CicleCIのコンテナでためしました。

CircleCIはデバッグ用途で、30min限定でコンテナにsshできます。
ぶっ壊れてもいいので、今回の作業以外でも色々遊ぶといいです。

現在使っているシェルを確認

```bash
$ echo $SHELL
```
>
/bin/bash

現在使っているgoのバージョンを確認

```bash
$ go version
```
>
go version go1.6.2 linux/amd64

gvmをインストール

```bash
$ bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
```
>
Cloning from https://github.com/moovweb/gvm.git to /home/ubuntu/.gvm
Created profile for existing install of Go at "/usr/local/go"
Installed GVM v1.0.22
>
Please restart your terminal session or to get started right away run
 `source /home/ubuntu/.gvm/scripts/gvm`

上記出力の通り、以下を読み込んであげましょう。

```bash
source /home/ubuntu/.gvm/scripts/gvm
```

インストールgo一覧の確認

```bash
$ gvm list
```
>
gvm gos (installed)
>
   system

現状システムインストールされたgoだけが表示されています。CircleCIで使われてるイメージはデフォルトでgo入ってるので。すなわちsystemですね。

gvmで任意のバージョンのgoインストール

```bash
gvm install go1.4 -B
```
>
Installing go1.4 from binary source

ちゃんと入ったようなので、先ほどインストールしたバージョンを使います

```bash
gvm use go1.4 
```
>
Now using version go1.4

`--default`オプションをつけることもできます。たぶん基本的につけてつかうことになるでしょう。

goのバージョン確認

```bash
go version
```
>
go version go1.4 linux/amd64

ちゃんと1.4に変わってます。

元に戻す

```bash
gvm use system
```

ちなみにgvm経由でインストール可能なgoのバージョンの一覧は以下で得ることができます

```bash
gvm listall
```

バルスコマンド。インストールしたバイナリなどに加え、gvm自身も消え去ります。
けっきょく、`${HOME}/.gvm` (= `${GVM_ROOT}`) を`rm -rf`すればおなじことです。

```bash
gvm implode
```

さて。もともと、やりたかったことは、CircleCIのビルド時のバージョン固定なので、これを`circle.yml`に落とし込みます。

## CircleCIで任意のバージョンのgo使ってビルドする
https://circleci.com/docs/language-go/#environment
> 
Since the install is in the default location, GOROOT is not set. If you install your own version of Go, make sure to set the location in GOROOT

任意のバージョン使いたければちゃんと$GOROOTセットしてねって書いてるけど、これはgvmが勝手にやってくれてました。

```bash
echo $GOROOT
```

これはありがたいのでしたが、しかし、とてもありがた迷惑だったのが、$GOPATHの変更まで勝手にやっちゃってくれます。

```bash
echo $GOPATH
```
>
e.g.
/Users/a13533/.gvm/pkgsets/system/global

ここで結構はまります。
このGOPATHで頑張ってみてもいいのですが、circleciでは`$HOME/.go_project`をGOPATHと扱うよう推奨してあります。推奨ではなくデフォルトですが、これをぼくは推奨として受け取ります。公式ドキュメントに沿っておいた方が後続のコーダーが理解しやすいとおもうので良。

https://circleci.com/docs/language-go/#environment
> 
a symlink is placed to your project’s directory at /home/ubuntu/.go_project/src/github.com/\<USER\>/\<REPO_NAME\>

なので、gvmが決めるGOPATHにこちらが指定したいGOPATHを追加する方法で解決しました。

そもそもどこで環境変数を上書きしているのかを探します。結論は、当該シェルのrcファイルを改変してくれていたのでした。
bashでインスコしたなら`.bashrc`、zshでインスコしたなら`.zshrc`の末尾に以下が追記されていると思います。

```bash
[[-s "$HOME/.gvm/scripts/gvm"]] && source "$HOME/.gvm/scripts/gvm"
```

このなかを追って読むと、デフォルトのpkgsetに書かれてある環境変数がロードされていることがわかるとおもいます。
そこで、デフォルトの`pkgset`の設定ファイル末尾に追記してGOPATHをoverrideします。

**注意: gvmのpkgsetやpkgenvを使ってGOPATH管理をしない前提です。**

```bash
echo "export GOPATH; GOPATH=\"${GVM_ROOT}/pkgsets/${GVM_GOS}/global:${GOPATH}:${GOPATH_ORG}\"" >> ${GVM_ROOT}/environments/default
```

これで、こちらが設定した`GOPATH_ORG`がGOPATHに追加されるようになります。

### 環境変数がセットできない、cdできない...etc
ここまで話して、```export GOPATH=$GOPATH:$追加パス```でよくないか？と思われるかとおもいますが、
ひっかかりポイントとして、**CircleCIは、各コマンドをサブシェルとして実行します**。
どういうことかというと、

```yaml
- export HOGE=fuga
- echo $HOGE
```

この結果は、設定した環境変数の中身は空になります。
なぜなら環境変数入れたあとに実行されるechoコマンドは別シェルで実行されるからです。

`cd`コマンドしてから何かを実行したいパターンでよくはまりそうです。以下も想定した通りにはいきません。

```yaml
- cd path/to/repo
- sh ./hoge.sh
```
>
sh: ./hoge.sh: No such file or directory

流れるようにコマンドが実行されるかと思いきやここ要注意です。
さて。以下、今回やった範囲の設定です。

```yaml
machine:
  environment:
    GOROOT: ""
    PATH: "/usr/local/go/bin:/usr/local/go_workspace/bin:~/.go_workspace/bin:${PATH}"
    GOPATH_ORG: "${HOME}/.go_workspace:/usr/local/go_workspace:${HOME}/.go_project"
    GVM_GOS: "go1.6.2"
  post:
    - bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) && source ${HOME}/.gvm/scripts/gvm
    - gvm install ${GVM_GOS} -B
    - gvm use ${GVM_GOS} --default 
    # `gvm` arbitrarily changes GOPATH value :( so forcibly override it with its original value.
    - echo "export GOPATH; GOPATH=\"${GVM_ROOT}/pkgsets/${GVM_GOS}/global:${GOPATH}:${GOPATH_ORG}\"" >> ${GVM_ROOT}/environments/default

dependencies:
  pre:
    - go get github.com/golang/lint/golint
    - sudo add-apt-repository ppa:masterminds/glide -y && sudo apt-get update && sudo apt-get install glide -y
    - mkdir -p ${HOME}/.go_project/src/github.com/${CIRCLE_PROJECT_USERNAME}
    - ln -sfnv ${HOME}/${CIRCLE_PROJECT_REPONAME} ${HOME}/.go_project/src/github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}
  override:
    - glide install
    - cd ${HOME}/.go_project/src/github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} && go build -v -race -o build/output

test:
  override:
      - cd ${HOME}/.go_project/src/github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} && go test -v -race -cover `glide nv`
```

今回なかなか強引に対応しましたがほかにいいやりかたないかな。
ghq使っている自分としてはGOPATH問題がなかなかめんどうなためやりづらい。
普通に単体で使えばちゃんと便利なんだけど。

## 参考
- https://github.com/moovweb/gvm
- http://www.ascent.io/blog/2014/03/11/gvm-with-golang/


