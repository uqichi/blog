---
title: "Vimを使ってapiaryのapibファイルを快適に編集できるようにする"
date: 2016-12-21T04:15:22+09:00
draft: false
toc: false
images:
tags: 
  - vim
  - apiary
---

今回はじめてapiaryを使ってAPIドキュメントの作成をやっています。
[API Blueprint 記法を学びながら](https://github.com/apiaryio/api-blueprint/blob/master/API%20Blueprint%20Specification.md#def-uriparameters-section)わりと快適に作業していたのですが、問題発生。

## 発生した問題
- 途中からapiraryのオンラインエディタのvalidationが遅すぎて死んだ
- apiaryの一時的な接続問題か、ブラウザの問題かはわからないが
- しかし、編集するたびにvalidateされるのはうっとうしい
- apiaryのvalidationをdisableする手段が現状ない
- ので、ローカルで編集してpushする方法に切り替えることにした

## [apiblueprint.vim](https://github.com/kylef/apiblueprint.vim)導入
API Blueprintのシンタックスハイライトとlintチェックをやってくださるプラグイン。

### 依存関係の[syntastic](https://github.com/vim-syntastic/syntastic)をインスコ
Vim周りのいろんなシンタックスチェックをがんばってくれるプラグイン。

```.vimrc
call dein#add('vim-syntastic/syntastic')

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
```

### 依存関係の[drafter](https://github.com/apiaryio/drafter#install)をインスコ
API Blueprintのvalidationを手伝ってくれるコマンドラインツール。

```bash
$ brew install --HEAD \
  https://raw.github.com/apiaryio/drafter/master/tools/homebrew/drafter.rb
```

### おまちかねの[apiblueprint.vim](https://github.com/kylef/apiblueprint.vim)をインスコ
```.vimrc
call dein#add('kylef/apiblueprint.vim')
```

### 便利な[Tagbar](https://github.com/majutsushi/tagbar)もインスコ
クラスとか関数のoutlineを表示してくれるプラグイン。

依存関係の[Exuberant ctags 5.5](http://ctags.sourceforge.net/)をインスコ

```bash
$ brew install ctags-exuberant
```

```.vimrc
call dein#add('majutsushi/tagbar')

nmap <F8> :TagbarToggle<CR>
nmap <F9> :TagbarShowTag<CR>
```

### apiblueprint.vimはjsonの構文チェックしてくれないので[vim-json](https://github.com/elzr/vim-json)もインスコ
jsonのシンタックスハイライト、構文チェックしてくれる。jsonの可読性をあげる`concealing`機能が超いい。

```vim
call dein#add('elzr/vim-json')
```

以上。

ごにょごにょ作業に時間食ったが、快適に過ごせそう〜

