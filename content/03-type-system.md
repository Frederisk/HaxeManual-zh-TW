<!--label:type-system-->
# 型式系統

我們已經在[型式](types)中學到了不同類型的型式，現在是時候了解他們是如何互相作用的了。我們首先從介紹 [typedef](type-system-typedef)開始，這是一種能夠為更複雜的型式提供名稱或者別名的方式。在一些其他使用案例中， typedef 會在處理具有[型式參數](type-system-type-parameters)的型式時派上用場。

透過檢查給定的型式是否相容可以達成大量的型式安全。也就是編譯器會嘗試在這些型式之間執行**統一**，正如[統一](type-system-unification)中所詳述的。

所有型式都組織在**模塊**之中，並可以透過**路徑**定址。[模塊和路徑](type-system-modules-and-paths)將會給出相關機制的詳細說明。

<!--label:type-system-typedef-->
## Typedef

我們在討論[匿名結構](types-anonymous-structure)時已經簡要的研究了 typedef 並了解到了如何用它來為複雜的[結構型式](types-anonymous-structure)提供名稱來縮短其寫法，這也正是 typedef 有用的原因。甚至可以認為為結構型式命名就是其主要功能，並且這種用法也十分普遍以至於兩者之間的區別似乎有些模糊。許多 Haxe 使用者會認為 typedef 就**是**結構。

typedef 可以為任意其他型式提供名稱：

```haxe
typedef IA = Array<Int>;
```

這能夠讓我們通常在使用 `Array<Int>`的地方可以使用 `IA`，雖然在這種特立下只能省去幾下按鍵，但對於更複雜復合的型式來說則會產生更大差異。同樣，這就是為什麼 typedef 與結構看起來是如此密切相關：

```haxe
typedef User = {
  var age : Int;
  var name : String;
}
```

typedef 並不是文本替換，而是實際的型式。它們甚至可以有[型式參數](type-system-type-parameters)，如同 Haxe 標準函式庫中的 `Iterable` 型式所示：

```haxe
typedef Iterable<T> = {
  function iterator() : Iterator<T>;
}
```

<!--label:type-system-type-parameters-->
## 型式參數

Haxe 容許參數化多種型式、[類別欄位](class-field)和[枚舉建構式](types-enum-constructor)，型式參數是透過括在尖括號 `<>` 中以逗號分隔的型式參數名稱來定義的。Haxe 標準庫的一個簡單示例是 `Array`：

```haxe
class Array<T> {
  function push(x : T) : Int;
}
```

每當建立 `Array` 的實例時，其型式參數 `T` 就會成為[單型](types-monomorph)。也就是說該實例可以繫結至任何型式上，但一次只能繫結一個。這種繫結可以是：

- 明確的，以引動具有明確型式的建構式（`new Array<String>()`），或是
- 隱含的，以對實例的[型式推理](type-system-type-inference)在引動 `arrayInstance.push("foo")` 時。

在帶有型式參數類別的定義中，型式參數是非特定型式。除非添加[約束](type-system-type-parameter-constraints)，否則編譯器必須假設型式參數可以是任何型式。所以說，對型式參數的欄位的存取和對成為型式參數型式的[轉換](expression-cast)是不可行的，同樣，也無法建立型式參數型式的新實例，除非型式參數是[泛型](type-system-generic)的並受對應約束。

下表列出了容許型式參數的位置：

參數在 | 繫結在 | 備註
 --- | --- | ---
類別 | 實例化 | 也能繫結至成員欄位存取。
成員欄位 | 實例化 |
枚舉 | 實例化 |
枚舉建構式 | 實例化 |
函式 | 引動 | 容許給方法和命名的局部值函數。
結構 | 實例化 |

由於函式型式參數在引動時繫結，如果沒有約束則其可以接受任何型式。但每次引動只會接受一種型式，在函式有多個引數也適用：

<!-- [code asset](assets/FunctionTypeParameter.hx) -->
```haxe
class Main {
  static public function main() {
    equals(1, 1);
    // 執行期訊息： bar should be foo
    equals("foo", "bar");
    // 編譯器錯誤：String 應當是 Int（String should be Int）
    equals(1, "foo");
  }

  static function equals<T>(expected:T, actual:T) {
    if (actual != expected) {
      trace('$actual should be $expected');
    }
  }
}
```

`equals` 函式的兩個引數 `expected` 和 `actual` 的形式是 `T`，這意味著對 `eunqals` 的每次引動這兩個引數都必須具有相同的型式。編譯器會容許第一次（兩個引數都是 `Int`）和第二次（個引數都是 `String`）呼叫，但第三次嘗試則會由於型式不匹配而造成編譯器錯誤。

> #### 瑣事： 表達式語法中的型式參數
>
> 我們經常會遇到一個問題，為什麼不能以 `method<String>(x)` 的方式呼叫帶有型式參數的函式？編譯器所給出的錯誤訊息不是很有幫助。不過也一個簡單的原因是上面的程式碼會解析作 `<` 和 `>` 都是二元運算子，產生為 `(method < String) > (x)`。

<!--label:type-system-type-parameter-constraints-->
### 約束

型式參數可以約束為多個型式：

<!-- [code asset](assets/Constraints.hx) -->
```haxe
typedef Measurable = {
  public var length(default, null):Int;
}

class Main {
  static public function main() {
    trace(test([]));
    trace(test(["bar", "foo"]));
    // String 應當是 Iterable<String>
    // test("foo");
  }

  #if (haxe_ver >= 4)
  static function test<T:Iterable<String> & Measurable>(a:T) {
  #else
  static function test<T:(Iterable<String>, Measurable)>(a:T) {
  #end
    if (a.length == 0)
      return "empty";
    return a.iterator().next();
  }
}
```

`test` 方法包含有約束為 `Iterable<String>` 和 `Measurable` 的型式參數 `T`。其中後者為了方便是用 [typedef](type-system-typedef) 定義的，並且需要相容型式要有型式為 `Int` 名稱為 `length` 的唯讀[屬性](class-field-property)。然後這些約束表明型式若要相容則需要：

- 它要與 `Iterable<String>` 相容，並且
- 有型式為 `Int` 的唯讀屬性 `length`。

在上面的例子中我們可以看到，在第 7 列使用空陣列和第 8 列使用 `Array<String>` 引動 `test` 都工作得很好。之所以這樣是由於 `Array` 具有 `length` 屬性和 `iterator` 方法。但是在第 9 行傳遞 `String` 引數則會在約束檢查上失敗，這是由於 `String` 與 `Iterable<T>` 並不相容。

當約束為單一型式時括號可以省略：

<!-- [code asset](assets/Constraints2.hx) -->
```haxe
class Main {
  static public function main() {
    trace(test([]));
    trace(test(["bar", "foo"]));
  }

  static function test<T:Iterable<String>>(a:T) {
    return a.iterator().next();
  }
}
```

#### 自 Haxe 4.0.0

在版本 3 和版本 4 之間的一個重大變更是多個型式的約束語法。就如上面第一個例子中所示，在 Haxe 4 中的約束之間的分隔由 `&` 取得了逗號。這有點像新的[結構延伸](types-structure-extensions)語法。

<!--label:type-system-generic-->
## 泛型

通常來說，Haxe 編譯器即便擁有型式參數也只會產生一個類別或函式。這會導致目標語言的產生器必須假設其型式參數可以是任何型式的自然抽象。產生的程式碼之後可能不得不去執行型式檢查，而這會損害效能。

類別或函式可以透過使用 `@:generic` [元資料](lf-metadata)來成為泛型。這會導致編譯器為每種型式參數組合產生不同的帶有自己名稱的類別或函式。這樣的形式可以以更大的輸出大小為代價來使[靜態目標](define-static-target)上效能關鍵的部分得到提升：

<!-- [code asset](assets/GenericClass.hx) -->
```haxe
@:generic
class MyValue<T> {
  public var value:T;

  public function new(value:T) {
    this.value = value;
  }
}

class Main {
  static public function main() {
    var a = new MyValue<String>("Hello");
    var b = new MyValue<Int>(42);
  }
}
```

在此處見到明確型式 `MyValue<String>` 似乎不那麼尋常，通常來說型式推理會處理這種類似的情況。不過在此種情形下這樣寫明是必要的，編譯器在建構時必須要得知泛型類別的具體型式。

```js
(function () { "use strict";
var Test = function() { };
Test.main = function() {
  var a = new MyValue_String("Hello");
  var b = new MyValue_Int(5);
};
var MyValue_Int = function(value) {
  this.value = value;
};
var MyValue_String = function(value) {
  this.value = value;
};
Test.main();
})();
```

我們可以確定 `MyValue<String>` 和 `MyValue<Int>` 分別變為了 `MyValue_String` 和 `MyValue_Int`。泛型函式的情況也類似：

<!-- [code asset](assets/GenericFunction.hx) -->
```haxe
class Main {
  static public function main() {
    method("foo");
    method(1);
  }

  @:generic static function method<T>(t:T) {}
}
```

同樣，JavaScript 輸出會使這很明顯：

```js
(function () { "use strict";
var Main = function() { }
Main.method_Int = function(t) {
}
Main.method_String = function(t) {
}
Main.main = function() {
  Main.method_String("foo");
  Main.method_Int(1);
}
Main.main();
})();
```

<!--label:type-system-generic-type-parameter-construction-->
### 泛型型式參數的建構

> #### 定義：泛型型式參數
>
> 若型式參數所包含的類別或方法是泛型的，則稱其是泛型的。

建構通常的型式參數是不可行的，比如 `new T()`將會導致編譯器錯誤。會這樣原因是 Haxe 對此只會產生一個單獨的函式，所以在這種情況下該建構式沒有任何意義。而在型式參數是泛刑時，情況會有所不同。因為我們知道編譯器會為每一種型式參數組合產生不同的函式，所以在這裡可以用真實型式來替換 `new T()` 的 `T`。

<!-- [code asset](assets/GenericTypeParameter.hx) -->
```haxe
import haxe.Constraints;

class Main {
  static public function main() {
    var s:String = make();
    var t:haxe.Template = make();
  }

  @:generic
  static function make<T:Constructible<String->Void>>():T {
    return new T("foo");
  }
}
```

需要注意的是，此處使用了自頂向下的推斷來確定 `T` 的實際型式。若要使這種型式參數起作用，構造的型式參數必須滿足下列兩個條件：

1. 必須是泛型。
1. 必須明確[約束](type-system-type-parameter-constraints)其具有[建構式](types-class-constructor)。

在此處，第一個要求式透過具有 `@:generic` 元資料的 `make` 來滿足的，而第二個要求式是透過 `Constructible` 來滿足的。該約束適用於 `String` 和 `haxe.Template`，因為它們都具有能接收一個 `String` 引數的建構式。想當然，相關的 JavaScript 輸出看上去和預期相同：

```js
var Main = function() { }
Main.__name__ = true;
Main.make_haxe_Template = function() {
  return new haxe.Template("foo");
}
Main.make_String = function() {
  return new String("foo");
}
Main.main = function() {
  var s = Main.make_String();
  var t = Main.make_haxe_Template();
}
```

<!--label:type-system-variance-->
## 變異數

變異數在型式參數中經常出現，雖然在其他地方也常常關聯，不過在這種情況下可能會有意想不到的表現。很容易就能觸發變異數錯誤：

<!-- [code asset](assets/Variance.hx) -->
```haxe
class Base {
  public function new() {}
}

class Child extends Base {}

class Main {
  public static function main() {
    var children = [new Child()];
    // Array<Child> 應當是 Array<Base>
    // 型式參數是不變的
    // Child 應當是 Base
    var bases:Array<Base> = children;
  }
}
```

即便 `Child` 可以賦值給 `Base`，但顯然 `Array<Child>` 不能賦值給 `Array<Base>`。會這樣的原因可能有些出人意料：由於陣列可以寫入所以不容許賦值，比如說有 `push()` 方法。忽略變異數很容易會導致問題：

<!-- [code asset](assets/Variance2.hx) -->
```haxe
class Base {
  public function new() {}
}

class Child extends Base {}
class OtherChild extends Base {}

class Main {
  public static function main() {
    var children = [new Child()];
    // 顛覆型式檢查器
    var bases:Array<Base> = cast children;
    bases.push(new OtherChild());
    for (child in children) {
      trace(child);
    }
  }
}
```

在此處，我們使用[轉換](expression-cast)來顛覆型式檢查器，從而使得能夠容許註釋行之後的賦值。如此一來，我們有了型式為 `Array<Base>` 的原始陣列引用 `bases`。這將容許我們將另一種與 `Base` 相容的型式推入至陣列中（在此實例中為 `OtherChild`）。然而在我們最初的引用中 `children` 依然是 `Array<Child>` 型式，所以當我們在迭代時遇到其元素中的一個 `OtherChild` 時，事情就會變得非常糟糕。

若 `Array` 沒有 `push()` 方法以及其他的修改方法，則該賦值將會因為不能向其中添加不相容的型式而是安全的。

<!-- [code asset](assets/Variance3.hx) -->
```haxe
class Base {
  public function new() {}
}

class Child extends Base {}

typedef MyArray<T> = {
  public function pop():T;
}

class Main {
  public static function main() {
    var a = [new Child()];
    var b:MyArray<Base> = a;
  }
}
```

我們可以安全地賦值給型式為 `MyArray<Base>` 且 `MyArray` 只有 `pop()` 方法的 `b`。在 `MyArray` 中並沒有定義可以添加不相容型式的方法。這種稱之為**共變**。

> #### 定義：共變數
>
> 如果[複合型式](define-compound-type)的組件型式可賦值至更不具體的組件，也就是說它們是唯讀但從不寫入，則認其為共變。

> #### 定義：反變數
>
> 如果[複合型式](define-compound-type)的組件型式可賦值至更不通用的組件，也就是說它們是唯寫但從不讀取，則認其為反變。

<!--label:type-system-unification-->
## 統一

統一是型式系統的核心，其極大地促進了 Haxe 程式的強健。統一描述了檢查一種型式是否與另一種型式相容的過程。

> #### 定義：統一
>
> 兩種型式 A 與 B 之間的統一是定向的過程，其回答了 A 是否**可以賦值給** B 的問題。若其是或有[單型](types-monomorph)則可**變異**為任一型式。

統一錯誤很容易就能觸發：

```haxe
class Main {
  static public function main() {
    // Int 應當是 String
    var s:String = 1;
  }
}
```

我們嘗試將 `Int` 型式的值賦值給 `String` 變數，這會導致變異氣嘗試去**以 String 統一 Int**。當然，這是不允許的，並會使編譯器發出「Int 應當是 String」（`Int should be String`）的錯誤。

在這種特殊情形下，統一是由**賦值**所觸發的，由「可賦值」所定義的上下文很直觀。這是會執行統一的幾種情形之一：

- 賦值：如果將 `a` 賦值給 `b`，則 `a` 的型式以 `b` 的型式相統一。
- 函式呼叫：我們在介紹[函式](types-function)的型式時已經簡要看過這樣的例子。通常，編譯器會嘗試將第一個給定引數的型式以第一個預期引數的型式統一，將第二個給定引數的型式以第二個預期引數的型式統一，以此類推，直到處理完所有引數的型式。
- 函式回傳：只要函式有 `return e` 的表達式，`e` 的型式就會以函式的返回型式相統一。如果函式沒有明確的返回型式，則推斷其為 `e` 的型式，並隨後的 `return` 表達式會針對它進行推斷。 TODO:  If the function(函式|) has no explicit return(回傳|) type(型式|), it is inferred to the type(型式|) of `e` and subsequent `return(回傳|)` expression(表達式|)s are inferred against it.
- 陣列宣告：編譯器會嘗試在陣列宣告中的所有給定型式之間找到最小型式。參閱[共同基底型式](type-system-unification-common-base-type)以獲取詳情。
- 物件宣告：如過宣告的物件與給定型式相「牴觸」，則編譯器會使每個給定欄位的型式以每個預期欄位的型式相統一。
- 運算子統一：某些運算子會期望特定型式以給定型式相統一。如，表達式 `a && b` 會將 `a` 和 `b` 以 `Bool` 統一、表達式 `a == b`會讓 `a` 以 `b` 相統一。

<!--label:type-system-unification-between-classes-and-interfaces-->
### 類別、介面之間

在定義類別之間的統一行為時，很重要的一點是要記得統一是定向的。我們可以將更為具體的類別賦值給更寬犯的類別，但反之不是有效的。

下列的賦值是容許的：

- 子類別到父類別。
- 類別到實作的介面。
- 介面到基底介面。

這些規則是遞移的，這意味著子類別也可以賦值給其基底類別的基底類別、其基底類別的實作的介面、實作的介面的基底介面等。

<!--label:type-system-structural-subtyping-->
### 結構子型態

> #### 定義：結構子型態
>
>結構子型態定義了具有相同結構的型式間的隱含關係。

在統一下列時結構子型態是可容許的：

- 具有[結構](types-anonymous-structure)的[類別](types-class-instance)以及
- 具有另一個結構的結構。

下列例子是 [Haxe 標準函式庫](std)中 `Lambda` 類別的部分：

```haxe
public static function empty<T>(it : Iterable<T>):Bool {
  return !it.iterator().hasNext();
}
```

`empty` 方法檢查 `Iterable` 是否具有元素。為此，除了將其視為可迭代這一事實之外，無需了解有關引數型式的任何資訊。這容許在使用與 `Iterable<T>` 相統一的任何型式都可呼叫 `empty` 方法，這適用於 Haxe 標準函式庫中的許多型式。

這種型態可能非常便於使用，然而過量使用則可能損害靜態目標的效能，這在[對效能的影響]中有詳細說明。

<!--label:type-system-monomorphs-->
### 單型

在[型式推理]中詳細說明了具有或者成為[單型]的型式的統一。

unification(統一|TODO) of type(型式|)s having or being a [monomorph(變型|)(單型|)](type(型式|)s-monomorph(變型|)(單型|)) is detailed in [type(型式|) inference(推斷|又：推定、推理)](type(型式|)-system-type(型式|)-inference(推斷|又：推定、推理)).

[類型推斷](type-system-type-inference)中詳細說明了具有或成為[單態](types-monomorph)的類型的統一。

<!--label:type-system-unification-function-return-->
### 函式回傳

函式回傳型式的回傳可能涉及 [`Void`]()型式，並且需要明確定義與 `Void` 統一的內容。`Void` 用作描述型式的缺失，其不可賦值給任何其他型式，甚至 `Dynamic` 也不行。這也意味著函式若明確宣告為回傳 `Dynamic`，則其不可返回 `Void`。

反之亦然：函式若明確宣告為回傳 `Void`，則其不可返回 `Dynamic` 或是其他型式。但是在為函式型式時則容許這種統一方向：

```haxe
var func:Void->Void = function() return "foo";
```

右側的函式的型式顯然是 `Void->String`，然而我們可將其賦值給 `Void->Void` 型式的變數 `func`。這是由於編譯器可以安全地假定返回型別是無關緊要的，因為其不可賦值給任何非 `Void` 的型式。

<!--label:type-system-unification-common-base-type-->
### 共同基底型式

給定一系列多種型式，**共同基底型式**就是該系列型式中所有型式統一所針對的型式：

<!-- [code asset](assets/UnifyMin.hx) -->
```haxe
class Base {
  public function new() {}
}

class Child1 extends Base {}
class Child2 extends Base {}

class Main {
  static public function main() {
    var a = [new Child1(), new Child2()];
    $type(a); // Array<Base>
  }
}
```

即便沒有提到 `Base`，但 Haxe 仍會設法將其推定為 `Child1` 與 `Child2` 的共同型式。Haxe 編譯器會在以下情況中採取這種統一：

- 陣列宣告。
- `if` 與 `else`。
- `switch` 的各情況。

<!--label:type-system-type-inference-->
## 型式推理

型式推理的影響已在本文檔中看到過，並將持續十分重要。展示型式推理工作的一個簡單例子：

類型推斷的影響已在本文檔中看到，並將繼續很重要。 一個簡單的示例顯示了工作中的類型推斷：

<!-- [code asset](assets/TypeInference.hx) -->
```haxe
class Main {
  public static function main() {
    var x = null;
    $type(x); // Unknown<0>
    x = "foo";
    $type(x); // String
  }
}
```

在前面提到的特殊構造 `$type` 是為簡化對[函式型式](types-function)的型式解釋，所以，現在來正式介紹一下：

> #### `$type`
>
> `$type` 是一種編譯期機制，其呼叫方式類似具有單個引數的函式。編譯器會評估引數表達式，然後輸出該表達式的型式。

在上面的例子中，第一個 `$type` 列印出 `Unknown<0>`，這是[單形](types-monomorph)，也就是還不知曉的型式。下一行的 `x = "foo` 將字串文字賦值給 `x`，這使單型與 `String` 相[統一](type-system-unification)。然後我們可以看到 `x` 的型式已變成 `String`。

每當[動態](types-dynamic)以外的型式與單型統一時，該單型就會**變型**為該型式，或者更簡單地說，**變成**該型式。因此，它以後不能在變型為不同的型式，這個屬性也就是其名稱中「**單**」所表明的。

遵循統一規則，型式推理可以發生在複合型式中：

<!-- [code asset](assets/TypeInference2.hx) -->
```haxe
class Main {
  public static function main() {
    var x = [];
    $type(x); // Array<Unknown<0>>
    x.push("foo");
    $type(x); // Array<String>
  }
}
```

變數 `x` 首先初始化為空陣列。在此時，我們可稱 `x` 的型式是陣列，但是我們還不知道陣列元素的型式是什麼。最後，`x` 的型式是 `Array<Unknown<0>>`。在推入一個 `String` 至陣列後我們才得知型式是 `Array<String>`。

<!--label:type-system-top-down-inference-->
### 自上而下推斷


大多數時候，類型是自己推斷出來的，然後可以與預期的類型統一。 然而，在少數地方，可能會使用預期類型來影響推理。 然後我們談到**自上而下的推理**。

> #### 定義：預期型式
>
> 當表達式的型式在輸入表達式之前就已經已知時就會出現預期型式。比如在表達式是函式呼叫的引數時。預期型式可透過[自上而下推斷](type-system-top-down-inference)影響表達式的型式。

一個很好的例子是混合型式的陣列，如[動態]()中所述，編譯器會因無法確定元素型式而拒絕 `[1, "foo"]`。而採用自上而下推斷則可以克服這個問題：

<!-- [code asset](assets/TopDownInference.hx) -->
```haxe
class Main {
  static public function main() {
    var a:Array<Dynamic> = [1, "foo"];
  }
}
```

此處，編譯器知道鍵入的TODO: `[1, "foo"]` 預期的型式是 `Array<Dynamic>`，所以元素的型式就是 `Dynamic`。與編譯器嘗試（並失敗）確定[共同基底型式](type-system-unification-common-base-type)的通常行為不同，此處的各個元素是針對 `Dynamic` 型式化和統一的。

我們已經看到過自上而下推斷在引入[泛型型式結構](type-system-generic-type-parameter-construction)時的另一個有趣用途：

<!-- [code asset](assets/GenericTypeParameter.hx) -->
```haxe
import haxe.Constraints;

class Main {
  static public function main() {
    var s:String = make();
    var t:haxe.Template = make();
  }

  @:generic
  static function make<T:Constructible<String->Void>>():T {
    return new T("foo");
  }
}
```

在此處以明確型式 `String` 和 `haxe.Template` 明確型式來確定了 `make` 的回傳型式。這種做法有效，因為該方法以 `make()` 引動，所以我們知道回傳型式將賦值給變數。利用這資訊，就可以將未知型式 `T` 分別繫結至 `String` 和 `haxe.Template` 了。

<!--label:type-system-inference-limitations-->
### 限制

型式推理減少了使用局部變數時對手動型式提示的需求，但有時型式系統仍會需要引導。除非有直接的初始化，否則型式推理不會嘗試去推斷[變數](class-field-variable)或[屬性](class-field-property)欄位的型式。

另外在一些涉及遞迴的情況中型式推理會友侷限。如果一個函式在其型式還不完全已知的情形下呼叫自身，則型式推理可能會推理出不正確而且過於特定的型式。

另一個需要考慮的問題是程式碼的可讀性。如果過度使用型式推理，由於缺少可見的型式，程式的某些部分可能會變得難易理解。對於方法的簽章尤其如此，因此建議在型式推理與明確型式找到一個較好的平衡點。

<!--label:type-system-modules-and-paths-->
## 模組和路徑

> #### 定義：模組
>
> 所有的 Haxe 程式碼都組織在模組中並使用路徑定址。本質上，每個 .hx 檔案代表一個可能包含多種型式的模組。型別可能是 `private` 的，在這種情況下則只有包含它的模組可以存取它。

模組與其同名的包含型式之間的區別是模糊的。事實上，對 `haxe.ds.StringMap<Int>` 的定址可視作是 `haxe.ds.StringMap.StringMap<Int>` 的簡寫。後者由四部分組成：

模塊與其同名的包含類型之間的區別在設計上是模糊的。事實上，尋址 haxe.ds.StringMap<Int> 可以被認為是 haxe.ds.StringMap.StringMap<Int> 的簡寫。後一個版本由四個部分組成：

1. 套件 `haxe.ds`。
1. 模組名 `StringMap`。
1. 型式名 `StringMap`。
1. 型式參數 `Int`。

如果模組與型式名稱相同，則可以刪去重複，從而得到 `haxe.ds.StringMap<Int>` 的短版本。不過，了解擴充版本有助於了解如何處理[模組子型式](type-system-module-sub-types)。

使用[匯入](type-system-import)通常會容許省略路徑中套件的部分可以進一步縮短路徑。這可能會導致使用非限定<!--TODO:-->的識別符，為此需要了解[解析順序](type-system-resolution-order)。

> #### 定義：型式路徑
>
> 型式的（點）路徑由套件、模組名稱與型式名稱組成。其一般形式為 `pack1.pack2.packN.ModuleName.TypeName`。

<!--label:type-system-module-sub-types-->
### 模組子型式

模組子型式是在模組中宣告的名稱與模組不同的型式。這可容許單個 .hx 檔案包含多種型式，並可在模組內以及在使用 `package.Module.Type` 的其他模組中無限制地存取這些型式：

```haxe
var e:haxe.macro.Expr.ExprDef;
```

此處存取了在 `haxe.macro.Expr` 模組中的 `ExprDef` 子型式。

樣例子型式宣告看起來會像這樣：

```haxe
// a/A.hx
package a;

class A { public function new() {} }
// 子型別
class B { public function new() {} }
```

```haxe
// Main.hx
import a.A;

class Main {
    static function main() {
        var subtype1 = new a.A.B();

        // 這些同樣有效，但需要先匯入 a.A 或 匯入 a.A.B：
        var subtype2 = new B();
        var subtype3 = new a.B();
    }
}
```

The sub-type(型式|)(子型式|) relation is not reflected at run-time(執行期|又：執行時); public sub-type(型式|)(子型式|)s become a member of their containing package, which could lead to conflicts if two modules within the same package tried to define(定義：|) the same sub-type(型式|)(子型式|). Naturally, the Haxe compiler(編譯器|) detects these cases and reports them accordingly. In the example above `ExprDef` is generated as `haxe.macro(巨集|).ExprDef`.

sub-type(型式|)(子型式|)s can also be made private:

```haxe
private class C { ... }
private enum E { ... }
private typedef T { ... }
private abstract A { ... }
```

> ##### define(定義：|): Private type(型式|)
>
> A type(型式|) can be made private by using the `private` modifier. Afterwards, the type(型式|) can only be directly accessed from within the [module](define(定義：|)-module) it is define(定義：|)d in.
>
> Private type(型式|)s, unlike public ones, do not become a member of their containing package.

The accessibility of type(型式|)s can be controlled more precisely by using [access control](lf-access-control).

<!--label:type(型式|)-system-import-->
#### Import

If a type(型式|) path(路徑|) is used multiple times in a .hx file, it might make sense to use an `import` to shorten it. The package can then be omitted when using the type(型式|):

<!-- [code asset](assets/Import.hx) -->
```haxe
import haxe.ds.Stringmap(映射|);

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    // instead of: new haxe.ds.Stringmap(映射|)();
    new Stringmap(映射|)();
  }
}
```

With `haxe.ds.Stringmap(映射|)` being imported in the first line, the compiler(編譯器|) is able to resolve(解析|) the unqualified identifier(識別符|) `Stringmap(映射|)` in the `main` function(函式|) to this package. The module `Stringmap(映射|)` is said to be **imported** into the current file.

In this example, we are actually importing a **module**, not just a specific type(型式|) within that module. This means that all type(型式|)s define(定義：|)d within the imported module are available:

<!-- [code asset](assets/Import2.hx) -->
```haxe
import haxe.macro(巨集|).Expr;

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    var e:Binop = OpAdd;
  }
}
```

The type(型式|) `Binop` is an [enum(枚舉|)](type(型式|)s-enum(枚舉|)-instance(實例|)) declare(宣告|)d in the module `haxe.macro(巨集|).Expr`, and thus available after the import of said module. If we were to import only a specific type(型式|) of that module, for example, `import haxe.macro(巨集|).Expr.ExprDef`, the program would fail to compile with `class(類別|) not found : Binop`.

There are several aspects worth knowing about importing:

* The bottommost import takes priority (detailed in [Resolution Order](type(型式|)-system-resolution-order)).
* The [static(靜態|) extension(延伸|)](lf-static(靜態|)-extension(延伸|)) keyword(關鍵字|) `using` implies the effect of `import`.
* If an enum(枚舉|) is imported (directly or as part of a module import), all of its [enum(枚舉|) construct(結構體|)(建構|)ors](type(型式|)s-enum(枚舉|)-construct(結構體|)(建構|)or) are also imported (this is what allow(容許|又：允許)s the `OpAdd` usage in the above example).

Furthermore, it is also possible to import [static(靜態|) field(欄位|)s](class(類別|)-field(欄位|)) of a class(類別|) and use them unqualified:

<!-- [code asset](assets/Import3.hx) -->
```haxe
import Math.random;

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    random();
  }
}
```

Special care has to be taken with field(欄位|) names or local variable(變數|)(局部變數|) names that conflict with a package name. Since field(欄位|)s and local variable(變數|)(局部變數|)s take priority over packages, a local variable(變數|)(局部變數|) named `haxe` blocks off usage of the entire `haxe` package.

##### Wildcard import

Haxe allow(容許|又：允許)s using a wildcard symbol `.*` to allow(容許|又：允許) import of all modules in a package, all type(型式|)s in a module, or all static(靜態|) field(欄位|)s in a type(型式|). It is important to understand that this kind of import only crosses a single level as we can see in the following example:

<!-- [code asset](assets/ImportWildcard.hx) -->
```haxe
import haxe.macro(巨集|).*;

class(類別|) Main {
  static(靜態|) function(函式|) main() {
    var expr:Expr = null(空|);
    // var expr:ExprDef = null(空|); // class(類別|) not found : ExprDef
  }
}
```

Using the wildcard import on `haxe.macro(巨集|)` allow(容許|又：允許)s accessing `Expr`, which is a module in this package, but it does not allow(容許|又：允許) accessing `ExprDef` which is a sub-type(型式|)(子型式|) of the `Expr` module. This rule extend(擴充|又：延伸)s to static(靜態|) field(欄位|)s when a module is imported.

When using wildcard imports on a package, the compiler(編譯器|) does not eagerly process all modules in that package; modules that have not been used explicitly(明確|) are not part of the generated output.

##### Import with alias

If an imported type(型式|) or static(靜態|) field(欄位|) is used frequently in a module, it might help to alias it to a shorter name. This can also be used to disambiguate conflicting names by giving them a unique identifier(識別符|).

<!-- [code asset](assets/ImportAlias.hx) -->
```haxe
import String.fromCharCode in f;

class(類別|) Main {
  static(靜態|) function(函式|) main() {
    var c1 = f(65);
    var c2 = f(66);
    trace(c1 + c2); // AB
  }
}
```

Here, we import `String.fromCharCode` as `f` which allow(容許|又：允許)s us to use `f(65)` and `f(66)`. While the same could be achieved with a local variable(變數|)(局部變數|), this method is compile-time(編譯期|又：編譯時) exclusive and guaranteed to have no run-time(執行期|又：執行時) overhead.

##### since Haxe 3.2.0

The more natural `as` can be used in place of `in` when importing modules.

<!--label:type(型式|)-system-import-default(預設|)s-->
#### Import default(預設|)s / import.hx

##### since Haxe 3.3.0

Using the specially named `import.hx` file (note the lowercase name), default(預設|) imports and usings can be define(定義：|)d that will be applied for all modules inside a directory, which reduces the number of imports for large code bases with many helpers and static(靜態|) extension(延伸|)s.

The `import.hx` file must be placed in the same directory as your code. It can only contain import and using statements, which will be applied to all Haxe modules in the directory and its subdirectories.

default(預設|) imports of `import.hx` act as if its contents are placed at the top of each module.

##### Related content

* [Introduction of `import.hx`](https://haxe.org/blog/importhx-intro/)

<!--label:type(型式|)-system-resolution-order-->
#### Resolution Order

Resolution order comes into play as soon as unqualified identifier(識別符|)s are involved. These are [expression(表達式|)s](expression(表達式|)) in the form of `foo()`, `foo = 1` and `foo.field(欄位|)`. The last one in particular includes module path(路徑|)s such as `haxe.ds.Stringmap(映射|)`, where `haxe` is an unqualified identifier(識別符|).

We describe(描述|) the resolution order algorithm here, which depends on the following state:

* The declare(宣告|)d [local variable(變數|)(局部變數|)s](expression(表達式|)-var) (including function(函式|) argument(引數|)s).
* The [imported](type(型式|)-system-import) modules, type(型式|)s and static(靜態|)s.
* The available [static(靜態|) extension(延伸|)s](lf-static(靜態|)-extension(延伸|)).
* The kind (static(靜態|) or member) of the current field(欄位|).
* The declare(宣告|)d member field(欄位|)s on the current class(類別|) and its parent class(父類別|)(類別|)es.
* The declare(宣告|)d static(靜態|) field(欄位|)s on the current class(類別|).
* The [expected type(型式|)](define(定義：|)-expected-type(型式|)).
* The expression(表達式|) being `untype(型式|)d` or not.

![](assets/figures/type(型式|)-system-resolution-order-diagram.svg)

_Figure: Resolution order of identifier(識別符|) `i'_

Given an identifier(識別符|) `i`, the algorithm is as follows:

1. If i is `true(真|)`, `false(假|)`, `this`, `super` or `null(空|)`, resolve(解析|) to the matching constant and halt.
2. If a local variable(變數|)(局部變數|) named `i` is accessible, resolve(解析|) to it and halt.
3. If the current field(欄位|) is static(靜態|), go to 6.
4. If the current class(類別|) or any of its parent class(父類別|)(類別|)es has a field(欄位|) named `i`, resolve(解析|) to it and halt.
5. If a static(靜態|) extension(延伸|) with a first argument(引數|) of the type(型式|) of the current class(類別|) is available, resolve(解析|) to it and halt.
6. If the current class(類別|) has a static(靜態|) field(欄位|) named `i`, resolve(解析|) to it and halt.
7. If an enum(枚舉|) construct(結構體|)(建構|)or named `i` is declare(宣告|)d on an imported enum(枚舉|), resolve(解析|) to it and halt.
8. If a static(靜態|) named `i` is explicitly(明確|) imported, resolve(解析|) to it and halt.
9. If `i` starts with a lower-case character, go to 11.
10. If a type(型式|) named `i` is available, resolve(解析|) to it and halt.
11. If the expression(表達式|) is not in untype(型式|)d mode, go to 14.
12. If `i` equals `__this__`, resolve(解析|) to the `this` constant and halt.
13. Generate a local variable(變數|)(局部變數|) named `i`, resolve(解析|) to it and halt.
14. Fail.

For step 10, it is also necessary to define(定義：|) the resolution order of type(型式|)s:

1. If a type(型式|) named `i` is imported (directly or as part of a module), resolve(解析|) to it and halt.
2. If the current package contains a module named `i` with a type(型式|) named `i`, resolve(解析|) to it and halt.
3. If a type(型式|) named `i` is available at top-level, resolve(解析|) to it and halt.
4. Fail.

For step 1 of this algorithm, as well as steps 5 and 7 of the previous one, the order of import resolution is important:

* Imported modules and static(靜態|) extension(延伸|)s are checked from bottom to top with the first match being picked.
* Imports that come from [import.hx](type(型式|)-system-import-default(預設|)s) files are considered to be at the top of affected modules, which means they have the lowest priority. If multiple `import.hx` files affect a module, the ones in child directories have priority over the ones in parent directories.
* Within a given module, type(型式|)s are checked from top to bottom.
* For imports, a match is made if the name equals.
* For [static(靜態|) extension(延伸|)s](lf-static(靜態|)-extension(延伸|)), a match is made if the name equals and the first argument(引數|) [unifies](type(型式|)-system-unification(統一|TODO)). Within a given type(型式|) being used as a static(靜態|) extension(延伸|), the field(欄位|)s are checked from top to bottom.

<!--label:type(型式|)-system-untype(型式|)d-->
### untype(型式|)d

**Important note:** This syntax should be avoided whenever possible. The produced code cannot be properly checked by the Haxe compiler(編譯器|) and so it may have type(型式|) error(錯誤|)s or other bug(錯誤|)s that would be caught at compile time in regular code. Use only when absolutely necessary and when you know what you are doing.

It is possible to completely circumvent the type(型式|) checker by prefixing an expression(表達式|) with the keyword(關鍵字|) `untype(型式|)d`. The majority of type(型式|) error(錯誤|)s are not emitted inside an untype(型式|)d expression(表達式|). This is primarily used with the target(目標|)-specific [code injection expression(表達式|)s](target(目標|)-syntax).
