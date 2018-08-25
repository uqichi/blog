---
title: "エンジニアブログ作るならGithub Pages x Hugoがおすすめ"
date: 2018-08-25T14:20:11+09:00
tags: [""]
categories: [""]
draft: false
---

そろそろ自分のブログを作るか。全然技術ブログなど書いてないけど。ということで、作ってみました。

# TL;DR

Hugoを使って、Githubにブログをホスティングし公開しました。

やってるうちに色々メリットなど気づいたので、エンジニアさんがブログを開設するならばこの技術スタックでやることをお勧めします。（カレーブログとかテーマはなんでもいい）

キーワードはGithub PagesとHugoのみ。

公式ページがわかりやすくシンプルです。本記事はセットアップ方法について詳しくは説明しません。


# Github Pagesとは

https://pages.github.com/


> Websites for you and your projects.
> Hosted directly from your [GitHub repository](https://github.com/). Just edit, push, and your changes are live.

Githubのrepositoryに静的ファイルをおくだけでweb pageを公開できる機能。


## 長所

**ページの更新が簡単**

 `git push origin master` するだけ。シンプルな方法で運用できる。
 
**記事の投稿が簡単**

.mdファイルを指定のディレクトリ配下におくだけでも、よしなにhtmlに変換して公開してくれます。

**ブログ書いてるだけでGithub contribute**

今のご時世、エンジニア採用の履歴書としてGithubがみられるから意外とありがたい福利。

**無料、SSL対応、カスタムドメイン対応**

これだけ対応されてれば問題ないだろう。


## 短所

**利用制約がある**

無料だから仕方ない。とはいえ、これから始めるブログビギナーにとってはあってないようなもの。
公式ページにてUsage Limitを説明されています。（2018/08/25時点）

https://help.github.com/articles/what-is-github-pages/#usage-limits

> GitHub Pages source repositories have a [recommended limit of 1GB](https://help.github.com/articles/what-is-my-disk-quota/#file-and-repository-size-limitations) .

ソースコードは1GBまでを推奨。
推奨と言っているのは、以下の項のためですね。


> Published GitHub Pages sites may be no larger than 1 GB.

公開される静的ファイルのホスティングは1GBまで。


> GitHub Pages sites have a soft bandwidth limit of 100GB per month.

**ネットワーク通信料が100GBまで**。
この制約がもっとも気をつけないとなところ。

ブログによってまちまちですが、1ページあたりのリクエスト100KBだとすると、最大PVは1,048,576になります。
まるめて、月におよそ100万PVまで。デイリーだと、33,333PV。
デイリーで一人当たり平均3PVとすると、11,111人が見ることのできるサイトとなります。

まあ1万人も読者が増えたら、その時にはちゃんと有料のレンタルサーバー借りて移行しましょう 😎
ブログではなくECサイトなど商用利用する際はちょっと厳しくなってくるんじゃないかな。 


> GitHub Pages sites have a soft limit of 10 builds per hour.

1時間に10プッシュまで。
まあ大丈夫でしょう。 基本的に`hugo server`でローカルチェックすると思うし。


# Hugoとは

https://gohugo.io/


> The world’s fastest framework for building websites
> Hugo is one of the most popular open-source static site generators. With its amazing speed and flexibility, Hugo makes building websites fun again.

静的サイトを自動生成してくれるツールです。オープンソース製でGoで書かれています。


## 長所

**高速ビルド**

公式もこれをセールスポイントにしている。
数秒もかかりません。さすがgoといったところ。

**マークダウンファイルに対応**

hugoもまた.mdファイルの表示に対応しています。
Github Pagesに公開する場合は、ローカルビルドしてhtmlファイルを生成しそれらをデプロイする感じになります。

**テーマが豊富**

https://themes.gohugo.io/
hugoは色々な方々が作ってくれたテーマがあって、みていてたのしい。
一応Github Pagesにも用意されたテーマがあるのですが、少ないしょぼい。


## 短所

さしあたり特に無いなー。

**インタフェースが技術者向け**

強いて言うなら。コマンドで投稿を作成したりデプロイしたりするので管理画面やエディタ画面もなく、素人だと扱うのが少々難しい。
しかし今回の記事はエンジニア向けと言っちゃってるのでこれはデメリットにはならない！

いやはや、とてもいいツールだ。


# このブログができるまでの流れ

HugoでGithub Pagesに公開するには以下の記事見るとよい。

## [Host on GitHub \| Hugo](https://gohugo.io/hosting-and-deployment/hosting-on-github/)

簡単に注意点など説明。


## Githubのレポジトリは二つ作成
- https://github.com/uqichi/uqichi.github.io
  User Site. 公開する静的ファイルのホスティングに使う。
- https://github.com/uqichi/blog
  Project Site. 投稿記事ファイルやhugoのソースコードを保管する。

もちろん一つのrepositoryにまとめちゃってもおk。


## 好きなテーマを選ぶ

https://themes.gohugo.io/hugo-theme-cactus-plus/

テーマは `git submodule add` で追加して、configファイルで `themes/{テーマ}`を指定する。

テーマ触ってて自分で手入れたい部分が色々出てきたので、最初にforkしてから追加したほうが良い。
https://github.com/uqichi/hugo-theme-cactus-plus

ちなみに、このテーマはなぜかカテゴリが表示されない仕様（バグ？）があるので今度直したい。


# ブログの運用方法
## どのエディタを使うか

Dropbox Paperを使って書いて、mdファイルとしてエクスポートして運用していくことにする。

MacDownも迷ったが、こちらはmac専用のデスクトップアプリ。複数端末で同期取れるメリットを優先しPaperに決定。
一応、出力ファイルをデプロイして表示確認してみたところ両者問題なかった。

色々使ったことあるので、Markdown対応エディタの比較記事も今度描こうとおもう。


## 運用をもっと簡単にする

Makefileを作った。https://github.com/uqichi/blog/blob/master/Makefile

例えば、`make post`で記事作成できる。
ファイル名を入力しなかったら、現在日時が適当に入る。


    Tools for 'blog' project.
    
    Usage:
    
            make command
    
    The commands are:
    
            list    List all posts
            post    Add new post
            deploy    Deploy posts
            server    Run local server
            help    Show help
    


1. `make post` で記事を作成
2. `make deploy`で記事をアップ

以上。

外から持ってきたmdファイルにfrontmatter入れるコマンドも欲しい。

# おわりに
エンジニアにとってはコマンドべーすだったりGithubベースだったりと、管理しやすく使ってて楽しいと思います。

これを機に、ブログ書くのを楽しみながら続けられるといいな。
