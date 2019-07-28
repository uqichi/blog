---
title: "GoのSplit関数を使うときの注意 Field関数との挙動の違い"
date: 2019-07-28T20:16:52+09:00
draft: false
toc: false
images:
tags: 
  - golang
---

文字列をスペースや,や.をデリミタとして分割してスライスに入れたいこと、あると思います。

そんな時によく使われる標準パッケージの関数として、

- `Split`
- `Fields`

があるかと思います。
（`Fields` は空白文字をデリミタとして使用します。それ以外を指定したい場合は `FieldsFunc` を使います。）

突然ですが、以下のコードをみてください。

```go
s := "abc def xyz"

fmt.Println(len(strings.Split(s, " "))
fmt.Println(len(strings.Fields(s))
```

こちらの出力結果にはどうなるでしょう？

正解はどちらも「3」です。


続いてこちらをご覧ください。

```go
s := ""

fmt.Println(len(strings.Split(s, " "))
fmt.Println(len(strings.Fields(s))
```

対象を空の文字にしてみました。

どんな出力結果を期待しますか？



答えはこちらです。

>1
>0


これが今回言いたかったことなんですが、

*`Split` 関数を使った場合空文字を指定すると返却されたスライスの長さは0ではなく1となります。*

これは分割文字を `,` にしようが、 `.` にしようが同じ挙動をします。


ややこしい挙動をするなーと思ったのでメモでした。

例えばサブドメインを抽出するために `.` とかで分割しようとするケースで、

さて `Split` と `FieldsFunc` となった時に `Split` の方がインタフェースがお手軽なのでこっち使っちゃうことは多いと思うので注意です。


コードはこちら:

https://play.golang.org/p/Hl1xUHhhqDW
