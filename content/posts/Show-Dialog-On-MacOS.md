---
title: "コマンドでMacの画面に通知ダイアログを出す"
date: 2016-01-26T04:09:44+09:00
draft: false
toc: false
images:
tags: 
  - MacOS
---

TwitterのChromeプラグインの通知がうるさすぎるので、API叩いてMacの通知に流すシェル書けないかな〜のかな〜とかおもって。

`osascript`という、Apple Scriptを実行するコマンドが入ってます。
これを使って、アプリ通知を出します。

```bash
osascript -e 'display notification "hogehoge" with title "Fuga"'
```

シェルからも実行できます。

```shell
#!/bin/sh
/usr/bin/osascript -e 'display notification "hogehoge" with title "Fuga"'
```

Apple Scriptおもしろそうやん。
なにか使えそう。

