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

在 Haxe 中則不需要顯式類型註釋，因為 Haxe 編譯器會推斷出型別：

```haxe
var myButton = new MySpecialButton(); // Haxe
```

我們將在稍後的[型別推斷](type-system-type-inference)中詳細探討 Haxe 的型別推斷。目前，只需要說明上述程式碼中的變數 `myButton` 是一個 `MySpecialButton` **類的實例**即可。

Haxe 型別系統可得知的七個觲別組：

- **類別實例**：給定了類別或介面的物件
- **列舉實例**：Haxe 列舉的值
- **結構**：匿名結構，即命名欄位的集合
- **函式**：可以接受一個或多個參數並且有回傳值的複合型別
- **動態**：與任何其他型別相容的萬用型別
- **抽象**：在執行期會由不同型別表示的編譯期型別
- **單態**：未知型別，在隨後可能會變為另一種型別。

我們將在隨後的章節中描述這些型別組以及它們之間的關係。

> #### 定義：複合型別
>
> 複合型別是具有子型別的型別，其包括任何具有[型別參數](type-system-type-parameters)與[函式](types-function)型別的型別。

<!--label:types-basic-types-->
## 基本型別

**基本型別**有 `Bool`、`Float` 和 `Int`，他們具有以下的值所以可以在語法中輕易識別：

- `Bool` 有 `true` 和 `false`
- `Int` 有類如 `1`、`0`、`-1` 和 `0xFF0000`
- `Float` 有類如 `1.0`、`0.0`、`-1.0` 和 `1e10`

基本類別在 Haxe 中並非類別，而是以抽象實作，並與編譯器的內部算子相繫結，如同下文所述。

<!--label:types-numeric-types-->
### 數字型別

> #### 定義：Float
>
> 表示雙精度的 IEEE 64 位浮點數。

> #### 定義：Int
>
> 表示整型數。

雖然每個 `Int` 都可以在預期為 `Float` 的地方使用，也就是說，`Int` 可**分配為** `Float` 或者是與 `Float` **相統一**，但是事實並非如此：將 `Float` 分配為 `Int` 可能會導致精度損失，因此並不允許這樣的隱含轉換。

<!--label:types-overflow-->
### 溢出

出於效能原因，Haxe 編譯器不會強制檢查任何溢出行為，檢查溢出的負擔落在了目標平台上。以下是一些特定平台上溢出行為的註解：

- C++、Java、C#、Neko、Flash：與 32 位整型數有相同的溢出機理
- PHP、JS、Flash 8：沒有原生的 **Int** 型別，當數字達到浮點限制時會有精度損失。

作為替代，可以使用 **haxe.Int32** 與 **haxe.Int64** 類別來確保正確的溢出行為，但這在某些平台上需要以額外計算作為代價。

<!--label:types-bool-->
### Bool

> #### 定義：Bool
>
> 表示**真**或**假**的值。

`Bool` 型別的值在 `if` 和 `while` 等的條件式中很常見。

<!--label:types-void-->
### Void

> #### 定義：Void
>
> 表示沒有型別，其通常用於表示一些東西（通常是函式）沒有值。

`Void` 是型別系統中的一個特例，因為它事實上不是型別，這用於表示沒有型別，主要用於函式的參數和傳回值。

在一開始的 Hello World 例子中，我們已經見過 `Void`了：

<!--[code asset](assets/HelloWorld.hx)-->
```haxe
/**
    多行文檔註釋。
**/
class Main {
    static public function main():Void {
        // 單行註釋
        trace("Hello World");
    }
}
```

函式的型別將在[函式型別](types-function)部分中詳細探索，但快速預覽在此處有助益：在上面例子中的 `main` 函式的型別是 `Void->Void`，也就是「沒有參數也不回傳任何東西」。Haxe 不容許 `Void` 的欄位或變數，如果有此類聲明，會發生錯誤：

```haxe
// 不容許 Void 的參數和變數
var x:Void;
```

<!--label:types-nullability-->
#### 可空性

> #### 定義：可空
>
> 在 Haxe 中，如果 `null` 可以分配給一個型別，那這個型別就是可空的。

通常而言，程式語言會對可空性有單一清晰的定義。
