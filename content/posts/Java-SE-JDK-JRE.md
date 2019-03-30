---
title: "Javaを始めた頃によくある疑問。Java SE? JDK? JRE?"
date: 2016-01-17T04:06:32+09:00
draft: false
toc: false
images:
tags: 
  - java
---


Javaはじめてから2年くらいたちました。
始めたての頃は、J2EEとかJava SEとかいみわかりませんでした。
そして今でもちゃんとわかってなかったのでこうしてまとめようとしています。謙虚です。

`J2EE`、`J2SE`、`Java SE`、`Java EE`、`JDK`、`JRE`。
このあたりの単語がわかるようにざっくばらんに説明してみたいと思います。

## Javaプログラムを実行するために必要なもの
- JVM
- API
- コンパイラ
- プログラムファイル

### カップラーメンを食べるために
ぼくの好きなカップラーメンを食べるためにはなにが必要でしょうか。

目的は麺をおいしくいただくことです。頑張りたいです。
まずじぶんの好きなインスタントラーメン用意します。
さあ、これで一応食事の体は整いました。味ない乾麺バリバリ食べます？まだ食べません。
調味料を加えて準備を整えます。まだ食べれません。
追加で具材など入れるとよりおいしく召し上がれます。
沸騰したお湯を注ぎます。3分待ちます。
こうしてぼくの好きなインスタントラーメンがちゃんといただけます。

| カップラーメン喰う | Javaを使う |
|:----------:|:-----------:|
| 麺       |        プログラムファイル |
| 付属の調味料         |          API |
| 野菜         |          外部API |
| カップ     |      JVM |
| お湯       |        コンパイラ |

### Java開発するために
Javaは、JVM(カップ、器)を置き、その上でプログラムファイル(麺)を用意します。
プログラムを書くときには、`System.out.print`などのAPI(付属調味料)を使います。
Apache Commonsなどの外部ライブラリ(その他の具材)を追加するとコーディングが楽になります。
準備ができたらコンパイルして(お湯を注いで)はじめて実行可能な成果物(食べれるカップ麺)ができあがります。

※ あくまでわかりやすい例えとして提示しており、厳密な対応にはなりえないため、イメージとして掴む目的でご覧ください。

さて。


## Java SEとかって何なの？
これすなわちAPIのこと。
Javaプラットフォームには主にJava SE, Java EE, Java MEの3つのAPIがある。
まあAPIって書いてるわけですが、個人的にはライブラリといってくれたほうがしっくりきます。
要するに、これ実行したらこういう処理ができますよっていう規約と実際の関数群のことをいう。
おなじみの`System.out.println`はなぜ使えてるのか。
APIがあるからなのです。


## 3つのAPI

### Java SE (旧称J2SE)
**Java Platform, Standard Edition**の略称。
こちらが標準APIになります。基礎となる標準的な機能をまとめたもの。前述の`System.out.println`なんかはここに入ってます。
これがないとなにも始まらないヨ。

http://docs.oracle.com/javase/jp/8/docs/api/

## Java EE (旧称J2EE)
**Java 2 Platform, Enterprise Edition**の略称。
前述のSEに、企業用途(Enterprise)のサーバー用の機能が追加されたAPI。
Webサーバー対話処理のためのサーブレット関連のAPIなどがここに含まれる。`HttpServletRequest`など。
エンタープライズ目的の名称になっているが、個人でもWeb開発はされているので、これは命名当時の状況のためっぽいよね。

https://docs.oracle.com/javaee/7/api/

## Java ME (旧称J2ME)
**Java 2 Platform, Micro Edition**の略称。
情報家電や携帯端末や組み込み機器向けの機能セットとなるAPI。
個人的には全く馴染みないです。ラズパイとかであそぶときはこれにお世話になるのかしら。

http://docs.oracle.com/javame/config/cldc/ref-impl/midp2.0/jsr118/

## JVMについて
**Java Virtual Machine**の略称。
Java仮想環境のうえで、Javaのプログラムは動作します。
メイン環境がLinuxとかのOSで、そのうえに乗っかるかたちでJVMが機能します。
よくJavaは特定の環境に依存せずどこでも動作するといいますが、これは、JVMがプログラムとOSの仲介をしてくれているから。
Javaプログラムを実行すると、JVMが橋となって、乗っかってるコンピュータがわかるようにそれを変換してOSが実行。

ちなみに関係ないけど、iOS/Android両方に変換できるような、クロスプラットフォームのサードパーティフレームワーク(PhoneGapやTitanium)があまり流行ってないのは、まだネイティブ開発が若いからオリジナル機能に対応しきれてないからなんですかね。だれかおしえて。

## コンパイラは何するか
人が書くコードはあくまで人のためのコードで、機械はそれを読めません。
そのため、プログラムを実行するためには、機械語に変換しなければなりません。
それをやるのがコンパイラ。

## お得なバリューセット
上で説明したようなAPIを含む、Javaの実行環境や開発環境をまとめて用意してくれているパッケージがあります。
Javaを使うとなった際は、通常はこれらを使うことになるでしょう。

### JRE
**Java Runtime Environment**の略称。
Javaプラグラムを使う(実行する)ために最低限必要のソフトをまとめたもの。
API、JVMがここにはいってるよ。
でもコンパイラはいってないから開発はできないよ。

### JDK
**Java Development Environment**の略称。
その名の通りこちらは開発用のパッケージ。
JVMとコンパイラとAPIがまとまったセットで、JDKはJREを内包している。


# 参考URL
- http://www.searchman.info/java_eclipse/1000.html
- http://builder.japan.zdnet.com/sp_oracle/weblogic/35051347/
- http://www.fujitsu.com/jp/solutions/infrastructure/dynamic-infrastructure/sdas/technology/j2ee/01-j2ee/index.html
- http://detail.chiebukuro.yahoo.co.jp/qa/question_detail/q1169502751

