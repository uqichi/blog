---
title: "MySQL5.7のインデックスを操作する方法"
date: 2018-09-05T18:48:16+09:00
tags: ["mysql"]
categories: [""]
draft: false
---

MySQL5.7のインデックス操作をメモ。

既存のテーブルにインデックスを追加する場合Syntax（書き方）が2通りあります。


1. **CRUDのSyntax**
2. **ALTER TABLEのSyntax**

カラムの変更などがあるときはALTER文で、インデックスの編集のみの場合はそれぞれのsyntaxで書けばいいと思います。

# インデックスを作成する

```sql
CREATE INDEX idx_1 ON teams (created_at DESC)
```

or

```sql
ALTER TABLE teams ADD INDEX idx_2 (created_at DESC)
```

# インデックスを削除する
```sql
DROP INDEX idx_1 ON teams
```

or

```sql
ALTER TABLE teams DROP INDEX idx_2
```

# インデックス"名"を変更する

MySQL5.7からできるようになりました。
これはALTER TABLE Syntaxしか用意されてないようです。

```sql
ALTER TABLE teams RENAME INDEX idx_x TO idx_y
```

# インデックスを変更する

キー部分の修正のことです。例えば、

`(created_at DESC)`としていたのを`(user_id ASC, created_at DESC)`に変えたいとか。もしくはそれと同時にインデックス名も変えたいとか。

ALTER TABLE構文でいうMODIFYやCHANGEをしたいみたいな。

しかし、インデックスではこれはできないので、一旦DROPしてから新たにCREATEするという手順になります。

```sql
DROP INDEX idx_1 ON teams;
CREATE INDEX idx_1_after ON teams (user_id ASC, created_at DESC);
```

参考

- https://dev.mysql.com/doc/refman/5.7/en/alter-table.html
- https://dev.mysql.com/doc/refman/5.7/en/create-index.html
- https://dev.mysql.com/doc/refman/5.7/en/drop-index.html

