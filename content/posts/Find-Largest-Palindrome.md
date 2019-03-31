---
title: "Find Largest Palindrome"
date: 2013-04-28T21:52:08+09:00
draft: false
toc: false
images:
tags: 
  - quiz
---

プログラムの問題といてみた。

→　[project euler](https://projecteuler.net/problem=4)

問題は

*三桁の数の積で作られる最も大きな回文数はなーんだ？*

というもの。

＊回文数とは：1221, 12321, 123321, 111111, 1,,,などあたまからよんでもおしりからよんでも同じ数。


以下、ソース

```java
public class P4 {

	public static void main(String[] args) {
		int answer = getLargestPalindrome();
		System.out.println(answer);
	}
	
	private static int getLargestPalindrome() {
		int largePal = 0;
		for(int i = 999; i > 0; i--) {
			for(int j = 999; j > 0; j--) {
				int[] arr = (MyUtil.splitIntToArray(i*j)).clone();
				if(isPalindrome(arr) && (i*j) > largePal) largePal = i*j;
			}
		}
		return largePal;
	}
	
	private static boolean isPalindrome(int[] arr) {
		for(int i = 0; i < arr.length/2; i++) {
			if(arr[i] != arr[arr.length-(i+1)]) {
				return false;
			}
		}
		return true;
	}
	
}
```

とりあえず、ささっと解けたけども、三桁の積の組み合わせぜんぶチェックしているのはさすがに効率悪すぎる。


ということで、まあ、それはあとで再考してみよう。




それより、この問題やっているときに、処理速度計測しつつコーディングしてて、けっこうおもしろかったので、それつかってなにか検証してみようとおもう。



次の記事に書く。
