---
title: "Bonding構築"
date: 2014-10-15T04:32:07+09:00
draft: false
toc: false
images:
tags: 
  - centos
---

参考

[VMWare] VMWareのVMのNICの増設方法（CentOSの場合） - eji著

意外と知らない？NICを冗長化するボンディング（bonding） - うさぎ文学日記

CentOS/NICの冗長化（bonding設定） - maruko2 Note.

http://open-groove.net/linux/linux-bonding-fail-over-test/

**環境**

VMware, CentOS6

**目標**

2NICに1IPを割り当てる

**手順**

現状確認

```
ifconfig
```

ネットワークアダプタがいまんところeth0だけであることを確認。

ネットワークアダプタを追加
VMWare work stationにて、ネットワークアダプタを2個増設する。

設定＞デバイス＞「追加」＞ネットワークアダプタ

ブリッジを選択して完了
再起動して再度 ifconfig

eth1とeth2が増えていることを確認。

問題なく通信できることを確認

```bash
ping yahoo.co.jp
```

NICの設定

以下の設定ファイルを作成/変更。

`/etc/sysconfig/network-scripts/ifcfg-bond0`

```
DEVICE=bond0
BOOTPROTO=none
ONBOOT=yes
NETWORK=192.168.1.0
NETMASK=255.255.255.0
IPADDR=192.168.1.11
```

`/etc/sysconfig/network-scripts/ifcfg-eth1`

```
DEVICE=eth1
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
```

`/etc/sysconfig/network-scripts/ifcfg-eth2`

```
DEVICE=eth2
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
```

VM再起動.
これでいちおう完了。

確認

```bash
cat /proc/net/bonding/bond0
```

または、

```bash
ifconfig
```
