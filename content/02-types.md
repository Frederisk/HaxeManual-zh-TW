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
