---
title: "LVM作成してスナップショット機能を検証する"
date: 2014-10-22T04:30:42+09:00
draft: false
toc: false
images:
tags: 
  - centos
---

LVM作成してスナップショット機能を検証する
環境
VMWare, CentOs6

参考
検証内容
ゴール
LVM snapshot機能の確認

プロセス
CentOSのVMに5GBのHDDを2つ追加する
追加した2台のHDDを、LVMを利用して2GBと6GBの論理ボリュームを作成する
LVMスナップショット機能を利用し、/shareの静止点を作ったのうちtarコマンドでバックアップを取得する

/shareにファイル用意
スナップショット作成
/shareのデータを追加、変更
バックアップ作成(tar,rsync,cpio,,,)
1の時点のデータであることを確認
手順
デバイス登録
仮想マシンの設定でHDを2つ追加する。

追加してリブートしてでデバイスが認識されていることを確認。

$ fdisk -l
sdb, sdcが追加されている。

追加したデバイスをパーティションに登録。

$ fdisk /dev/sdb
$ fdisk /dev/sdc
LVM作成
PV作成
物理ボリュームを作成。

$ pvcreate /dev/sdb1
$ pvcreate /dev/sdc1
確認。

$ pvdisplay
VG作成
vg1というボリュームグループを作成。

$ vgcreate Vg1 /dev/sdb1 /dev/sdc1
確認。

$ vgdisplay
LV作成
vg1から2GBのlv1という論理ボリューム,6GBのlv2という論理ボリュームをそれぞれ作成。

$ lvcreate -L 2G -n lv2 vg1
$ lvcreate -L 6G -n lv1 vg1
確認。

$ lvdisplay // or lvscan
ファイルシステム構築。

mkfs.ext3 /dev/vg1/lv1
mkfs.ext3 /dev/vg1/lv2
適当なディレクトリにマウント
mkdir /data
mount -t ext3 /dev/vg1/lv1 /data

mkdir /share
mount -t ext3 /dev/vg1/lv2 /share
スナップショット作成
lv2論理ボリュームで、32MB容量のlv2ss1というスナップショットを作成。

lvcreate -s -L 32M -n lv2ss1 /dev/vg1/lv2
