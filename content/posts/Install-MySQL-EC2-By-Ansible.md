---
title: "AWS EC2にansibleでmysqlインストール"
date: 2016-10-14T04:27:31+09:00
draft: false
toc: false
images:
tags: 
  - mysql
  - aws
  - ec2
  - ansible
---

golangのAPIサーバー構築のためにmysql使いたいからansibleでやってみるかってノリだけなので、簡易的にやります。 ansibleのaの字くらいでやります。nsibleは後で学ぶ。

このへんみながら
http://qiita.com/bboobbaa/items/c5466369d744a29dc6e9
http://qiita.com/bboobbaa/items/d2288724bdefeff1c550
http://docs.ansible.com/ansible/yum_module.html
EC2
省略。無料のmicroインスタンスを立てる。

ansibleをインストール
ひとまず。

brew install ansible
鍵指定なしでsshできるようにしておく
pemファイルをダウンロードして~/.ssh/ec2test/に配置

キーを指定せずsshできるようにconfigに以下を追記。

Host 52.198.155.206
  User ec2-user
  IdentityFile ~/.ssh/ec2test/ec2test.pem
Inventory
[ec2-52-198-155-206.ap-northeast-1.compute.amazonaws.com]
52.198.155.206
疎通確認
~ ❯❯❯ ansible ec2-52-198-155-206.ap-northeast-1.compute.amazonaws.com -m ping                                                                                                     master
52.198.155.206 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
実行
ansible-playbook -i hosts site.yml
mysqlの起動時にエラー発生
MySQL server PID file could not be found!
とりあえず、エラーログ見てみる。

2016-10-14 05:15:55 12056 [ERROR] Fatal error: Can't open and lock privilege tables: Table 'mysql.user' doesn't exist
データ格納するディレクトリがどこかわからなくなってるので指定してあげる。

mysql_install_db --datadir=/var/lib/mysql --user=mysql
FATAL ERROR: please install the following Perl modules before executing /usr/bin/mysql_install_db: Data::Dumper

Perlのサブパッケージが足りないらしいのでこれもタスクに追記。 出力補助系のライブラリみたい。

そして、最後。

ansibleのmysqlタスク実行時にエラー発生
msg: the python mysqldb module is required というエラーメッセージが出る。

これ、MySQL-pythonをインストールすればokらしいけど、インストールしてなお止まない。

結構はまって、ようやく解決。 http://akira-junkbox.blogspot.jp/2016/04/ansiblemsg-python-mysqldb-module-is.html

インストールしたにもかかわらず、msg: the python mysqldb module is requiredが出続ける場合、サーバ上のPythonのバージョンを確認してください。 実はOSによっては、Pythonのバージョンによって、MySQL-Python27のようにパッケージ名が異なるものがあります。

ということでした〜。

無事、すべてのタスクが通ったら、 当該ec2インスタンスにsshして、

mysql -u root testuser -ptestpass
でWelcome~

以下、修正された後の最終的なメインファイル。

---
- hosts: ec2-52-198-155-206.ap-northeast-1.compute.amazonaws.com
  #user: ec2-user
  sudo: yes
  vars:
    mysql_url: http://dev.mysql.com/get/Downloads/MySQL-5.6
    mysql_ver: "5.6.26-1"
    mysql_items:
      - rpm: MySQL-client-{{ mysql_ver }}.el6.x86_64.rpm
      - rpm: MySQL-devel-{{ mysql_ver }}.el6.x86_64.rpm
      - rpm: MySQL-server-{{ mysql_ver }}.el6.x86_64.rpm
      - rpm: MySQL-shared-{{ mysql_ver }}.el6.x86_64.rpm
      - rpm: MySQL-shared-compat-{{ mysql_ver }}.el6.x86_64.rpm
  tasks:
    - name: install mysql
      yum: name={{ mysql_url }}/{{ item.rpm }} state=present
      with_items: mysql_items
    - name: install dependency packages
      yum: name={{ item }} state=present
      with_items:
        - perl-Data-Dumper
        - MySQL-python27
    - name: setup mysql datadir
      shell: mysql_install_db --datadir=/var/lib/mysql --user=mysql
    - name: start mysql
      service: name=mysql state=restarted enabled=yes
    - name: get mysql password
      shell: cat /root/.mysql_secret | awk '{print $18}'
      register: mysql_root_password
    - name: copy .my.cnf
      template: src=.my.cnf.j2 dest=/root/.my.cnf owner=root mode=0600
    - name: setup mysql database
      mysql_db: name=testdb state=present
    - name: setup mysql user
      mysql_user: name=testuser password=testpass priv=*.*:ALL,GRANT state=present
今回はいきなり実践的に使ってみたなので、別途ansible基本から勉強すること。
