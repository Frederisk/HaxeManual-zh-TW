<!--label:expression-->
# 運算式

在 Haxe 中，運算式定義了程式要**做**甚麼。大多數運算式都在[方法](class-field-method)的本體中，在其中它們互相組合以表達程式應當做甚麼。這部分會介紹不同種類的運算式。有一些會有幫助的定義：

> #### 定義：名稱
>
> 通常上的名稱可以去指代：
>
> - 型式、
> - 局部變數、
> - 局部函式、
> - 欄位。
<!---->
> #### 定義：識別符
>
> Haxe 的識別符會以底線 `_`、貨幣符號 `$`、小寫字元 `a-z` 或大寫字元 `A-Z` 開頭，之後可以是若干 `_`、`A-Z`、`a-z` 或 `0-9` 的任意組合。
>
> 另外根據上下文也會有對輸入的進一步檢查：
>
> - 型式命名必須以大寫字母 `A-Z` 或底線 `_` 開頭。
> - 任何種類的[名稱](define-name)都不可以以貨幣符號（帶貨幣的名稱多用於[巨集具體化](macro-reification)）。

#### 自 Haxe 3.3.0

Haxe 會保留識別符前綴 `_hx_` 以供內部使用，這並非由剖析器或型式系統強制的。

#### 關鍵字

以下的關鍵字不可用於識別符：

- `abstract`
- `break`
- `case`
- `cast`
- `catch`
- `class`
- `continue`
- `default`
- `do`
- `dynamic`
- `else`
- `enum`
- `extends`
- `extern`
- `false`
- `final`
- `for`
- `function`
- `if`
- `implements`
- `import`
- `in`
- `inline`
- `interface`
- `macro`
- `new`
- `null`
- `operator`
- `overload`
- `override`
- `package`
- `private`
- `public`
- `return`
- `static`
- `switch`
- `this`
- `throw`
- `true`
- `try`
- `typedef`
- `untyped`
- `using`
- `var`
- `while`

#### 相關內容

- Haxe Code Cookbook 文章：[一切都是運算式](http://code.haxe.org/category/principles/everything-is-an-expression.html)。

<!--label:expression-block-->
## 塊段

Haxe 中的塊段以左大括號 `{` 開始，以右大括號 `}` 結束，一個塊段可以包含有多個運算式，每個運算式後面會跟有一個分號 `;`。一般語法大概會是這樣：

```haxe
{
  expr1;
  expr2;
  // ...
  exprN;
}
```

塊段運算式的值和拓展型式與最後一個子運算式的值和型式相同。<!--TODO: The value and by extension the type of a block-expression is equal to the value and the type of the last sub-expression. -->

塊段可以包含由 [`var` 運算式](expression-var)宣告的局部變數，以及由 [`function` 運算式](expression-arrow-function)宣告的局部函式。這些內容在所在塊段內及其子塊段內可以使用，但在塊段外則不可以。另外，它們只在宣告之後可用。以下的例子是以 `var` 示範，不過 `function` 也適用同樣的規則：

```haxe
{
  a; // 錯誤，`a` 尚未宣告
  var a = 1; // 宣告 `a`
  a; // 可以，`a` 已宣告
  {
    a; // 可以，`a` 在子塊段中可用
  }
  // 可以，`a` 在子塊段之後也可用
  a;
}
a; // 錯誤，`a` 在之外不可用
```

在執行期，會自頂向底去評估塊段。控制流（比如[異常](expression-try-catch)或[回傳運算式](expression-return)）可能會在評估完所有運算式之前就離開塊段。

#### 變數遮蔽

Haxe 容許在同一塊段內對局部變數遮蔽。這表示 `var`、`final` 和 `function` 可以宣告為和塊段中之前可用名稱相同的名稱，從而將其有效地在之後的程式碼中隱藏：

```haxe
{
  var v = 42; // 宣告 `v`
  $type(v); // Int
  var v = "hi"; // 宣告新的 `v`
  $type(v); // String，先前的宣告不可用
}
```

容許這樣做可能會讓人有些意外，不過這樣有助於避免汙染局部名稱空間，從而避免意外用到錯誤的變數。

注意，遮蔽嚴格遵守語法，因此若變數是在遮蔽之前就由閉包捕獲，則閉包仍然會引用原始的宣告：

```haxe
{
  var a = 1;
  function f() {
    trace(a);
  }
  var a = 2;
  f(); // 印出 1
}
```

#### 自 Haxe 4.0.0

有時可能會在無意中寫出變數遮蔽。此時可以以 `-D warn-var-shadowing` 定義使編譯器設定為為所有變數遮蔽的實例發出警告。

<!--label:expression-literals-->
## 常值

常值是使用保留語法為許多 Haxe 核心型式建構值的方式。下表總結了 Haxe 中的可用常值：

例子 | 型式 | 備註
--- | --- | ---
`42`, `0xFF42` | `Int` | [整數](define-int)常數
`0.32`, `3.`, `2.1e5` | `Float` | [浮點](define-float)十進位常數
`true`, `false` | `Bool` | [布林](define-bool)常數
`~/haxe/gi` | `EReg` | [正規表示式](std-regex)
`null` | `T` | 任何[可空](types-nullability)型式的空值
`"XXX"`, `'XXX'` | `String` | [字串常值](std-String-literals)
`"X".code`, `'X'.code` | `Int` | [Unicode 字元字碼指標](std-String#character-code)
`[1, 2, 3]`, `[]` | `Array<T>` | [陣列常值](expression-array-declaration)
`["a" => 1]`, `[]` | `Map<T, U>` | [映射常值](expression-map-declaration)
`{foo: true}`, `{}` | `T` | [匿名結構常值](expression-object-declaration)
`1...3` | `IntIterator` | [範圍](expression-for)

<!--label:expression-array-declaration-->
### 陣列宣告

[陣列](std-Array)以用括號 `[]` 括住並以逗號 `,` 分隔的值初始化。空白的 `[]` 表示空陣列，而 `[1, 2, 3]` 會初始化包含三個元素 `1`, `2` 和 `3` 的陣列。

```haxe
var b = [];
var a = [1, 2, 3];
```

在不支援陣列初始化的平台上，生成的程式碼可能會不那麼簡潔。在本質上，這種初始化程式碼會像是這樣：

```haxe
var a = new Array();
a.push(1);
a.push(2);
a.push(3);
```

在決定是否要[內聯](class-field-inline)時應考慮到這一點，因為這樣內聯的程式碼會比在語法中能看到的要多。

在[陣列理解](lf-array-comprehension)中描述有進階初始化技術。

<!--label:expression-map-declaration-->
### 映射宣告

[映射](std-Map)的初始化與陣列類似，不過內容鍵和其對應的值。`["example" => 1, "data" => 2]` 初始化了一個映射（特定為 `Map<String, Int>`），其中鍵 `"example"` 存儲值 `1`，`"data"` 存儲值 `2`。

#### 自 Haxe 4.0.0

在需要映射型式的地方（基於[自上而下的推斷](type-system-top-down-inference)），`[]` 指的是空映射。

<!--label:expression-object-declaration-->
### 物件宣告

物件宣告由左大括號 `{` 開始，然後是 `key: value` 的鍵值對並以逗號分隔 `,`，然後最後是右大括號 `}`。

```haxe
{
  key1: value1,
  key2: value2,
  // ...
  keyN: valueN
}
```

對物件宣告得更多細節有在[匿名結構](types-anonymous-structure)的部分中描述。

<!--label:expression-constants-->
## 常數

常數是不會改變的值。這些值可用於[內聯變數](class-field-inline#inline-variables)和[函式的默認值](types-function-default-values)。除了無引數枚舉構造器外，所有的常數都是[常值](expression-literals)：

例子 | 型式 | 備註
--- | --- | ---
`42`, `0xFF42` | `Int` | [整數](define-int)常數
`0.32`, `3.`, `2.1e5` | `Float` | [浮點](define-float)十進位常數
`true`, `false` | `Bool` | [布林](define-bool)常數
`~/haxe/gi` | `EReg` | [正規表示式](std-regex)
`null` | `T` |  任何[可空](types-nullability)型式的空值
`"XXX"`, `'XXX'` | `String` | [字串常值](std-String-literals)
`"X".code`, `'X'.code` | `Int` | [Unicode 字元字碼指標](std-String#character-code)
`MyEnum.Haxe` | `T` | 無引數的[枚舉建構式](types-enum-constructor)

此外，內部語法結構視[識別符](define-identifier)為常數，在使用[巨集](macro)時可能需要注意到這一點。

<!--label:expression-operators-->
## 運算子

<!--subtoc-->

<!--label:expression-operators-unops-->
### 一元運算子

運算子 | 運算 | 運算元型式 | 位置 | 結果型式
--- | --- | --- | --- | ---
`~` | 位元否定 | `Int` | 前綴 | `Int`
`!` | 邏輯否定 | `Bool` | 前綴 | `Bool`
`-`| 算術否定 | `Float/Int` | 前綴 | 與運算元相同
`++` | 遞增 | `Float/Int` | 前綴和後綴 | 與運算元相同
`--` | 遞減 | `Float/Int` | 前綴和後綴 | 與運算元相同

#### 遞增和遞減

遞增和遞減運算子會改變給定的值，因此其不可用於唯讀值。這些運算子還會因是前綴或後綴而產生不同結果，前綴運算子會評估為修改的值，而後綴運算子會評估為原始的值。

```haxe
var a = 10;
trace(a++); // 10
trace(a); // 11

a = 10;
trace(++a); // 11
trace(a); // 11
```

<!--label:expression-operators-binops-->
### 二元運算子

#### 算術運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`%` | 模數 | `Float/Int` | `Float/Int` | `Float/Int`
`*` | 乘法 | `Float/Int` | `Float/Int` | `Float/Int`
`/` | 除法 | `Float/Int` | `Float/Int` | `Float`
`+` | 加法 | `Float/Int` | `Float/Int` | `Float/Int`
`-` | 減法 | `Float/Int` | `Float/Int` | `Float/Int`

對於 `Float/Int` 回傳型式：若其中的一個運算元為 `Float`，運算式結果也會是 `Float`，此外的型式將為 `Int`。除法的結果始終為浮點數，不過可以以 `Std.int(a / b)` 的方式以整數除（將丟棄任何小數部分）。

在 Haxe 中，若除數為非負數，則模數運算結果的符號將始終為被除數（左運算元）的符號。有負除數的解果將是特定於目標的。

#### 字串序連運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`+`| 序連 | 任意 | `String` | `String`
`+`| 序連 | `String` | 任意 | `String`
`+=` | 序連 | `String` | 任意 | `String`

注意「任意」的運算元將字串化。類別和抽象可以以使用者自訂的 `toString` 函式來控制字串化。

#### 位元運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`<<` | 左移 | `Int` | `Int` | `Int`
`>>` | 右移 | `Int` | `Int` | `Int`
`>>>` | 無符號右移 | `Int` | `Int` | `Int`
`&` | 位元及 | `Int` | `Int` | `Int`
`\|` | 位元或 | `Int` | `Int` | `Int`
`^` | 位元互斥或 | `Int` | `Int` | `Int`

#### 邏輯運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`&&` | 邏輯及 | `Bool` | `Bool` | `Bool`
`\|\|` | 邏輯或 | `Bool` | `Bool` | `Bool`

**短路：**

Haxe 保證具有相同運算子的複合布林運算式會從左到右計算，但在執行期將根據具體所需計算。例如，類似 `A && B` 這樣的運算式將首先評估 `A`，並在僅當 `A` 的評估結果為 `true` 時，才會評估 `B`。同理，運算式 `A || B` 若 `A` 的評估結果為 `true`，則不會再評估 `B`，因為在這種情況下，`B` 的值並不重要。這對於以下的情況來說很重要：

```haxe
if (object != null && object.field == 1) { }
```

若在 `object` 為 `null` 時存取 `object.field` 會導致執行期錯誤，但檢查 `object != null` 會防範這個錯誤。

##### 複合指派運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`%=` | 模數 | `Float/Int` | `Float/Int` | `Float/Int`
`*=` | 乘法 | `Float/Int` | `Float/Int` | `Float/Int`
`/=` | 除法 | `Float` | `Float/Int` | `Float`
`+=` | 加法 | `Float/Int` | `Float/Int` | `Float/Int`
`-=` | 減法 | `Float/Int` | `Float/Int` | `Float/Int`
`<<=` | 左移 | `Int` | `Int` | `Int`
`>>=` | 右移 | `Int` | `Int` | `Int`
`>>>=` | 無符號右移 | `Int` | `Int` | `Int`
`&=` | 位元及 | `Int` | `Int` | `Int`
`\|=` | 位元或 | `Int` | `Int` | `Int`
`^=` | 位元互斥或 | `Int` | `Int` | `Int`

在所有情況下複合指派都會修改給定的變數、欄位、結構成員等，因此其不可用於唯讀值。在以子運算式使用時，複合指派會計算為修改後的值：

```haxe
var a = 3;
trace(a += 3); // 6
trace(a); // 6
```

注意， `/=` 的第一個運算元必須始終是 `Float`，因為除法的結果在 Haxe 中始終為 `Float`。同樣，若 `+=` 和 `-=` 的第二個運算元是 `Float`，那就不可以 `Int` 為第一個運算元，因為其結果會是 `Float`。

#### 數值比較運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`==` | 等於 | `Float/Int` | `Float/Int` | `Bool`
`!=` | 不等於 | `Float/Int` | `Float/Int` | `Bool`
`<` | 小於 | `Float/Int` | `Float/Int` | `Bool`
`<=` | 小於或等於 | `Float/Int` | `Float/Int` | `Bool`
`>` | 大於 | `Float/Int` | `Float/Int` | `Bool`
`>=` | 大於或等於 | `Float/Int` | `Float/Int` | `Bool`

#### 字串比較運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`==` | 等於 | `String` | `String` | `Bool`
`!=` | 不等於 | `String` | `String` | `Bool`
`<` | 字典序前於 | `String` | `String` | `Bool`
`<=` | 字典序前於或等於 | `String` | `String` | `Bool`
`>` | 字典序後於 | `String` | `String` | `Bool`
`>=` | 字典序後於或等於 | `String` | `String` | `Bool`

在 Haxe 中若兩個 `String` 的長度與內容都相同，則認為它們相等。

```haxe
var a = "foo";
var b = "bar";
var c = "foo";
trace(a == b); // false
trace(a == c); // true
trace(a == "foo"); // true
```

#### 等號比較運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`==` | 等於 | 任意 | 任意 | `Bool`
`!=` | 不等於 | 任意 | 任意 | `Bool`

運算元 1 和運算元 2 的型式必須[統一](type-system-unification)。

**枚舉：**

- 沒有參數的枚舉總是表述相同的值，因此 `MyEnum.A == MyEnum.A`。
- 有參數的枚舉可以透過 `a.equals(b)` 比較（這是 `Type.enumEq()` 的較短寫法）。

**動態：**

包含一個以上 `Dynamic` 型式的比較並未規定而且特定於平台。

#### 雜項運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`...` | 區間（參看[範圍疊代](expression-for)） | `Int` | `Int` | `IntIterator`
`=>` | 箭頭（參看[映射](expression-map-declaration), [鍵值疊代](expression-for#key-value-iteration)、[映射理解](lf-map-comprehension)） | 任意 | 任意 | -

<!--label:expression-operators-ternary-->
#### 三元運算子

運算子 | 運算 | 運算元 1 | 運算元 2 | 運算元 3 | 結果型式
--- | --- | --- | --- | --- | ---
`?:` | 條件 | `Bool` | 任意 | 任意 | 任意

運算元 1 和運算元 2 的型式必須[統一](type-system-unification)。所統一的型式將是運算式的結果型式。

三元運算子是 [`if`](expression-if) 的較簡短形式。

```haxe
trace(true ? "Haxe" : "Neko"); // Haxe
trace(1 == 2 ? 3 : 4); // 4

// equivalent to:

trace(if (true) "Haxe" else "Neko"); // Haxe
trace(if (1 == 2) 3 else 4); // 4
```

<!--label:expression-operators-precedence-->
### 優先順序

以優先順序排列（即表中越前的運算子越優先評估）：

運算子 | 備註 | 結合性
 --- | --- | ---
`!`, `++`, `--` | 後綴一元運算子 | 右
`~`, `!`, `-`, `++`, `--` | 前綴一元運算子 | 右
`%` | 模數 | 左
`*`, `/` | 乘法、除法 | 左
`+`, `-` | 加法、減法 | 左
`<<`, `>>`, `>>>` | 位元移位 | 左
`&`, `\|`, `^` | 位元運算子 | 左
`==`, `!=`, `<`, `<=`, `>`, `>=` | 比較 | 左
`...` | interval | 左
`&&` | 邏輯及 | 左
`\|\|` | 邏輯或 | 左
`@`| metadata | 右
`?:` | 條件 | 右
`%=`, `*=`, `/=`, `+=`, `-=`, `<<=`, `>>=`, `>>>=`, `&=`, `\|=`, `^=` | 複合指派 | 右
`=>` | 箭頭 | 右

#### 與類 C 優先順序的差異

許多語言（C++、Java、PHP、JavaScript等）的優先順序與 C 相同，在 Haxe 中這些規則有一些不同之處：

- `%`（模數）的優先順序高過 `*` 和 `/`，在 C 中這些的優先順序相同。
- `|`、`&`、`^`（位元運算子）的優先順序相同，在 C 中這三個運算子的優先順序都不相同。
- `|`、`&`、`^`（位元運算子）的優先順序較 `==`、`!=` 等（比較運算子）低。

<!--label:expression-operators-overloading-->
### 多載和巨集

先前的部分指定的運算子指定了基本型式和含意。而附加功能可以用[抽象運算子多載](types-abstract-operator-overloading)或[巨集處理](macro)實作。

運算子的優先順序並不能以抽象運算子多載來改變。

特別對巨集處理還有一個額外的運算子，後綴 `!` 運算子，可用。

<!--label:expression-field-access-->
## 欄位存取

欄位存取以點 `.` 表示，其後接欄位的名稱。

```haxe
object.fieldName
```

此語法還用於以 `pack.Type` 的型式存取套件中的型式。

型式系統會確保存取的欄位確實存在，並可以由欄位的性質應用轉換。若欄位存取模稜兩可，了解[解析順序](type-system-resolution-order)或許會有助益。

<!--label:expression-array-access-->
## 陣列存取

陣列存取以左括號 `[` 後跟索引運算式和右括號 `]` 表示。

```haxe
expr[indexExpr]
```

這種表示法可用於任意運算式，但在型態層次只可用於某些組合：

- `expr` 是 `Array` 或 `Dynamic` 而 `indexExpr` 是 `Int`。
- `expr` 是[抽象型式](types-abstract)並定義有匹配[陣列存取](types-abstract-array-access)。

<!--label:expression-function-call-->
## 函式呼叫

函式呼叫由任意主體運算式後跟左括號 `(` 、作為引數的由逗號 `,` 分隔的運算式列表、右括號 `)` 組成。

```haxe
subject(); // 無引數呼叫
subject(e1); // 以一個引數呼叫
subject(e1, e2); // 以兩個引數呼叫
// 以多個引數呼叫
subject(e1, e2, /*...*/ eN);
```

#### 相關內容

- Haxe Code Cookbook 文章：[如何宣告函式](http://code.haxe.org/category/beginner/declare-functions.html)
- 類別方法：[方法](class-field-method)

<!--label:expression-var-->
## var 與 final

`var` 關鍵字容許宣告以逗號分隔 `,` 的多個變數。每個變數都有有效[識別符](define-identifier)，以及可選的由指派運算子 `=` 引導的指派。變數也可以有明確的型式提示。

```haxe
var a; // 宣告局部的 `a`
var b:Int; // 以型式 Int 宣告 `b`
// 宣告變數 `c`, 初始化值為 1
var c = 1;
// 宣告未初始化的變數 `d`
// 以及以值 2 初始化的變數 `e`
var d,e = 2;
```

局部變數的作用域行為以及變數遮蔽在[塊段](expression-block)中有描述。

#### 自 Haxe 4.0.0

在 Haxe 4 中，在運算式階層引入了替代關鍵字 `final`，以 `final` 取代 `var` 宣告的變數只能指派一次。

<!-- [code asset](assets/Final.hx) -->
```haxe
class Main {
  static public function main() {
    final a = "hello";
    var b = "world";
    trace(a, b); // hello, world
    b = "Haxe";
    trace(a, b); // hello, Haxe

    // 下一列將導致編譯錯誤：
    // a = "bye";
  }
}
```

重要的是要注意對於非不可變型式，例如陣列或物件，`final` 可能會不會產生預期的結果。即使變數不能以其他物件指派給它，物件自身仍可以以自己的方法修改：

<!-- [code asset](assets/FinalMutable.hx) -->
```haxe
class Main {
  static public function main() {
    final a = [1, 2, 3];
    trace(a); // [1, 2, 3]

    // 下一列將導致編譯錯誤：
    // a = [1, 2, 3, 4];

    // 但下一列可以正常工作：
    a.push(4);
    trace(a); // [1, 2, 3, 4]
  }
}
```

<!--label:expression-arrow-function-->
## 局部函式

Haxe 支援第一級函式並容許在運算式中宣告局部函式。語法遵循[類別欄位方法](class-field-method)：

<!-- [code asset](assets/LocalFunction.hx) -->
```haxe
class Main {
  static public function main() {
    var value = 1;
    function myLocalFunction(i) {
      return value + i;
    }
    trace(myLocalFunction(2)); // 3
  }
}
```

我們在 `main` 類別欄位的[塊段運算式](expression-block)中宣告了 `myLocalFunction`。它接受一個引數 `i` 並將其加入至範圍外定義的 `value` 中。

局部函式的範圍和[變數](expression-var)的等同，而且在多數情況下，編寫命名的局部函式可視為等於將未命名的局部函式指派至局部變數：

```haxe
var myLocalFunction = function(a) { }
```

不過，在型式參數和函式的位置上會有一些差異。若在聲明時沒有指派至任何東西，則我們稱之為「左值」函式，否則稱為「右值」函式。

- 左值函式需要有名稱並可以有[型式參數](type-system-type-parameters)。
- 右值函式可以有名稱，但不可以有型式參數。

#### 自 Haxe 4.0.0

#### 箭頭函式

Haxe 4 引入了更短的語法去定義沒有名稱的局部函式，該語法與函式型式語法十分相似。以括號包裹引數清單，之後跟一個箭頭 `->`，緊接著的是運算式。有單個引數的箭頭函式並不必要在引數周圍加上括號，零引數的箭頭函式應以 `() -> ...` 的方式宣告：

<!-- [code asset](assets/ArrowFunction.hx) -->
```haxe
class Main {
  static public function main() {
    var myConcat = (a:String, b:String) -> a + b;
    var myChar = (a:String, b:Int) -> (a.charAt(b) : String);
    $type(myConcat); // (a : String, b : String) -> String
    $type(myChar); // (a : String, b : Int) -> String
    trace(myConcat("foo", "bar")); // "foobar"
    trace(myChar("example", 1)); // "x"
    var oneArgument = number -> number + 1;
    var noArguments = () -> "foobar";
    var myContains = (a:String, needle:String) -> {
      if (a.indexOf(needle) == -1)
        return false;
      trace(a, needle);
      true;
    };
  }
}
```

箭頭函式與普通的局部變數十分相似，但有一些區別：

- 箭頭後的運算式在隱含上視作函式的回傳值。對於上面如 `myConcat` 這種簡單的函式來說這是種方便的縮減程式碼的方法。通常的 `return` 運算式依然可用，如上面的 `myContains` 所示。
- 儘管你可以以[型式檢查](expression-type-check)統一函式運算式與所需的回傳型式，但回傳型式是不可宣告的。]
- [元資料](lf-metadata)不可用於箭頭函式的引數。

<!--label:expression-new-->
## new

`new` 關鍵字表示去實例化[類別](types-class-instance)或[抽象](types-abstract)。在這後面的是要實例化的型式的[型式路徑](define-type-path)。在左括號 `(` 後跟的以逗號 `,` 分隔的建構式引數後的右括號 `)` 之後，可以用 `<>` 括起來用逗號 `,` 分隔的明確[型式參數](type-system-type-parameters)。

<!-- [code asset](assets/New.hx) -->
```haxe
class Main<T> {
  static public function main() {
    new Main<Int>(12, "foo");
  }

  function new(t:T, s:String) {}
}
```

在 main 方法中，我們以明確型式參數 `Int` 以及引數 `12` 和 `"foo"` 實例化了 `Main` 本身的實例。正如我們所看到的，其語法與[函式呼叫語法](expression-function-call)十分相似，所以這也常稱為「建構式呼叫」。

<!--label:expression-for-->
## for

Haxe 不支援我們在 C 中的所知的傳統 for 迴圈。Haxe 的 `for` 關鍵字需要左括號 `(`，然後是變數識別符，之後跟關鍵字 `in` 和用作疊代集合的任意運算式，最後在右括號 `)` 之後跟上任意迴圈本體運算式。

```haxe
for (v in e1) e2;
```

型式系統會確保 `e1` 的型式是可疊代的，通常來說就是它有回傳 `Iterator<T>` 的 [`iterator`](lf-iterators) 方法，或者其本身就是 `Iterator<T>`。

之後變數 `v` 在迴圈本體 `e2` 中就可用，並會儲存 `e1` 各個元素的值。

```haxe
var list = ["apple", "pear", "banana"];
for (v in list) {
  trace(v);
}
// apple
// pear
// banana
```

#### 範圍疊代

Haxe 有特殊的範圍運算子來疊代區間，這是需要兩個 `Int` 運算元的二元運算子： `min...max` 會回傳 [`IntIterator`](http://api.haxe.org/IntIterator.html)，該實例會從 `min`（包含）疊代到 `max`（不包含）。須注意 `max` 不得小於 `min`。

```haxe
for (i in 0...10) trace(i); // 0 至 9
```

`for` 運算式的型式始終為 `Void`，這意味著它沒有值所以不可用作右側運算式。不過我們稍後會介紹[陣列理解](lf-array-comprehension)，這可以讓你用 `for` 運算式建構陣列。

迴圈的控制流程會受到 [`break`](expression-break) 和 [`continue`](expression-continue) 的影響。

```haxe
for (i in 0...10) {
  if (i == 2) continue; // 跳過 2
  if (i == 5) break; // 在 5 處停止
  trace(i);
}
// 0
// 1
// 3
// 4
```

#### 自 Haxe 4.0.0

#### 鍵值疊代

在 Haxe 4 中也可以疊代鍵值對的集合。語法與常規的 `for` 迴圈相同，但是是將單個的變數識別符替換為鍵的變數識別符，然後是 `=>`，接著是值的變數識別符：

```haxe
for (k => v in e1) e2;
```

鍵值疊代也會保障型式安全。型式系統會檢查 `e1` 是否具有回傳 `KeyValueIterator<K, V>` 的 `keyValueIterator` 方法，或者其本身是否就是 `KeyValueIterator<K, V>`。此處的 `K` 與 `V` 分別指的是鍵和值的型式。

```haxe
var map = [1 => 101, 2 => 102, 3 => 103];
for (key => value in map) {
  trace(key, value);
}
// 1, 101
// 2, 102
// 3, 103
```

#### 相關內容

- 手冊：[Haxe 疊代器文件]](lf-iterators)、[Haxe 資料結構文件](std-ds)
- Cookbook：[Haxe 疊代器示例](http://code.haxe.org/tag/iterator.html), [Haxe 示例](http://code.haxe.org/tag/data-structures.html)

<!--label:expression-while-->
## while

一般的 while 迴圈由 `while` 關鍵字開始，然後是左括號 `(`、條件運算式以及右括號 `)`。之後是迴圈本體運算式：

```haxe
while (condition) expression;
```

條件運算式的型式必須是 `Bool`。

在每次疊代時，先評估條件運算式。如果評估為 `false` ，迴圈停止，否則評估迴圈本體運算式。

<!-- [code asset](assets/While.hx) -->
```haxe
class Main {
  static public function main() {
    var f = 0.0;
    while (f < 0.5) {
      trace(f);
      f = Math.random();
    }
  }
}
```

這種 while 迴圈並不能保證一定會對迴圈本體運算式評估，如果條件在一開始就不成立，則其永遠也不會評估。這與 [do while](expression-do-while) 迴圈不同。

<!--label:expression-do-while-->
## do while

do while 迴圈以關鍵字 `do` 開始，然後是迴圈本體運算式，之後是 `while` 關鍵字、左括號 `(`、條件運算式以及右括號 `)`：

```haxe
do expression while (condition);
```

條件運算式的型式必須是 `Bool`。

正如語法上所暗示，迴圈本體運算式總會評估至少一次，這與 [while](expression-while) 迴圈不同。

<!--label:expression-if-->
## if

條件運算式的形式包括前導 `if`　關鍵字、在括號 `()` 中的條件運算式，以及條件成立時需要評估的運算式：

```haxe
if (condition) expression;
```

條件運算式的型式必須是 `Bool`。

另可選在 `expression` 之後有 `else` 關鍵字，以及條件不成立時需要評估的運算式：

```haxe
if (condition) expression1 else expression2;
```

此處的 `expression2` 也可以由另一個 `if` 運算式組成。

```haxe
if (condition1) expression1
else if (condition2) expression2
else expression3
```

如果會對 `if` 運算式的值有需求，比如 `var x = if(condition) expression1 else expression2` 型式系統將確保 `expression1` 與 `expression2` 的型式相[統一](type-system-unification)。如果沒有給出 `else` 運算式，則型式將會推斷為 `Void`。

<!--label:expression-switch-->
## switch

基本的 switch 運算式以 `switch` 關鍵字與 switch 主體運算式開始，然後是在大括號 `{}` 之間的 case 運算式。case 運算式可以以 `case` 關鍵字開始，後面跟著模式運算式，也可以以 `default` 關鍵字組成。在這兩種情況下，冒號 `:` 和任選的 case 本體運算式會是如下：

```haxe
switch subject {
  case pattern1: case-body-expression-1;
  case pattern2: case-body-expression-2;
  default: default-expression;
}
```

case 主體運算式並不會「fall through」<!--TODO: translate it!-->，所以 Haxe 並不支援 [`break`](expression-break) 關鍵字。

Switch expressions can be used as value; in that case the types of all case body expressions and the default expression must [unify](type-system-unification).

Each case (including the default one) is also a variable scope, which affects [variable shadowing](expression-block#variable-shadowing).

```haxe
switch (0) {
  case 0:
    var a = "foo";
  case _:
    // This would cause a compilation error, since `a` from the previous
    // case is not access(存取|)ible in this case:
    // trace(a);
}
```

##### Related content

- Further details on syntax of pattern expressions are detailed in [Pattern Matching](lf-pattern-matching).
- [Snippets and tutorials about pattern matching](http://code.haxe.org/tag/pattern-matching.html) in the Haxe Code Cookbook.

<!--label:expression-throw-->
### throw

Haxe allows throwing any kind of value using its `throw` syntax(語法|):

```haxe
throw expr
```

A value which is thrown like this can be caught by [`catch` blocks](expression(運算式|)-try-catch). If no such block catches it, the behavior(行為|) is target(目標|)-dependent.

##### since Haxe 4.1.0

It's highly recommended to not throw(擲回|) arbitrary value(值|)s and instead throw(擲回|) instance(實例|)s of `haxe.Exception`.
In fact, if `value` is not an instance(實例|) of `haxe.Exception`, then `throw value` is compiled as `throw haxe.Exception.thrown(value)`, which wraps `value` into an instance(實例|) of `haxe.Exception`.

However native target exceptions are thrown as-is. For example an instance of `cs.system.Exception` or `php.Exception` won't get automatically wrapped upon throw(擲回|)ing.

<!--label:expression-try-catch-->
### try/catch

Haxe allow(容許|又：允許)s catching value(值|)s using its `try/catch` syntax(語法|):

```haxe
try try-expr
catch (varName1:Type1) catch-expr-1
catch (varName2:Type2) catch-expr-2
```

If during runtime the evaluation of `try-expression` causes a [`throw`](expression-throw), it can be caught by any subsequent `catch` block. These blocks consist of

- a variable(變數|) name which hold(儲存|TODO:又：存儲)s the throw(擲回|)n value(值|),
- an explicit type(型式|n. 又：型別) annotation(表示法|) which determines which type(型式|n. 又：型別)s of value(值|)s to catch, and
- the expression(運算式|) to execute in that case.

Haxe allow(容許|又：允許)s throw(擲回|)ing and catching any kind of value(值|), it is not limited to type(型式|n. 又：型別)s inherit(繼承|)ing from a specific(特定|) exception or error(錯誤|) class(類別|). However since Haxe 4.1.0 it's highly recommended to throw(擲回|) and catch only instance(實例|)s of `haxe.Exception` and its descendants.

Catch blocks are checked from top to bottom with the first one whose type(型式|n. 又：型別) is compatible(相容|) with the throw(擲回|)n value(值|) being picked.

This process has many similarities to the compile-time(編譯期|又：編譯時) [unification(統一|TODO:)](type(型式|n. 又：型別)-system-unification) behavior(行為|). However, since the check has to be done at runtime there are several restrictions:

- The type(型式|n. 又：型別) must exist at runtime: [class instance(類別實例|)s](types-class-instance), [enum instance(枚舉實例|)s](types-enum-instance), [abstract(抽象|) core type(型式|n. 又：型別)s](types-abstract-core-type) and [dynamic(動態|)](types-dynamic).
- type parameter(型式參數|)s can only be [dynamic(動態|)](types-dynamic).

#### wildcard(萬用(字元)|) catch

#### Since Haxe 4.1

Instead of `Dynamic` and `Any` it's possible (and recommended) to omit the type(型式|n. 又：型別) hint for wildcard(萬用(字元)|) catches:

```haxe
try {
  doSomething();
} catch(e) {
  //All exceptions will be caught here
  trace(e.message);
}
```

This is equivalent to `catch(e:haxe.Exception)`.

##### Haxe 3.* and Haxe 4.0

Prior to Haxe 4.1.0 the only way to catch all exceptions is by using `Dynamic` or `Any` as the catch type(型式|n. 又：型別).
To get a string(字串|) representation of the exception `Std.string(e)` could be used.

```haxe
try {
  doSomething();
} catch(e:Any) {
  // All exceptions will be caught here
  trace(Std.string(e));
}
```

#### Exception stack

##### Since Haxe 4.1

If the catch type is `haxe.Exception` or one of its descendants, then the exception stack is available in the `stack` property(屬性|) of the exception instance(實例|).

```haxe
try {
  doSomething();
} catch(e:haxe.Exception) {
  trace(e.stack);
}
```

##### Haxe 3.* and Haxe 4.0

The exception call stack is available via `haxe.CallStack.exceptionStack()` inside of a `catch` block:

```haxe
try {
  doSomething();
} catch(e:Dynamic) {
  var stack = haxe.CallStack.exceptionStack();
  trace(haxe.CallStack.toString(stack));
}
```

#### Rethrowing exceptions

##### Since Haxe 4.1

Even if an instance of `haxe.Exception` is throw(擲回|)n again, it still preserves all the original information, including the stack.

```haxe
import haxe.Exception;

class Main {
  static function main() {
    try {
      try {
        doSomething();
      } catch(e:Exception) {
        trace(e.stack);
        throw e; //rethrow
      }
    } catch(e:Exception) {
      trace(e.stack);
    }
  }

  static function doSomething() {
    throw new Exception('Terrible error');
  }
}
```

This example being executed with `haxe --main Main --interp` would print something like this:

```plain
Main.hx:13:
Called from Main.doSomething (Main.hx line 11 column 15)
Called from Main.main (Main.hx line 5 column 5)
Main.hx:17:
Called from Main.doSomething (Main.hx line 11 column 15)
Called from Main.main (Main.hx line 5 column 5)
```

The compiler may avoid unnecessary wrapping when throwing native exceptions and handle this at the catch-site instead. This ensures that any exception (native or otherwise) can be caught with `catch (e:haxe.Exception)`. This also applies for rethrowing exceptions.

For example here's a Haxe code, which being compiled to PHP target catches and rethrows all exceptions in the inner `try/catch`. And rethrown exceptions are still catchable using their target native types:

```haxe
try {
  try {
    (null:Dynamic).callNonExistentMethod();
  } catch(e:Exception) {
    trace('Haxe exception: ' + e.message);
    throw e; //rethrow
  }
} catch(e:php.ErrorException) {
  trace('Rethrown native exception: ' + e.getMessage());
}
```

This sample being compiled to PHP target would print:

```plain
Main.hx:9: Haxe exception: Trying to get property 'callNonExistentMethod' of non-object
Main.hx:13: Rethrown native exception: Trying to get property 'callNonExistentMethod' of non-object
```

#### Chaining exceptions

##### Since Haxe 4.1

Sometimes it's convenient to chain exceptions instead of throwing the same exception instance again.
To do so just pass an exception to a new exception instance:

```haxe
try {
  doSomething();
} catch(e:haxe.Exception) {
  cleanup();
  throw new haxe.Exception('Failed to do something', e);
}
```

Being executed with `--interp` this sample would print a message like this:

```plain
Main.hx:12: characters 7-12 : Uncaught exception Exception: Terrible error
Called from Main.doSomething (Main.hx line 10 column 13)

Next Exception: Failed to do something
Called from Main.doSomething (Main.hx line 12 column 13)
Called from Main.main (Main.hx line 5 column 5)
Main.hx:5: characters 5-18 : Called from here
```

One use-case is to make error logs more readable.

Chained exceptions are available through `previous` property(屬性|) of `haxe.Exception` instance(實例|)s:

```haxe
try {
  try {
    doSomething();
  } catch(e:haxe.Exception) {
    cleanup();
    throw new haxe.Exception('Failed to do something', e);
  }
} catch(e:haxe.Exception) {
  trace(e.message); // "Failed to do something"
  trace(e.previous.message); // "Terrible error"
}
```

Another use-case is creating a library, which does not expose internal exceptions as public API, but still provides information about exceptions reasons:

```haxe
import haxe.Exception;

class MyLibException extends Exception {}

class MyLib {
  static public function calculateSomething() {
    try {
      heavyCalculation();
    } catch(e:Exception) {
      throw new MyLibException(e.message, e);
    }
  }

  static function heavyCalculation() {}
}
```

Now library users don't have to worry about specific arithmetic exceptions. All they need to do is handle `MyLibException`.

<!--label:expression-return-->
### return

A `return` expression(運算式|) can come with or without a value(值|) expression(運算式|):

```haxe
return;
return expression;
```

It leaves the control-flow of the innermost function it is declared in, which has to be distinguished when [local functions](expression-arrow-function) are involved:

```haxe
function f1() {
  function f2() {
    return;
  }
  f2();
  expression;
}
```

The `return` leaves local function(函式|) `f2`, but not `f1`, meaning `expression` is still evaluate(評估|)d.

If `return` is used without a value(值|) expression(運算式|), the typer(型式系統|TODO:) ensures that the return(回傳|) type(型式|n. 又：型別) of the function(函式|) it return(回傳|)s from is of `Void`. If it has a value expression, the typer [unifies](type-system-unification) its type with the return type (explicitly given or inferred by previous `return` expression(運算式|)s) of the function(函式|) it return(回傳|)s from.

<!--label:expression-break-->
### break

The `break` keyword(關鍵字|) leaves the control flow of the innermost loop (`for` or `while`) it is declared in, stopping further iterations:

```haxe
while (true) {
  expression1;
  if (condition) break;
  expression2;
}
```

Here, `expression1` is evaluate(評估|)d for each iteration, but as soon as `condition` hold(儲存|TODO:又：存儲)s, the current iteration is terminated without evaluating `expression2`, and no more iteration is done.

The typer ensures that it appears only within a loop. The `break` keyword(關鍵字|) in [`switch` cases](expression(運算式|)-switch) is not supported in Haxe.

<!--label:expression-continue-->
### continue

The `continue` keyword(關鍵字|) ends the current iteration of the innermost loop (`for` or `while`) it is declared in, causing the loop condition to be checked for the next iteration:

```haxe
while (true) {
  expression1;
  if (condition) continue;
  expression2;
}
```

Here, `expression1` is evaluate(評估|)d for each iteration, but if `condition` hold(儲存|TODO:又：存儲)s, `expression2` is not evaluate(評估|)d for the current iteration. Unlike `break`, iterations continue.

The typer ensures that it appears only within a loop.

<!--label:expression-cast-->
### cast

Haxe allows two kinds of casts:

```haxe
cast expr; // unsafe cast
cast (expr, Type); // safe cast
```

<!--label:expression-cast-unsafe-->
#### unsafe cast

Unsafe casts are useful to subvert the type system. The compiler types `expr` as usual and then wraps it in a [monomorph(單型|)](types-monomorph). This allow(容許|又：允許)s the expression(運算式|) to be assign(指派|又：賦值、指定、分配)ed to anything.

Unsafe cast(轉換|又：轉型 TODO:)s do not introduce any [dynamic(動態|)](types-dynamic) type(型式|n. 又：型別)s, as the following example shows:

<!-- [code asset](assets/UnsafeCast.hx) -->
```haxe
class Main {
  public static function main() {
    var i = 1;
    $type(i); // Int
    var s = cast i;
    $type(s); // Unknown<0>
    Std.parseInt(s);
    $type(s); // String
  }
}
```

variable(變數|) `i` is type(型式|n. 又：型別)d as `Int` and then assign(指派|又：賦值、指定、分配)ed to variable(變數|) `s` using the unsafe cast(轉換|又：轉型 TODO:) `cast i`. This causes `s` to be of an unknown type(型式|n. 又：型別), a monomorph(單型|). Following the usual rules of [unification(統一|TODO:)](type(型式|n. 又：型別)-system-unification), it can then be bound(繫結|) to any type(型式|n. 又：型別), such as `String` in this example.

These cast(轉換|又：轉型 TODO:)s are called "unsafe" because the runtime behavior(行為|) for invalid(有效|) cast(轉換|又：轉型 TODO:)s is not define(定義|)d. While most [dynamic target(動態目標|)s](define-dynamic-target) are likely to work, it might lead to undefined(未定義|) error(錯誤|)s on [static target(靜態目標|)s](define-static-target).

Unsafe cast(轉換|又：轉型 TODO:)s have little to no runtime overhead.

<!--label:expression-cast-safe-->
#### safe cast(轉換|又：轉型 TODO:)

Unlike [unsafe cast(轉換|又：轉型 TODO:)s](expression-cast-unsafe), the runtime behavior(行為|) in case of a failing cast(轉換|又：轉型 TODO:) is define(定義|)d for safe cast(轉換|又：轉型 TODO:)s:

<!-- [code asset](assets/SafeCast.hx) -->
```haxe
class Base {
  public function new() {}
}

class Child1 extends Base {}
class Child2 extends Base {}

class Main {
  public static function main() {
    var child1:Base = new Child1();
    var child2:Base = new Child2();
    cast(child1, Base);   // Ok
    cast(child1, Child2); // Exception: Class cast error
  }
}

```

In this example we first cast(轉換|又：轉型 TODO:) a class instance(類別實例|) of type(型式|n. 又：型別) `Child1` to `Base`, which succeeds because `Child1` is a [child class(子類別|)](types-class-inheritance) of `Base`. We then try to cast the same class instance to `Child2`, which is not allowed because instances of `Child2` are not instance(實例|)s of `Child1`.

The Haxe compiler guarantees that an exception of type `String` is [throw(擲回|)n](expression-throw) in this case. This exception can be caught using a [`try/catch` block](expression(運算式|)-try-catch).

Safe cast(轉換|又：轉型 TODO:)s have a runtime overhead. It is import(匯入|)ant to understand that the compiler(編譯器|) alread(讀出|)y generate(產生|)s type(型式|n. 又：型別) checks, so it is redundant(冗餘|) to add manual(手冊/手動|n./adj.) checks, e.g. using `Std.is`. The intended usage is to try the safe cast and catch the `String` exception.

<!--label:expression-type-check-->
### type(型式|n. 又：型別) check

##### since Haxe 3.1.0

It is possible to employ compile-time(編譯期|又：編譯時) type(型式|n. 又：型別) checks using the following syntax(語法|):

```haxe
(expr : type)
```

The parentheses are mandatory. Unlike [safe casts](expression-cast-safe) this construct has no run-time impact. It has two compile-time implications:

1. [Top-down inference](type-system-top-down-inference) is used to type `expr` with type(型式|n. 又：型別) `type`.
2. The resulting typed expression is [unified](type-system-unification) with type `type`.

This has the usual effect of both operations such as the given type being used as expected type when performing [unqualified identifier resolution](type-system-resolution-order) and the unification checking for [abstract casts](types-abstract-implicit-casts).

<!--label:expression-inline-->
### inline

##### since Haxe 4.0.0

The `inline` keyword(關鍵字|) can be used before a [function(函式|) call](expression-function-call) or a [constructor(建構式|) call](expression-new). This allow(容許|又：允許)s a finer-grained control of inlining, unlike the [inline(內聯|) access(存取|) modifier(修飾符|)](class-field-inline).

<!-- [code asset](assets/InlineCallsite.hx) -->
```haxe
class Main {
  static function mid(s1:Int, s2:Int) {
    return (s1 + s2) / 2;
  }

  static public function main() {
    var a = 1;
    var b = 2;
    var c = mid(a, b);
    var d = inline mid(a, b);
  }
}

```

The generate(產生|)d JavaScript output is:

```haxe
(function ($global) { "use strict";
var Test = function() { };
Test.mid = function(s1,s2) {
 return (s1 + s2) / 2;
};
Test.main = function() {
 var a = 1;
 var b = 2;
 var c = Test.mid(a,b);
 var d = (a + b) / 2;
};
Test.main();
})({});
```

Note that `c` produces a call to the function(函式|), whereas `d` does not. The usual warnings about what makes a good candidate for inlining still hold(儲存|TODO:又：存儲) (see [inline(內聯|)](class-field-inline)).

An `inline new` call can be used to avoid creating a local class instance(類別實例|). See [inline(內聯|) constructor(建構式|)s](lf-inline-constructor) for more details.
