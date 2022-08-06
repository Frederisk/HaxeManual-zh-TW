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

在執行期，會自頂向底去評估塊段。控制流（比如[例外狀況](expression-try-catch)或[回傳運算式](expression-return)）可能會在評估完所有運算式之前就離開塊段。

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

switch 運算式可以如同值一般使用，此時所有 case 主體運算式以及 default 運算式都必須[統一](type-system-unification)。

每個 case （包括 default）也都是變數範圍並會影響[變數遮蔽](expression-block#variable-shadowing)。

```haxe
switch (0) {
  case 0:
    var a = "foo";
  case _:
    // 將導致編譯錯誤，因為上一個 case 中的 `a` 在這個 case 並不可存取：
    // trace(a);
}
```

#### 相關內容

- [模式匹配](lf-pattern-matching)中有詳細介紹模式運算式的語法。
- Haxe Code Cookbook 中的[關於模式匹配的片段和教程](http://code.haxe.org/tag/pattern-matching.html)。

<!--label:expression-throw-->
## throw

Haxe 容許以其 `throw` 語法擲回任意種類的值：

```haxe
throw expr
```

像這樣擲回的值可以由 [`catch` 塊段](expression-try-catch)捕捉。如果沒有這樣的塊段捕捉，則其行為會由目標取決。

#### 自 Haxe 4.1.0

極度建議不要擲回任意值而是去擲回 `haxe.Exception` 的實例。不過事實上如若 `value` 不是 `haxe.Exception` 的實例，那麼 `throw value` 將會編譯為 `throw haxe.Exception.thrown(value)`，這會將 `value` 包裝為`haxe.Exception` 的實例。

不過原生目標的例外狀況會以原樣擲回。例如 `cs.system.Exception` 或 `php.Exception` 將不會在擲回時自動包裝。

<!--label:expression-try-catch-->
### try/catch

Haxe 容許以 `try/catch` 語法捕捉值：

```haxe
try try-expr
catch (varName1:Type1) catch-expr-1
catch (varName2:Type2) catch-expr-2
```

如果在執行期 `try-expression` 的評估導致 [`throw`](expression-throw)，則其可以由任意後續的 `catch` 塊段捕捉。這些塊段會包括：

- 儲存有擲回值的變數名稱，
- 確定哪些型式需要捕捉的明確型式標記，
- 在這種情況下要執行的運算式。

Haxe 容許擲回以及捕捉任意種類的值，該值並不受限於由特定的例外狀況或者錯誤繼承的型式。不過自 Haxe 4.1.0 起，強烈建議僅擲回與捕捉 `haxe.Exception` 及其子系的實例。

catch 塊段會自頂向底檢查首個其型式與與選取的擲回值相容的型式的塊段。

該處理與編譯期[統一](type-system-unification)有很多相似之處。不過由於檢查必須是在執行期，所以會存在一些限制：

- 型式必須在執行期存在：[類別實例](types-class-instance)、[枚舉實例](types-enum-instance)、[抽象核心型式](types-abstract-core-type)、[動態](types-dynamic)。
- 型式參數只能是[動態](types-dynamic)。

### 萬用 catch

#### 自 Haxe 4.1

可以（並且推薦）省略型式提示來使用萬用 catch，這可以取代 `Dynamic` 與 `Any`：

```haxe
try {
  doSomething();
} catch(e) {
  // 所有的例外狀況都會在此處捕捉
  trace(e.message);
}
```

這相當於 `catch(e:haxe.Exception)`。

#### Haxe 3.* 與 Haxe 4.0

在 Haxe 4.1.0 之前，捕捉所有例外狀況的唯一方式是使用 `Dynamic` 或 `Any` 作為捕捉型式。要獲取例外狀況的字串表示可以使用 `Std.string(e)`。

```haxe
try {
  doSomething();
} catch(e:Any) {
  // 所有的例外狀況都會在此處捕捉
  trace(Std.string(e));
}
```

### 例外狀況堆疊

#### 自 Haxe 4.1

若捕捉的型式是 `haxe.Exception` 或其子系之一，則可以在例外狀況實例的 `stack` 屬性中取得例外狀況堆疊。

```haxe
try {
  doSomething();
} catch(e:haxe.Exception) {
  trace(e.stack);
}
```

#### Haxe 3.* 與 Haxe 4.0

例外狀況呼叫堆疊可在 `catch` 塊段中以 `haxe.CallStack.exceptionStack()` 取得：

```haxe
try {
  doSomething();
} catch(e:Dynamic) {
  var stack = haxe.CallStack.exceptionStack();
  trace(haxe.CallStack.toString(stack));
}
```

### 重新擲回例外狀況

#### 自 Haxe 4.1

既便再次擲回 `haxe.Exception` 的實例，其仍會保留所有原始資料，包括堆疊。

```haxe
import haxe.Exception;

class Main {
  static function main() {
    try {
      try {
        doSomething();
      } catch(e:Exception) {
        trace(e.stack);
        throw e; // 重新擲回
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

以 `haxe --main Main --interp` 執行此範例會印出這樣的結果：

```plain
Main.hx:13:
Called from Main.doSomething (Main.hx line 11 column 15)
Called from Main.main (Main.hx line 5 column 5)
Main.hx:17:
Called from Main.doSomething (Main.hx line 11 column 15)
Called from Main.main (Main.hx line 5 column 5)
```

編譯器在擲回原生例外狀況時可能會避免不必要的包裝而在捕捉處處理。這可確保任何例外狀況（原生或其他）都可以以 `catch (e:haxe.Exception)` 捕捉。這也同時適用於重新擲回例外狀況。

比如此處有一段樣例 Haxe 程式碼，將其編譯為 PHP 目標並且重新擲回內部 `try/catch` 中的所有例外狀況。並且重新擲回的例外狀況仍可以以其目標原生型式捕捉：

```haxe
try {
  try {
    (null:Dynamic).callNonExistentMethod();
  } catch(e:Exception) {
    trace('Haxe exception: ' + e.message);
    throw e; // 重新擲回
  }
} catch(e:php.ErrorException) {
  trace('Rethrown native exception: ' + e.getMessage());
}
```

這個例子編譯為 PHP 目標將印出：

```plain
Main.hx:9: Haxe exception: Trying to get property 'callNonExistentMethod' of non-object
Main.hx:13: Rethrown native exception: Trying to get property 'callNonExistentMethod' of non-object
```

### 鏈式例外狀況

#### 自 Haxe 4.1

有時鏈接異常而不是再次擲回相同的例外狀況實例會很方便。要這樣做只需要將例外狀況傳遞至新的例外狀況實例：

```haxe
try {
  doSomething();
} catch(e:haxe.Exception) {
  cleanup();
  throw new haxe.Exception('Failed to do something', e);
}
```

以 `--interp` 執行此範例會印出這樣的訊息：

```plain
Main.hx:12: characters 7-12 : Uncaught exception Exception: Terrible error
Called from Main.doSomething (Main.hx line 10 column 13)

Next Exception: Failed to do something
Called from Main.doSomething (Main.hx line 12 column 13)
Called from Main.main (Main.hx line 5 column 5)
Main.hx:5: characters 5-18 : Called from here
```

一個使用案例是使錯誤紀錄更可讀。

鏈接的異常可以透過 `haxe.Exception` 實例的 `previous` 屬性取得：

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

另一個使用案例是創建函式庫，這樣做可以避免將內部例外狀況公開為公共 API 並仍可提供有關異常原因的資訊：

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

如此以來，函式庫的使用者不必關心特定的算術例外狀況，他們只需要處理 `MyLibException` 就可以了。

<!--label:expression-return-->
## return

`return` 運算式可以有也可以沒有值運算式：

```haxe
return;
return expression;
```

此運算式會使宣告了它的最內層函式控制流程脫離，這在涉及[局部函式](expression-arrow-function)時必須區分：

```haxe
function f1() {
  function f2() {
    return;
  }
  f2();
  expression;
}
```

`return` 會脫離局部函式 `f2`，但 `f1` 不會，也就是 `expression` 仍會評估。

若在沒有值運算式時使用 `return`，則型式系統會確保回傳其的函式的回傳型式為 `Void`。若有，則型式系統會使其型式與回傳其的函式的回傳型式（明確給定或由先前的回傳運算式推斷）相[統一](type-system-unification)。

<!--label:expression-break-->
## break

`break` 關鍵字會使宣告了它的最內層迴圈（`for` 或 `while`）的控制流程脫離以停止進一步的疊代：

```haxe
while (true) {
  expression1;
  if (condition) break;
  expression2;
}
```

此處每次疊代都會評估 `expression1`，不過一旦 `condition` 成立，當前的疊代將終止而不評估 `expression2`，並且不再疊代。

型式系統會確保這只出現在迴圈中。Haxe 並不支援在 [`switch` case](expression-switch)中的 `break` 關鍵字。

<!--label:expression-continue-->
## continue

`continue` 關鍵字會使使宣告了它的最內層迴圈（`for` 或 `while`）結束當前疊代，從而檢查迴圈條件以繼續疊代：

```haxe
while (true) {
  expression1;
  if (condition) continue;
  expression2;
}
```

此處每次疊代都會評估 `expression1`，不過一旦 `condition` 成立，`expression2` 將在該次疊代中不再評估。不同於 `break`，疊代還將繼續。

型式系統會確保這只出現在迴圈中。

<!--label:expression-cast-->
## cast

Haxe 容許兩種轉換：

```haxe
cast expr; // 不安全的轉換
cast (expr, Type); // 安全的轉換
```

<!--label:expression-cast-unsafe-->
### 不安全的轉換

不安全的轉換在顛覆型式系統時十分有用。編譯器會如往常一樣型式化 `expr` 然後將其包裝在[單型](types-monomorph)之中。這可容許將運算式指派至任何東西。

不安全的轉換並不會引入任何[動態](types-dynamic)型式，如下例所示：

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

變數 `i` 型式化為 `Int` 然後由不安全的轉換 `cast i` 指派至變數 `s`。這會使 `s` 的型式是未知的，也就是單型。按照[統一](type-system-unification)的規則，其可以繫結至任意型式，比如此例中的 `String`。

這些轉換稱為「不安全」是由於沒有定義無效轉換的執行期行為。雖然對於大多數[動態目標](define-dynamic-target)都可能工作，但在[靜態目標](define-static-target)中可能會出現未定義的錯誤。

不安全的轉換幾乎沒有執行期負荷。

<!--label:expression-cast-safe-->
### 安全的轉換

不同於[不安全的轉換](expression-cast-unsafe)，定義有轉換失敗的情況的執行期行為定義為安全的轉換。

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

在此例中，我們首先將型式 `Child1` 的類別實例轉換為 `Base`，因為 `Child1` 是 `Base` 的[子類別](types-class-inheritance)所以會成功。然後我們嘗試將相同的類別實例轉換為 `Child2`，這是不容許的，因為 `Child2` 的實例不是 `Child1` 的實例。

Haxe 編譯器會保障在這種情形下會擲回型式 `String` 的例外狀況。該例外狀況可以使用 [`try/catch` 塊段](expression-try-catch)捕捉。

安全的轉換會有執行期負荷。重要的是需要了解到編譯器已經會生成型式檢查，因此添加手動的檢查是冗餘的，比如使用 `Std.is`。其預期用法是嘗試使用安全的轉換並捕捉 `String` 異常。

<!--label:expression-type-check-->
## 型式檢查

#### 自 Haxe 3.1.0

可以使用下列語法使用編譯期型式檢查：

```haxe
(expr : type)
```

括號是必須的。與[安全的轉換](expression-cast-safe)不同，此構造沒有執行期影響。這有兩種編譯期含意：

1. [自上而下推斷](type-system-top-down-inference)會用於型式化 `expr` 為型式 `type`。
2. 結果型式化運算式會與型式 `type` [統一](type-system-unification)。

這具有兩種運算的通常效果，例如在執行[非限定識別符解析](type-system-resolution-order)時將作為預期型式的給定型式與[抽象轉換](types-abstract-implicit-casts)作統一檢查。

<!--label:expression-inline-->
## inline

#### 自 Haxe 4.0.0

inline 關鍵字可以在[函式呼叫](expression-function-call)或[建構式呼叫](expression-new)之前使用。與[內聯存取修飾符](class-field-inline)不同，該種容許對內聯更細緻的控制。

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

產生的 JavaScript 輸出為：

```js
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

注意 `c` 會產生對函式的呼叫但 `d` 不會。對於內聯的良好候選者的常規警告同樣適用（見[內聯](class-field-inline)）。

`inline new` 的呼叫可用於避免建立局部類別實例。更多細節可見[內聯建構式](lf-inline-constructor)。
