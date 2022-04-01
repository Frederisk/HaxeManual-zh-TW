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

- Haxe Code Cookbook文章：[一切都是運算式](http://code.haxe.org/category/principles/everything-is-an-expression.html)。

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

About the `Float/Int` return(回傳|) type(型式|n. 又：型別): If one of the operands is of type(型式|n. 又：型別) `Float`, the resulting expression will also be of type `Float`, otherwise the type will be `Int`. The result of a division is always a `Float`; use `Std.int(a / b)` for integer division (discarding any fractional part).

In Haxe, the result of a modulo operation(運算|) always keeps the sign of the dividend (the left operand) if the divisor is non-negative. The result is target(目標|)-specific(特定|) with a negative divisor.

##### string(字串|) concatenation operator(運算子|)

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`+`| 序連 | 任意 | `String` | `String`
`+`| 序連 | `String` | 任意 | `String`
`+=` | 序連 | `String` | 任意 | `String`

Note that the "any" operand will be stringified. For classes and abstracts stringification can be controlled with user-defined `toString` function(函式|).

##### Bitwise operator(運算子|)s

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`<<` | 左移 | `Int` | `Int` | `Int`
`>>` | 右移 | `Int` | `Int` | `Int`
`>>>` | 無符號右移 | `Int` | `Int` | `Int`
`&` | 位元及 | `Int` | `Int` | `Int`
`\|` | 位元或 | `Int` | `Int` | `Int`
`^` | 位元互斥或 | `Int` | `Int` | `Int`

##### Logical operators

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`&&` | 邏輯及 | `Bool` | `Bool` | `Bool`
`\|\|` | 邏輯或 | `Bool` | `Bool` | `Bool`

**Short-circuiting:**

Haxe guarantees that compound boolean expressions with the same operator are evaluated from left to right but only as far as necessary at run-time. For instance, an expression like `A && B` will evaluate(評估|) `A` first and evaluate(評估|) `B` only if the evaluation of `A` yielded `true`. Likewise, the expression `A && B` will not evaluate `B` if the evaluation of `A` yielded `true`, because the value of `B` is irrelevant in that case. This is import(匯入|)ant in cases such as this:

```haxe
if (object != null && object.field == 1) { }
```

Accessing `object.field` if `object` is `null` would lead to a run-time(執行期|又：執行時) error(錯誤|), but the check for `object != null` guards against it.

##### Compound assign(指派|又：賦值、指定、分配)ment operator(運算子|)s

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

In all cases, a compound assignment modifies the given variable, field, structure member, etc., so it will not work on a read-only value. The compound assignment evaluates to the modified value when used as a sub-expression:

```haxe
var a = 3;
trace(a += 3); // 6
trace(a); // 6
```

Note that the first operand of `/=` must always be a `Float`, since the result of a division is always a `Float` in Haxe. Similarly, `+=` and `-=` cannot accept `Int` as the first operand if `Float` is given as the second operand, since the result would be a `Float`.

##### Numeric comparison operators

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`==` | 等於 | `Float/Int` | `Float/Int` | `Bool`
`!=` | 不等於 | `Float/Int` | `Float/Int` | `Bool`
`<` | 小於 | `Float/Int` | `Float/Int` | `Bool`
`<=` | 小於或等於 | `Float/Int` | `Float/Int` | `Bool`
`>` | 大於 | `Float/Int` | `Float/Int` | `Bool`
`>=` | 大於或等於 | `Float/Int` | `Float/Int` | `Bool`

##### String comparison operators

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`==` | 等於 | `String` | `String` | `Bool`
`!=` | 不等於 | `String` | `String` | `Bool`
`<` | 字典序前於 | `String` | `String` | `Bool`
`<=` | 字典序前於或等於 | `String` | `String` | `Bool`
`>` | 字典序後於 | `String` | `String` | `Bool`
`>=` | 字典序後於或等於 | `String` | `String` | `Bool`

Two values of type `String` are considered equal in Haxe when they have the same length and the same contents:

```haxe
var a = "foo";
var b = "bar";
var c = "foo";
trace(a == b); // false
trace(a == c); // true
trace(a == "foo"); // true
```

##### Equality operators

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`==` | 等於 | 任意 | 任意 | `Bool`
`!=` | 不等於 | 任意 | 任意 | `Bool`

The types of operand 1 and operand 2 must [unify](type-system-unification).

**Enums:**

- Enums without parameters always represent the same value, so `MyEnum.A == MyEnum.A`.
- Enums with parameters can be compared with `a.equals(b)` (which is short for `Type.enumEq()`).

**Dynamic:**

Comparison involving at least one operand of type `Dynamic` is unspecified and platform-specific(特定|).

##### Miscellaneous operator(運算子|)s

運算子 | 運算 | 運算元 1 | 運算元 2 | 結果型式
--- | --- | --- | --- | ---
`...` | 區間（參看[範圍疊代](expression-for)） | `Int` | `Int` | `IntIterator`
`=>` | 箭頭（參看[映射](expression-map-declaration), [key-value iteration](expression-for#key-value-iteration)、[映射理解](lf-map-comprehension)） | 任意 | 任意 | -

<!--label:expression-operators-ternary-->
#### Ternary Operator

運算子 | 運算 | 運算元 1 | 運算元 2 | 運算元 3 | 結果型式
 --- | --- | --- | --- | --- | ---
`?:` | 條件 | `Bool` | 任意 | 任意 | 任意

The type(型式|n. 又：型別) of operand 2 and operand 3 must [unify](type-system-unification). The unified type(型式|n. 又：型別) is used as the result type(型式|n. 又：型別) of the expression(表達式|).

The ternary conditional operator(運算子|) is a shorter form of [`if`](expression-if):

```haxe
trace(true ? "Haxe" : "Neko"); // Haxe
trace(1 == 2 ? 3 : 4); // 4

// equivalent to:

trace(if (true) "Haxe" else "Neko"); // Haxe
trace(if (1 == 2) 3 else 4); // 4
```

<!--label:expression-operators-precedence-->
#### Precedence

In order of descending precedence (i.e. operators higher in the table are evaluated first):

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

##### Differences from C-like precedence

Many languages (C++, Java, PHP, JavaScript, etc) use the same operator precedence rules as C. In Haxe, there are a couple of differences from these rules:

- `%` (modulo) has a higher precedence than `*` and `/`; in C they have the same precedence
- `|`, `&`, `^` (bitwise operator(運算子|)s) have the same precedence; in C the three operator(運算子|)s all have a different precedence
- `|`, `&`, `^` (bitwise operator(運算子|)s) also have a lower precedence than `==`, `!=`, etc (comparison operators)

<!--label:expression-operators-overloading-->
#### Overloading and macros

The operators specified in the previous sections specify the types and meanings for operations on basic types. Additional functionality can be implemented using [abstract operator overloading](types-abstract-operator-overloading) or [macro processing](macro).

Operator precedence cannot be changed with abstract operator overloading.

For macro processing in particular, there is an additional operator available: the postfix `!` operator(運算子|).

<!--label:expression-field-access-->
### field(欄位|) access(存取|)

field(欄位|) access(存取|) is expressed by using the dot `.` followed by the name of the field(欄位|).

```haxe
object.fieldName
```

This syntax is also used to access types within packages in the form of `pack.Type`.

The typer ensures that an accessed field actually exist and may apply transformations depending on the nature of the field. If a field access is ambiguous, understanding the [resolution order](type-system-resolution-order) may help.

<!--label:expression-array-access-->
### Array Access

Array access is expressed by using an opening bracket `[` followed by the index expression(表達式|) and a closing bracket `]`.

```haxe
expr[indexExpr]
```

This notation is allowed with arbitrary expressions, but at typing level only certain combinations are admitted:

- `expr` is of `Array` or `Dynamic` and `indexExpr` is of `Int`
- `expr` is an [abstract(抽象|) type(型式|n. 又：型別)](types-abstract) which define(定義|)s a match(匹配|)ing [array(陣列|) access(存取|)](types-abstract-array-access)

<!--label:expression-function-call-->
### function(函式|) Call

function(函式|)s calls consist of an arbitrary subject expression(表達式|) followed by an opening parenthesis `(`, a comma `,` separated(分隔|) list(列表|) of expression(表達式|)s as argument(引數|)s and a closing parenthesis `)`.

```haxe
subject(); // call with no arguments
subject(e1); // call with one argument
subject(e1, e2); // call with two arguments
// call with multiple arguments
subject(e1, e2, /*...*/ eN);
```

##### Related content

- Haxe Code Cookbook article: [How to declare functions](http://code.haxe.org/category/beginner/declare-functions.html)
- Class Methods: [Method](class-field-method)

<!--label:expression-var-->
### var and final

The `var` keyword(關鍵字|) allow(容許|又：允許)s declaring multiple variable(變數|)s, separated(分隔|) by comma `,`. Each variable has a valid [identifier](define-identifier) and optionally a value assignment following the assignment operator `=`. Variables can also have an explicit type-hint.

```haxe
var a; // declare local `a`
var b:Int; // declare variable `b` of type(型式|n. 又：型別) Int
// declare(宣告|) variable(變數|) `c`, initialized to value 1
var c = 1;
// declare an uninitialized variable `d`
// and variable `e` initialize(初始化|)d to value(值|) 2
var d,e = 2;
```

The scoping behavior of local variables, as well as variable shadowing is described in [Blocks](expression-block).

##### since Haxe 4.0.0

In Haxe 4, the alternative keyword `final` was introduced at the expression(表達式|) level. variable(變數|)s declare(宣告|)d with `final` instead of `var` can only be assign(指派|又：賦值、指定、分配)ed a value(值|) once.

<!-- [code asset](assets/Final.hx) -->
```haxe
class Main {
  static public function main() {
    final a = "hello";
    var b = "world";
    trace(a, b); // hello, world
    b = "Haxe";
    trace(a, b); // hello, Haxe

    // the following line would cause a compilation error:
    // a = "bye";
  }
}

```

It is import(匯入|)ant to note that `final` may not have the intended effect with type(型式|n. 又：型別)s that are not immutable, such as array(陣列|)s or objects. Even though the variable(變數|) cannot have a different object assign(指派|又：賦值、指定、分配)ed to it, the object itself can still be modified using its method(方法|)s:

<!-- [code asset](assets/FinalMutable.hx) -->
```haxe
class Main {
  static public function main() {
    final a = [1, 2, 3];
    trace(a); // [1, 2, 3]

    // the following line would cause a compilation error:
    // a = [1, 2, 3, 4];

    // but the following line works:
    a.push(4);
    trace(a); // [1, 2, 3, 4]
  }
}

```

<!--label:expression-arrow-function-->
### Local function(函式|)s

Haxe supports first-class(類別|) function(函式|)s and allow(容許|又：允許)s declaring local function(函式|)s in expression(表達式|)s. The syntax(語法|) follows [class(類別|) field(欄位|) method(方法|)s](class-field-method):

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

We declare(宣告|) `myLocalFunction` inside the [block expression(表達式|)](expression-block) of the `main` class(類別|) field(欄位|). It takes one argument(引數|) `i` and adds it to `value`, which is defined in the outside scope.

The scoping is equivalent to that of [variables](expression-var) and for the most part writing a named local function can be considered equal to assigning an unnamed local function to a local variable:

```haxe
var myLocalFunction = function(a) { }
```

However, there are some differences related to type parameters and the position of the function. We speak of a "lvalue" function if it is not assigned to anything upon its declaration, and an "rvalue" function otherwise.

- Lvalue functions require a name and can have [type parameters](type-system-type-parameters).
- Rvalue functions may have a name, but cannot have type parameters.

##### since Haxe 4.0.0

##### Arrow functions

Haxe 4 introduced a shorter syntax for defining local functions without a name, very similar to the function type syntax. The argument list is defined between two parentheses, followed by an arrow `->`, followed directly by the expression. An arrow function with a single argument does not require parentheses around the argument, and an arrow function with zero arguments should be declared with `() -> ...`:

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

Arrow functions are very similar to normal local functions, with a couple of differences:

- The expression after the arrow is implicitly treated as the return value of the function. For simple functions like `myConcat` above, this can be a convenient way to shorten the code. Normal `return` expression(表達式|)s can still be used, as shown in `myContains` above.
- There is no way to declare(宣告|) the return(回傳|) type(型式|n. 又：型別), although you can use a [type(型式|n. 又：型別) check](expression-type-check) to unify the function(函式|) expression(表達式|) with the desired return(回傳|) type(型式|n. 又：型別).
- [metadata(元資料|)](lf-metadata) cannot be applied to the argument(引數|)s of an arrow function(箭頭函式|).

<!--label:expression-new-->
### new

The `new` keyword(關鍵字|) signals that a [class(類別|)](types-class-instance) or an [abstract(抽象|)](types-abstract) is being instantiate(實例化|)d. It is followed by the [type(型式|n. 又：型別) path(路徑|)](define-type-path(路徑|)) of the type(型式|n. 又：型別) which is to be instantiate(實例化|)d. It may also list(列表|) explicit [type parameter(型式參數|)s](type-system-type-parameters) enclosed(括住|) in `<>` and separated(分隔|) by comma `,`. After an opening parenthesis `(` follow the constructor(建構式|) argument(引數|)s, again separated(分隔|) by comma `,`, with a closing parenthesis `)` at the end.

<!-- [code asset](assets/New.hx) -->
```haxe
class Main<T> {
  static public function main() {
    new Main<Int>(12, "foo");
  }

  function new(t:T, s:String) {}
}

```

Within the `main` method(方法|) we instantiate(實例化|) an instance(實例|) of `Main` itself, with an explicit type parameter(型式參數|) `Int` and the argument(引數|)s `12` and `"foo"`. As we can see, the syntax is very similar to the [function call syntax](expression-function-call) and it is common to speak of "constructor calls".

<!--label:expression-for-->
### for

Haxe does not support traditional for-loops known from C. Its `for` keyword(關鍵字|) expects an opening parenthesis `(`, then a variable identifier followed by the keyword `in` and an arbitrary expression(表達式|) used as iterating collection. After the closing parenthesis `)` follows an arbitrary loop body(本體|) expression(表達式|).

```haxe
for (v in e1) e2;
```

The typer ensures that the type of `e1` can be iterate(疊代|)d over, which is typically the case if it has an  [`iterator`](lf-iterators) method returning an `Iterator<T>`, or if it is an `Iterator<T>` itself.

variable(變數|) `v` is then available within loop body(本體|) `e2` and hold(儲存|TODO:又：存儲)s the value(值|) of the individual elements of collection `e1`.

```haxe
var list = ["apple", "pear", "banana"];
for (v in list) {
  trace(v);
}
// apple
// pear
// banana
```

##### Range iteration

Haxe has a special range operator to iterate over intervals. It is a binary operator taking two `Int` operands: `min...max` return(回傳|)s an [IntIterator](http://api.haxe.org/IntIterator.html) instance(實例|) that iterate(疊代|)s from `min` (inclusive) to `max` (exclusive). Note that `max` may not be smaller than `min`.

```haxe
for (i in 0...10) trace(i); // 0 to 9
```

The type of a `for` expression(表達式|) is always `Void`, meaning it has no value and cannot be used as right-side expression. However, we'll later introduce [array comprehension](lf-array-comprehension), which lets you construct arrays using `for` expression(表達式|)s.

The control flow of loops can be affected by [`break`](expression-break) and [`continue`](expression-continue) expressions.

```haxe
for (i in 0...10) {
  if (i == 2) continue; // skip 2
  if (i == 5) break; // stop at 5
  trace(i);
}
// 0
// 1
// 3
// 4
```

##### since Haxe 4.0.0

##### Key-value iteration

In Haxe 4 it is possible to iterate over collections of key-value pairs. The syntax is the same as regular `for` loops, but the single variable(變數|) identifier(識別符|) is replaced with the key variable(變數|) identifier(識別符|), followed by `=>`, followed by the value variable identifier:

```haxe
for (k => v in e1) e2;
```

Type safety is ensured for key-value iteration as well. The typer checks that `e1` either has a `keyValueIterator` method(方法|) return(回傳|)ing return(回傳|)ing a `KeyValueIterator<K, V>`, or if it is a `KeyValueIterator<K, V>` itself. Here `K` and `V` refer to the type(型式|n. 又：型別) of the keys and the value(值|)s, respectively.

```haxe
var map = [1 => 101, 2 => 102, 3 => 103];
for (key => value in map) {
  trace(key, value);
}
// 1, 101
// 2, 102
// 3, 103
```

##### Related content

- Manual: [Haxe iterators documentation](lf-iterators), [Haxe Data Structures documentation](std-ds)
- Cookbook: [Haxe iterators examples](http://code.haxe.org/tag/iterator.html), [Haxe data structures examples](http://code.haxe.org/tag/data-structures.html)

<!--label:expression-while-->
### while

A normal while loop starts with the `while` keyword(關鍵字|), followed by an opening parenthesis `(`, the condition expression and a closing parenthesis `)`. After that follows the loop body expression:

```haxe
while (condition) expression;
```

The condition expression has to be of type `Bool`.

Upon each iteration, the condition expression is evaluated. If it evaluates to `false`, the loop stops, otherwise it evaluates the loop body expression.

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

This kind of while-loop is not guaranteed to evaluate the loop body expression at all: If the condition does not hold from the start, it is never evaluated. This is different for [do-while loops](expression-do-while).

<!--label:expression-do-while-->
### do-while

A do-while loop starts with the `do` keyword(關鍵字|) followed by the loop body(本體|) expression(表達式|). After that follows the `while` keyword(關鍵字|), an opening parenthesis `(`, the condition expression and a closing parenthesis `)`:

```haxe
do expression while (condition);
```

The condition expression has to be of type `Bool`.

As the syntax suggests, the loop body expression is always evaluated at least once, unlike [while](expression-while) loops.

<!--label:expression-if-->
### if

Conditional expressions come in the form of a leading `if` keyword(關鍵字|), a condition expression(表達式|) enclosed(括住|) in parentheses `()` and a expression(表達式|) to be evaluate(評估|)d in case the condition hold(儲存|TODO:又：存儲)s:

```haxe
if (condition) expression;
```

The condition expression has to be of type `Bool`.

Optionally, `expression` may be followed by the `else` keyword(關鍵字|) as well as another expression(表達式|) to be evaluate(評估|)d if the condition does not hold(儲存|TODO:又：存儲):

```haxe
if (condition) expression1 else expression2;
```

Here, `expression2` may consist of another `if` expression(表達式|):

```haxe
if (condition1) expression1
else if (condition2) expression2
else expression3
```

If the value of an `if` expression(表達式|) is required, e.g. for `var x = if(condition) expression1 else expression2`, the typer ensures that the types of `expression1` and `expression2` [unify](type-system-unification). If no `else` expression(表達式|) is given, the type(型式|n. 又：型別) is inferred to be `Void`.

<!--label:expression-switch-->
### switch

A basic switch expression starts with the `switch` keyword(關鍵字|) and the switch subject expression(表達式|), as well as the case expression(表達式|)s between curly braces(大括號|) `{}`. Case expressions either start with the `case` keyword(關鍵字|) and are followed by a pattern expression(表達式|), or consist of the `default` keyword(關鍵字|). In both cases a colon `:` and an optional(任選|) case body(本體|) expression(表達式|) follows:

```haxe
switch subject {
  case pattern1: case-body-expression-1;
  case pattern2: case-body-expression-2;
  default: default-expression;
}
```

Case body expressions never "fall through", so the [`break`](expression-break) keyword is not supported in Haxe.

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

A value which is thrown like this can be caught by [`catch` blocks](expression(表達式|)-try-catch). If no such block catches it, the behavior(行為|) is target(目標|)-dependent.

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
- the expression(表達式|) to execute in that case.

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

A `return` expression(表達式|) can come with or without a value(值|) expression(表達式|):

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

If `return` is used without a value(值|) expression(表達式|), the typer(型式系統|TODO:) ensures that the return(回傳|) type(型式|n. 又：型別) of the function(函式|) it return(回傳|)s from is of `Void`. If it has a value expression, the typer [unifies](type-system-unification) its type with the return type (explicitly given or inferred by previous `return` expression(表達式|)s) of the function(函式|) it return(回傳|)s from.

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

The typer ensures that it appears only within a loop. The `break` keyword(關鍵字|) in [`switch` cases](expression(表達式|)-switch) is not supported in Haxe.

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

Unsafe casts are useful to subvert the type system. The compiler types `expr` as usual and then wraps it in a [monomorph(單型|)](types-monomorph). This allow(容許|又：允許)s the expression(表達式|) to be assign(指派|又：賦值、指定、分配)ed to anything.

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

The Haxe compiler guarantees that an exception of type `String` is [throw(擲回|)n](expression-throw) in this case. This exception can be caught using a [`try/catch` block](expression(表達式|)-try-catch).

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
