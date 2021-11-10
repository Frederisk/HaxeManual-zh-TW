<!--label:types-->
# 型別

Haxe 編譯器採用豐富的型別系統，其有助於在編譯時檢測程式中與型別相關的錯誤。型別錯誤是指對給定型別以無效操作的情況，例如嘗試除以一個字串、嘗試對數字欄位的存取或在呼叫一個函式時使用過多或過少的參數。

在某些語言中，這種額外的安全性是有代價的，程式設計師不得不將型別顯式分配給語法結構：

```as3
var myButton:MySpecialButton = new MySpecialButton(); // As3
```

```cpp
MySpecialButton* myButton = new MySpecialButton(); // C++
```
