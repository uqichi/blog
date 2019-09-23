---
title: Helmの光と闇
date: 2019-09-23T22:57:52+09:00
draft: false
tags:
  - kubernetes
  - helm
  - gitops
keywords:
  - kubernetes
  - helm
  - gitops
---

https://helm.sh/

Helm使ってとある実装をしたので、メリットとデメリットを整理しておきたい。

# Pros - 光


## 動的にパラメーターを埋め込める

KubernetesはManifestと呼ばれるyamlファイルを記述することで、コンテナの状態を宣言的に管理することができる。

                                

しかし、複数の環境（テスト環境、本番環境など）があるとき、共通部分を多く持ち合わせることになるため、似たようなManifestをいくつも書かなければいけないケースがある。

Helmを使うと、テンプレートファイル（KubernetesのManifestファイル）に任意の値をセットしてデプロイすることができる。

ちなみにこのテンプレートファイルを含む独自のパッケージング機構のことをHelmでは**Chart**と呼ぶ。

例えば、以下のようなテンプレートファイルを定義する


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

このとき、
テスト環境ではレプリカ数2、本番環境では4としたいとして、その部分を変数定義してくと、デプロイ（リリース）する際にそれぞれの環境でパラメーターを渡すことで（`--set` や `--values` を使って）、マニフェストはそのままにデプロイ変数を変えることができる。

コマンドは以下例


```bash
// テスト環境
helm install --set replicas=2 test

// 本番環境
helm install --set replicas=4 production
```

こういうことしたいときに類似のツールとして**Kustomize**がある。これはGoogleさんお手製で、去年 `kubectl` に取り込まれて標準となった。 `kubectl -k` で使える。


## パッケージマネジャーとしてのHelm

また、アプリケーションをデプロイするとなるとたいていの場合、Deployments, Service, Configmapなどと、色々なKubernetesリソースが複合的に組み合わさって、一つのアプリケーションとして動作する。

Helmはこの複数のKubernetesリソースを、**Package**という機能を使ってパッケージングしてくれる。

いや、*Kubernetesのマニフェストでも複数リソースの定義はできるじゃないか？*

確かにできる。

一つのマニフェストのなかに `---` で区切り線を使って定義するか、もしくはディレクトリに複数マニフェストファイルを入れて、 `kubectl -f ./dir` すればいい。

しかし、Helmはパッケージマネジャーとしてより強力な機能を提供している。


## リリースバージョニング

**Release**を使うことで、Helmは複数のリソースからなる**一つのアプリケーション単位で世代管理**してくれる。

これはすなわち、**サービスの単位でロールバックが可能**ということだ。

ちなみに、KubernetesのDeploymentsがやってくれる世代管理はリソース単位。

ちなみに、先ほど紹介したKustomizeにはこの機能はなく、現状Helmの大きなアドバンテージと言っていいだろう。

## Helm Chart Repository

例えば、datadogをクラスタにデプロイしたいとする。

自分でDeploymentを書いて、ServiceAccountやConfigMapを追加して、、とやるのが通常。

Helmにはみんながよく使うツールやライブラリをパッケージ化したチャートが豊富に用意されている。チャートはもちろん自作もできる。

なので、datadog入れたいってなったらチャートを持ってきて、動的にパラメータ変えたいとこ変えて `install` してしまえばdoneとなる。

要は、人気のツール使うときにごにょごにょ書かなきゃいけないのをほとんど書かなくてよくなって、設定値を渡すだけでよくなる。

これがPackageの恩恵。


----------

ここまでは、Helmのありがたい機能を紹介したけど、実際使ってみて闇を感じたところもあったのでそちらも紹介していく。


# Cons - 闇


## "宣言的"ではない

動的に値を埋め込めるのはいい。パッケージングできるのもいい。

ただ、Helmを使った結果、**宣言的な管理が難しくなる。**

 `helm install --set`  や `helm install --values` という形のコマンドインタフェースしか持っていないため、パラメーター＋テンプレートや複数のReleaseを宣言的に管理できない。
 
 これを解決するために[helmfile](https://github.com/roboll/helmfile)というOSSがある。
 
 helmfileを使うと、**状態のあるべき姿**を`helmfile.yaml`に記述することで、あとは`helmfile apply`するだけでいい。


## 黒魔術を使ったテンプレートファイル

Helmのチャートテンプレートのなかを覗くと突然 `{{ .Values.hoge }}` とか `{{ include "temaki.labels" . | indent 4 }}`とか出てくる。

これの正体は、[GoのTemplateという標準ライブラリ](https://golang.org/pkg/text/template/)の記法だ。

HelmのソースコードはGoで書かれていて、パラメーターの変数埋め込みの機能の部分はこれがそのまま採用されている。

なので、良い感じのチャートを作るためには頑張ってこちらを学習する必要がある。

もともとGoを書いている人ならまだ良いけど、初見だとなんだこの記法は・・となるんじゃないだろうか？

というわけでプログラミング言語の標準そのままなので、やろうと思えばやりたいことは割となんでもできる。forとかifとか。

最初は・・・

マニフェストの定義をしていたつもりでも気づいたらあなたはプログラミングをしていることだろう。。。

Helmを触っていたつもりでも気づいたらGoを書いている人になっている。。。

その柔軟性ゆえに、Helmチャートは黒魔術化しやすい。

正直人が書いたチャート読みたくない・・・

でも自分でチャート描きたくない・・・・・


## 公開チャートは万能ではない

上で、datadogの例でチャートをインストールすればよしという話を下が、いつでもこの方法が全てを解決してくれるとは限らない。

なぜか？

パラメーター渡せば済むから簡単じゃないのか？

理由はそこにある。

**本来のKubernetesマニフェストを書くことにHelmが独自の制約を作ることで、パラメータを渡すだけでよくなり、開発者の考えることを減らしてくれている。**

裏返せば、そうして柔軟性を奪われているために、ここもパラメータで渡したいんだけど・・というケースには対応しないからだ。

提供されているチャートが自分のユースケースには合わない場合は、独自にチャートを変更する必要がある。


## 複数のRelease間であるリソースを共有できない

これはnicheな悩みだったので、具体的に困ったことをのべる。

以下のような構成をとりたかった。



![](https://paper-attachments.dropbox.com/s_2E56CA8496D292EA33B7C3BB858B7162E5416B919A8A56A586EF37760B86DE93_1569246365412_VTB1JiCm30RWkvyYoXsfQQjj0Z5DE--0s77Y46glYmX9bPOTDl7k984DJuNs5El_xBHML_sWm_3nRW5D6tHt4Aqum_Tf1q6xDpH1F0gvUPRmyW3E8yLWxztGcnEbHCqaz0VTvOAiDLrFsHAsoSOJoDHNo5XP_Kes3_GQnLfRxHeAR4AWnWVC0tANkkdQKZYQXdxZSZgUJyVLJVpaKHpLnBlKOrvEyCMOLt_pouBkzuMuMugV.png)


Podには同じアプリケーションの違うバージョンが乗る。

このときはじめに作成したチャートのテンプレートには以下のリソースを含んだ。


- Ingress
- Service
- Deployment

Ingressは全リリースで共通にして、ルーティングルールで向き先を変える運用にしたかった。

が、結果的にこれは期待して期待していた挙動にはならなかった。

何が起こったかというと、例えばv1のリリースをデプロイする。そのあとにv2のリリースをデプロイすると、もともと存在したIngressリソースは削除され新たにIngressが再作成される動作になる。

そうなると何が起こるかというと、クラウドベンダー側ではロードバランサーが再作成されてしまい、IPアドレスとIDが変化するため、DNSのAレコードが外れてしまい名前解決されなくなってしまう事になる。

[external-dns](https://github.com/kubernetes-incubator/external-dns)を使ってDNSのレコードセットも同期させればいいじゃないとも思うが、新しいアプリケーション環境が追加されるたびにロードバランサが再作成されるのは、なんか不愉快だ。

というわけで、この問題については、IngressだけHelm Releaseを分けることで解決した。

---

以上！

僕は今回要件的にKustomizeだと難しそうだったのでHelmを採用しました。

標準でシンプルなKustomizeと比べるとなかなか闇深い面を備えているけれども、バージョニングしてくれるところとかチャートレポジトリにあやかれるところとかはHelmならではの良さですね。

Helm便利ですね。結構難しい要件にも対応できる。
