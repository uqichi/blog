---
title: "GKEがEKSより優れている点をまとめる"
date: 2019-09-22T00:37:34+09:00
draft: false
tags:
  - kubernetes
  - gke
  - eks
---

![](https://miro.medium.com/max/600/1*AW9u5KpikeJ9BxlxvaIohw.png)

最近EKSもGKEも触ってみた中で感じたGKEの優位性について書き留めておく。

逆はどうなのかという点、EKSが優っているメリットは今の所特に思いつかない。

GCP vs AWSというクラウドベンダーの比較の観点からすると、それぞれの分野で甲乙出てくるだろうが、今回はあくまでGKE vs EKS。

なので、実際に導入・選定するときには周りの他のサービスやエコシステム、セキュリティや安定性、コンプライアンスといった色々な観点で選ぶ必要がある。

## 安い

GKEはMaster Nodeが無料。

一方でEKSでは**$0.20/h**が固定でかかる。

例えば、テスト環境・ステージング環境・本番環境という３つの環境があって、それぞれクラスタを分ける構成をとっていたとする。

$0.20 x 24hour x 30day x 12year x 3env = $5184 x JPY108.22 = 年間561,012.48円

結果、EKSを採用した時点で、年間56万円の費用が上乗せされる。

GKEだとこの分の固定費用が一切かからない。


## クラスタ構築が爆速
- GKEは3分
- EKSは20分

なんでここまで差があるのか。


## GKE標準ダッシュボード

PodやServiceの稼働状況やコンテナログ(Stackdriver)への導線などがあるダッシュボードがGKEには標準でついている。

これはメトリクス情報のことではなくて、普段 `kubectl get pods` などのコマンドを叩いた結果みることのできるPodやServiceの状態がUI上で眺められる。

EKSにはこれがなく、そもそもEKSのコンソールには開発やデバッグで参考になる情報が何もない。

実際EKSを使ってみるとわかるが、このコンソール画面にアクセスする機会はないに等しい。

一方、GKEを使うととりあえずこの標準ダッシュボードを見ていれば基本的な情報があるし、ノードのメモリやCPUが不足しているせいで一部のPodが起動していない状況をUI上で教えてくれたりするので常にこの画面を見ながら開発やデバッグを快適に行うことができる。

EKSでこれが欲しければ公式のダッシュボードをインストールする感じになる。

https://github.com/kubernetes/dashboard


## Cluster Autoscalerがワンポチ

GKEではクラスタサイズのオートスケーリングの設定がGKEダッシュボードから簡単に行える。

desired, max, min を入力してボタンを押すだけ。

EKSでは詳しくは https://aws.amazon.com/jp/premiumsupport/knowledge-center/eks-cluster-autoscaler-setup/ をご覧いただきたい。


## Stackdriverがデフォルト

まずはStackdriverがどんな機能を持っているかを簡単に挙げる。


- ログ
- モニタリング
- 分散トレーシング
- デバッグ
- エラーレポート

何も考えずにクラスタを作ると、このうちログとモニタリングはデフォルトで有効になっていて、すぐに開発に取りかかれる。

EKSは今年５月にようやくこれらの情報が見れる[Cloud Watch Insights](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)が発表された。現在はOpen Previewのステータスとなっている。

これを利用することで無事ログとモニタリングが見れるようになる。

それまでは、そのノードやコンテナのメトリクスやログを収集するためには、別途FluentdやDatadogなどのオープンソースやSaaSなどを利用する必要があった。

分散トレーシングについては、AWSのマネージドサービスを使う場合は[AWS X-Ray](https://aws.amazon.com/jp/xray/)となる。


## Istio on GKE（Beta）

https://cloud.google.com/istio/docs/istio-on-gke/overview

[Anthos](https://cloud.google.com/anthos/docs/concepts/anthos-overview?hl=ja)のベータ機能。まだ使ったことはない。

普通にIstioインストールするといくらか手順を踏む必要があるのだが、これだと設定画面で有効/無効があるので、有効にするだけでIstioが使えるようになるらしい。

>easily manage the installation and upgrade

インスコとアプデがラクチン

>If you need to use a more recent open source version of Istio, or want greater control over your Istio control plane configuration (which may happen in some production use cases), we recommend that you use the open source version of Istio

最新バージョン使いたかったりIstioのコントロールプレーン完全制御したかったら、OSSの方つかってね

OSSのIstioのインストール自体はそんなに大変じゃないので、普通に入れるでも良さそう。後々Pilotとかの設定いじりたくなった時困るし。


## Spinnaker on GKE
https://www.infoq.com/jp/news/2019/09/netflix-google-spinnaker-gcp/


これも割と最近発表されたやつ。

SpinnakerもOSSだが、こちらはインストールするまでの手順が煩雑で正直めんどくさい。全てコマンドベースでできるようにはなっているけども。

[この動画](https://www.youtube.com/watch?v=z4riSXd3Y5w)みるとわかるけど、これは俄然楽そう。


## Cloud Shell便利すぎ

本件はEKS/GKEには関係ない。

ただただ、AWSいつも使っている身で、このCloud Shellを使うとありがたすぎてツライ。

ブラウザ上でエフェメラルなコンテナ環境が起動しその中で、様々なターミナル作業ができる。手元のローカル環境で `kubectl` や `helm` コマンドインスコしたりしなくていい。大方のものはすでに入っている。認証もGoogle認証だから必要ない。

詳細は省略。


## ノードの自動修復

https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-repair?hl=ja

>GKE のノードの自動修復は、[クラスタ](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture?hl=ja)内の[ノード](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture?hl=ja#nodes)の実行状態を正常に保つための機能です。この機能を有効にすると、GKE はクラスタ内の各ノードのヘルス状態を定期的にチェックします。ノードが長期にわたって連続してヘルスチェックに失敗すると、GKE はそのノードの修復プロセスを開始します。

EKSにはない。


## ノードの任意自動アップグレード

https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-upgrades?hl=ja

>ノードの自動アップグレードを有効にすると、マスターが更新されたときに、クラスタ マスター バージョンを使用して[クラスタ](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture?hl=ja)内の[ノード](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture?hl=ja#nodes)を最新の状態に維持できます。

EKSにはない。

## 高可用性 99.9999...%

これはAWSとGCPのネットワークの仕組みの差で、GCPはネットワーク(VPC)が世界の全リージョンにまたがることができるので、理論上どこまでもHigh Availableなのだ。（実際ここまで必要なケースは少ないかも）


## Kubernetes生みの親Google

GKEにのっかっておけばその分、Kubernetesと親密でズブズブなエコシステムの中に身を置けるはずだ。
EKSはあとをついてくる感じになっている（最近出たCloud Watch Insightsなどもそう）

