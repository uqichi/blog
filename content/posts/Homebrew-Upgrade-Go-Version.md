---
title: "HomebrewでGolangのバージョンを最新にアップグレード"
date: 2018-06-20T04:19:49+09:00
draft: false
toc: false
images:
tags: 
  - go
  - homebrew
---

## brew upgradeしたときの最新が古い

```bash
brew upgrade go
```

しても、現在の1.9.2が最新なんだと。ほう


## Fomulaをアップデート
[https://formulae.brew.sh/formula/go:embed:cite]

上のgoのformulaページ見るとStableが1.10になっている。ちゃんとなってるやん。

ということは自分のローカルのFormulaが古いようなのでpullする。

```zsh
cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula
git pull origin master
```

ちなみにこのpullするのをコマンドでするにはどうすればいいんだろうか。

わからなかったけど、今回はこれでいい。

pullできたらもう一度、

```sh
brew upgrade go
```



>
==> Upgrading 1 outdated package, with result:
go 1.9.2 -> 1.10.2
==> Upgrading go
==> Downloading https://homebrew.bintray.com/bottles/go-1.10.2.high_sierra.bottle.tar.gz
######################################################################## 100.0%
==> Pouring go-1.10.2.high_sierra.bottle.tar.gz
[==> Caveats
A valid GOPATH is required to use the `go get` command.
If $GOPATH is not specified, $HOME/go will be used by default:
  https://golang.org/doc/code.html#GOPATH
>
You may wish to add the GOROOT-based install location to your PATH:
  export PATH=$PATH:/usr/local/opt/go/libexec/bin
==> Summary
🍺  /usr/local/Cellar/go/1.10.2: 8,161 files, 336.7MB


確認してみよう。

```bash
go version
```

>go version go1.10.2 darwin/amd64

ちゃんと上がった。

ちなみに、Mac OS自体のバージョンもちゃんと最新にしておきましょう。じゃないと多分問題起きるよ。

