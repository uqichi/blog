---
title: "DDDでモデリングをするときに知っておくべき構成要素"
date: 2019-07-30T00:41:07+09:00
draft: false
toc: false
images:
tags: 
  - DDD
---

保守性に欠けたコードを読むのは骨が折れるし、変更を加えて何が起こるかわからないコードには恐怖と不安が付いて回るから、モデリングを頑張りたい。

そんなところで、今回はドメインのモデリングをする上で最低限理解しておかなければならない登場キャラクターたちについて、チートシートとして使えるようにした。

ドメイン駆動開発についての書籍を読み返しながら。

- [エリック・エヴァンスのドメイン駆動設計](https://www.amazon.co.jp/%E3%82%A8%E3%83%AA%E3%83%83%E3%82%AF%E3%83%BB%E3%82%A8%E3%83%B4%E3%82%A1%E3%83%B3%E3%82%B9%E3%81%AE%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E9%A7%86%E5%8B%95%E8%A8%AD%E8%A8%88-Eric-Evans-ebook/dp/B00GRKD6XU)
  - 第2部 モデル駆動設計の構成要素 第5章 ソフトウェアで表現されたモデル
  - 第2部 モデル駆動設計の構成要素 第6章 ドメインオブジェクトのライフサイクル
- [実践ドメイン駆動設計](https://www.amazon.co.jp/%E5%AE%9F%E8%B7%B5%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E9%A7%86%E5%8B%95%E8%A8%AD%E8%A8%88-Object-Oriented-SELECTION-%E3%83%B4%E3%82%A1%E3%83%BC%E3%83%B3%E3%83%BB%E3%83%B4%E3%82%A1%E3%83%BC%E3%83%8E%E3%83%B3/dp/479813161X/ref=tmm_other_meta_binding_swatch_0?_encoding=UTF8&qid=&sr=)
	- 第5章 エンティティ
	- 第6章 値オブジェクト
	- 第7章 サービス
	- 第8章 ドメインイベント
	- 第9章 モジュール
	- 第10章 集約

ちょいちょい僕個人の表現や考えも入っていますのでご了承ください。あと、書き出したりメモしてるところも僕自身が興味あるとこだったり、わからないとこだったりしてるので、内容に偏りがあるかも。

あくまで個人メモ。ちゃんと原著読んでください。

ちなみに

今回は、コンテキストやコアドメイン/汎用ドメイン、アーキテクチャの内容は含んでいない。アーキテクチャについては、ちょいちょい入っちゃっているところもあります。

ファクトリ・レポジトリに関しては、入れてもよかったけど、理解がそんなに難しくなく、レイヤーアーキテクチャやデザインパターンで見知った人も多そうなことから今回は省略しています。（めんどくさかっただけ）

一旦初期のモデリング活動においては外しても怒られないでしょう。エヴァンズもそれっぽいこと言ってる

> リポジトリとファクトリは、それ自体はドメインに由来しないが、ドメイン設計においては意味のある役割をもっている （P. 122）


## エンティティ（Entities）
- 状態が異なったり実装を跨いだりしても追跡されるような、**連続性と一意性**を持つ
- 別名：参照オブジェクト（Reference Objects）
- 各オブジェクトを識別する手段を定義すること
- 同じものであるということが何を意味するかを定義しなければならない
- 同一性は世の中に本来備わっているものではない。これは「意味」である。**現実には同じものであってもあるドメインモデルにおいてはエンティティとして表現されるかもしれないし、そうでないかもしれない**
    - スタジアムの座席予約アプリケーションの例
        - 指定席の場合、席はエンティティ
        - 自由席の場合、席はエンティティではない
- クラスの定義をシンプルに保ち、ライフサイクルの連続性と同一性に集中すること
- 属性や振る舞いに集中するよりは、定義をもっとも本質的な特徴にまで削ぎ落とすこと
- 同一性を持つため、双方向の関連があると、保守が難しくなるかもしれない
- -
- データベースを主軸に考えると、データモデルがオブジェクトになり、Getter/Setterだらけのエンティティが出来上がってしまう（**ドメインモデル貧血症**）
- **一意な識別子**があって、オブジェクトが変化する
- ユビキタス言語に沿った**意図の明白なインタフェース**（ふるまい）を持たせる
- オブジェクトのバリデーション
	- 三つのレベル
		- 個別の属性/プロパティ
		- オブジェクト全体
		- オブジェクトどうしの合成
- オブジェクトのバリデーションと呼びたくない。それ単体で個別の関心ごとであり、ドメインオブジェクトではなくバリデーション専任のクラスが受け持つ責務だから。エンティティの責務はドメインおふるまいを扱うこと
- 変更の追跡にはドメインイベントとイベントストアが有効

## 値オブジェクト（Value Objects）
- 何かの状態を記述する**属性**
- 概念的な**同一性を持たない**
- 追跡を要求しないようなものに同一性を持たせてしまうとシステムの性能を失い分析作業が増す
- **何であるかだけが問題。どれだとか誰であるかとかは問わない**
- 値オブジェクトはエンティティを参照することもできる
    - オンライン地図サービスの例
        - ドライブルートの検索において、2都市と道路はエンティティであっても、その経路オブジェクトは値オブジェクト
- 「住所」は値オブジェクト？その質ものをしているのは誰か？
    - 通販ソフトの宛先→値オブジェクト
    - 郵便サービスの配達先→エンティティ
    - 電力会社ソフトの電力サービスの目的地→エンティティ、電力サービスを住居のような住所を持つエンティティと関連づけた場合、住所は値オブジェクト
- 操作のために**生成されては破棄される**
- エンティティの属性としても使用される
- 自分が伝える属性の意味を表現させ、関係した機能を与える
- **不変**なものとして扱う。完全に置き換える以外変更はできない
    - 所有者の手を離れている間、さすらうオブジェクトにはどんなことでも起こりうる
    - パフォーマンスの観点で参照（ポインタ）を使うことはありえる（フライウェイと、FLYWEIGHT）
        - 数が多くなる場合は一つの値オブジェクトを参照した方が効率がいい
    - いつ可変性を認めるべきか？
        - 値が頻繁に変化する場合
        - オブジェクトの生成や削除が高くつく場合
- 複雑な設計を避ける
- 値オブジェクトを構成する属性は、**概念的な統一体**を形成すべき（完結した値、WHOLE VALUEパターン）
    - 町、都市、郵便番号は、人オブジェクトの別々な属性であってはならない。ある住所全体の一部である
    - 50,000,000ドルは50,000,000とドルから成る金銭的な計測値
- 同じ値オブジェクト同士は相互に交換・コピーできる
- 同一性がないため、双方向の関連があっても、意味をなさない。しかし、双方向の関連は完全に取り除くよう試みること。どうしてもこれが必要となったら、そもそもそれを値オブジェクトとして宣言することを見直す。隠れた同一性があるはず
- -
- 値型は使うのも最適化するのも保守するのも楽
- 可能な限り、エンティティより値オブジェクトを使ってモデリングすべき
- 値の特徴
	- 計測・定量化・説明
	- 不変
	- 概念的な統一体
	- 交換可能性
	- 値の等価性
	- **副作用のないふるまい**

## サービス（Services）
- **アクションや操作**として表現した方が明確になるもの
- オブジェクト指向モデリングの伝統からはやや外れる
- 操作を行う責務をエンティティや値オブジェクトに押し付けない方が適切なとき
- 要求に応じてクライアントのために行われる何か
- ソフトウェアの技術的なレイヤには多くのサービスがある
- あんまり多用すると手続き型のコードになり**ドメインモデル貧血症**に陥る
- **単純に「もの」とはできないことがある**
- **概念的にどのオブジェクトにも属さないような操作**
- ドメインの重要な操作でありながら、エンティティにも値オブジェクトにも自然な落ち着き場所を見つけることができないもの。モデルに基づくオブジェクトの定義を歪めたり、意味のない不自然なオブジェクトを追加することになるもの
- 複雑な操作はシンプルなオブジェクトを侵食しその役割を曖昧にしかねない。そういう操作は多くのドメインオブジェクトを一緒に調整したり動かしたりすることが多い
- サービスがモデルオブジェクトになりすます時、こういう実行者は「マネジャー」などで終わる名前を持つことになる（デジャヴ…）
- 実態よりも**活動**、名詞よりも**動詞**
- 操作名はユビキタス言語に由来しなければならない
- 引数と結果はドメインオブジェクトであるべき
- 実際には何も表していない偽のオブジェクトとして宣言するよりも、モデルの中でサービスとして宣言されている方が、独立した操作によって誰かが誤解することはない
- 優れたサービスの三つの特徴
    - **操作がドメインの概念に関係していて、その概念がエンティティや値オブジェクトの自然な一部ではない**
    - **ドメインモデルの他の要素の観点からインタフェースが定義されている**
    - **操作に状態がない（ステートレス）**
- エンティティと値オブジェクトで構成される集合体の上に構築され、ドメインに本来備わっている能力をまとめ上げて、実際に何らかの処理を行うスクリプトのように振る舞う
- 細粒度のドメインオブジェクトを用いると、ドメイン層からアプリケーション層へ知識が流出するかもしれない（ドメインモデル貧血症を引き起こす）。アプリケーション層は、ドメインオブジェクトの振る舞いが組み合わされる場所だから。ドメインサービスを慎重に導入すれば、複数のレイヤ間で境界を鮮明に維持できる
- インタフェースの単純さが優先され、便利な中粒度の機能が提供される
- -
- サービスといってもSOAとかRPCとかMoMのそれとは異なる
- アプリケーションサービスとは違う。アプリケーションサービスはドメインモデルのクライアント
- サービスインタフェースの宣言は関わる集約と同じモジュール内で行う
- セパレートインタフェースは必須なのかというと必ずしもそうではない。大抵実装が一つなのだから
- ドメインサービスでパッケージングするとドメインモデル貧血症を引き起こしがち

## モジュール（Modules）
- モジュール間では**低結合**
    - 人が一度に考えられる物事の数には限りがある
- モジュール内では**高凝集**
    - 首尾一貫していない思考の断片は、思考がバラバラに溶け合ったスープのようなもの
- 別名：パッケージ（Packages）
- モデルにおいて意味のある一部として現れ、より大きな尺度でドメインを語らなければならない
- コードと概念の分割
- 粒度の大きいモデリング
- コミュニケーションの仕組み
    - いくつかのクラスを一つのモジュールに入れるということは、その設計を見る開発者に、それらをひとまとめに考えるよう伝えていることになる
    - **モデルが物語だとすれば、モジュールは章**
- モジュールにはユビキタス言語の一部になる名前をつける
- モデルと同様にモジュールも進化すべきだが、モジュールのリファクタリングは影響範囲が大きくなる
- インフラストラクチャ駆動パッケージングの落とし穴
    - 別々のサーバーにコードを分散させようという糸が実際にない限り、単一の概念オブジェクトを実装するコードは全て、同一のオブジェクトにはならなくても、同一のモジュールにまとめた方がいい
    - 抽象と具象の結合度が高いなら同じパッケージでいいじゃないか
- 概念の凝集した集合を含んでいるものを選ぶこと
- モジュール間が低結合にならないなら、概念のもつれをほぐすようにモデルを変更する方法を探す
- -
- **概念の境界**↔︎「集約」
- ドメインオブジェクト内のひとまとまりのクラス群をまとめる、名前付きのコンテナとして機能する
- いい例え
	- キッチンの引き出しには銀製のナイフとフォーク、スプーンがきちんとまとめられていて、ガレージの工具箱にはドライバーや電源タップ、ハンマーがちゃんと入っていてほしいよね。それぞれ混じっている状態って誰も嬉しくないよね。
		- placesettings.{Fork,Spoon,Knife,Serviette}
	- 一方、キッチンの整理整頓を機械的にやってしまおうとは思わないよね。頑丈なものは全部一つの引き出しにほうりこんで、壊れやすいものは戸棚の上の方にまとめるといった整理はしないよね。
		- pronged, scooping, blunt ...
- 対等なモジュールどうしの結合が必須に成る場合は、循環依存にならないようにすべし
- 境界づけられたコンテキストの前にモジュールを検討する。境界づけられたコンテキストはモジュールの代わりに使うべきではない


## 集約（Aggregates）
- **明確な所有権**と境界を定義しモデルを引き締める
- 集約が区切るスコープによって、**不変条件**が維持されなければならない範囲が示される
- ファクトリとリポジトリは集約を対象にとする
- 複雑な関連を伴うモデルでは、オブジェクトに対する変更の一貫性を保証するのは難しい
- 集約とは、**関連するオブジェクトの集まり**であり、**データを変更するための単位**として扱われる
- 各集約にはルートと境界がある
    - **境界**：集約の内部に何があるかを定義するもの。境界内のオブジェクトは互いに参照を保持しあっても良い
    - **ルート**：集約に含まれている特定の１エンティティ（**ルートエンティティ**）。集約のメンバの中で、外部のオブジェクトが参照を保持していいのはルートだけ
    - ルート以外のエンティティは局所的な同一性を持っているが、その同一性は集約内部でのみ識別できれば良い
- 自動車修理店向けのソフトの例
    - 自動車：集約ルートエンティティ
    - タイヤ：集約の境界内にあるエンティティ。特定の自動車というコンテキストの外部でタイヤの同一性が気にされることはない
    - エンジンブロック：集約ルート かもしれないしそうじゃないかもしれない。自動車とは独立して追跡されることがあればそれは集約ルートになる
- 集約のルートエンティティはグローバルな同一性を持ち、不変条件をチェックする最終的な責務を負う
- エンティティの同一性のスコープ
	- ルートエンティティ：**グローバルな同一性**を持つ
	- 境界内部のエンティティ：**ローカルな同一性**を持つ
- **集約の境界外部にあるオブジェクトは、ルートエンティティを除き、境界内部への参照を保持できない**
- ルートエンティティは内部のエンティティへの参照を他のオブジェクトに渡せるが、受け手側は参照を一時的に利用することができるだけで、その参照を保持してはならない。
- ルートがアクセスを制御するので、内部が知らないうちに変更されることはなくなる
- データベースに問い合わせて直接取得できるのは、集約ルートだけ。それ以外のオブジェクトは全て、関連を辿ることで取得しなければならない
- 削除操作は、集約境界内部に存在するあらゆるものを一度に削除しなければならない
- 集約境界の内部に存在するオブジェクトに対する変更がコミットされるときには、集約全体の不変条件が全て満たされていなければならない
- トランザクション効率にも繋がる。集約の境界が不適切に広いとロックがかかる時間も長くなるため
- -
- **トランザクション整合性の境界**↔︎「モジュール」
- トランザクションの分析をしてからでないと、集約の設計の良し悪しを正しく判断することはできない
- 小さな集約を設計する
	- **パフォーマンスやスケーラビリティの問題**に関わる
	- 究極、一意な識別子とそれ以外の属性を一つだけ持つ形
	- 結果整合性を保つことで逃げられないか考える
- 集約から別の集約を参照する際に、その識別子を使うように設計すべき
	- **切り離されたドメインモデル**
	- リポジトリあるいはドメインサービスを使って、集約のふるまいを実行する前に依存オブジェクトを検索する。クライアントであるアプリケーションサービスがこれを制御し、その後、集約に処理を回す
- 集約の境界の外部で**結果整合性**を使う
- 「命じろ、たずねるな」（デメテルの法則）
	- 情報隠蔽を重視した原則。最小知識の原則。クライアントは必要以上にサーバーの構造を知ってはならない。
- （アプリケーションの）利便性を重視するとどんどん合成して大きくなるし、かといって簡素にすると真の不変条件を守れなってしまう
- トランザクション整合性か結果整合性か？→**それは誰の役割か**を考える
	- ユースケースを実行するユーザー自身なら、トランザクション整合性を保つ
	- 別のユーザーあるいはシステムなら、結果整合性を受け入れる
- 集約のパーツを設計するときは、可能な限り、エンティティではなく値オブジェクトを使う
- 依存性の注入を避ける

## ファクトリ（Factories）

省略

## リポジトリ（Repositories）

省略


とりあえず、これをチートシートとして見ながらモデリング進めて行けば道を踏み外すことはないかと。

個人的な悩みは、モジュールの境界と集約の境界の切り方がむずいなーと感じてる。

一説では、モジュール＝集約もありというようなのを見かけたが、そうなるとモジュール小さくなりすぎないかねと思うところではある。

ちなみにモデリング会やる上で、今の所考えている流れはこんな感じです。


1. ユースケースを見つける（アプリケーション層のインタフェース）
2. エンティティを見つける
3. エンティティの属性（値オブジェクト）を見つける
4. エンティティのふるまいを見つける
5. サービスを見つける
6. モジュールを見つける
7. トランザクション整合性の境界（集約）を見つける

特に、2〜4を繰り返してモデルを洗練させるのが大事だと思ってる。

