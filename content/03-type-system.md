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

`equals` 函式的兩個引數 `expected` 和 `actual` 的形式是 `T`，這意味著對 `equals` 的每次引動這兩個引數都必須具有相同的型式。編譯器會容許第一次（兩個引數都是 `Int`）和第二次（個引數都是 `String`）呼叫，但第三次嘗試則會由於型式不匹配而造成編譯器錯誤。

> #### 瑣事： 運算式語法中的型式參數
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

在上面的例子中我們可以看到，在第 7 列使用空陣列和第 8 列使用 `Array<String>` 引動 `test` 都工作得很好。之所以這樣是由於 `Array` 具有 `length` 屬性和 `iterator` 方法。但是在第 9 列傳遞 `String` 引數則會在約束檢查上失敗，這是由於 `String` 與 `Iterable<T>` 並不相容。

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

即便 `Child` 可以指派給 `Base`，但顯然 `Array<Child>` 不能指派給 `Array<Base>`。會這樣的原因可能有些出人意料：由於陣列可以寫入所以不容許指派，比如說有 `push()` 方法。忽略變異數很容易會導致問題：

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

在此處，我們使用[轉換](expression-cast)來顛覆型式檢查器，從而使得能夠容許註釋行之後的指派。如此一來，我們有了型式為 `Array<Base>` 的原始陣列引用 `bases`。這將容許我們將另一種與 `Base` 相容的型式推入至陣列中（在此實例中為 `OtherChild`）。然而在我們最初的引用中 `children` 依然是 `Array<Child>` 型式，所以當我們在疊代時遇到其元素中的一個 `OtherChild` 時，事情就會變得非常糟糕。

若 `Array` 沒有 `push()` 方法以及其他的修改方法，則該指派將會因為不能向其中添加不相容的型式而是安全的。

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

我們可以安全地指派給型式為 `MyArray<Base>` 且 `MyArray` 只有 `pop()` 方法的 `b`。在 `MyArray` 中並沒有定義可以添加不相容型式的方法。這種稱之為**共變**。

> #### 定義：共變數
>
> 如果[複合型式](define-compound-type)的組件型式可指派至更不具體的組件，也就是說它們是唯讀但從不寫入，則認其為共變。
<!---->
> #### 定義：反變數
>
> 如果[複合型式](define-compound-type)的組件型式可指派至更不通用的組件，也就是說它們是唯寫但從不讀取，則認其為反變。

<!--label:type-system-unification-->
## 統一

統一是型式系統的核心，其極大地促進了 Haxe 程式的強健。統一描述了檢查一種型式是否與另一種型式相容的過程。

> #### 定義：統一
>
> 兩種型式 A 與 B 之間的統一是定向的過程，其回答了 A 是否**可以指派給** B 的問題。若其是或有[單型](types-monomorph)則可**變異**為任一型式。

統一錯誤很容易就能觸發：

```haxe
class Main {
  static public function main() {
    // Int 應當是 String
    var s:String = 1;
  }
}
```

我們嘗試將 `Int` 型式的值指派給 `String` 變數，這會導致變異氣嘗試去**以 String 統一 Int**。當然，這是不允許的，並會使編譯器發出「Int 應當是 String」（`Int should be String`）的錯誤。

在這種特殊情形下，統一是由**指派**所觸發的，由「可指派」所定義的上下文很直觀。這是會執行統一的幾種情形之一：

- 指派：如果將 `a` 指派給 `b`，則 `a` 的型式以 `b` 的型式相統一。
- 函式呼叫：我們在介紹[函式](types-function)的型式時已經簡要看過這樣的例子。通常，編譯器會嘗試將第一個給定引數的型式以第一個預期引數的型式統一，將第二個給定引數的型式以第二個預期引數的型式統一，以此類推，直到處理完所有引數的型式。
- 函式回傳：只要函式有 `return e` 的運算式，`e` 的型式就會以函式的返回型式相統一。如果函式沒有明確的返回型式，則推斷其為 `e` 的型式，並隨後的 `return` 運算式會針對它進行推斷。 TODO:  If the function(函式|) has no explicit return(回傳|) type(型式|), it is inferred to the type(型式|) of `e` and subsequent `return(回傳|)` expression(運算式|)s are inferred against it.
- 陣列宣告：編譯器會嘗試在陣列宣告中的所有給定型式之間找到最小型式。參閱[共同基底型式](type-system-unification-common-base-type)以獲取詳情。
- 物件宣告：如過宣告的物件與給定型式相「牴觸」，則編譯器會使每個給定欄位的型式以每個預期欄位的型式相統一。
- 運算子統一：某些運算子會期望特定型式以給定型式相統一。如，運算式 `a && b` 會將 `a` 和 `b` 以 `Bool` 統一、運算式 `a == b`會讓 `a` 以 `b` 相統一。

<!--label:type-system-unification-between-classes-and-interfaces-->
### 類別、介面之間

在定義類別之間的統一行為時，很重要的一點是要記得統一是定向的。我們可以將更為具體的類別指派給更寬犯的類別，但反之不是有效的。

下列的指派是容許的：

- 子類別到父類別。
- 類別到實作的介面。
- 介面到基底介面。

這些規則是遞移的，這意味著子類別也可以指派給其基底類別的基底類別、其基底類別的實作的介面、實作的介面的基底介面等。

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

`empty` 方法檢查 `Iterable` 是否具有元素。為此，除了將其視為可疊代這一事實之外，無需了解有關引數型式的任何資訊。這容許在使用與 `Iterable<T>` 相統一的任何型式都可呼叫 `empty` 方法，這適用於 Haxe 標準函式庫中的許多型式。

這種型態可能非常便於使用，然而過量使用則可能損害靜態目標的效能，這在[對效能的影響]中有詳細說明。

<!--label:type-system-monomorphs-->
### 單型

在[型式推理]中詳細說明了具有或者成為[單型]的型式的統一。

unification(統一|TODO) of type(型式|)s having or being a [monomorph(變型|)(單型|)](type(型式|)s-monomorph(變型|)(單型|)) is detailed in [type(型式|) inference(推斷|又：推定、推理)](type(型式|)-system-type(型式|)-inference(推斷|又：推定、推理)).

[類型推斷](type-system-type-inference)中詳細說明了具有或成為[單態](types-monomorph)的類型的統一。

<!--label:type-system-unification-function-return-->
### 函式回傳

函式回傳型式的回傳可能涉及 [`Void`](types-void)型式，並且需要明確定義與 `Void` 統一的內容。`Void` 用作描述型式的缺失，其不可指派給任何其他型式，甚至 `Dynamic` 也不行。這也意味著函式若明確宣告為回傳 `Dynamic`，則其不可返回 `Void`。

反之亦然：函式若明確宣告為回傳 `Void`，則其不可返回 `Dynamic` 或是其他型式。但是在為函式型式時則容許這種統一方向：

```haxe
var func:Void->Void = function() return "foo";
```

右側的函式的型式顯然是 `Void->String`，然而我們可將其指派給 `Void->Void` 型式的變數 `func`。這是由於編譯器可以安全地假定返回型別是無關緊要的，因為其不可指派給任何非 `Void` 的型式。

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

型式推理的影響已在本文件中看到過，並將持續十分重要。展示型式推理工作的一個簡單例子：

類型推斷的影響已在本文件中看到，並將繼續很重要。 一個簡單的示例顯示了工作中的類型推斷：

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
> `$type` 是一種編譯期機制，其呼叫方式類似具有單個引數的函式。編譯器會評估引數運算式，然後輸出該運算式的型式。

在上面的例子中，第一個 `$type` 列印出 `Unknown<0>`，這是[單形](types-monomorph)，也就是還不知曉的型式。下一列的 `x = "foo` 將字串常值指派給 `x`，這使單型與 `String` 相[統一](type-system-unification)。然後我們可以看到 `x` 的型式已變成 `String`。

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
> 當運算式的型式在輸入運算式之前就已經已知時就會出現預期型式。比如在運算式是函式呼叫的引數時。預期型式可透過[自上而下推斷](type-system-top-down-inference)影響運算式的型式。

一個很好的例子是混合型式的陣列，如[動態](types-dynamic)中所述，編譯器會因無法確定元素型式而拒絕 `[1, "foo"]`。而採用自上而下推斷則可以克服這個問題：

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

在此處以明確型式 `String` 和 `haxe.Template` 明確型式來確定了 `make` 的回傳型式。這種做法有效，因為該方法以 `make()` 引動，所以我們知道回傳型式將指派給變數。利用這資訊，就可以將未知型式 `T` 分別繫結至 `String` 和 `haxe.Template` 了。

<!--label:type-system-inference-limitations-->
### 限制

型式推理減少了使用局部變數時對手動型式提示的需求，但有時型式系統仍會需要引導。除非有直接的初始化，否則型式推理不會嘗試去推斷[變數](class-field-variable)或[屬性](class-field-property)欄位的型式。

另外在一些涉及遞迴的情況中型式推理會有侷限。如果一個函式在其型式還不完全已知的情形下呼叫自身，則型式推理可能會推理出不正確而且過於特定的型式。

另一個需要考慮的問題是程式碼的可讀性。如果過度使用型式推理，由於缺少可見的型式，程式的某些部分可能會變得難易理解。對於方法的簽章尤其如此，因此建議在型式推理與明確型式找到一個較好的平衡點。

<!--label:type-system-modules-and-paths-->
## 模組和路徑

> #### 定義：模組
>
> 所有的 Haxe 程式碼都組織在模組中並使用路徑定址。本質上，每個 .hx 檔案代表一個可能包含多種型式的模組。型別可能是 `private` 的，在這種情況下則只有包含它的模組可以存取它。

模組與其同名的包含型式之間的區別是模糊的。事實上，對 `haxe.ds.StringMap<Int>` 的定址可視作是 `haxe.ds.StringMap.StringMap<Int>` 的簡寫。後者由四部分組成：

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

子型式關係不會在執行期反射，公用子型式會成為其所包含套件的成員，如果同一個套件中的兩個模組試圖去定義相同的子型式則可能導致衝突。自然而然，Haxe 編譯器會偵測到這些情況並相應地回報它們。在上面的例子中 `ExprDef` 會產生 `haxe.macro.ExprDef`。

子型式也可以設為是私用的：

```haxe
private class C { ... }
private enum E { ... }
private typedef T { ... }
private abstract A { ... }
```

> #### 定義：私用型式
>
> 可以以 `private` 修飾符將型式設為私用。之後，該型式將只能從定義它的模組中存取。
>
> 與公用型式不同，私用型式不會成為其包含套件的成員。

型式的可存取性可以透過使用[存取控制](lf-access-control)來更精確地控制。

<!--label:type-system-import-->
### 匯入

如果型式路徑在 .hx 檔案中多次使用，那麼使用匯入來縮短可能會有意義。在使用該型式時可以省略套件：

<!-- [code asset](assets/Import.hx) -->
```haxe
import haxe.ds.StringMap;

class Main {
  static public function main() {
    // instead of: new haxe.ds.StringMap();
    new StringMap();
  }
}
```

由於在第一列中匯入了 `haxe.ds.StringMap`，所以編譯器能夠將 `main` 函式中的非限定識別符 `StringMap` 解析至這個套件。就是說模組 `StringMap` 匯入至了對應檔案中。

在這個例子中，我們實際上匯入了一個模組，而不僅是該模組中的特定型式，這意味著在匯入中的模組中定義的所有型式都是可用的：

<!-- [code asset](assets/Import2.hx) -->
```haxe
import haxe.macro.Expr;

class Main {
  static public function main() {
    var e:Binop = OpAdd;
  }
}
```

型式 `Binop` 是在模組 `haxe.macro.Expr` 中宣告的[枚舉](types-enum-instance)，因此在匯入上述模組後可用。如果我們只匯入該模組中的特定型式，例如 `import haxe.macro.Expr.ExprDef`，那麼程式會以「類別未找到：Binop」（`Class not found : Binop`）編譯失敗。

對於匯入，有幾個方面值得了解：

- 最底部的匯入有優先權（詳見[解析順序](type-system-resolution-order)）。
- [靜態延伸](lf-static-extension)關鍵字 `using` 意味著<!--TODO: implies--> `import` 的效果。
- 如果（直接或作為模組匯入的一部分）匯入枚舉，則其所有[枚舉建構式](types-enum-constructor)也會匯入（這就是上面例子中容許使用 `OpAdd` 的原因）。

此外，也可以匯入一個類別的[靜態欄位](class-field)並以非限定的方式使用：

<!-- [code asset](assets/Import3.hx) -->
```haxe
import Math.random;

class Main {
  static public function main() {
    random();
  }
}
```

特別注意，對於與套件名衝突的欄位名稱或局部變數名稱，由於欄位和局部變數的優先權高於套件，名為 `haxe` 的局部變數會阻擋對整個 `haxe` 套件的使用。

#### 萬用匯入

Haxe 容許使用萬用符號 `.*` 來容許匯入套件中的所有模組，模組中的所有型式或者型式中的所有欄位。重要的是要理解這種匯入只會跨越一個層級，我們可以在下面的例子中看到：

<!-- [code asset](assets/ImportWildcard.hx) -->
```haxe
import haxe.macro.*;

class Main {
  static function main() {
    var expr:Expr = null;
    // var expr:ExprDef = null; // Class not found : ExprDef
  }
}
```

在 `haxe.macro` 上使用萬用字元匯入將容許存取 `Expr`，它是這個套件中的一個模組，但這樣不能容許存取 `Expr` 模組的子型式 `ExprDef`。當匯入一個模組時，這個規則也會擴充到靜態欄位。

當在一個套件上使用萬用字元匯入時，編譯器不會急於處理該套件中的所有模組，沒有明確使用的模組不會成為生成輸出的一部份。

#### 帶別名的匯入

如果匯入的型式或靜態欄位在模組中頻繁使用，給其一個更短的別名可能會有幫助。這也可以用於透過給它們唯一的識別符來消除沖突的名稱。

<!-- [code asset](assets/ImportAlias.hx) -->
```haxe
import String.fromCharCode in f;

class Main {
  static function main() {
    var c1 = f(65);
    var c2 = f(66);
    trace(c1 + c2); // AB
  }
}
```

此處，我們將 `String.fromCharCode` 匯入為 `f`，這樣我們就可以使用 `f(65)` 和 `f(66)`。雖然這同樣可以以局部變數實現，但這種方法是編譯期專用的，並可以保證沒有執行期的開銷。

#### 自 Haxe 3.2.0

在匯入模組時可以使用更自然的 `as` 來替代 `in`。

<!--label:type-system-import-defaults-->
### 匯入預設、import.hx

#### 自 Haxe 3.3.0

使用特別命名的 `import.hx` 檔案（注意名稱是小寫的），可以定義默認的匯入和使用這將使用與一個所有目錄下的所有模組，並將減少有許多輔助和靜態延伸的大型程式庫的匯入數量。

`import.hx` 檔案必須和你的程式放在同一個目錄下，它只能包含匯入和使用語句這些語句將套用至該目錄及其子目錄下的所有 Haxe 模組。

`import.hx` 的預設匯入就如同其內容放置在每個模組的頂部一樣。

#### 相關內容

- [`import.hx` 的介紹]((https://haxe.org/blog/importhx-intro/))

<!--label:type-system-resolution-order-->
### 解析順序

一旦涉及非限定的識別符，解析順序就將開始發揮作用。非限定識別符是形如 `foo()`、`foo = 1` 和 `foo.field` 的[運算式](expression)。特別是最後一種還包含模組路徑，如 `haxe.ds.StringMap`，其中 `haxe` 是非限定識別符。

我們在此描述解析順序的算法，其取決于以下狀態：

- 宣告的[局部變數](expression-var)（包含函式引數）。
- [匯入](type-system-import)的模組型式和靜態。
- 可用的[靜態延伸](lf-static-extension)。
- 當前欄位的種類（靜態或成員）。
- 在當前類別和其父類別上宣告的成員欄位。
- 當前類別中已宣告的靜態欄位。
- [預期型式](define-expected-type)。
- 運算式是否為 `untyped`。

![圖：識別符 `i` 的解析順序](assets/figures/type-system-resolution-order-diagram.svg)

_圖：識別符 `i` 的解析順序_

給定一個識別符 `i`，其算法如下：

1. 如果 `i` 是 `true`、`false`、`this`、`super` 或 `null`解析至匹配的常數並停止。
2. 如果有名為 `i` 的可存取局部變數，解析至其並停止。
3. 如果當前欄位是靜態的，轉至 6。
4. 如果當前類別或任何父類別中有名為 `i` 的欄位，解析至其並停止。
5. 如果具有當前類別型式第一個引數的靜態延伸可用，解析至其並停止。
6. 如果當前類別中有名為 `i` 的靜態欄位，解析至其並停止。
7. 如果在匯入的枚舉中有名為 `i` 的枚舉建構式宣告，解析至其並停止。
8. 如果有名為 `i` 的靜態明確匯入，解析至其並停止。
9. 如果 `i` 以小寫字元開頭，轉至 11。
10. 如果名為 `i` 的型式可用，解析至其並停止。
11. 如果運算式不在非具型式模式下，轉至 14。
12. 如果 `i` 等於 `__this__`，解析至 `this` 常數並停止。
13. 產生一個名為 `i` 的局部變數，解析至其並停止。
14. 失敗。

對於第 10 步，還需要定義型式的解析順序：

1. 如果有（直接或作為模組的一部份）導入名為 `i` 的型式，解析至其並停止。
1. 如果當前套件包含名為 `i` 的模組，並有名為 `i` 的型式，解析至其並停止。
1. 如果名為 `i` 的型式在頂層可用，解析至其並停止。
1. 失敗。

對於這個算法的第 1 步，以及前一個算法的第 5 和第 7 步，匯入的解析順序十分重要：

- 匯入模組和靜態延伸會自下至上檢查，並選中第一個所匹配的。
- 自 [`import.hx`](type-system-import-defaults) 的匯入會認為是在受影響的模組的頂部，這意味著它們的優先權最低。如果多個 `import.hx` 檔案影響同一個模組，則子目錄較父目錄中的更有優先權。
- 在給定的模組中，型式自上而下檢查。
- 對於匯入，如果名稱相同則匹配。
- 對於[靜態延伸](lf-static-extension)，如果名稱相同且第一個引數[統一](type-system-unification)，則匹配。在用作靜態延伸的給定型式中，欄位自上而下檢查。

<!--label:type-system-untyped-->
## 非具型式

**重要提示：**只要有其他可能就應該避免使用這種語法。以此產生的程式碼 Haxe 編譯器無法正確檢查，因此可能會有型式錯誤或其他錯誤，而這些錯誤在常規程式碼中的編譯期就可發現。只有在絕對必要和你知道自己在做什麼時才使用。

在運算式前加上關鍵字 `untyped` 可完全規避型式檢查器。大多數型式錯誤都不會在非具型式運算式中發生。該語法主要用於特定目標的[程式碼插入運算式](target-syntax)。
