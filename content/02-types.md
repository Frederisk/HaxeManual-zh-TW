<!--label:types-->
# 型式

Haxe 編譯器採用豐富的型式系統，其有助於在編譯時檢測程式中與型式相關的錯誤。型式錯誤是指對給定型式以無效操作的情況，例如嘗試除以一個字串、嘗試對數字欄位的存取或在呼叫一個函式時使用過多或過少的引數。

在某些語言中，這種額外的安全性是有代價的，程式設計師不得不將型式明確賦值給語法結構：

```as3
var myButton:MySpecialButton = new MySpecialButton(); // As3
```

```cpp
MySpecialButton* myButton = new MySpecialButton(); // C++
```

在 Haxe 中則不需要明確類型註釋，因為 Haxe 編譯器會推斷出型式：

```haxe
var myButton = new MySpecialButton(); // Haxe
```

我們將在稍後的[型式推理](type-system-type-inference)中詳細探討 Haxe 的型式推理。目前，只需要說明上述程式碼中的變數 `myButton` 是一個 `MySpecialButton` **類的實例**即可。

Haxe 型式系統可得知的七個觲別組：

- **類別實例**：給定了類別或介面的物件
- **列舉實例**：Haxe 列舉的值
- **結構**：匿名結構，即命名欄位的集合
- **函式**：可以接受一個或多個引數並且有回傳值的複合型式
- **動態**：與任何其他型式相容的萬用型式
- **抽象**：在執行期會由不同型式表示的編譯期型式
- **單型**：未知型式，在隨後可能會變為另一種型式。

我們將在隨後的章節中描述這些型式組以及它們之間的關係。

> #### 定義：複合型式
>
> 複合型式是具有子型式的型式，其包括任何具有[型式參數](type-system-type-parameters)與[函式](types-function)型式的型式。

<!--label:types-basic-types-->
## 基本型式

**基本型式**有 `Bool`、`Float` 和 `Int`，他們具有以下的值所以可以在語法中輕易識別：

- `Bool` 有 `true` 和 `false`
- `Int` 有類如 `1`、`0`、`-1` 和 `0xFF0000`
- `Float` 有類如 `1.0`、`0.0`、`-1.0` 和 `1e10`

基本類別在 Haxe 中並非類別，而是以抽象實作，並與編譯器的內部算子相繫結，如同下文所述。

<!--label:types-numeric-types-->
### 數字型式

> #### 定義：Float
>
> 表示雙精度的 IEEE 64 位浮點數。
<!---->
> #### 定義：Int
>
> 表示整型數。

雖然每個 `Int` 都可以在預期為 `Float` 的地方使用，也就是說，`Int` 可**賦值為** `Float` 或者是與 `Float` **相統一**，但是事實並非如此：將 `Float` 賦值為 `Int` 可能會導致精度損失，因此並不允許這樣的隱含轉換。

<!--label:types-overflow-->
### 溢位

出於效能原因，Haxe 編譯器不會強制檢查任何溢位行為，檢查溢位的負擔落在了目標平台上。以下是一些特定平台上溢位行為的註解：

- C++、Java、C#、Neko、Flash：與 32 位整型數有相同的溢位機理
- PHP、JS、Flash 8：沒有原生的 **Int** 型式，當數字達到浮點限制時會有精度損失。

作為替代，可以使用 **haxe.Int32** 與 **haxe.Int64** 類別來確保正確的溢位行為，但這在某些平台上需要以額外計算作為代價。

<!--label:types-bool-->
### Bool

> #### 定義：Bool
>
> 表示**真**或**假**的值。

`Bool` 型式的值在 `if` 和 `while` 等的條件式中很常見。

<!--label:types-void-->
### Void

> #### 定義：Void
>
> 表示沒有型式，其通常用於表示一些東西（通常是函式）沒有值。

`Void` 是型式系統中的一個特例，因為它事實上不是型式，這用於表示沒有型式，主要用於函式的引數和回傳型式。

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

函式的型式將在[函式型式](types-function)部分中詳細探索，但快速預覽在此處有助益：在上面例子中的 `main` 函式的型式是 `Void->Void`，也就是「沒有引數也不回傳任何東西」。Haxe 不容許 `Void` 的欄位或變數，如果有此類宣告，會發生錯誤：

```haxe
// 不容許 Void 的引數和變數
var x:Void;
```

<!--label:types-nullability-->
### 可空性

> #### 定義：可空
>
> 在 Haxe 中，如果 `null` 可以賦值給一個型式，那這個型式就是可空的。

通常而言，程式語言會對可空性有單一清晰的定義。然而，由於 Haxe 目標語言的性質，Haxe 必在這方面取得妥協，雖然其中有一些語言容許並事實上對一切的預設值設為 `null`，但另一些卻甚至不容許某些型式有 `null` 值。因此，這需要區分兩種類型的目標語言：

> #### 定義：靜態目標
>
> 靜態目標使用自己的型式系統，對這些來說 `null` 不是基本型式的有效值。Flash、C++、Java與C#目標屬於此類。
<!---->
> #### 定義：動態目標
>
> 動態目標的型式系統更寬鬆，並容許基本型式使用 `null` 作為值。這適用於 JavaScript、PHP、Neko與 Flash 6-8 目標。

在動態目標上使用 `null` 時並沒有好擔心的，不過，對靜態目標則需要進一步考慮。首先，基本型式會初始化為它們的預設值。

> #### 定義：預設值
>
> 靜態目標的基本型式具有下列預設值：
>
> - `Int`：0
> - `Float`：在 Flash 上為 `NaN`，在其他靜態目標上則為 `0.0`
> - `Bool`：`false`

因此，Haxe編譯器並不容許將 `null` 賦值至靜態目標上的基本型式。為了實現賦值 `null` ，基本型式必須首先包裝為 `Null<T>`：

```haxe
// 在靜態目標上錯誤
var a:Int = null;
var b:Null<Int> = null; // 容許
```

同樣，除非經過包裝，否則基本型式不能與 `null` 比較：

```haxe
var a:Int = 0;
// 在靜態目標上錯誤
if( a == null) { ... }
var b:Null<Int> = 0;
if( b != null) { ... } // 容許
```

此限制<!--TODO:適用於-->擴充至一切執行 <!--TODO-->unification(type-system-unification) 的情況。

> #### 定義：`Null<T>`
>
> 在靜態目標上，可以使用 `Null<Int>`、`Null<Float>` 以及 `Null<Bool>` 來使之容許 `null` 作為值，這在動態目標上不會造成影響。`Null<T>` 也可以與其他型式一起使用以標記 `null` 是一個可接受的值。

如果 `Null<T>` 或 `Dynamic` 「隱含」有 `null` 值並賦值給了基本型式，則受賦值者會使用預設值：

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
> 在一些其他程式語言中，**引數**（argument）與**參數**（parameter）是可混用的。而在 Haxe 中，對方法使用的是**引數**，而對[型式引數](type-system-type-parameters)則使用**參數**。

<!--label:types-class-instance-->
## 類別實例

與許多物件導向的程式設計語言相似，類別是 Haxe 中大多數程式中主要的資料結構。每一個 Haxe 類別有一個明確的名稱、一個隱含的<!--TODO-->路徑以及若干類別欄位。在此處，我們將專注於類別的一般結構與其基本關係，同時將類別欄位的細節留給[類別欄位](class-field)。

以下的程式碼樣例是本節其餘部分的基礎：

```haxe
class Point {
  var x:Int;
  var y:Int;

  public function new(x, y) {
    this.x = x;
    this.y = y;
  }

  public function toString() {
    return "Point(" + x + "," + y + ")";
  }
}
```

從語意上說，該類別表示離散二為空間上的一個點，不過這不重要。相反，讓我們描述一下基本結構：

- 關鍵字 `class` 表明我們正在表示一個類別。
- `Point` 是類別的名稱並且可以是符合[型式識別符規則](define-identifier)的任何東西。
- 用大括號 `{}` 括住著的是類別的欄位，
- 其由兩個變數欄位 `x` 和 `y` 組成，
- 接下來是一個名為 `new` 的特殊函數欄位，這是類別的建構式，
- 以及一個名為 `toString` 的通常函數。

Haxe 中有一種特殊型式與所有類別相容：

> #### 定義：`Class<T>`
>
> 該型式與所有類別型式相容，這意味著所有類別都可以賦值給它。不過類別的實例不能賦值給該類別。
>
> 在編譯時，`Class<T>` 是所有類別型式的共同基底型式。這種關係不會反映在生成程式碼中。
>
> 當 API 要求**一個**類別而不是特定類別時，這種型式十分有用。這適用於 [[Haxe 反射 API]]中的幾個方法。

<!--label:types-class-constructor-->
### 類別建構式

類別實例是通過呼叫類別建構式建立的，這個過程通常稱作**實例化**。類別實例的另一個名稱是**物件**。儘管如此，我們更喜歡用術語類別實例來強調類別實例與[枚舉實例](types-enum-instance)的相似。

```haxe
var p = new Point(-1, 65);
```

上述程式碼將生成類別 `Point` 的實例，該實例賦值給了名為 `p` 的變數。`Point`的建構式接收到了兩個引數 `x` 和 `y`（可在[類別實例](types-class-instance)比較其定義）。我們將在之後的 [new](expression-new) 部分重新審視 `new` 表達式的確切含意。目前，先將其視為呼叫類別建構式並返回了適合的物件。

<!--label:types-class-inheritance-->
### 繼承

類別可以用關鍵字 `extends` 表示從其他類別繼承：

```haxe
class Point3 extends Point {
  var z:Int;

  public function new(x, y, z) {
    super(x, y);
    this.z = z;
  }
}
```

這種關係通常描述做「是一個」：任何 `Point3` 類別的實例也都是 `Point` 的實例。`Point` 是 `Point3` 的**父類別**，`Point3` 是 `Point` 的**子類別**。一個類別可以有多個子類別，但是只有一個父類別。術語「類別 X 的父類別」通常是說它的直接父類別、他的父類別的父類別，以此類推。

上面的程式碼與最初的 `Point` 類別非常像似，其展示了兩個新的構造：

- `extend Point` 表示這個類別繼承自類別 `Point`
- `super(x, y)` 呼叫父類別的建構式，在此例中是 `Point.new`

為子類別定義其自己的建構式並不是必要的，但只要定義了，則定義內對 `super()` 是必要的，與其他物件導向的語言不同，這個呼叫可以出現在建構式的任何位置而不必只能是第一個表達式。

類別也可通過 `override` 關鍵字覆寫其父類的[方法](class-field-method)，其效果和限制在[覆寫方法](class-field-overriding)中有更多詳細描述。

#### 自 Haxe 4.0.0

類別可使用關鍵字 `final` 宣告以阻止其他類別擴充。

> #### 瑣事：`final` 元資料
>
> 在 Haxe 4 之前，標記一個類列別是最終的也是可以的，不過需要使用 `:final` 元資料標記。

<!--label:types-interfaces-->
### 介面

介面可視作類別的簽章，它描述了類別的公共欄位。介面並不提供實作，而只是提供純粹的結構資料。

```haxe
interface Printable {
  public function toString():String;
}
```

語法與類別相似，但有一些差異:

- 使用關鍵字 `interface` 而不是 `class`。
- 函式沒有任何[表達式](expression)。
- 所有欄位都必須具有明確的型式。

介面不同於<!--TODO-->[結構子型態](type-system-structural-subtyping)描述的是類別之間的靜態關係。給定的類別需要明確宣告才會視為與介面兼容：

```haxe
class Point implements Printable { }
```

此處的 `implements` 關鍵字表明 `Point` 與 `Printable` 之間存在著「是一個」的關係，比如說每一個 `Point` 的實例都是 `Printable` 的實例。雖然一個類別只能有一個父類別，但可以透過多個 `implements` 關鍵字實作多個介面：

```haxe
class Point implements Printable
  implements Serializable
```

編譯器會檢查 `implements` 的假設是否成立。也就是確認類別是否已實作介面所有的欄位。如果類別或其任何父類別對一個欄位有實作，那麼這個欄位就會被視為已實作。

介面欄位並不僅限為方法，他們也可以是變數和屬性：

<!-- [code asset](assets/InterfaceWithVariables.hx) -->
```haxe
interface Placeable {
  public var x:Float;
  public var y:Float;
}

class Main implements Placeable {
  public var x:Float;
  public var y:Float;

  static public function main() {}
}
```

介面也可使用 `extends` 關鍵詞與多個其他介面擴充：

```haxe
interface Debuggable extends Printable extends Serializable
```

#### 自 Haxe 4.0.0

如同類別，介面也可使用關鍵字 `final` 宣告以阻止其他介面擴充。

> #### implements 語法
>
> Haxe 版本 3.0 之前多個 `implements` 關鍵字必須用逗號分隔，我們決定遵照 Java 的事實標準棄用逗號，這是 Haxe 2 與 Haxe 之間的重大變更之一。

<!--label:types-abstract-class-->
### 抽象類別

#### 自 Haxe 4.2.0

抽象類別（不要與[抽象](type-system-type-inference)相混淆）是具有部分實作的類別。因此，抽象類別無法實作而必須首先擴充，其子類要麼提供所有抽象方法的實作，要麼宣告自己也是抽象的。

與抽象類別相反，實作了所有自身方法的類別稱之為具體類別。具體型式宣告時不能使用 `abstract` 關鍵字，且父類別中的抽象方法必須全部實作。

抽象類別支援具體類別中的所有語言特徵，任何類別都可宣告為抽象的。此外，抽象類別方法與介面相似，方法的實作不須使用 `override` 關鍵字。

```haxe
abstract class Vehicle {
  var speed:Float = 0;

  abstract public function getWheels():Int;

  public function new() {}
}

class Car extends Vehicle {
  public function getWheels() {
    return 4;
  }

  public function accelerate() {
    speed += 1;
  }
}

class Bike extends Vehicle {
  public function getWheels() {
    return 2;
  }

  public function accelerate() {
    speed += 2;
  }
}
```

抽象類別可只提供實作介面的部分，其餘的實作交由子類別。

```haxe
interface Vehicle {
  public function getFuelType():String;
  public function getWheels():Int;
}

abstract class Bike implements Vehicle {
  public function getWheels():Int {
    return 2;
  }

  public function new() {}
}

class EBike extends Bike {
  public function getFuelType():String {
    return "electric";
  }
}
```

如同其他繼承關係，子類別可賦值至其抽象父類別類型。

```haxe
abstract class Base {
  public abstract function say():String;

  public function new() {}
}

class Derived extends Base {
  public function say():String {
    return "Hello";
  }
}

class Main {
  public static function main() {
    var instance:Base = new Derived();
  }
}
```

類別即便沒有抽象方法也可宣告為抽象的。在此例中，這個抽象類別無法實例化，但是非抽象的子類別可以。

```haxe
abstract class Spaceship {
  public function whatAmI():Void {
    trace("Spaceship");
  }

  public function new() {}
}

class Rocket extends Spaceship {}

class Main {
  public static function main() {
    // var spaceship = new Spaceship();  // 錯誤：Spaceship 是抽象的，無法建構
    var rocket = new Rocket(); // 成功
  }
}
```

儘管其無法實例化，但抽象類別依然可以有建構式，其可以由子類別透過 `super()` 呼叫。

```haxe
abstract class Parent {
  public function new() {
    trace("Parent created!");
  }
}

class Child extends Parent {
  public function new() {
    super();
    trace("Child created!");
  }
}
```

<!--label:types-enum-instance-->
## 枚舉實例

Haxe 提供了極其強大的枚舉型式，其實質上是**代數資料型式**（ADT）。雖然此種型式不能擁有任何表達式，但其在描述資料時十分有用。

<!-- [code asset](assets/Color.hx) -->
```haxe
enum Color {
  Red;
  Green;
  Blue;
  Rgb(r:Int, g:Int, b:Int);
}
```

該枚舉在語意上描述了一個顏色：紅、綠、藍、或者一個特定的 RGB 值。語法結構如下：

- 關鍵字 `enum` 表示我們正在宣告枚舉。
- `Color` 表示枚舉名稱並且可以是符合[型式識別符規則](define-identifier)的任何東西。
- 用大括號 `{}` 括住著的是**枚舉建構式**，
- 其中 `Red`、`Green` 和 `Blue` 不需要引數，
- 另外的 `Rgb` 要有三個 `Int` 引數，分別名為 `r`, `g` 和 `b`。

Haxe 的型式系統提供了一種統一了所有枚舉的型式：

> #### 定義：`Enum<T>`
>
> 此型式與所有枚舉型式相容。在編譯期 `Enum<T>` 可視作所有枚舉型式的共同基底型式，不過這種關係不會反映在生成程式碼中。

<!--label:types-enum-constructor-->
### 枚舉建構式

與類別與其建構式類似，枚舉可透過建構式實例化。不過與類別同的是，枚舉提供了多個建構式，這些建構式可以透過各自的名稱呼叫：

```haxe
var a = Red;
var b = Green;
var c = Rgb(255, 255, 0);
```

在此處的程式碼中，`a`、`b` 和 `c` 是 `Color` 枚舉的實例，變數 `c` 以引數的方式呼叫 `Rgb` 建構式實例化。

所有的枚舉實例都可賦值至一個特殊型式 `EnumValue`。

> ##### Define: EnumValue
>
> EnumValue 是一種與所有枚舉實例相統一的特殊型式。其由[標準函式庫](std)所用於為所有枚舉實例提供某些操作，以及在 API 需要的情況下容許在用戶程式碼中使用不特定枚舉實例。

區別枚舉型式與枚舉建構式十分重要，如此例所示：

<!-- [code asset](assets/EnumUnification.hx) -->
```haxe
enum Color {
  Red;
  Green;
  Blue;
  Rgb(r:Int, g:Int, b:Int);
}

class Main {
  static public function main() {
    var ec:EnumValue = Red; // 有效
    var en:Enum<Color> = Color; // 有效
    // 錯誤：Color 應為 Enum<Color>
    // var x:Enum<Color> = Red;
  }
}
```

如果對註釋內容取消註釋，程式將因為 `Red`（枚舉建構式）無法賦值給型式為 `Enum<Color>`（枚舉型式）而無法編譯。這種關係和類別與其實作的關係是類似的。

> 瑣事：`Enum<T>`的具體型別參數
>
> 本手冊的其中一位審閱者對上面例子中 `Color` 與 `Enum<Color>` 的區別表示困惑。實際上在這兒使用具體型式只是提供示範而沒有實際意義。通常來說，我們會省略那兒的型式然後讓[型式推理](type-system-type-inference)去處理。
>
> 不過推斷的型式會與 `Enum<Color>` 有差別。編譯器會推斷出一個將枚舉建構式作為「欄位」的偽型式。Haxe 3.2.0 後沒有任何語法能夠表達這種型式，當然也沒有任何這樣做的必要。

<!--label:types-enum-using-->
### 使用枚舉

如果想要只允許使用有限的值集合，枚舉會是不錯的選擇。然後各個建構式表示允許的變體，這樣編譯器就能夠檢查是否所有可能的值都得到了遵守：

<!-- [code asset](assets/Color2.hx) -->
```haxe
enum Color {
  Red;
  Green;
  Blue;
  Rgb(r:Int, g:Int, b:Int);
}

class Main {
  static function main() {
    var color = getColor();
    switch (color) {
      case Red:
        trace("Color was red");
      case Green:
        trace("Color was green");
      case Blue:
        trace("Color was blue");
      case Rgb(r, g, b):
        trace("Color had a red value of " + r);
    }
  }

  static function getColor():Color {
    return Rgb(255, 0, 255);
  }
}
```

首先透過分配 `getColor()` 的回傳值給 `color` 來檢索它的值，然後[`switch` 表達式](expression-switch)根據其值分支。前三個 case 中的 `Red`、`Green` 以及 `Blue` 十分簡單，會對應 `Color` 的無引數建構式。最後一個 case 中的 `Rgb(r, g, b)` 展示了從建構式中擷取引數值的方式，這幾個名稱在 case 的主體內可以如同使用了[`var` 表達式](expression-var)的局部變數一樣使用。

對於 `switch` 的進階使用資訊之後將在[模式匹配](lf-pattern-matching)部分進一步探索。

<!--label:types-anonymous-structure-->
## 匿名結構

匿名結構可不明確建立型式而<!--by MSFT: group data-->將資料組成群組。接下來的例子建立了一個有兩個欄位 `x` 和 `name` 的匿名結構，並分別以 `12` 和 `"foo"` 為值初始化：

<!-- [code asset](assets/Structure.hx) -->
```haxe
class Main {
  static public function main() {
    var myStructure = {x: 12, name: "foo"};
  }
}
```

一般語法規則如下：

1. 結構會用大括號 `{}` 括住並且
1. 有一個**以逗號分隔**的鍵值對列表。
1. 用**冒號**分隔的鍵和值，前者必須是一個有效[識別符](define-identifier)。
1. 值可以是任何 Haxe 表達式。

規則 4 意味著結構可以是巢套複雜的，比如：

```haxe
var user = {
  name : "Nicolas",
  age : 32,
  pos : [
    { x : 0, y : 0 },
    { x : 1, y : -1 }
  ],
};

```

結構的欄位可以如同類別一樣使用**點**（`.`）來存取：

```haxe
// 取得欄位 `name`，其值為 `Nicolas`
user.name;
// 設定 `age` 的值為 `33`
user.age = 33;
```

值得注意的是使用匿名結構並不會破壞型式系統。編譯器會確保只有可用欄位會存取，也就是說下列程式碼無法會編譯：

```haxe
class Test {
  static public function main() {
    var point = { x: 0.0, y: 12.0 };
    // { y : Float, x : Float } 沒有欄位 z
    point.z;
  }
}
```

錯誤訊息表示編譯器知道 `type` 的型式：這是一個有 `Float` 型式 `x` 和 `y` 欄位的結構。由於缺失 `z` 欄位，存取失敗。`point` 的型式是由[型式推理](type-system-type-inference)得出的，幸運的是這使我們免於對局部變數使用明確型式。若 `point` 是欄位，則明確型式是必要的：

```haxe
class Path {
    var start : { x : Int, y : Int };
    var target : { x : Int, y : Int };
    var current : { x : Int, y : Int };
}
```

為避免這種冗餘型式宣告，特別是對於更複雜的結構，建議使用 [typedef](type-system-typedef)：

```haxe
typedef Point = { x : Int, y : Int }

class Path {
    var start : Point;
    var target : Point;
    var current : Point;
}
```

你也可以用[延伸]來繼承其他結構的欄位：

```haxe
typedef Point3 = { > Point, z : Int }
```

<!--label:types-structure-json-->
### 結構值的 JSON

透過在鍵中使用**字串文字**，在結構中是可以用 <!--TODO-->**JavaScript Object Notation** 的。

```haxe
var point = { "x" : 1, "y" : -5 };
```

雖然允許使用任何字串文字，但只有在其是有效 [Haxe 識別符](define-identifier) 時該欄位會視為型式的一部分。此外，haxe 語法不容許表達對此類欄位的存取，而只能以 `Reflect.field` 和 `Reflect.setField` 使用[反射](std-reflection)作為替代。

<!--label:types-structure-class-notation-->
### 結構型式的類別表示法

在定義結構型式時，Haxe 容許使用與類別相同的語法描述。下面的 [typedef](type-system-typedef) 宣告了擁有 `Int` 型式變數欄位 `x` 和 `y` 的結構：

When defining a structure type, Haxe allows the use of the same syntax described in [Class Fields](class-field). The following [typedef](type-system-typedef) declares a `Point` type with variable fields `x` and `y` of type `Int`:

```haxe
typedef Point = {
    var x : Int;
    var y : Int;
}
```

#### 自 Haxe 4.0.0

結構的欄位也可宣告為 `final`，這將僅容許其賦值一次。這樣的結構將只會與其他對應欄位同為 `final` 的型式相[統一](type-system-unification)。

<!--label:types-structure-optional-fields-->
### 任選欄位

結構的欄位可以是任選的。在標準表示法中表示是在欄位名稱前加上問號 `?`：

```haxe
typedef User = {
  age : Int,
  name : String,
  ?phoneNumber : String
}
```

在類別表示法中則可用 `@:optional` 元資料：

```haxe
typedef User = {
  var age : Int;
  var name : String;
  @:optional var phoneNumber : String;
}
```

#### 自 Haxe 4.0.0

**類別表示法**的結構欄位也可透過在名稱加上問號 `?` 宣告為任選。

```haxe
typedef User = {
  var age : Int;
  var name : String;
  var ?phoneNumber : String;
}
```

<!--label:types-structure-performance-->
### 效能影響

使用結構以及更進一步的[結構子型態](type-system-structural-subtyping)在編譯為[動態目標](define-dynamic-target)時不會有影響。然而在[靜態目標](define-static-target)存取通常較慢。雖然在其中的一些（JVM、HL）最佳化了常見情況，但在最糟糕的情況下則需要動態查詢，這可能比類別欄位存取慢好幾個數量級。

<!--label:types-structure-extensions-->
### 延伸

延展用於表示結構具有給定型式的所有欄位以及其自身的一些其餘欄位：

<!-- [code asset](assets/Extension.hx) -->
```haxe
typedef IterableWithLength<T> = {
  > Iterable<T>,
  // 只讀屬性
  var length(default, null):Int;
}

class Main {
  static public function main() {
    var array = [1, 2, 3];
    var t:IterableWithLength<Int> = array;
  }
}
```

大於號 `>` 表示建立了 `Iterable<T>` 以及後面其餘類別欄位。在此例中，需要的是一個只讀 `Int` 型式的[屬性](class-field-property) `length`。

為了與 `IterableWithLength<T>` 相容，型式必須與 `Iterable<T>` 相容且提供一個只讀 `Int` 型式的 `length`。上面的例子中賦給值的是 `Array` ，這恰好能滿足需求。

#### 自 Haxe 3.1.0

多個結構可以一次延伸：

<!-- [code asset](assets/Extension2.hx) -->
```haxe
typedef WithLength = {
  var length(default, null):Int;
}

typedef IterableWithLengthAndPush<T> = {
  > Iterable<T>,
  > WithLength,
  function push(a:T):Int;
}

class Main {
  static public function main() {
    var array = [1, 2, 3];
    var t:IterableWithLengthAndPush<Int> = array;
  }
}
```

##### 自 Haxe 4.0.0

可以使用延伸的另外符號 `&` 間隔各個結構來表示：

<!-- [code asset](assets/Extension3.hx) -->
```haxe
typedef Point2D = {
  var x:Int;
  var y:Int;
}

typedef Point3D = Point2D & {z:Int};

class Main {
  static public function main() {
    var point:Point3D = {x: 5, y: 3, z: 1};
  }
}
```

<!--label:types-function-->
## 函式型式

函式型式以及[單型](types-monomorph)對 Haxe 使用者通常隱藏，但實際上到處存在。我們可以通過使用 `$type` 使之浮上水面，這是個可以在編譯時輸出型式自己表達式的特殊 `Haxe` 識別符：

<!-- [code asset](assets/FunctionType.hx) -->
```haxe
class Main {
  static public function main() {
    // (i : Int, s : String) -> Bool
    $type(test);
    $type(test(1, "foo")); // Bool
  }

  static function test(i:Int, s:String):Bool {
    return true;
  }
}
```

函式 `test` 的宣告與第一個 `$type` 表達式的輸出十分相似，不過後者有一個微妙不同是**函式回傳型式**出現在了 `->` 後面。

在兩種表式中，無疑函式 `test` 接受一個  `Int` 型式的引數和一個 `String` 型式的引數，並回傳一個 `Bool` 型式的值。如果呼叫該函式，例如在第二個 `$type` 表達式中的 `test(1, "foo")` 那樣。haxe 型式系統會檢查 `1` 是否可以以 `Int` 賦值以及 `"foo"` 是否可以以 `String` 賦值，該呼叫的型式與 `test` 回傳值的型式相同，都是 `Bool`。

注意函式型式中引數名稱是任選的。如果函式型式有其他函式型式作為其引數或回傳的型式，則可使用括號為它們正確分組。例如

如果函數類型具有其他函數類型作為參數或返回類型，則可以使用括號來正確對它們進行分組。`(Int, ((Int) -> Void)) -> Void` 表示一個函式，其有一個 `Int` 型式的引數和一個 `Int -> Void` 函式型式的引數，並回傳 `Void`。

沒有引數的函式使用 `()`表示引數列表：

<!-- [code asset](assets/FunctionType2.hx) -->
```haxe
class Main {
  static public function main() {
    // () -> Bool
    $type(test2);
  }

  static function test2():Bool {
    return true;
  }
}
```

#### 舊的函式型式表示法

在 Haxe 4 之前，函式型式表示法與其他函式程式語言有著更多共同之處，像是用 `->` 而不是逗號分隔引數型式。上面的 `test` 函式在這種表示法中會是 `Int -> String -> Bool`；`test2` 則是 `Void -> Bool`。

儘管舊的表示法依然在支援中，但在新程式碼中應當使用新表示法，這樣能更清晰的從引數型式中區分出回傳型式。

> 瑣事：新的函式型式表示法
>
> 新的函式型式表示法基於[箭頭函式]，(expression-arrow-function)語法，其中後者也是在 Haxe 4 中引入的。

<!--label:types-function-optional-arguments-->
### 任選引數

在引數識別符前使用問號 `?` 可宣告其為任選引數：

<!-- [code asset](assets/OptionalArguments.hx) -->
```haxe
class Main {
  static public function main() {
    // (?i : Int, ?s : String) -> String
    $type(test);
    trace(test()); // i: null, s: null
    trace(test(1)); // i: 1, s: null
    trace(test(1, "foo")); // i: 1, s: foo
    trace(test("foo")); // i: null, s: foo
  }

  static function test(?i:Int, ?s:String) {
    return "i: " + i + ", s: " + s;
  }
}
```

函式 `test` 有兩個任選引數：`Int`型式的 `i` 以及 `String` 型式的 `s`。這將直接反映在第四行的函式型式輸出中。這個樣例程式呼叫了 `test` 四次，並列印出了各自的回傳值。

1. 第一次呼叫沒有引數。
1. 第二次呼叫有一個引數，且引數為 `1`。
1. 第三次呼叫有兩個引數，且引數為 `1` 和 `foo`。
1. 第四次呼叫有一個引數，且引數為 `foo`。

輸出展示出了在呼叫中省略的任選引數的值將會是 `null`。這意味著這些引數的型式必須能將 `null` 作為其值，這引發了[可空性](types-nullability)的問題。在編譯至靜態目標時 Haxe 編譯器透過推斷任選基底型式的引數為 `Null<T>` 以確保任其是可空的。

前三個呼叫相對來說直觀，但第四種用法可能有些出人意料。在此處，其實際
原理是如果所賦值可由之後的引數接受，那麼前面的引數是可跳過的。

<!--label:types-function-default-values-->
### 預設值

Haxe 容許為引數以**定值**賦默認值：

<!-- [code asset](assets/DefaultValues.hx) -->
```haxe
class Main {
  static public function main() {
    // (?i : Int, ?s : String) -> String
    $type(test);
    trace(test()); // i: 12, s: bar
    trace(test(1)); // i: 1, s: bar
    trace(test(1, "foo")); // i: 1, s: foo
    trace(test("foo")); // i: 12, s: foo
  }

  static function test(?i = 12, s = "bar") {
    return "i: " + i + ", s: " + s;
  }
}
```

該樣例與[任選引數](types-function-optional-arguments)十分相似，唯一的不同是引數 `i` 與 `s` 分別賦值為了 `12` 和 `"bar"`。此時在呼叫時省略引數，則會使用預設值而不是 `null`。

Haxe 中的預設值不是型式的一部分並且除非函式是[內聯](class-field-inline)的，否則不會在呼叫處替換。在某些平台上，編譯器可能在省略引數時仍然傳入 `null`，而在函式內生成的程式碼看上去會是類似這樣：

```haxe
  static function test(i = 12, s = "bar") {
    if (i == null) i = 12;
    if (s == null) s = "bar";
    return "i: " +i + ", s: " +s;
  }
```

在效能關鍵的程式碼中該點值得注意，不使用預設值的解決方案可能會更可行。

<!--label:types-dynamic-->
## 動態

雖然 Haxe 有靜態型式系統，但其本質上可以透過使用 `Dynamic` 型式來關閉。**動態值**可以以任何變數賦值，也可以賦值給任何變數。這有幾個缺點：

- 編譯器將不再對預期特定型式的賦值、函式呼叫以及其他建構子執行型式檢查。
- 特定最佳化將無法套用，尤其是在編譯為靜態目標時。
- 一些常見錯誤，例如欄位的錯字，將無法在編譯期捕獲而可能造成執行期錯誤。
- 在使用 `Dynamic` 時，[死碼刪除](cr-dce)將無法探測欄位是否有在使用。

很容易就能舉出使用 `Dynamic` 造成執行期錯誤的例子。考慮編譯以靜態目標編譯以下兩行程式：

```haxe
var d:Dynamic = 1;
d.foo;
```

嘗試在 Flash Player 執行編譯後的程式將產生錯誤「在 Number 中找不到屬性 foo 並且也沒有預設值」（`Property foo not found on Number and there is no default value`）。如果不使用 `Dynamic` 則該問題在編譯期就可以檢測到。

`Dynamic` 應當盡量少範圍使用，通常而言會有其他更好的選項替代。不過偶爾這也能成為好方案，Haxe 的[反射](std-reflection) API 就用到了它。此外，在處理編譯期不明確的自訂資料結構時使用 `Dynamic` 可以是最佳選擇。

在與[單型](types-monomorph)相[統一](type-system-unification)時，`Dynamic` 的行為會比較特殊。單型不會繫結至 `Dynamic`，這可能會導致一些出人意料的結果，比如這個例子：

<!-- [code asset](assets/DynamicInferenceIssue.hx) -->
```haxe
class Main {
  static function main() {
    var jsonData = '[1, 2, 3]';
    var json = haxe.Json.parse(jsonData);
    $type(json); // Unknown<0>
    for (i in 0...json.length) {
      // 陣列存取不容許使用於
      // {+ length : Int }
      trace(json[i]);
    }
  }
}
```

雖然 `Json.parse` 的回傳型式是 `Dynamic`，但局部變數 `json` 並不會與之繫結而仍然是單型。在之後該型式在 `json.length` 欄位存取時推斷為[匿名結構](types-anonymous-structure)，這導致接下來的 `json[0]` 陣列存取失敗。為避免這種狀況，可以將變數 `json` 透過 `var json:Dynamic` 明確標註型式為 `Dynamic`。

> #### 瑣事：Haxe 3 之前的動態推斷
>
> Haxe 3 的編譯器永遠不會將型式推斷為 `Dynamic`，因此使用者必須明確指定。過往的 Haxe 版本將其用於混合型式陣列的推斷，比如 `[1, true, "foo"]` 推斷為 `Array<Dynamic>`。我們發現該行為引發了諸多型式問題，所以為 Haxe 3 將其移除。
<!---->
> #### 瑣事：標準函式庫中的動態
>
> 動態在 Haxe 3 之前的 Haxe 標準庫中使用多見，而隨著 Haxe 型式系統的不斷改進，在 Haxe 3 之前的幾個版本中動態的出現已經有所減少。

<!--label:types-dynamic-with-type-parameter-->
### 動態與型式參數

`Dynamic` 是種特殊的型式，因為其容許帶有以及不帶有[型式參數](type-system-type-parameters)的明確宣告。

动态是一个特殊的类型，因为它允许带或不带类型参数的明确声明。如果提供了型式參數，動態所描述的語意會限制為其所有欄位都與其參數的型式相容：

```haxe
var att : Dynamic<String> = xml.attributes;
// 有效，值為 String
att.name = "Nicolas";
// 同上（這文檔有些舊了）
att.age = "26";
// 錯誤，值不是 String
att.income = 0;
```

<!--label:types-dynamic-access-->
### 動態存取

`DynamicAccess` 與匿名結構相配合工作可用於以字串鍵控制物件集合。基本上，`DynamicAccess` 將[反射](std-reflection)呼叫包裝在了類似映射的介面中。

<!-- [code asset](assets/DynamicAccess.hx) -->
```haxe
class Main {
  static public function main() {
    var user:haxe.DynamicAccess<Dynamic> = {};

    // Sets values for specified keys.
    user.set("name", "Mark");
    user.set("age", 25);

    // Returns values by specified keys.
    trace(user.get("name")); // "Mark"
    trace(user.get("age")); // 25

    // Tells if the structure contains a specified key
    trace(user.exists("name")); // true
  }
}
```

<!--label:types-dynamic-any-->
### 任意型式

`Any` 是種在雙方向上與任意其他型式相容的型式，它只有存儲任意型式的值這一個目標。為確保程式碼不會突然變成動態型式，在使用這種型式的值時需要明確轉換。這個限制保障了 Haxe 的形式靜態，並可允許繼續使用進階的型式系統與型式系統相關的最佳化。

該型式的實作非常簡單：

```haxe
abstract Any(Dynamic) from Dynamic to Dynamic {}
```

「任意」型式內部的實際值或者支援的欄位完全取決於使用者處理而不會對有任何假設。

<!-- [code asset](assets/Any.hx) -->
```haxe
class Main {
  static function setAnyValue(value:Any) {
    trace(value);
  }

  static function getAnyValue():Any {
    return 42;
  }

  static function main() {
    // 任意型式的值都可工作
    setAnyValue("someValue");
    setAnyValue(42);

    var value = getAnyValue();
    $type(value); // 會是 Any 而不是 Unknown<0>

    // 無法編譯：沒有動態欄位存取
    // value.charCodeAt(0);

    if (Std.is(value, String)) {
      // 明確提升，型式安全
      // TODO
      trace((value : String).charCodeAt(0));
    }
  }
}
```

`Any` 由於不支援欄位存取與運算子，並且會繫結至單型，所以是 `Dynamic` 更加型式安全的替代。若要用實際值則需明確提升其為其他型式。

<!--label:types-abstract-->
## 抽象

抽象型式在運行期實際會是不同的型式。這是一種在編譯期定義在具體型式「之上」以修改或是增強其行為的特徵：

<!-- [code asset](assets/MyAbstract.hx#L1-L5) -->
```haxe
abstract AbstractInt(Int) {
  inline public function new(i:Int) {
    this = i;
  }
}
```

我們可以通過這個例子掌握如下事項：

- 關鍵詞 `abstract` 表示我們正在宣告抽象型式。
- `AbstractInt`表示抽象型式名稱並且可以是符合[型式識別符規則](define-identifier)的任何東西。
- **底層型式** `Int` 以括號 `()` 括住。
- 以大括號 `{}` 括住的是欄位，
- 其中有一個接受 `Int` 型式的引數 `i` 的 建構式 `new`。

> #### 定義：底層型式
>
> 抽象的底層型式用於在運行期代表的那個抽象的型式，其往往是一種具體型式（比如非抽象型式），但也可以是另一種抽象型式。

這種語法讓人想到類別，而且語意上兩者也確實相似。事實上，抽象「主體」中的所有東西（將大括號展開後的一切）都會解析為類別欄位。

語法讓人想起類，語義確實相似。 事實上，抽象的“身體”中的一切（打開捲曲括號之後的一切）被解析為類領域。抽象可以有[方法](class-field-method)欄位和非[physical](define-physical-field)<!--TODO-->[屬性](class-field-property)欄位。

此外，抽象還可以和類別一樣實例化和使用：

<!-- [code asset](assets/MyAbstract.hx#L7-L12) -->
```haxe
class Main {
  static public function main() {
    var a = new AbstractInt(12);
    trace(a); // 12
  }
}
```

如前所述，抽象是編譯期功能，所以觀察上面所實際生成的東西會很有趣，由於 JavaScript 傾向生成簡潔清晰的程式碼所以比較合適作為目標。以指令 `haxe --main MyAbstract --js myabstract.js` 編譯會得到以下 JavaScript 程式：

```js
var a = 12;
console.log(a);
```

抽象型式 `Abstract` 完全從輸出中消失了，存留下的只有其底層型式 `Int` 的值。這是由於 `Abstract` 的建構式是內聯的，並且其內聯表達式為為 `this` 賦值。對於內聯，我們將在之後的[內聯](class-field-inline)部分去了解。若以類別去考慮，這可能有些令人吃驚。不過這正是我們在抽象的上下文中所想要表達的。抽象的任何**內聯成員方法**都可賦值葛給 `this`，從而修改「內部值」。

有一個可能很明顯的問題是，如果一個成員函式沒有宣告為內聯的話會發生什麼？程式碼顯然必須放在某個地方！Haxe 會通過創建稱為 **實作類別** 的私有類別來處理這個問題，該類別會包括所有的成員函式作為靜態函式，該函式接受底層型式的第一個附加引數 `this`。

> #### 瑣事：基底型式和抽象
>
> 在抽象型式出現之前，所有的基底型式都以外部類或枚舉的方式實作。雖然這在某些方面處理得很好，比如讓 `Int` 是 `Float` 的「子類別」，但這在其他地方引起了問題。例如，當 `Float` 是外部類別時，其將與空結構 `{}` 統一，從而無法將型式限制為僅接受真實物件。

<!--label:types-abstract-implicit-casts-->
### 隱含轉換

與類別不同，抽象容許定義隱含轉換。共有兩種隱含轉換：

- 直接：容許將抽象形式直接轉換為另一種型式或是從另一種型式轉換回來。此種透過向抽象型式添加 `as` 或 `is` 規則來定義，並且只容許與抽象的底層型式相統一的型式。
- 類別欄位：容許透過呼叫特殊的轉換函式來轉換，這些函式以 `@:to` 和 `@:from` 元資料定義。所有的型式都容許此種型式轉換。

下面的程式碼展示了**直接**轉換的例子：

<!-- [code asset](assets/ImplicitCastDirect.hx) -->
```haxe
abstract MyAbstract(Int) from Int to Int {
  inline function new(i:Int) {
    this = i;
  }
}

class Main {
  static public function main() {
    var a:MyAbstract = 12;
    var b:Int = a;
  }
}
```

我們宣告了 `MyAbstract` 是 `from int` 和 `to Int` 的，也就意味著其可以從 `Int` 賦值也可以賦值給 `Int`。第 9 到 10  行展示了這一點，在此處我們首先將 `Int` 的 `12` 賦值給了 `MyAbstract` 的變數 `a` ，由於 `from Int` 宣告，這可以正常工作；之後那個抽象又返回給了 `Int` 型式的變數 `b` ，由於 `to Int` 宣告，這也可以正常工作。

類別欄位轉換具有相同的語義，但定義完全不同：

<!-- [code asset](assets/ImplicitCastField.hx) -->
```haxe
abstract MyAbstract(Int) {
  inline function new(i:Int) {
    this = i;
  }

  @:from
  static public function fromString(s:String) {
    return new MyAbstract(Std.parseInt(s));
  }

  @:to
  public function toArray() {
    return [this];
  }
}

class Main {
  static public function main() {
    var a:MyAbstract = "3";
    var b:Array<Int> = a;
    trace(b); // [3]
  }
}
```

靜態函式可以透過添加 `@:from` 成為從其引數型式轉換至抽象型式的隱含轉換函式，這些函式必須返回抽象型式的值，並且必須宣告為 `static`。

類似，添加 `@:to` 至函式可以讓其成為從抽象型式轉換至引數型式的隱含轉換函式。

在前面的例子中，方法 `fromString` 容許將值 `"3"` 賦值至型式為 `MyAbstract` 的變數 `a`，而方法 `toArray` 容許將該抽象賦值至 `Array<Int>` 型式變數 `b` 的內部。

在使用這種型式轉換時，對轉換函式的呼叫會在需要的地方插入。查看 JavaScript 的輸出時這會很顯著：

```js
var a = _ImplicitCastField.MyAbstract_Impl_.fromString("3");
var b = _ImplicitCastField.MyAbstract_Impl_.toArray(a);
```

也可以透過[內聯](class-field-inline)將兩個轉換函式進一步最佳化以將輸出轉換為以下內容：

```haxe
var a = Std.parseInt("3");
var b = [a];
```

將型式 `A` 賦值給型式 `B` 時的 **選擇算法** 很簡單：

1. 如果 `A` 不是抽象，轉向 3。
2. 如果 `A` 定義了一個接受 `B` 的 **to** 轉換，轉向 6。
3. 如果 `B` 不是抽象，轉向 5。
4. 如果 `B` 定義了一個接受 `A` 的 **from** 轉換，轉向 6。
5. 停止，統一失敗。
6. 停止，統一成功。

![圖：選擇算法流程圖。](assets/figures/types-abstract-implicit-casts-selection-algorithm.svg)

_圖：選擇算法流程圖。_

在設計上，隱含轉換是**不可遞移**的，如以下所示：

<!-- [code asset](assets/ImplicitTransitiveCast.hx) -->
```haxe
abstract A(Int) {
  public function new()
    this = 0;

  @:to public function toB() return new B();
}

abstract B(Int) {
  public function new()
    this = 0;

  @:to public function toC() return new C();
}

abstract C(Int) {
  public function new()
    this = 0;
}

class Main {
  static public function main() {
    var a = new A();
    var b:B = a; // 有效，使用 A.toB
    var c:C = b; // 有效，使用 B.toC
    var c:C = a; // 錯誤，A 應當是 C
  }
}
```

雖然容許從 `A` 至 `B` 以及從 `B` 至 `C` 這樣的單個轉換，但從 `A` 至 `C` 的遞移轉換無法實施，這種作法是為了避免模稜兩可的轉換路徑以及保留簡單的選擇算法。

<!--label:types-abstract-operator-overloading-->
### 運算子多載

抽象容許將 `@:op` 元資料添加至類別欄位以多載一元和二元運算子：

<!-- [code asset](assets/AbstractOperatorOverload.hx) -->
```haxe
abstract MyAbstract(String) {
  public inline function new(s:String) {
    this = s;
  }

  @:op(A * B)
  public function repeat(rhs:Int):MyAbstract {
    var s:StringBuf = new StringBuf();
    for (i in 0...rhs)
    return new MyAbstract(s.toString());
      s.add(this);
  }
}

class Main {
  static public function main() {
    var a = new MyAbstract("foo");
    trace(a * 3); // foofoofoo
  }
}
```

透過定義 `@:op(A * B)`，當左值的型式為 `MyAbstract`，右值的型式為 `Int` 時，運算子乘法 `*` 的方法會是 `repeat`。用法如第 17 列所示，在編譯為 Java 時會轉換為如下程式碼：

```js
console.log(_AbstractOperatorOverload.
  MyAbstract_Impl_.repeat(a,3));
```

與[有類別欄位的隱含轉換](types-abstract-implicit-casts)類似，對轉換函式的呼叫會在需要的地方插入。

例子中的 `repeat` 函式並非是可交換的，也就是說雖然 `MyAbstract * Int` 可以運作，但 `Int * MyAbstract` 不能。不過可以將 `@:commutative` 元資料附加致函式以強制使其可以以任意順序接受型式。

如果函式應當**僅**在 `Int * MyAbstract` 工作，而不應當在 `MyAbstract * Int`，那麼可以將多載方法設為靜態，並分別將 `Int` 和 `MyAbstract` 設為接受的第一和第二個型式。

對一元運算子的多載類似：

<!-- [code asset](assets/AbstractUnopOverload.hx) -->
```haxe
abstract MyAbstract(String) {
  public inline function new(s:String) {
    this = s;
  }

  @:op(++A) public function pre() return "pre" + this;

  @:op(A++) public function post() return this + "post";
}

class Main {
  static public function main() {
    var a = new MyAbstract("foo");
    trace(++a); // prefoo
    trace(a++); // foopost
  }
}
```

二元與一元運算子多載都可以回傳任何類型。

#### 自 Haxe 4.0.0

`@:op` 語法可以用於在抽象上多載欄位和陣列存取：

- `@:op([])` 在帶有一個引數的函式上會多載陣列讀存取。
- `@:op([])` 在帶有兩個引數的函式上會多載陣列寫存取，第一個引數為索引，第二個引數為寫入值。
- `@:op(a.b)` 在帶有一個引數的函式上會多載欄位讀存取。
- `@:op(a.b = c)` 在帶有兩個引數的函式上會多載欄位寫存取。

<!-- [code asset](assets/AbstractAccessOverload.hx) -->
```haxe
abstract MyAbstract(String) from String {
  @:op([]) public function arrayRead(n:Int)
    return this.charAt(n);

  @:op([]) public function arrayWrite(n:Int, char:String)
    return this.substr(0, n) + char + this.substr(n + 1);

  @:op(a.b) public function fieldRead(name:String)
    return this.indexOf(name);

  @:op(a.b) public function fieldWrite(name:String, value:String)
    return this.split(name).join(value);
}

class Main {
  static public function main() {
    var s:MyAbstract = "example string";
    trace(s[1]); // "x"
    trace(s[2] = "*"); // "ex*mple string"
    trace(s.string); // 8
    trace(s.string = "code"); // "example code"
  }
}
```

#### 公開底層型式運算

`@:op` 函式的方法本體可以省略，但前提是抽象的底層型式容許相關運算，並且結果的型式可以賦值回抽象。

<!-- [code asset](assets/AbstractExposeTypeOperations.hx) -->
```haxe
abstract MyAbstractInt(Int) from Int to Int {
  // 下面一列從底層 Int 中公開了 (A > B) 運算
  // 注意，沒有函式本體：
  @:op(A > B) static function gt(a:MyAbstractInt, b:MyAbstractInt):Bool;
}

class Main {
  static function main() {
    var a:MyAbstractInt = 42;
    if (a > 0)
      trace('Works fine, > operation implemented!');

    // < 運算子未實作。
    // 這將導致「無法比較 MyAbstract 與 Int」（Cannot compare MyAbstractInt and Int）的錯誤。
    if (a < 100) {}
  }
}
```

<!--label:types-abstract-array-access-->
### 陣列存取

陣列存取是一種傳統上用於存取陣列鍾某個偏移量的值的特定語法，其通常只容許使用型式為 `Int` 的引數，不過利用抽象可以定義客製的陣列存取方法。[Haxe 標準函式庫](std)在 `Map` 型式中就用到了這點，在其中可以找到以下兩種方法：

```haxe
@:arrayAccess
public inline function get(key:K) {
  return this.get(key);
}
@:arrayAccess
public inline function arrayWrite(k:K, v:V):V {
  this.set(k, v);
  return v;
}
```

有兩種陣列存取方法：

- 如果 `@:arrayAccess` 方法接受兩個引數，那麼是取得器。
- 如果 `@:arrayAccess` 方法接受三個引數，那麼是設定器。

上面的 `get` 和 `arrayWrite` 方法可以這樣使用：

<!-- [code asset](assets/AbstractArrayAccess.hx) -->
```haxe
class Main {
  public static function main() {
    var map = new Map();
    map["foo"] = 1;
    trace(map["foo"]);
  }
}
```

如此以來，在看到對陣列存取欄位的呼叫插入至輸出時也就不足為奇了：

```js
map.set("foo", 1);
console.log(map.get("foo")); // 1
```

#### 陣列存取解析順序

由於在 Haxe 版本 3.2 之前的一個錯誤，檢查 `@:arrayAccess` 欄位的順序沒有定義。這個問題已在 Haxe 3.2 中解決，欄位現在會從上至下順序檢查：

<!-- [code asset](assets/AbstractArrayAccessOrder.hx) -->
```haxe
abstract AString(String) {
  public function new(s)
    this = s;

  @:arrayAccess function getInt1(k:Int) {
    return this.charAt(k);
  }

  @:arrayAccess function getInt2(k:Int) {
    return this.charAt(k).toUpperCase();
  }
}

class Main {
  static function main() {
    var a = new AString("foo");
    trace(a[0]); // f
  }
}
```

陣列存取 `a[0]` 會解析為 `getint1` 欄位，並且回傳 `f`，而在 3.2 之前的版本中結果可能有所不同。

較早定義的欄位即便需要[隱含轉換](types-abstract-implicit-casts)也具有優先權。

<!--label:types-abstract-enum-->
### 抽象枚舉

##### 自 Haxe 3.1.0

透過向抽象定義添加 `@:enum` 元資料，抽象可以用作定義有限值的集合：

<!-- [code asset](assets/AbstractEnum.hx) -->
```haxe
@:enum
abstract HttpStatus(Int) {
  var NotFound = 404;
  var MethodNotAllowed = 405;
}

class Main {
  static public function main() {
    var status = HttpStatus.NotFound;
    var msg = printStatus(status);
  }

  static function printStatus(status:HttpStatus) {
    return switch (status) {
      case NotFound:
        "Not found";
      case MethodNotAllowed:
        "Method not allowed";
    }
  }
}
```

The Haxe Compiler replaces all field access to the `HttpStatus` abstract with their values, as evident in the JavaScript output:

```js
Main.main = function() {
  var status = 404;
  var msg = Main.printStatus(status);
};
Main.printStatus = function(status) {
  switch(status) {
  case 404:
    return "Not found";
  case 405:
    return "Method not allowed";
  }
};
```

This is similar to accessing [variables declared as inline](class-field-inline), but has several advantages:

* The typer can ensure that all values of the set are typed correctly.
* The pattern matcher checks for [exhaustiveness](lf-pattern-matching-exhaustiveness) when [matching](lf-pattern-matching) an enum abstract.
* Defining fields requires less syntax.

##### since Haxe 4.0.0

Enum abstracts can be declared without using the `@:enum` metadata, instead using the more natural syntax `enum abstract`. Additionally, if the underlying type is `String` or `Int`, the values for the enum cases can be omitted and are deduced by the compiler:

* For `Int` abstracts, the deduced values increment the last user-defined value or start at zero if no value was declared yet.
* For `String` abstracts, the deduced value is the identifier of the enum case.

<!-- [code asset](assets/AbstractEnum2.hx) -->
```haxe
enum abstract Numeric(Int) {
  var Zero; // implicit value: 0
  var Ten = 10;
  var Eleven; // implicit value: 11
}

enum abstract Textual(String) {
  var FirstCase; // implicit value: "FirstCase"
  var AnotherCase; // implicit value: "AnotherCase"
}
```

<!--label:types-abstract-forward-->
#### Forwarding abstract fields

##### since Haxe 3.1.0

When wrapping an underlying type, it is sometimes desirable to "keep" parts of its functionality. Because writing forwarding functions by hand is cumbersome, Haxe allows adding the `@:forward` metadata to an abstract type:

<!-- [code asset](assets/AbstractExpose.hx) -->
```haxe
@:forward(push, pop)
abstract MyArray<S>(Array<S>) {
  public inline function new() {
    this = [];
  }
}

class Main {
  static public function main() {
    var myArray = new MyArray();
    myArray.push(12);
    myArray.pop();
    // MyArray<Int> has no field length
    // myArray.length;
  }
}
```

The `MyArray` abstract in this example wraps `Array`. Its `@:forward` metadata has two arguments which correspond to the field names to be forwarded to the underlying type. In this example, the `main` method instantiates `MyArray` and accesses its `push` and `pop` methods. The commented line demonstrates that the `length` field is not available.

As usual, we can look at the JavaScript output to see how the code is being generated:

```js
Main.main = function() {
  var myArray = [];
  myArray.push(12);
  myArray.pop();
};
```

`@:forward` can be utilized without any arguments in order to forward all fields. Of course, the Haxe Compiler still ensures that the field actually exists on the underlying type.

> ##### Trivia: Implemented as macro
>
> Both the `@:enum` and `@:forward` functionality were originally implemented using [build macros](macro-type-building). While this worked nicely in non-macro code, it caused issues if these features were used from within macros. The implementation was subsequently moved to the compiler.

<!--label:types-abstract-core-type-->
#### Core-type abstracts

The [Haxe Standard Library](std) defines a set of basic types as core-type abstracts. They are identified by the `@:coreType` metadata and the lack of an underlying type declaration. These abstracts can still be understood to represent a different type. Still, that type is native to the Haxe target.

Introducing custom core-type abstracts is rarely necessary in user code as it requires the Haxe target to be able to make sense of it. However, there could be interesting use-cases for authors of macros and new Haxe targets.

In contrast to opaque abstracts, core-type abstracts have the following properties:

* They have no underlying type.
* They are considered nullable unless they are annotated with `@:notNull` metadata.
* They are allowed to declare [array access](types-abstract-array-access) functions without expressions.
* [Operator overloading fields](types-abstract-operator-overloading) that have no expression are not forced to adhere to the Haxe type semantics.

<!--label:types-monomorph-->
### Monomorph

A monomorph is a type which may, through [unification](type-system-unification), morph into a different type later. Further details about this type are explained in the section on [type inference](type-system-type-inference).
