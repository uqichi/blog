---
title: "Protocol Buffer と Message Pack の違いとベンチマークを比較"
date: 2018-09-24T23:57:14+09:00
tags: ["protobuf","msgpack"]
categories: [""]
draft: false
---

**TL;DR**

だいたい使い方や結果わかっているけれど、自分なりに触って、実際にみてみるのが目的。

あくまで違いとベンチマークの比較を記事にするので、それぞれの使い方については詳細は省略。

コードはこちら https://github.com/uqichi/go-protobuf-msgpack


# Protocol Buffer と Message Pack の違い
## Protocol Bufferとは

https://developers.google.com/protocol-buffers/


> **What are protocol buffers?**
> Protocol buffers are Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data – think XML, but smaller, faster, and simpler. You define how you want your data to be structured once, then you can use special generated source code to easily write and read your structured data to and from a variety of data streams and using a variety of languages.

データを構造化するための、言語中立的でプラットフォーム中立的な拡張システム。
XMLみたいな、けれども、小さくて早くてシンプルなやつ。
一度構造化してしまえば、自動生成されるコードを簡単に使えるし、言語を問わず様々なデータストリームの読み書きができる。


## Message Packとは

https://msgpack.org/


> It's like JSON.
> but fast and small.
> MessagePack is an efficient binary serialization format. It lets you exchange data among multiple languages like JSON. But it's faster and smaller. Small integers are encoded into a single byte, and typical short strings require only one extra byte in addition to the strings themselves.

JSONみたいな、だけど早くて小さい、効率のいいバイナリシリアライゼーションフォーマット。
JSONのようにいろんな言語のデータ交換ができる上に、早くて小さい。
小さい整数はシングルバイトにエンコードされるし、よくある短い文字列はほんの数バイトの長さで済む。


## それぞれの思想の違い

Protocol BufferとMessage Packはよく比較されますが、それぞれの公式サイトに記載されているこいつはなんぞやについての説明文（上記）の一文目を読むと、その根底が違うことが端的に表れているように思う。

Protocol Bufferはあくまで**データの構造化**に重きを置いているのに対し、
Message Packは**serialize/deserializeの速度とデータ長の圧縮**をアドバンテージとしている。


## Protocol Bufferの特徴（メリット・デメリット）
- IDL (Interface Definition Language) によるシリアライザ実装コードの生成
- 複数の言語間のデータ構造定義を共有できる
- 静的型付け
## Message Packの特徴（メリット・デメリット）
- 高速
- データが小さくなる
- 動的型付け


# Protocol Bufferのproto2とproto3の違い

https://qiita.com/ksato9700/items/0eb025b1e2521c1cab79

根底の思想から仕様が変わる部分があるが、新しくProtocol Bufferの利用を開始する場合はあまり気にすることはない。

proto3は、 `required` オプションの指定ができなくなっていたり、デフォルト値の指定ができなくなっていたりと一見不便なアップデートに見えますが、端的に言えば、フォーマットの下位互換性を保つという目的のためのよう。

まだ試行錯誤の段階で恒久的な変更では内容ですが、新しい方針にしたがってproto3を使った方が良さそう。

また、proto3の新機能としてJSONへのマッピングが可能。


# Protocol BufferとMessage Packのテストコード

https://github.com/uqichi/go-protobuf-msgpack/blob/master/serialize_test.go

# Protocol BufferとMessage Packのベンチマーク

https://github.com/uqichi/go-protobuf-msgpack/blob/master/serialize_bench_test.go

ベンチをとるにあたって押さえておきたい前情報。
結果が変わりそうなものとか実際の運用で必ず使いそうな型とかを対象に含めるように意識してテストを作ります。


- 整数が符号付きか符号無しか
- 文字列の長さ。短いか長いか
- 配列は結構使いそう
- JSONも入れて比較してみる


## ベンチマーク結果
- Protocol Buffer
- Message Pack
- and JSON

**Serialization**

    BenchmarkProtobuf-8      1000000              1640 ns/op            1392 B/op         12 allocs/op
    
    BenchmarkMsgpack-8        500000              3400 ns/op            2600 B/op         24 allocs/op
    
    BenchmarkJSON-8           200000              8348 ns/op            2224 B/op         18 allocs/op

**Data length**

    Content-Type: application/protobuf
    Date: Mon, 24 Sep 2018 14:49:51 GMT
    Content-Length: 505
    
    Content-Type: application/x-msgpack
    Date: Mon, 24 Sep 2018 14:48:58 GMT
    Content-Length: 539
    
    Content-Type: application/json
    Date: Mon, 24 Sep 2018 14:50:14 GMT
    Content-Length: 563

serialize/deserializeの速度、データ長どちらもprotocol bufferの勝利となってしまった。

条件を変えればmessage packに軍配が上がるのだろうけど、今回はこういったシンプルな条件でやってみた。

今度また再試験してみよう。

