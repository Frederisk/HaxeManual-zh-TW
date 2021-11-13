<!--label:types-->
# 型別

Haxe 編譯器採用豐富的型別系統，其有助於在編譯時檢測程式中與型別相關的錯誤。型別錯誤是指對給定型別以無效操作的情況，例如嘗試除以一個字串、嘗試對數字欄位的存取或在呼叫一個函式時使用過多或過少的引數。

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
- **函式**：可以接受一個或多個引數並且有回傳值的複合型別
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
<!---->
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

`Void` 是型別系統中的一個特例，因為它事實上不是型別，這用於表示沒有型別，主要用於函式的引數和傳回值。

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

函式的型別將在[函式型別](types-function)部分中詳細探索，但快速預覽在此處有助益：在上面例子中的 `main` 函式的型別是 `Void->Void`，也就是「沒有引數也不回傳任何東西」。Haxe 不容許 `Void` 的欄位或變數，如果有此類聲明，會發生錯誤：

```haxe
// 不容許 Void 的引數和變數
var x:Void;
```

<!--label:types-nullability-->
#### 可空性

> #### 定義：可空
>
> 在 Haxe 中，如果 `null` 可以分配給一個型別，那這個型別就是可空的。

通常而言，程式語言會對可空性有單一清晰的定義。然而，由於 Haxe 目標語言的性質，Haxe 必在這方面取得妥協，雖然其中有一些語言容許並事實上對一切的默認值設為 `null`，但另一些卻甚至不容許某些型別有 `null` 值。因此，這需要區分兩種類型的目標語言：

> #### 定義：靜態目標
>
> 靜態目標使用自己的型別系統，對這些來說 `null` 不是基本型別的有效值。Flash、C++、Java與C#目標屬於此類。
<!---->
> #### 定義：動態目標
>
> 動態目標的型別系統更寬鬆，並容許基本型別使用 `null` 作為值。這適用於 JavaScript、PHP、Neko與 Flash 6-8 目標。

在動態目標上使用 `null` 時並沒有好擔心的，不過，對靜態目標則需要進一步考慮。首先，基本型別會初始化為它們的默認值。

> #### 定義：默認值
>
> 靜態目標的基本型別具有下列默認值：
>
> - `Int`：0
> - `Float`：在 Flash 上為 `NaN`，在其他靜態目標上則為 `0.0`
> - `Bool`：`false`

因此，Haxe編譯器並不容許將 `null` 分配至靜態目標上的基本型別。為了實現分配 `null` 值，基本型別必須首先包裝為 `Null<T>`：

```haxe
// 在靜態目標上錯誤
var a:Int = null;
var b:Null<Int> = null; // 容許
```

同樣，除非經過包裝，否則基本型別不能與 `null` 比較：

```haxe
var a:Int = 0;
// 在靜態目標上錯誤
if( a == null) { ... }
var b:Null<Int> = 0;
if( b != null) { ... } // 容許
```

此限制適用於一切執行 <!--TODO-->unification(type-system-unification) 的情況。

> #### 定義：`Null<T>`
>
> 在靜態目標上，可以使用 `Null<Int>`、`Null<Float>` 以及 `Null<Bool>` 來使之容許 `null` 作為值，這在動態目標上不會造成影響。`Null<T>` 也可以與其他型別一起使用以標記 `null` 是一個可接受的值。

如果 `Null<T>` 或 `Dynamic` 「隱含」有 `null` 值並分配給了基本型別，則受分配者會使用默認值：

```haxe
var n:Null<Int> = null;
var a:Int = n;
trace(a); //在靜態目標上為 0
```

<!--label:types-nullability-optional-arguments-->
### 可選引數與可空性

在考慮可空性時必須考慮可選引數，不可為空的**原生**可選引數與可能需要定義的特定於 Haxe 的可選引數之間的區分。這種區別通過使用問號可選引數實現：

```haxe
// x 是原生的 Int（不可為空）
function foo(x:Int = 0) {}
// y 是 Null<Int>（可為空）
function bar(?y:Int) {}
// z 也是 Null<Int>
function opt(?z:Int = -1) {}
```

> #### 瑣事：引數與參數
> 在一些其他程式語言中，**引數**（argument）與**參數**（parameter）是可混用的。而在 Haxe 中，對方法使用的是**引數**，而對[型別引數](type-system-type-parameters)則使用**參數**。

<!--label:types-class-instance-->
## 類別實例
