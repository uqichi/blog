---
title: "処理速度の計測。System.nanoTime()"
date: 2013-04-29T21:31:55+09:00
draft: false
toc: false
images:
tags: 
  - java
  - performance
---

さて、処理速度の計測。

Systemクラスの`nanoTime()`メソッド。

は、現在の時間をナノ秒で返す。



ナノ秒？ナノって何分の一ナノ？←



なんと、

**1秒の10おくぶんの1**だそう。





`0.000000001sec = 1nanosec`ってことですね。！




んなこと言われてもよくわかりませんが、これで計測していきます。





ちなみに、`currentTimeMillis()`メソッドというのもあったんですが、こちらは1ミリ秒。精度劣るらしいんで、今回は`nanoTime()`を使用





とりあえず、かんたんに使いたいのでクラス作りました。

```java
import java.text.NumberFormat;
import java.io.*;

/**
*処理速度を管理するクラス.
*/
public class TimeMeasure {
	
	/**ナノ秒から秒に換算するための割数.*/
	private static final int DIVISOR = 1000000000;
	
	/**NumberFormatインスタンス.*/
	private static final NumberFormat nf = NumberFormat.getInstance();
	
	/**PrintWriterインスタンス.*/
	private static PrintWriter pw;

	/**計測開始時間.*/
	private double startTime;
	
	/**計測終了時間.*/
	private double endTime;
	
	/**
	*Constructor.
	*/
	TimeMeasure() {
		//フォーマットを10桁で指定
		nf.setMaximumFractionDigits(10);
	}
	/**
	*Constructor.
	*@param filename 計測結果を書き出すファイル
	*/
	TimeMeasure(String filename) {
		this();
		try {
			pw  = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new File(filename), true)));
		}catch(FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	/**
	*計測開始時間をセット.
	*/
	public void start() {
		this.startTime = System.nanoTime();
	}
	
	/**
	*計測終了時間をセット.
	*/
	public void finish() {
		this.endTime = System.nanoTime();
	}
	
	/**
	*計測結果を取得.
	*@return 指定範囲の処理にかかった時間を秒で返す
	*/
	public String getResult() {
		return nf.format((this.endTime - this.startTime) / DIVISOR);
	}
	
	/**
	*計測結果を出力.
	*指定範囲の処理にかかった時間を秒で出力する.
	*/
	public void printResult() {
		System.out.println(getResult());
	}

	/**
	*計測結果をファイルに出力.
	*指定範囲の処理にかかった時間を秒でファイルに追加して書き出す.
	*/
	public void writeResult() {
		pw.println(getResult());
		pw.close();
	}
}
```

使い方はかんたんで、速度を計測したい処理の記述されたソースを`start()` , `finish()`ではさんであげて、`printResult`でかかった時間を秒単位で出力となります。

結果をファイルに書き出す場合は、コンストラクタの引数にファイルのパスわたしてあげて、`writeResult()`してあげればいい。


命名は、ぼく個人が使いやすいようになのであしからず。


そして、今回試すこと。

*「ループまわしてArrayList参照するときに、終了条件の.size()って、毎回呼び出してるけど、変数入れて外出ししといたほうがいいんじゃないの？」*


*「いや、可読性さがるし、たいして変わらないから別にいいだろう。」*


っていう議論があったので、**何ナノ秒違うものナノ？**


てことで、やってみましょう

配列に1~1000の数字をつっこんで、forでまわして出力するプログラムです。


## case 1: forの外で変数に入れといてそれをを条件式に利用

```java
import java.util.ArrayList;

public class Test1 {

	public static void main(String[] args) {
		ArrayList<Integer> list = new ArrayList<Integer>();
		TimeMeasure tm = new TimeMeasure("test1.txt");
		
		//とりあえず数字1~1000をつっこむ。
		for(int i = 0; i < 1000; i++) {
			list.add(i);
		}
		
		//ここから計測
		tm.start();
		
		int size = list.size();
		for(int i = 0; i < size; i++) {
			System.out.println(list.get(i));
		}
		
		tm.finish();
		//計測結果を出力
		tm.printResult();
		//計測結果をファイルに書き出し
		tm.writeResult();
	}
}
```

## case 2: for文の条件式で毎回.size()で大きさ取得

```java
import java.util.ArrayList;

public class Test2 {

	public static void main(String[] args) {
		ArrayList<Integer> list = new ArrayList<Integer>();
		TimeMeasure tm = new TimeMeasure("test2.txt");
		
		//とりあえず数字1~1000をつっこむ。
		for(int i = 0; i < 1000; i++) {
			list.add(i);
		}
		
		//ここから計測
		tm.start();
		
		for(int i = 0; i < list.size(); i++) {
			System.out.println(list.get(i));
		}
		
		tm.finish();
		//計測結果を出力
		tm.printResult();
		//計測結果をファイルに書き出し
		tm.writeResult();
	}
}
```
 

はい。





ぼくもまだ結果みてないですが、今回、Test1, Test2それぞれ10回ずつ実行してtxtファイルにかきだました。



いちいち参照していないTest1のほうが早いはずですねそうあるべきですね。




たのしみですね。

みてみましょう。




**Test1の実行結果 > test1.txt**

>
0.040651008
0.036770048
0.032475136
0.036116224
0.040324096
0.03845504
0.043949056
0.043888896
0.040741888
0.0376192

**Test2の実行結果 > test2.txt**

>
0.040118784
0.041011968
0.044377856
0.0369152
0.042546944
0.040598016
0.040033024
0.041903872
0.03662592
0.04056192
 



あんまり、かわらない...？



え。






たぶん処理が軽すぎるんだろう。ということで次は1から100000までの数字を配列につっこむました。



千　→　十万

```java
for(int i = 0; i < 100000; i++) {
```
 

やってみました。






しかも、今回は、書き出したファイルの結果の平均も計算してみました。




以下、結果.

**Test1の実行結果 > test1.txt**

>
0.878774016
0.87911296
0.863933184
0.865096192
0.909432832
0.867913984
0.875821056
0.848235776
0.851052032
0.868338176

**Test2の実行結果 > test2.txt**

>
0.860528128
0.849287168
0.855068928
0.870048
0.86439296
0.845218048
0.866543104
0.865903872
0.905996032
0.856982016
 

んーよくわからん。あんまかわらないような。




しかし、今回はファイル読み込んで平均出すプログラムも書いたので平均値だしてもらいましょう。







**Test1.java**

>
0.8707710208000001

**Test2.java**

>
0.8639968255999999
 




＜結果＞



**Test1**

```java
int size = list.size();
for(int i = 0; i < size; i++) {
```

と、

**Test2**

```java
for(int i = 0; i < list.size(); i++) {
```

で、実行結果をそれぞれ10回記録し、その平均値を得たところ、

Test2のほうが、0.0067741952000002215秒速く処理する。





はい。




想定外です。






0.006secなんて、瞬きより速そうなんで、取るに足らない数字ですが。



`.size()`はfor文を実行したときに毎回毎回大きさを取得しているかとおもわれましたが、実はちがうのかもしれません。





配列格納が終了した時点で、ArrayListインスタンスに属するメタデータの一部としてsize値をもっているとか？




変数参照も、`.size()`による参照も、内部的にはけっきょく同様の参照なんですかね。



なんか、すっきりしませんでした。



今回のこれ、げんざい新卒研修のコードレビューにて小さな議論をかもしていて、毎度.size()の処理には無駄があるというニュアンスで話を受け取ったので、試してみました。





結果こういうことになったので、とりあえず、回答していた講師の方にきいてみようかとおもいます。





個人的には、今回つくったTimeMeasureクラスは使えるかなとおもいます。





プログラム問題を解くときなど、処理速度は気になりますし、まあ。