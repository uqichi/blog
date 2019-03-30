---
title: "Macで辞書アプリをコマンドでらくらく開く"
date: 2016-01-18T14:04:09+09:00
draft: false
toc: false
images:
tags: 
  - macos
---

以下で開ける。

```bash
open dict://{単語}
```

めんどくさいのでエイリアスを貼る。
しかし、zsh, bashだと引数付きのエイリアスは貼れないので関数として定義する

```zsh
dict() { open dict://$1; }
```

以下でよりシンプルに開けるようになります。

```bash
dict {単語}
```

