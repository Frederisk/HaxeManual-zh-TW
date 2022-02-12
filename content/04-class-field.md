<!--label:class-field-->
# 類別欄位

> #### 定義：類別欄位
>
> 類別欄位是類別的變數、屬性或方法，其可以是靜態或非靜態的。非靜態欄位可稱其為**成員**欄位，所以我們將其稱之為例如**靜態方法**或**成員變數**。

在目前為止，我們已經了解到了型式和 Haxe 程式的結構。對於類別欄位部分總結了結構的部分以及連接至 Haxe 行為的部分。這是由於類別欄位是[表達式](expression)所在的地方。

類別欄位有三種：

- 變數：[變數](class-field-variable)類別欄位儲存某種型式的值以供讀寫。
- 屬性：[屬性](class-field-property)類別欄位為在類別之外的內容定義了客製存取行為始知看起來像是變數欄位。
- 方法：[方法](class-field-method)是可呼叫以執行程式碼的函式。

嚴格來說，變數是可視作具有某些存取修飾符的屬性。事實上，Haxe 編譯器在其編寫階段不區分變數和屬性，但在語法級別上兩者保持分隔。

在術語方面，方法是所屬類的（靜態或非靜態）函式。而其他函式，例如表達式中的局部函式則不會視為方法。

<!--label:class-field-variable-->
## 變數

我們已經在前幾部分的幾個程式碼例子中見到過了變數欄位。變數欄位儲存值，這是它們與大多數（但不是全部）屬性共有的特徵。

<!-- [code asset](assets/VariableField.hx) -->
```haxe
class Main {
  static var example:String = "bar";

  public static function main() {
    trace(example);
    example = "foo";
    trace(example);
  }
}
```

我們可以從中得知，變數：<!--TODO: example -> member-->

1. 有一個名稱（此處：`member`），
2. 有一個型式（此處：`String`），
3. 可以有一個常數初始化（此處：`"bar"`）以及
4. 可以有[存取修飾符](class-field-access-modifier)（此處：`static`）。

這個例子首先會列印 `member` 的初始化值，然後將其設定為 `"foo"` 並列印其新值。存取修飾符的效果由全部三種類別欄位共享並在單獨的部分中得到解釋。

需要注意的是如果有初始化值的話，則不需要明確型式。在這種情況下，編譯器會[推斷](type-system-type-inference)。

![圖：變數欄位的初始化值](assets/figures/class-field-variable-init-values.svg)

_圖：變數欄位的初始化值。_

<!--label:class-field-property-->
## 屬性

除[變數](class-field-variable)以外，屬性是處理類別資料的第二個選項。不過，以變數不同的是，它們提供了應該容許哪種欄位的存取以及如何產生其的更多控制。常見的使用案例包括：

- 有可以從任何地方讀出但只能在定義類別中寫入的欄位。
- 有在讀存取時引動**取得器**方法的欄位。
- 有在寫存取時引動**設定器**方法的欄位。

在處理屬性時，了解兩種存取方式很重要：

> #### 定義：讀存取
>
> 在使用右側[欄位存取表達式](expression-field-access)時，會發生對欄位的讀存取。這包括形如 `obj.field()` 的呼叫，其中 `field` 以讀的方式受存取。
<!---->
> #### 定義：寫存取
>
> 當[欄位存取表達式](expression-field-access)以形如 `obj.field = value` 的方式賦值時，會發生對欄位的寫存取。這也可能會與`obj.field += value` 等表達式中的如 `+=` 的特殊賦值運算子的[讀存取](define-read-access)結合使用。

讀存取和寫存取會直接反應在語法當中，如以下例子所示：

<!-- [code asset](assets/Property.hx) -->
```haxe
class Main {
  public var x(default, null):Int;

  static public function main() {}
}
```

在大多數情況下其語法類似於變數的語法，並且確實適用相同的規則。屬性識別由：

- 在欄位名稱之后是左括號 `(`，
- 后跟一個特殊的**存取識別符**（此處為 `default`），
- 用逗號 `,` 分隔，
- 另一個特殊的存取識別符（此處為 `null`），
- 隨後是右括號 `)`。

存取識別符定義了讀出（第一個識別符）和寫入（第二個標識符）欄位時的行為。接受的值有：

- `default`：若欄位的可見性是共用的，則容許正常的欄位存取，否則等同於 `null` 存取。
- `null`：只允許從定義的類別中存取。
- `get` 或 `set`：存取將生成為對**存取器方法**的呼叫。編譯器將確保存取器可用。
- `dynamic`：與 `get` 或 `set` 存取相似，但是不會驗證存取器欄位的存在。
- `never`：完全不容許存取。

> #### 定義：存取器方法
>
> 對型式為 `T` 名為 `field` 的欄位，**存取器方法**或**存取器**是型式為 `Void->T` 名為 `get_field` 的**取得器**或型式為 `T->T` 名為 `set_field` 的**設定器**。
<!---->
> #### 瑣事：存取器名稱
>
> 在 Haxe 2 中，可以使用任意識別符作為存取識別符，這會導致容許自訂存取器方法名稱。同時還也使得部分的實作非常難以處理，特別是 `Reflect.getProperty()` 和 `Reflect.setProperty()` 必須假設可以使用任意名稱，這要求目標產生器產生元資訊並執行查找。
>
> 我們不容許使用這些識別符並採取了 `get_` 和`set_` 命名約定，這大大簡化了實作。這是 Haxe 2 和 3 之間的重大變更之一。

<!--label:class-field-property-common-combinations-->
### 常見存取器識別符組合

下一個例子展示了屬性常見存取器識別符組合：

<!-- [code asset](assets/Property2.hx) -->
```haxe
class Main {
  // 可以在外部讀出，只能在 Main 中寫入
  public var ro(default, null):Int;

  // 可以在外部寫入，只能在 Main 中讀出
  public var wo(null, default):Int;

  // 透過取得器 get_x 和設定器 set_x 存取
  public var x(get, set):Int;

  // 透過取得器讀存取，不能寫存取
  public var y(get, never):Int;

  // 由欄位 x 所需
  function get_x() return 1;

  // 由欄位 x 所需
  function set_x(x) return x;

  // 由欄位 y 所需
  function get_y() return 1;

  function new() {
    var v = x;
    x = 2;
    x += 1;
  }

  static public function main() {
    new Main();
  }
}
```

JavaScript 輸出有助於理解，`main` 方法中的欄位存取會編譯為：

```js
var Main = function() {
  var v = this.get_x();
  this.set_x(2);
  var _g = this;
  _g.set_x(_g.get_x() + 1);
};
```

如同指定的那樣，讀存取產生 ˋget_x()` 的呼叫，而寫存取產生對 `set_x(2)` 的呼叫，其中 `2` 是賦給 `x`的值。`+=` 的生成方式起初看起來有點奇怪，不過可以透過下面的例子輕鬆證明：

<!-- [code asset](assets/Property3.hx) -->
```haxe
class Main {
  public var x(get, set):Int;

  function get_x() return 1;

  function set_x(x) return x;

  public function new() {}

  static public function main() {
    new Main().x += 1;
  }
}
```

在此處發生的情況是，在 `main` 方法中存取 `x` 欄位的表達式部分是**複合的**：其具有潛在的副作用，比如在這種情況下需要建構 `Main`。因此，編譯器無法將 `+=` 運算生成為 `new Main().x = new Main().x + 1`，並且將複合表達式快取在局部變數中：

```js
Main.main = function() {
  var _g = new Main();
  _g.set_x(_g.get_x() + 1);
}
```

<!--label:class-field-property-type-system-impact-->
### 對型式系統的影響

屬性的存在對型式系統有許多影響。最重要的是，必須了解到屬性是編譯期特徵，因此**需求的是已知型式**。如果我們將具有屬性的類別賦值為 `Dynamic`，那麼欄位存取將**不再**考量存取器方法。同樣，存取限制也將不再適用，所有的存取實際上都會是公開。

在使用 `get` 或 `set` 存取識別符時，編譯器會確保取得器和設定器確實存在。下列程式碼片段無法編譯：

<!-- [code asset](assets/Property4.hx) -->
```haxe
class Main {
  // 方法 get_x 為屬性 x 的取得器方法缺失
  public var x(get, null):Int;

  static public function main() {}
}
```

缺少方法 `get_x`，但只要在父類別中定義，就不需要在本身定義了屬性的類別上宣告它。

<!-- [code asset](assets/Property5.hx) -->
```haxe
class Base {
  public function get_x() return 1;
}

class Main extends Base {
  // 可以，get_x 已經在父類別中宣告
  public var x(get, null):Int;

  static public function main() {}
}
```

`dynamic` 存取修飾符的工作方式與 `get` 或 `set` 完全相同，但不會檢查是否存在。

<!--label:class-field-property-rules-->
#### Rules for getter and setter

Visibility of accessor methods has no effect on the accessibility of its property. That is, if a property is `public` and define(定義|)d to have a getter(取得器|TODO:), that getter(取得器|TODO:) may be define(定義|)d as `private` regardless.

Both getter(取得器|TODO:) and setter(設定器|又：寫入器 TODO:) may access(存取|) their physical field(欄位|) for data storage. The compiler(編譯器|) ensures that this kind of field(欄位|) access(存取|) does not go through the access(存取|)or method(方法|) when made from within the access(存取|)or method(方法|) itself, thus avoiding infinite recursion(遞迴|):

<!-- [code asset](assets/GetterSetter.hx) -->
```haxe
class Main {
  public var x(default, set):Int;

  function set_x(newX) {
    return x = newX;
  }

  static public function main() {}
}
```

However, the compiler assumes that a physical field exists only if at least one of the access identifiers is `default` or `null`.

> ##### Define: Physical field
>
> A field is considered to be **physical** if it is either
>
> * a [variable](class-field-variable)
> - a [property](class-field-property) with the read-access or write-access identifier being `default` or `null`
>
> - a [property](class-field-property) with `:isVar` [metadata(元資料|)](lf-metadata)

If this is not the case, access(存取|) to the field(欄位|) from within an access(存取|)or method(方法|) causes a compilation(編譯|名詞) error(錯誤|):

<!-- [code asset](assets/GetterSetter2.hx) -->
```haxe
class Main {
  // This field cannot be accessed because it is not a real variable
  public var x(get, set):Int;

  function get_x() {
    return x;
  }

  function set_x(x) {
    return this.x = x;
  }

  static public function main() {}
}
```

If a physical field is indeed intended, it can be forced by attributing the field in question with the `:isVar` [metadata(元資料|)](lf-metadata):

<!-- [code asset](assets/GetterSetter3.hx) -->
```haxe
class Main {
  // @isVar forces the field to be physical allowing the program to compile.
  @:isVar public var x(get, set):Int;

  function get_x() {
    return x;
  }

  function set_x(x) {
    return this.x = x;
  }

  static public function main() {}
}
```

> ##### Trivia: Property setter type
>
> It is not uncommon for new Haxe users to be surprised by the type of a setter being required to be `T->T` instead of the seemingly more natural `T->Void`. After all, why would a **setter** have to return something?
>
> The rationale is that we still want to be able to use field assignments using setters as right-side expressions. Given a chain like `x = y = 1`, it is evaluated as `x = (y = 1)`. In order to assign the result of `y = 1` to `x`, the former must have a value. If `y` had a setter(設定器|又：寫入器 TODO:) return(回傳|)ing `Void`, this would not be possible.

<!--label:class-field-method-->
### Method

While [variables](class-field-variable) hold data, methods are defining behavior of a program by hosting [expressions](expression). We have seen method fields in every code example of this document with even the initial [Hello World](introduction-hello-world) example containing a `main` method(方法|):

<!-- [code asset](assets/HelloWorld.hx) -->
```haxe
/**
  Multi-line comments for documentation.
**/
class Main {
  static public function main():Void {
    // Single line comment
    trace("Hello World");
  }
}
```

Methods are identified by the `function` keyword(關鍵字|). We can also learn that they

1. have a name (here: `main`),
2. have an argument list (here: empty `()`),
3. have a return type (here: `Void`),
4. may have [access modifiers](class-field-access-modifier) (here: `static` and `public`) and
5. may have an expression (here: `{trace("Hello World");}`).

We can also look at the next example to learn more about arguments and return types:

<!-- [code asset](assets/MethodField.hx) -->
```haxe
class Main {
  static public function main() {
    myFunc("foo", 1);
  }

  static function myFunc(f:String, i) {
    return true;
  }
}
```

Arguments are given by an opening parenthesis `(` after the field(欄位|) name, a comma `,` separated(分隔|) list(列表|) of argument(引數|) specific(特定|)ations and a closing parenthesis `)`. Additional information on the argument specification is described in [Function Type](types-function).

The example demonstrates how [type inference](type-system-type-inference) can be used for both argument and return types. The method `myFunc` has two argument(引數|)s but only explicitly(明確|) gives the type(型式|n. 又：型別) of the first one, `f`, as `String`. The second one, `i`, is not type-hinted and it is left to the compiler to infer its type from calls made to it. Likewise, the return type of the method is inferred from the `return true` expression(表達式|) as `Bool`.

<!--label:class-field-overriding-->
#### Overriding Methods

Overriding fields is instrumental for creating class hierarchies. Many design patterns utilize it, but here we will explore only the basic functionality. In order to use overrides in a class, it is required that this class has a [parent class](types-class-inheritance). Let us consider the following example:

<!-- [code asset](assets/Override.hx) -->
```haxe
class Base {
  public function new() {}

  public function myMethod() {
    return "Base";
  }
}

class Child extends Base {
  public override function myMethod() {
    return "Child";
  }
}

class Main {
  static public function main() {
    var child:Base = new Child();
    trace(child.myMethod()); // Child
  }
}
```

The important components here are:

* the class `Base` which has a method(方法|) `myMethod` and a constructor(建構式|),
* the class(類別|) `Child` which `extends Base` and also has a method(方法|) `myMethod` being declare(宣告|)d with `override`, and
* the `Main` class(類別|) whose `main` method(方法|) create(建立|)s an instance(實例|) of `Child`, assigns it to a variable `child` of explicit type(型式|n. 又：型別) `Base` and calls `myMethod()` on it.

The variable(變數|) `child` is explicitly(明確|) type(型式|n. 又：型別)d as `Base` to highlight an import(匯入|)ant difference: At compile-time(編譯期|又：編譯時) the type(型式|n. 又：型別) is known to be `Base`, but the runtime still finds the correct method `myMethod` on class(類別|) `Child`. This is because field access is resolved dynamically at runtime.

The `Child` class(類別|) can access(存取|) method(方法|)s it has overridden by calling `super.methodName()`:

<!-- [code asset](assets/OverrideCallParent.hx) -->
```haxe
class Base {
  public function new() {}

  public function myMethod() {
    return "Base";
  }
}

class Child extends Base {
  public override function myMethod() {
    return "Child";
  }

  public function callHome() {
    return super.myMethod();
  }
}

class Main {
  static public function main() {
    var child = new Child();
    trace(child.callHome()); // Base
  }
}
```

The section on [Inheritance](types-class-inheritance) explains the use of `super()` from within a `new` constructor(建構式|).

<!--label:class-field-override-effects-->
#### Effects of variance(變異數|) and access(存取|) modifier(修飾符|)s

Overriding adheres to the rules of [variance(變異數|)](type-system-variance). That is, their argument(引數|) type(型式|n. 又：型別)s allow(容許|又：允許) **contravariance(反變數|)** (less specific(特定|) type(型式|n. 又：型別)s) while their return(回傳|) type(型式|n. 又：型別) allow(容許|又：允許)s **covariance(共變數|)** (more specific(特定|) type(型式|n. 又：型別)s):

<!-- [code asset](assets/OverrideVariance.hx) -->
```haxe
class Base {
  public function new() {}
}

class Child extends Base {
  private function method(obj:Child):Child {
    return obj;
  }
}

class ChildChild extends Child {
  public override function method(obj:Base):ChildChild {
    return null;
  }
}

class Main {
  static public function main() {}
}
```

Intuitively, this follows from the fact that arguments are "written to" the function and the return value is "read from" it.

The example also demonstrates how [visibility](class-field-visibility) may be changed: An overriding field may be `public` if the overridden field(欄位|) is `private`, but not the other way around.

It is not possible to override fields which are declared as [`inline`](class-field-inline). This is due to the conflicting concepts: While inlining is done at compile-time by replacing a call with the function body, overriding fields necessarily have to be resolved at runtime.

<!--label:class-field-access-modifier-->
### Access Modifier

<!--subtoc-->

<!--label:class-field-visibility-->
#### Visibility

Fields are by default **private**, meaning that only the class and its sub-classes may access them. They can be made **public** by using the `public` access(存取|) modifier(修飾符|), allow(容許|又：允許)ing access(存取|) from anywhere.

<!-- [code asset](assets/Visibility.hx) -->
```haxe
class MyClass {
  static public function available() {
    unavailable();
  }

  static private function unavailable() {}
}

class Main {
  static public function main() {
    MyClass.available();
    // Cannot access private field unavailable
    MyClass.unavailable();
  }
}
```

Access to field `available` of class(類別|) `MyClass` is allow(容許|又：允許)ed from within `Main` because it is denote(表示|)d as being `public`. However, while access to field `unavailable` is allow(容許|又：允許)ed from within class(類別|) `MyClass`, it is not allowed from within class `Main` because it is `private` (explicitly(明確|), although this identifier(識別符|) is redundant(冗餘|) here).

The example demonstrates visibility through **static(靜態|)** field(欄位|)s, but the rules for member(成員|) field(欄位|)s are equivalent. The following example demonstrates visibility behavior(行為|) for when [inheritance(繼承|)](types-class-inheritance) is involved.

<!-- [code asset](assets/Visibility2.hx) -->
```haxe
class Base {
  public function new() {}

  private function baseField() {}
}

class Child1 extends Base {
  private function child1Field() {}
}

class Child2 extends Base {
  public function child2Field() {
    var child1 = new Child1();
    child1.baseField();
    // Cannot access private field child1Field
    child1.child1Field();
  }
}

class Main {
  static public function main() {}
}
```

We can see that access to `child1.baseField()` is allow(容許|又：允許)ed from within `Child2` even though `child1` is of a different type(型式|n. 又：型別), `Child1`. This is because the field is defined on their common ancestor class `Base`, contrary to field `child1Field` which can not be access(存取|)ed from within `Child2`.

Omitting the visibility modifier usually defaults the visibility to `private`, but there are exceptions where it becomes `public` instead:

1. If the class(類別|) is declare(宣告|)d as `extern`.
2. If the field is declared on an [interface](types-interfaces).
3. If the field [overrides](class-field-overriding) a public field.
4. If the class has metadata `@:publicFields`, which forces all class fields of inheriting classes to be public.

> ##### Trivia: Protected
>
> Haxe does not support the `protected` keyword(關鍵字|) known from many other object-oriented(物件導向|) programming language(程式語言|)s like Java and C++. However, Haxe's `private` behaves similarly to `protected` in other languages, but does not allow(容許|又：允許) access(存取|) from non-inherit(繼承|)ing class(類別|)es in the same package(套件|).

<!--label:class-field-inline-->
#### inline(內聯|)

##### inline(內聯|) function(函式|)s

The `inline` keyword(關鍵字|) allow(容許|又：允許)s function(函式|) bodies to be directly inserted in place of calls to them. This can be a powerful optimization tool but should be used judiciously as not all function(函式|)s are good candidates for inline(內聯|) behavior(行為|). The following example demonstrates the basic usage:

<!-- [code asset](assets/Inline.hx) -->
```haxe
class Main {
  static inline function mid(s1:Int, s2:Int) {
    return (s1 + s2) / 2;
  }

  static public function main() {
    var a = 1;
    var b = 2;
    var c = mid(a, b);
  }
}
```

The generated JavaScript output reveals the effect of inline:

```js
(function () { "use strict";
var Main = function() { }
Main.main = function() {
  var a = 1;
  var b = 2;
  var c = (a + b) / 2;
}
Main.main();
})();
```

As evident, the function body `(s1 + s2) / 2` of field(欄位|) `mid` was generate(產生|)d in place of the call to `mid(a, b)`, with `s1` being replaced by `a` and `s2` being replaced by `b`. This avoids a function call which, depending on the target and frequency of occurrences, may yield noticeable performance improvements.

It is not always easy to judge if a function qualifies for being inline. Short functions that have no writing expressions (such as a `=` assign(賦值|又：指派、指定、分配)ment) are usually a good choice, but even more complex function(函式|)s can be candidates. However, in some cases, inlining can actually be detrimental to performance(效能|), e.g. because the compiler(編譯器|) has to create(建立|) temporary variable(變數|)s for complex expression(表達式|)s.

inline(內聯|) is not guaranteed to be done. The compiler(編譯器|) might cancel inlining for various reasons or a user(使用者|) could supply the `--no-inline` command line(列|) argument(引數|) to disable inlining. The only exception is if the class(類別|) is [extern](lf-externs) or if the class(類別|) field(欄位|) has the [`extern`](class-field-extern) access modifier, in which case inline is forced. If it cannot be done, the compiler emits an error.

It is important to remember this when relying on inline:

<!-- [code asset](assets/InlineRelying.hx) -->
```haxe
class Main {
  public static function main() {}

  static function test() {
    if (Math.random() > 0.5) {
      return "ok";
    } else {
      error("random failed");
    }
  }

  @:extern static inline function error(s:String) {
    throw s;
  }
}
```

If the call to `error` is inline(內聯|)d the program compiles correctly because the control flow checker(檢查器|) is satisfied due to the inline(內聯|)d [throw](expression-throw) expression(表達式|). If inline(內聯|) is not done, the compiler(編譯器|) only sees a function(函式|) call to `error` and emits the error(錯誤|) `A return is missing here`.

Since Haxe 4 it is also possible to inline specific calls to a function or constructor, see [`inline` expression(表達式|)](expression(表達式|)-inline(內聯|)).

##### inline(內聯|) variable(變數|)s

The `inline` keyword(關鍵字|) can also be applied to variable(變數|)s, but only when used together with `static`. An inline variable must be initialized to a [constant](expression-constants), otherwise the compiler emits an error. The value of the variable is used everywhere in place of the variable itself.

The following code demonstrates the usage of an inline variable:

<!-- [code asset](assets/InlineVariable.hx) -->
```haxe
class Main {
  static inline final language = "Haxe";

  static public function main() {
    trace(language);
  }
}
```

The generated JavaScript shows that the `language` variable(變數|) is not present anymore:

```js
(function ($global) { "use strict";
var Main = function() { };
Main.main = function() {
  console.log("root/program/Main.hx:5:","Haxe");
};
Main.main();
})({});
```

Note that even though we call such kind of fields "variables", inline variables can never be reassigned as the value must be known at compile-time to be inlined at the place of usage. This makes inline variables a subset of [`final` field(欄位|)s](class(類別|)-field(欄位|)-final(最終|)), hence the usage of the `final` keyword(關鍵字|) in the code example above.

> ##### Trivia: `inline var`
>
> Prior to Haxe 4, there was no `final` keyword(關鍵字|). The inline(內聯|) variable(變數|)s feature(特徵|) however was present for a long time, using the `var` keyword(關鍵字|) instead of `final`. Using `inline var` still works in Haxe 4 but might be deprecated in the future, because `final` is more appropriate.

<!--label:class-field-dynamic-->
#### dynamic(動態|)

method(方法|)s can be denote(表示|)d with the `dynamic` keyword(關鍵字|) to make them (re-)bind(繫結|)able:

<!-- [code asset](assets/DynamicFunction.hx) -->
```haxe
class Main {
  static dynamic function test() {
    return "original";
  }

  static public function main() {
    trace(test()); // original
    test = function() {
      return "new";
    }
    trace(test()); // new
  }
}
```

The first call to `test()` invoke(引動|)s the original function(函式|) which return(回傳|)s the `String` `"original"`. In the next line, `test` is **assign(賦值|又：指派、指定、分配)ed** a new function(函式|). This is precisely what `dynamic` allow(容許|又：允許)s: function(函式|) field(欄位|)s can be assign(賦值|又：指派、指定、分配)ed a new function(函式|). As a result, the next invocation(引動|) of `test()` return(回傳|)s the `String` `"new"`.

Dynamic fields cannot be `inline` for obvious reasons: While inlining is done at compile-time(編譯期|又：編譯時), dynamic(動態|) function(函式|)s necessarily have to be resolve(解析|)d at runtime.

<!--label:class-field-override-->
#### override(覆寫|)

The access(存取|) modifier(修飾符|) `override` is required when a field(欄位|) is declare(宣告|)d which also exists on a [parent class(父類別|)](types-class-inheritance). Its purpose is to ensure that the author of a class(類別|) is aware of the override(覆寫|) as this may not always be obvious in large class(類別|) hierarchies. Likewise, having `override` on a field(欄位|) which does not actually override(覆寫|) anything (e.g. due to a misspelt field(欄位|) name) triggers an error(錯誤|).

The effects of overriding field(欄位|)s are detailed in [Overriding method(方法|)s](class-field-overriding). This modifier(修飾符|) is only allow(容許|又：允許)ed on [method(方法|)](class-field-method) field(欄位|)s.

<!--label:class-field-static-->
#### static(靜態|)

All field(欄位|)s are member(成員|) field(欄位|)s unless the modifier(修飾符|) `static` is used. static(靜態|) field(欄位|)s are used "on the class(類別|)" whereas non-static(靜態|) field(欄位|)s are used "on a class instance(類別實例|)":

<!-- [code asset](assets/StaticField.hx) -->
```haxe
class Main {
  static function main() {
    Main.staticField; // static read
    Main.staticField = 2; // static write
  }

  static var staticField:Int;
}
```

Static [variable](class-field-variable) and [property](class-field-property) fields can have arbitrary initialization [expressions](expression).

<!--label:class-field-extern-->
#### Extern

##### since Haxe 4.0.0

The `extern` keyword(關鍵字|) causes the compiler(編譯器|) to not generate(產生|) the field(欄位|) in the output. This can be used in combination with the [`inline`](class-field-inline) keyword to force a field to be inlined (or cause an error if this is not possible). Forcing inline may be desirable in abstracts or extern classes.

> ##### Trivia: `:extern` metadata(元資料|)
>
> Prior to Haxe 4, this access(存取|) modifier(修飾符|) could only be applied to a field(欄位|) using the `:extern` [metadata(元資料|)](lf-metadata).

<!--label:class-field-final-->
#### final(最終|)

##### since Haxe 4.0.0

The `final` keyword(關鍵字|) can be used on class(類別|) field(欄位|)s with the following effects:

* `final function ...` to make a function(函式|) non-overridable in subclass(類別|)es.
* `final x = ...` to declare(宣告|) a constant(常數|) that must be initialize(初始化|)d immediately or in the constructor(建構式|) and cannot be written to.
* `inline final x = ...` is the same but [inline(內聯|)s](class-field-inline) the value(值|) wherever it is used. Only constant value(定值|)s can be assign(賦值|又：指派、指定、分配)ed.

`static final` field(欄位|)s must be initialize(初始化|)d immediately by providing an expression(表達式|). If a class(類別|) has non-static(靜態|) `final` variable(變數|)s which are not initialize(初始化|)d immediately, it requires a constructor(建構式|) which has to assign(賦值|又：指派、指定、分配) value(值|)s to all such field(欄位|)s. `final` does not affect [visibility](class-field-visibility) and it is not supported on [properties](class-field-property).
