---
title: "RAID5構築"
date: 2014-10-15T04:34:01+09:00
draft: false
toc: false
images:
tags: 
  - centos
---

参考
CentOSでソフトウェアRAIDの構築 - maruko2 Note.

**環境**

VMWare, CentOS6

**目標**

SCSI ハードディスクを 3個増設し、その 3個のディスクを使ってRAID アレイを構築する

**手順**

仮想HDD追加

VMWare work stationにて、 SCSI ハードディスクを 3個増設する。

設定＞デバイス＞「追加」＞ハードディスク

すると、`/dev/`にsdb, sdc, sdd,,,とディスクが追加されている。

RAID用にパーティション作成

```bash
fdisk /dev/sdb
```

:w でEnter.

他二つsdc, sddも同様に。

RAIDアレイ作成

```bash
mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sd[bcd]
```

構築完了まで時間がかかるので、プロセスを確認。

```bash
cat /proc/mdstat
```

RAIDアレイの設定

`/etc/mdadm.conf` にRAIDアレイの情報を記述する

```bash
mdadm --detail --scan >> /etc/mdadm.conf
```

RAIDアレイにファイルシステムを作成

```bash
mkfs -t ext3 /dev/md0
```

RAIDアレイをマウント

`/dev/md0` デバイスを、例えば `/data` ディレクトリにマウントする。

`/etc/fstab` を編集

```
/dev/md0  /data  ext3  defaults 1 2
```

`/data` ディレクトリを作成し、mount する。

```bash
mkdir /data
```

```bash
mount -a
```

アンマウント。

```bash
umount /data
```

マウント状況の確認

```bash
mount -v
```

とか

```bash
df
```
