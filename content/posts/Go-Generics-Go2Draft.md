---
title: "GolangにおけるGenericsについて考えることでみえてくるGoらしさ"
date: 2018-10-12T00:01:11+09:00
tags: ["golang"]
categories: [""]
draft: false
---

# tl;dr

[Go 2 Draft](https://blog.golang.org/go2draft) が発表され、その中にはgenericsの機能追加が検討されています。この機会にジェネリクスとは何かについて考えてみたい。

以前はJavaを書いていて、当時使いながら便利だなあと感じていた。

けど、いわば抽象化テクニックであるgenericsを多用するとコードの可読性は著しく下がります。

そして、これが「Golang」というプログラミング言語の思想として正しい方向に向かうのかということもこっそり考えてみたい。


# Golangでジェネリクスを使いたい

現状はできない。 `interface{}` を使って強引に書くことはできるが、結果的には不完全な実装になる。これについては、あとでコードを紹介します。


# genericsの使い所と勘所

よくある、というかもしgenericsがあったとしたら真っ先に思いつくのがマップ操作。じゃないですか？

型としてのmapではないので、リスト操作と言ったほうがしっくりくるかも。

例えばリストの各値に対して処理したものを別の（または同じ）リストに詰め直すとか、リストの各値を合計した値を返却するだとか。

どういうものかは実装をみたほうが早いので、例としてmapのfilter処理を実装することで比較考察してみることにします。

なお、以下のようなパターンの実装をもとに比較します。


- go言語（interface{}を使わない）
- go言語（interface{}を使う）
- [fo言語](https://github.com/albrow/fo) - An experimental language which adds functional programming features to Go
- go言語（Go 2 Draftで提案されているもの）

実装するfilter関数についてはこちら https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array/filter

コードは全部githubにアプしております。

https://github.com/uqichi/go-filter-generics

[](https://github.com/albrow/fo)

# interface{}を使わずに実装

まずはシンプルにpure goで書いてみる。


    func filter(ls []int, f func(i int) bool) []int {
      ret := make([]int, 0)
        for _, v := range ls {
          if f(v) {
            ret = append(ret, v)
          }
        }
      return ret
    }

これを使ってみると、こんな感じ。


    ls := []int{1, 2, 3, 4, 5, 4, 3, 2, 1}
    
    res := filter(ls, func(i int) bool {
      if i == 3 {
        return true
      }
      return false
    })

結果は以下になる。


> [3 3]

さて、このfilter関数を使ってstringのリストを処理したいとなったらどうなるだろう。残念ながら現在のgoではできない。

素直に筋肉を使って新たにstring用のfilterを書くことになりおます。


    func filterInt(ls []int, f func(i int) bool) []int {
      ret := make([]int, 0)
        for _, v := range ls {
          if f(v) {
            ret = append(ret, v)
          }
      }
      return ret
    }
    
    func filterString(ls []int, f func(s string) bool) []string {
      ret := make([]string, 0)
        for _, v := range ls {
          if f(v) {
            ret = append(ret, v)
          }
      }
      return ret
    }

こうして、使いたい型の数だけ関数を実直に増やしていかなければならない。

**どうにかならないものか！**


# interface{}を使って実装

さて、こうなってくると共通化したくなる欲がムラムラと湧いてきます。

interface{}でどうにかならないか。


    func filterWithIface(ls interface{}, f interface{}) interface{} {
      lsVal := reflect.ValueOf(ls)
      fVal := reflect.ValueOf(f)
    
      ret := reflect.MakeSlice(reflect.TypeOf(ls), 0, lsVal.Len())
    
      for i := 0; i < lsVal.Len(); i++ {
        b := fVal.Call([]reflect.Value{lsVal.Index(i)})[0]
          if b.Bool() {
            ret = reflect.Append(ret, lsVal.Index(i))
          }
      }
    
      return ret.Interface()
    }

共通化はできた模様ですが、みるからにinterface{}だらけでこれどうなのよというかんじ。

これを使ってみると、


    li := []int{1, 2, 3, 4, 5, 4, 3, 2, 1}
    ls := []string{"a", "b", "c", "d", "e", "d", "c", "b", "a"}
    
    // filter list of int
    {
      res := filterWithIface(li, func(i int) bool {
        if i == 3 {
          return true
        }
        return false
      })
      resInt := res.([]int)
    }
    
    // filter list of string
    {
      res := filterWithIface(ls, func(s string) bool {
        if s == "c" {
          return true
        }
        return false
      })
      resString := res.([]string)
    }

なんかそれらしくまとめられました。しかし、これでは以下のような理由から実用的とは言えません。


- interface{}が出てきすぎて何が起こっているのやら。
- interface{}が抽象的すぎるため、関数が引数として渡されることを想定しているのに、なんでも入ってきうる。
- 上と同じ問題で、渡された引数の型が関数内で処理できるとは限らない。上の例だと `=` でcomparableな型がくるかどうかわからない。
- 関数の取得結果を対象の型でキャストしなければならない。

わざわざ説明しなくてもなんか無理そうな空気がプンプンします。interface{}多すぎ。

これを型安全に使えるようにするためには、結局 `filterWithIface` のなかで、switch文を駆使してハンドリングするしかなさそうです。

にしても、結果のキャストとかしなきゃいけないので、これは使えない。

**どうにもならないものか！**


# fo言語を使って実装

先日 golang.tokyo という勉強会でエウレカの臼井さんという方が紹介していたライブラリです。

https://github.com/albrow/fo - An experimental language which adds functional programming features to Go


> 関数プログラミングの機能をGoに追加すべく作られた実験的な言語

ということなので、こちらも実用段階ではありません。これがgenericsの機能を備えてるんですね。

簡単に使い方を説明すると、main関数書いて、 `fo run <filename>` するだけ。

これだけ。fo run すると、同じ階層に.goファイルが生成され、同時に実行されます。fo runしないと使えません。

これだけのfolangですが、playgroundが用意されています。

https://play.folang.org/

既視感が半端ないですね←

ということで、早速コードを使ってみることにします。まずはインストール。

なんとなくGOPATHを汚染したくいのでカレントディレクトリで済ませる。（folangさん、汚染って言ってすみません。）



    dep init
    dep ensure -add github.com/albrow/fo
    go build ./vendor/github.com/albrow/fo

`fo`のバイナリが生成されます。

次はfolangのgenericsを使ってfilter関数を書いていきます。

 `main.fo` というファイルを作ります。拡張子は .**fo** !!


    func filter[T](ls []T, f func(T) bool) []T {
      ret := make([]T, 0)
      for _, v := range ls {
        if f(v) {
          ret = append(ret, v)
        }
      }
      return ret
    }

これぞジェネリクス！直感的でいい感じ。

関数名の直後に `[type]` を入れることで、genericsを定義（ここでは `[T]` ）します。複数ある場合はコンマ区切りでかける。

以下はこれを実行したサンプル。


    li := []int{1, 2, 3, 4, 5, 4, 3, 2, 1}
    ls := []string{"a", "b", "c", "d", "e", "d", "c", "b", "a"}
    
    // int filter generics with fo lang
    {
      res := filter[int](li, func(i int) bool {
        if i == 3 {
          return true
        }
        return false
      })
    }
    
    // string filter generics with fo lang
    {
      res := filter[string](ls, func(s string) bool {
        if s == "c" {
          return true
        }
        return false
      })
    }

結果のキャストも不要です。

この `main.fo` を先ほどビルドした `fo` commandでrunします。


    ./fo run main.fo

と、`main.go` が生成され、実行されます。

可読性も悪くなく、なかなか実用に耐えるシンプルなジェネリクスな気がします。

しかし、こちらのfolang.. あくまで”experimental”なので使うのは厳しいですね。エディタで書いてもsyntaxもcompile checkもはいりません。流石に無理だ。

なお、生成された `main.go` の中身はどうなっているかというと、、、


    func filter__int(ls []int, f func(int) bool) []int {
      ret := make([]int, 0)
      for _, v := range ls {
        if f(v) {
          ret = append(ret, v)
        }
      }
      return ret
    }
    
    func filter__string(ls []string, f func(string) bool) []string {
      ret := make([]string, 0)
      for _, v := range ls {
        if f(v) {
          ret = append(ret, v)
        }
      }
      return ret
    }


結局、冒頭のinterface{}を使わず愚直に筋肉を使ったように、こちらも、関数利用する際に使用されているそれぞれの型に合わせてその分の関数が作られていますね。

つまり、**golangでgenericsを表現するには結局地道に関数を書いていくことが正**ということでしょう。

**しかし！**

まあめんどくさいよ。という声が多数挙がったのを聞いて、Go 2 Draftのなかでgenericsが上がったわけですね。



# Go 2 Draftのgenericsを使って実装

GenericsのDraft Designはこちら https://go.googlesource.com/proposal/+/master/design/go2draft-generics-overview.md

ここらでちょっともう疲れてきたので、早速書いてみます。Go 2にGenericsが入ることで世界はどう変わるのか。

※もちろんのことですが、ドラフト段階なので、動作確認はできません。ドラフトデザインに沿ったサンプル書けてるかもあやしい。。。



    contract Comparable(t T) {
      t == t
    }
    
    func filterInGo2Draft(type T Comparable(T))(ls []T, f func(T) bool) []T {
      ret := make([]T, 0)
      for _, v := range ls {
        if f(v) {
          ret = append(ret, v)
        }
      }
      return ret
    }


むむー。合ってるのかな？

個人的に、folangの方がわかりやすかった感じあります。

まず、Generics型を定義するには `type` を使って明示する必要があります。golangの定義をするときはすでにみんなそうしていますね。今回もそうしましょうといったところか。

そして次に、どうみても違和感のある新参者 `contract` 。

これは、folangではなかった機能で、実際に使われる型に制約を設けることができます。

上の例では、「Tの型は==で比較できますよ」ってことになります。Comparableって名前のは僕が自由に定義したcontractであって、重要なのは `t == t`の部分になります。

つまり、これまで書いた `i == 3` や  `s ==` `"``c``"` のような比較がおkですよ〜ってこと。型によってはこの==の比較ができないものがあるので、あらかじめ`contract`で縛ってやろうという算段ですね。

なるほど、folangよりも緻密にtype-safeなGenericsが書けることになります。

なお、 `type T Comparable(T)` の部分は以下のように省略が可能らしい。

→ `type T Comparable`

使うときは以下のような感じ（になると思います自信ない）


    li := []int{1, 2, 3, 4, 5, 4, 3, 2, 1}
    
    res := filterInGo2Draft(int)(li, func(i int) bool {
      if i == 3 {
        return true
      }
      return false
    })


はーい。以上。

Go 2 Draft Generics Designは、`contract` によって、Generics型のその後の振る舞いまで縛れるためより安全に記述することが可能になっているみたいですね。

なんかもはやGoっぽくはないと僕の直感は言っているのですが、Generics入ってきたらきたでめっちゃ使うだろうしめっちゃ謝謝ってなる気はします。



# 終わりに

Generics使えると便利！ですね。それを再認識しました。

一方で、Goがそれをやるか？やるか？という疑問もあります。うまく言えないけどシンプルなGoが..hmm

folangを教えてもらったgolang.tokyoの勉強会で、別で話してたスピーカーの [kaneshinさん](https://twitter.com/kaneshin0120) が、トーク終了間際に聴衆にこんなこと問うていました。

**「皆さんはGoらしさってなんだと思います？」**

僕なりには、シンプルで使いやすい。っていう非凡な答えに落ち着くのですが。。これにGenericsがどう組みいるのか、今後もwatchしていきたい所存です。

— 

コードは全部githubにアプしております。

https://github.com/uqichi/go-filter-generics

ご意見ありましたら、ツイートに反応したりDMしてください。

長々と、ありがとうございました。

