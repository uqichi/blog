---
title: "Protocol Buffer と Message Pack の違いとベンチマークを比較"
date: 2018-09-24T23:57:14+09:00
tags: ["protobuf","msgpack"]
categories: [""]
draft: false
---

**TL;DR**

恥ずかしながらProtocol BufferとMessage Pack触ったことない..。

ので、実際に触ってみて、自分なりにみて考えるみるのが目的。

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

# Protocol Bufferの使い方
## IDLを定義する
必要なツール群をインスコ

```bash
brew install protobuf
go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
```
	
`.proto`ファイルを作成

```protobuf
syntax = "proto3";

package proto;

message Product {
    uint64 id = 1;
    string name = 2;
    string description = 3;
    int32 price = 4;
    repeated string colors = 5;
}

message ProductList {
    repeated Product products = 1;
}
```

コンパイルしてシリアライザのコードを生成

```bash
mkdir -p proto
protoc --go_out=proto *.proto
```

https://github.com/uqichi/go-protobuf-msgpack/blob/master/proto/product.pb.go が生まれました。

簡単にAPIを実装してみる

```go
package main

import (
	"log"
	"net/http"

	"github.com/golang/protobuf/proto"
	_proto "github.com/uqichi/go-protobuf-msgpack/proto"
)

func main() {
	http.HandleFunc("/protobuf", handlerProtobuf)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}

func handlerProtobuf(w http.ResponseWriter, r *http.Request) {
	p := &_proto.Product{
		Id:          191919191919,
		Name:        "FIFA World Cup Soccer Ball",
		Description: "Lorem ipsum dolor sit amet,,,",
		Price:       18900,
		Colors:      []string{"red", "yello", "blue"},
	}

	res, err := proto.Marshal(p)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	w.Header().Set("Content-Type", "application/protobuf")
	w.WriteHeader(http.StatusOK)
	w.Write(res)
}
```

# Message Packの使い方
続いて、Message Packも実装してみます。

ライブラリは複数あるようですが、今回は `github.com/vmihailenco/msgpack` を使っています。

```go
package main

import (
	"log"
	"net/http"

	"github.com/vmihailenco/msgpack"
)

func main() {
	http.HandleFunc("/protobuf", handlerProtobuf)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}

type product struct {
	Id          int64
	Name        string
	Description string
	Price       int32
	Colors      []string
}

func handlerMsgpack(w http.ResponseWriter, r *http.Request) {
	p := &product{
		Id:          191919191919,
		Name:        "FIFA World Cup Soccer Ball",
		Description: "Lorem ipsum dolor sit amet,,,",
		Price:       18900,
		Colors:      []string{"red", "yello", "blue"},
	}

	res, err := msgpack.Marshal(p)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	w.Header().Set("Content-Type", "application/x-msgpack")
	w.WriteHeader(http.StatusOK)
	w.Write(res)
}
```

Protocol Bufferと比べて、IDLがないので、シリアライズする実装のみ書けば使える。

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
うーん。なんでだ...

条件を変えればmessage packに軍配が上がるのだろうけど、今回はこういったシンプルな条件でやってみた。

今度また再実験してみよう。

# まとめと所感
Protocol Buffer, Message Pack, JSONを比較してみたわけだが、それぞれ使い所がありそう。

Protocol BufferとMessage PackがJSONより高速で軽いからといって、JSONが使えないことは決してなく、例えば外向けのAPIを提供する場合なんかはJSONが使われるのがもっとも効率的だと思う。

コンパイラ要らないし、読みやすい。 
また、デバッグがしやすいというのもJSONの強み。バイナリ化されると普通は読めないのでHTTP Clientによる開発にはやはりJSONが返却された方がやりやすい。
逆に、Message Pack使うと結構大変そうだ。

Protocol
BufferのIDLは多言語間でのデータのやり取りをする上でかなり役にたつ。近年はAPIサーバーを立てて、web・iOSアプリ・Androidアプリがぶら下がってるようなプロジェクト構成が一般的になりつつあるので、IDLによって構造を定義し、互換性のあるデータの交換やドキュメントにもなりうるのはとても嬉しい。
フィールド名も抽象化されるため、簡単にrenameできるし型変更だって容易。
Message Packにも、proto3からJSONにもコンパイルできるということなのでこれを使わない手はない。

Message Packは手軽に使えるというのが利点、なのかな。これは、IDLみたいなスキーマ定義がないということの裏返しになる。
スキーマがはっきりしないもの、構造化や正規化が難しいものには相性が良いみたい。
アプリケーションログなんかをファイルに書き出してやるとか。
データストアだと、RedisみたいなKVSとかドキュメント指向のMongoDBとかは、いいお友達になれるんじゃないか。

一番大きい違いと使い所の見極めは、**スキーマ定義をするかしないか**だと思いました。

するならProtocol Bufferは絶対使った方がいい。

しないなら、JSONかMessage Pack。JSONは可読性が高く扱いやすいし汎用的。MessagePackは高速で軽い。

って感じかー。

結局Protocol Buffer使うのが最良なんじゃないという結論に落ち着いたので、次回はgRPCを試してみようと思う。
