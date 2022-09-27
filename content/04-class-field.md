<!--label:class-field-->
# 類別欄位

> #### 定義：類別欄位
>
> 類別欄位是類別的變數、屬性或方法，其可以是靜態或非靜態的。非靜態欄位可稱其為**成員**欄位，所以我們將其稱之為例如**靜態方法**或**成員變數**。

在目前為止，我們已經了解到了型式和 Haxe 程式的結構。對於類別欄位部分總結了結構的部分以及連接至 Haxe 行為的部分。這是由於類別欄位是[運算式](expression)所在的地方。

類別欄位有三種：

- 變數：[變數](class-field-variable)類別欄位儲存某種型式的值以供讀寫。
- 屬性：[屬性](class-field-property)類別欄位為在類別之外的內容定義了客製存取行為始知看起來像是變數欄位。
- 方法：[方法](class-field-method)是可呼叫以執行程式碼的函式。

嚴格來說，變數是可視作具有某些存取修飾符的屬性。事實上，Haxe 編譯器在其編寫階段不區分變數和屬性，但在語法級別上兩者保持分隔。

在術語方面，方法是所屬類的（靜態或非靜態）函式。而其他函式，例如運算式中的局部函式則不會視為方法。

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
> 在使用右側[欄位存取運算式](expression-field-access)時，會發生對欄位的讀存取。這包括形如 `obj.field()` 的呼叫，其中 `field` 以讀的方式受存取。
<!---->
> #### 定義：寫存取
>
> 當[欄位存取運算式](expression-field-access)以形如 `obj.field = value` 的方式指派時，會發生對欄位的寫存取。這也可能會與`obj.field += value` 等運算式中的如 `+=` 的特殊指派運算子的[讀存取](define-read-access)結合使用。

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
- `get` 或 `set`：存取將產生為對**存取器方法**的呼叫。編譯器將確保存取器可用。
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

如同指定的那樣，讀存取產生 `get_x()` 的呼叫，而寫存取產生對 `set_x(2)` 的呼叫，其中 `2` 是賦給 `x`的值。`+=` 的產生方式起初看起來有點奇怪，不過可以透過下面的例子輕鬆證明：

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

在此處發生的情況是，在 `main` 方法中存取 `x` 欄位的運算式部分是**複雜的**：其具有潛在的副作用，比如在這種情況下需要建構 `Main`。因此，編譯器無法將 `+=` 運算產生為 `new Main().x = new Main().x + 1`，並且將複雜運算式快取在局部變數中：

```js
Main.main = function() {
  var _g = new Main();
  _g.set_x(_g.get_x() + 1);
}
```

<!--label:class-field-property-type-system-impact-->
### 對型式系統的影響

屬性的存在對型式系統有許多影響。最重要的是，必須了解到屬性是編譯期特徵，因此**需求的是已知型式**。如果我們將具有屬性的類別指派為 `Dynamic`，那麼欄位存取將**不再**考量存取器方法。同樣，存取限制也將不再適用，所有的存取實際上都會是公開。

在使用 `get` 或 `set` 存取識別符時，編譯器會確保取得器和設定器確實存在。下列程式碼片段無法編譯：

<!-- [code asset](assets/Property4.hx) -->
```haxe
class Main {
  // 屬性 x 的取得器方法 get_x 缺失
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
### 取得器與設定器的規則

存取器方法的可見性對其屬性的可存取性沒有影響。也就是說，如果屬性是 `public` 的並且定義有取得器，那這個取得器識可定義為 `private` 的。

取得器和設定器都可透過其實體欄位以資料儲存。編譯器會確保在存取器方法本身內部執行欄位存取時不會透過存取器方法以避免發生無盡遞迴。

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

不過，編譯器會在至少有一個存取器識別符為 `default` 或 `null` 時才假定其實體欄位存在。

> #### 定義：實體欄位
>
> 滿足下列條件的欄位是**實體的**：
>
> - [變數](class-field-variable)，
> - 讀存取或寫存取識別符為 `default` 或 `null` 的[屬性](class-field-property)，
> - 有 `:isVar` [元資料](lf-metadata)的[屬性](class-field-property)。

若不在上列而在存取器方法之內存取欄位將導致編譯錯誤：

<!-- [code asset](assets/GetterSetter2.hx) -->
```haxe
class Main {
  // 該欄位由於不是實體欄位，所以無法存取
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

若確實需用實體欄位，則可以強制透過 `:isVar` [元資料](lf-metadata)標定所需的欄位：

<!-- [code asset](assets/GetterSetter3.hx) -->
```haxe
class Main {
  // @:isVar 強制使欄位為實體的以容許程式編譯。
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

> #### 瑣事：屬性設定器的型式
>
> 對新的 Haxe 使用者來說很常見的困惑是設定器的型式要求是 `T->T` 而不是看似更自然的 `T->Void`。畢竟**設定器**為何需要返回一些東西？
>
> 其原因是我們仍會希望使用設定器作為右運算式來指派。比如運算式鏈 `x = y = 1`將會解析為 `x = (y = 1)`。為了將 `y = 1` 的結果指派給 `x`，前者必須要有一個值。若 `y` 的設定器回傳是 `Void` 就無法實現。

<!--label:class-field-method-->
## 方法

[變數](class-field-variable)儲存資料，方法則透過存放運算式定義程式的行為。我們在本文件的每個程式碼樣例中都見到了方法欄位，甚至在最初的 [Hello World](introduction-hello-world)中都包含有 `main` ：

<!-- [code asset](assets/HelloWorld.hx) -->
```haxe
/**
    多行文件註釋。
**/
class Main {
  static public function main():Void {
    // 單行註釋
    trace("Hello World");
  }
}
```

方法由 `function` 關鍵字識別。我們可以了解到它們：

1. 有一個名稱（此處：`main`），
1. 有一個引數清單（此處：空 `()`），
1. 有一個回傳型式（此處：`Void`），
1. 可以有若干[存取修飾符](class-field-access-modifier)（此處：`static`、`public`），
1. 可以有一個運算式（此處：`{trace("Hello World");}`）。

我們可以看看下一個例子以了解到關於引數和回傳型式的更多資訊：

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

引數由欄位名之後的左括號 `(` 開始，然後就是以逗號分隔的引數規格列表，最後再以右括號 `)` 結束。引數規格中的其餘資訊由[函式型式](types-function)描述。

該例子演示了如何將型式推理應用於引數和回傳型式。方法 `myFunc` 有兩個引數，但只有第一個引數 `f` 明確給定了型式為 `String`，而第二個引數 `i` 則沒有型式提示，這會留給編譯器在對其的呼叫中推斷其型式。同樣，方法的回傳型式可以由 `return true` 運算式推斷為 `Bool`。

<!--label:class-field-overriding-->
### 覆寫方法

覆寫欄位有助於建立類別的層次結構，有許多設計型樣都有用到這點，但在此處我們將只探討其基本功能。為了在類別中使用覆寫，這個類需要有一個[父類別](types-class-inheritance)。我們考慮以下例子：

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

此處的重要組成部分是：

- 類別 `Base`，有一個方法 `myMethod` 和建構式。
- 類別 `Child`，`extends Base` 並且也有一個方法 `myMethod` 以 `override` 宣告。
- `Main` 類別的 `main` 方法建立了 `Child` 的實例，並將其指派至了型式為 `Base` 的變數 `child`，然後在其上呼叫了 `myMethod` 方法。

變數 `child` 在此明確形式化為了 `Base`，這是為了突出一個重要區別：雖然編譯期可知其型式為 `Base`，但在執行期欄位呼叫仍會找到在類別 `Child` 中的正確方法 `myMethod`。這是由於欄位的存取是在執行期動態解析的。

`Child` 類別可以透過呼叫 `super.methodName()` 存取覆寫前的方法。

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

在[繼承](types-class-inheritance)中，對 `new` 建構式中 `super()` 的使用有所解釋。

<!--label:class-field-override-effects-->
### 變異數和存取修飾符的影響

覆寫遵循[變異數](type-system-variance)規則。也就是其引數的型式容許**反變數**（更不特定的型式），而回傳型式則容許**共變數**（更特定的型式）：

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

直觀來說，這是由於引數是要「寫入」函式而回傳值是由它「讀出」的事實決定的。

該例子還演示了如何修改[可見性](class-field-visibility)：如果受覆寫欄位是 `private` 的，那覆寫的欄位可以是 `public` 的，但反之則不然。

宣告為 [`inline`](class-field-inline)的欄位不可覆寫。這是由於概念上的衝突：內聯是在編譯期透過替換呼叫完成的，而欄位覆寫需要在執行期解析。

<!--label:class-field-access-modifier-->
## 存取修飾符

<!--subtoc-->

<!--label:class-field-visibility-->
### 可見性

欄位默認下是**私用的**，也就是說只有類別及其子類別可以存取它們。不過可以透過使用 `public` 存取修飾符使之成為**公用的**，這將容許其可於任何位置存取。

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
    // 無法存取私有欄位 unavailable
    MyClass.unavailable();
  }
}
```

因為 `available` 是以 `public` 表示的，所以其在 `Main` 中是可以存取的。不過，由於 `unavailable` 是 `private` 的（是明確寫出的，不過在此處是冗餘的）所以欄位 `unavailable` 可以在類別 `MyClass` 中存取但在類別 `Main` 中不行。

該例子以**靜態**欄位演示了可見性，不過對於成員欄位來說規則也是一樣的。以下例子演示了涉及[繼承](types-class-inheritance)時的可見性行為。

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
    // 無法存取私有欄位 child1Field
    child1.child1Field();
  }
}

class Main {
  static public function main() {}
}
```

我們可以看到透過 `Child2` 存取 `child1.baseField()` 是容許的，即便 `child1` 是另一種不同的型式。這是由於該欄位是由它們的共同父類別 `Base` 上定義的，與無法在 `Child2` 中存取的欄位 `childField` 不同。

省略可見性修飾符通常會使得可見性莫認為 `private`，但也有例外，下列將會變為 `public`：

1. 類別宣告為 `extern`。
1. 欄位宣告在[介面](types-interfaces)上。
1. 欄位[覆寫](class-field-overriding)了共用欄位。
1. 類別具有元資料 `@:publicFields`，這將強制繼承的所有類別的欄位是共用的。

> #### 瑣事：保護
>
> Haxe 並不支援在其他許多物件導向程式語言，比如 Java 和 C++ 中的 `protected` 關鍵字。不過，Haxe 的 `private` 行為和其他語言中的 `protected` 很類似，但是不容許在相同套件的從非繼承類存取。

<!--label:class-field-inline-->
### 內聯

#### 內聯函式

`inline` 關鍵字容許以函式本體直接插入替代對其的呼叫。這可以是非常強大的優化工具，但應謹慎使用，因為並非所有的函式都適合內聯行為。以下例子展示了其基本用法：

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

產生的 JavaScript 輸出揭示了內聯的效果：

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

顯然，對 `mid(a, b)` 的呼叫會以欄位 `mid` 的函式本體替代，其中 `s1` 與 `s2` 分別替換為 `a` 與 `b`。這樣可以迴避函式呼叫，根據目標和發生頻次，這樣可能會產生顯著的效能提升。

判斷一個函式是否符合內聯的條件並不總是那麼容易。不過對沒有書寫運算式的短函式（例如： `=` 指派式）通常是個不錯的選擇，不過更複雜的函式也可以是候選函式。不過在某些情形下，內聯又可能會損害效能，例如編譯器會必須為複雜的運算式建立臨時變數。

內聯不能確保會完成，編譯器可能會出於各種原因取消內聯，或者用戶可以以 `--no-inline` 命令列引數來停用內聯。唯一的例外是如若類別是[外部的](lf-externs)或者是類別欄位有[`extern`](class-field-extern)存取修飾符，在這種情況下會強制內聯。如果無法完成則編譯器會出錯。

在依賴內聯時記住這點很重要：

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

如果對 `error` 的呼叫是內聯的，則程式可以正常編譯，因為內聯的[擲回](expression-throw)運算式可以滿足流控制檢查器的要求。若內聯沒有完成，編譯器只會程式對 `error` 的呼叫並發出錯誤「此處缺少回傳值」（`A return is missing here`）。

自 Haxe 4 後，也可以內聯對函式或構造器的特定呼叫，請參閱 [`inline` 運算式](expression-inline)。

#### 內聯變數

`inline` 關鍵字也可用於變數，但僅可與 `static` 共用。內聯變數必須初始化為[常數](expression-constants)，否則編譯器會發出錯誤。在任何地方的變數的值將替換掉變數本身。

以下程式碼演示了內聯變數的用法：

<!-- [code asset](assets/InlineVariable.hx) -->
```haxe
class Main {
  static inline final language = "Haxe";

  static public function main() {
    trace(language);
  }
}
```

產生的 JavaScript 顯示出 `language` 變數不再存在：

```js
(function ($global) { "use strict";
var Main = function() { };
Main.main = function() {
  console.log("root/program/Main.hx:5:","Haxe");
};
Main.main();
})({});
```

注意即便我們仍將這類欄位稱為「變數」，但內聯變數永遠無法重新指派，因為必須在編譯期時知道該值才可以在使用處內聯。這也使得內聯變數成為了 [`final` 欄位](class-field-final)的子集，因此在上面的例子中有使用 `final` 關鍵字。

> #### 瑣事：`inline var`
>
> 在 Haxe 4 之前並沒有 `final` 關鍵字。不過內聯變數功能已經存在了相當長時間，不過使用的是 `var` 而不是 `final` 關鍵字。在 Haxe 4 中使用 `inline var` 仍然有效，但在將來這種寫法可能會棄用，因為 `final` 更為合適。

<!--label:class-field-dynamic-->
### 動態

方法可以以 `dynamic` 關鍵字表示，已使之可以（重新）繫結：

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

對 `test()` 的第一次呼叫引動了回傳 `String` `"original"` 的原始函式。然會在下一列中又為 `test` **指派**了一個新的函式。這正是 `dynamic` 所容許的：可以為函式欄位指派新的函式。所以，下一次對 `test()` 的引動回傳了 `String` `"new"`。

動態欄位無法是 `inline` 的，原因很顯然：內聯是在編譯期完成的，而動態函式必須在執行期解析。

<!--label:class-field-override-->
### 覆寫

當欄位的宣告也於[父類別](types-class-inheritance)存在時，就需要存取修飾符 `override`。這是為了讓類別的作者知道自己在覆寫，因為在大型的類別層次結構中這並不總是顯而易見的。在沒有實際覆寫任何內容的欄位使用 `override`（例如欄位名稱的拼寫錯誤）會觸發錯誤。

覆寫欄位的效果在[覆寫方法](class-field-overriding)中有詳細說明。此修飾符僅容許於[方法](class-field-method)欄位上使用。

<!--label:class-field-static-->
### 靜態

除了使用 `static` 了的以外，其他所有的欄位會是成員欄位。靜態欄位「在類別中」使用，而非靜態欄位則「在類別實例中」使用：

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

靜態[變數](class-field-variable)與[屬性](class-field-property)欄位可以有任意初始化[運算式](expression)。

<!--label:class-field-extern-->
### 外部

#### 自 Haxe 4.0.0

`extern` 關鍵字會使得編譯器不在輸出中產生對應欄位，這可以與 [`inline`](class-field-inline)聯合使用以強制使欄位內聯（如果不可行則可能導致錯誤）。在抽象類別或外部類別中可能會需要強制內聯。

> #### 瑣事：`:extern` 元資料
>
> 在 Haxe 4 之前，該存取修飾符只能以 `:extern` 元資料套用於欄位。

<!--label:class-field-final-->
### 最終

#### 自 Haxe 4.0.0

`final` 關鍵字可以用於也下列效果的欄位：

- `final function ...` 可使函式在子類別中不能覆寫。
- `final x = ...` 會宣告必須立即或在構造函式中初始化的不可寫入欄位。
- `inline final x = ...` 同上，不過在所有使用了的地方都會內聯該值，該變數只可指派定值。

`static final` 欄位必須以運算式立即初始化，如若類別有未有立即初始化的非靜態 `final` 變數，則需要指派值至所有欄位的建構式。`final` 不會影響可見性，並且不支援在屬性上使用。
