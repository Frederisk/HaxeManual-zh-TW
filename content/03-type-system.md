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

Whenever an instance(實例|) of `array(陣列|)` is create(建立|)d, its type(型式|) parameter(參數|) `T` becomes a [monomorph(變型|)(單型|)](type(型式|)s-monomorph(變型|)(單型|)). That is, it can be bound to any type(型式|), but only one at a time. This bind(繫結|)ing can happen either:

* explicitly(明確|), by invoking the construct(結構體|)(建構|)or with explicit type(型式|)s (`new array(陣列|)<String>()`) or
* implicit(隱含|)ly, by [type(型式|) inference(推斷|又：推定、推理)](type(型式|)-system-type(型式|)-inference(推斷|又：推定、推理)) for instance(實例|), when invoking `array(陣列|)instance(實例|).push("foo")`.

Inside the definition(定義|) of a class(類別|) with type(型式|) parameter(參數|)s, the type(型式|) parameter(參數|)s are an unspecific type(型式|). Unless [constraints](type(型式|)-system-type(型式|)-parameter(參數|)-constraints) are added, the compiler(編譯器|) has to assume that the type(型式|) parameter(參數|)s could be used with any type(型式|). As a consequence, it is not possible to access the field(欄位|)s of type(型式|) parameter(參數|)s or [cast(轉換|又：轉型 TODO)](expression(表達式|)-cast(轉換|又：轉型 TODO)) to a type(型式|) parameter(參數|) type(型式|). It is also not possible to create(建立|) a new instance(實例|) of a type(型式|) parameter(參數|) type(型式|) unless the type(型式|) parameter(參數|) is [generic](type(型式|)-system-generic) and constrained accordingly.

The following table shows where type(型式|) parameter(參數|)s are allow(容許|又：允許)ed:

每當創建 Array 的實例時，其類型參數 T 就變成了單形。 也就是說，它可以綁定到任何類型，但一次只能綁定一個。 這種綁定可以發生在：

通過顯式調用構造函數 (new Array<String>()) 或
例如，在調用 arrayInstance.push("foo") 時，通過類型推斷隱式地進行。
在帶有類型參數的類的定義中，類型參數是一種非特定類型。 除非添加約束，否則編譯器必須假設類型參數可以用於任何類型。 因此，無法訪問類型參數的字段或轉換為類型參數類型。 也不能創建類型參數類型的新實例，除非類型參數是通用的並相應地受到約束。

下表顯示了允許類型參數的位置：

parameter(參數|) on | Bound upon | Notes
 ---(---|---) | ---(---|---) | ---(---|---)
class(類別|) | instantiation | Can also be bound upon member field(欄位|) access.
enum(枚舉|) | instantiation |
enum(枚舉|) construct(結構體|)(建構|)or | instantiation |
function(函式|) | invocation | allow(容許|又：允許)ed for methods and named local lvalue(值|) function(函式|)s.
struct(結構體|)ure(結構|) | instantiation |


As function(函式|) type(型式|) parameter(參數|)s are bound upon invocation, they accept any type(型式|) if left unconstrained. However, only one type(型式|) per invocation is accepted. This can be utilized if a function(函式|) has multiple argument(引數|)s:

<!-- [code asset](assets/function(函式|)type(型式|)parameter(參數|).hx) -->
```haxe
class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    equals(1, 1);
    // runtime message: bar should be foo
    equals("foo", "bar");
    // compiler(編譯器|) error(錯誤|): String should be Int
    equals(1, "foo");
  }

  static(靜態|) function(函式|) equals<T>(expected:T, actual:T) {
    if (actual != expected) {
      trace('$actual should be $expected');
    }
  }
}

```

Both of the `equals` function(函式|)'s argument(引數|)s, `expected` and `actual`, have type(型式|) `T`. This implies that for each invocation of `equals`, the two argument(引數|)s must be of the same type(型式|). The compiler(編譯器|) permits the first call (both argument(引數|)s being of `Int`) and the second call (both argument(引數|)s being of `String`) but the third attempt causes a compiler(編譯器|) error(錯誤|) due to a type(型式|) mismatch.

> ##### Trivia: type(型式|) parameter(參數|)s in expression(表達式|) syntax
>
> We often get the question of why a method with type(型式|) parameter(參數|)s cannot be called as `method<String>(x)`. The error(錯誤|) messages the compiler(編譯器|) gives are not very helpful. However, there is a simple reason for that: the above code is parsed as if both `<` and `>` were binary operator(運算子|)s, yielding `(method < String) > (x)`.

<!--label:type(型式|)-system-type(型式|)-parameter(參數|)-constraints-->
#### Constraints

type(型式|) parameter(參數|)s can be constrained to multiple type(型式|)s:

<!-- [code asset](assets/Constraints.hx) -->
```haxe
type(型式|)def Measurable = {
  public var length(default(預設|), null(空|)):Int;
}

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    trace(test([]));
    trace(test(["bar", "foo"]));
    // String should be Iterable<String>
    // test("foo");
  }

  #if (haxe_ver >= 4)
  static(靜態|) function(函式|) test<T:Iterable<String> & Measurable>(a:T) {
  #else
  static(靜態|) function(函式|) test<T:(Iterable<String>, Measurable)>(a:T) {
  #end
    if (a.length == 0)
      return(回傳|) "empty";
    return(回傳|) a.iterator().next();
  }
}

```

The `test` method contains a type(型式|) parameter(參數|) `T` that is constrained to the type(型式|)s `Iterable<String>` and `Measurable`.  The latter is define(定義|)d using a [type(型式|)def](type(型式|)-system-type(型式|)def) for convenience and requires compatible(相容|) type(型式|)s to have a read-only [property(屬性|)](class(類別|)-field(欄位|)-property(屬性|)) named `length` of type(型式|) `Int`. The constraints then indicate that a type(型式|) is compatible(相容|) if:

* it is compatible(相容|) with `Iterable<String>` and
* has a `length` property(屬性|) of type(型式|) `Int`.

In the above example, we can see that invoking `test` with an empty array(陣列|) on line 7 and an `array(陣列|)<String>` on line 8 works fine. This is because `array(陣列|)` has both a `length` property(屬性|) and an `iterator` method. However, passing a `String` as argument(引數|) on line 9 fails the constraint check because `String` is not compatible(相容|) with `Iterable<T>`.

When constraining to a single type(型式|), the parentheses can be omitted:

<!-- [code asset](assets/Constraints2.hx) -->
```haxe
class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    trace(test([]));
    trace(test(["bar", "foo"]));
  }

  static(靜態|) function(函式|) test<T:Iterable<String>>(a:T) {
    return(回傳|) a.iterator().next();
  }
}

```

##### since Haxe 4.0.0

One of the breaking change(重大變更|)s between versions 3 and 4 is the multiple type(型式|) constraint syntax. As the first example above shows, in Haxe 4 the constraints are separated(分隔|) by an `&` symbol instead of a comma. This is similar to the new [struct(結構體|)ure(結構|) extension(延伸|)](type(型式|)s-struct(結構體|)ure(結構|)-extension(延伸|)s) syntax.





<!--label:type(型式|)-system-generic-->
### Generic

Usually, the Haxe compiler(編譯器|) generates only a single class(類別|) or function(函式|) even if it has type(型式|) parameter(參數|)s. This results in a natural abstract(抽象|)ion where the code generator for the target(目標|) language must assume that a type(型式|) parameter(參數|) could be of any type(型式|). The generated code might then have to perform type(型式|) checks which can be detrimental for performance(效能|).

A class(類別|) or function(函式|) can be made **generic** by attributing it with the `@:generic` [metadata(元資料|)](lf-metadata(元資料|)). This causes the compiler(編譯器|) to emit a distinct class(類別|) or function(函式|) per type(型式|) parameter(參數|) combination with mangled names. A specification like this can yield a boost in sections of performance(效能|)-critical code on [static(靜態|) target(目標|)s](define(定義|)-static(靜態|)-target(目標|)) at the cost of a larger output size:

<!-- [code asset](assets/Genericclass(類別|).hx) -->
```haxe
@:generic
class(類別|) Myvalue(值|)<T> {
  public var value(值|):T;

  public function(函式|) new(value(值|):T) {
    this.value(值|) = value(值|);
  }
}

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    var a = new Myvalue(值|)<String>("Hello");
    var b = new Myvalue(值|)<Int>(42);
  }
}

```

It may seem unusual to see the explicit type(型式|) `Myvalue(值|)<String>` here as [type(型式|) inference(推斷|又：推定、推理)](type(型式|)-system-type(型式|)-inference(推斷|又：推定、推理)) often handles similar situations. Nonetheless, it is required in this case as the compiler(編譯器|) must know the exact type(型式|) of a generic class(類別|) upon construct(結構體|)(建構|)ion. The JavaScript output shows the result:

```js
(function(函式|) () { "use strict";
var Test = function(函式|)() { };
Test.main = function(函式|)() {
	var a = new Myvalue(值|)_String("Hello");
	var b = new Myvalue(值|)_Int(5);
};
var Myvalue(值|)_Int = function(函式|)(value(值|)) {
	this.value(值|) = value(值|);
};
var Myvalue(值|)_String = function(函式|)(value(值|)) {
	this.value(值|) = value(值|);
};
Test.main();
})();
```

We can identify that `Myvalue(值|)<String>` and `Myvalue(值|)<Int>` have become `Myvalue(值|)_String` and `Myvalue(值|)_Int` respectively. The situation is similar for generic function(泛型函式|)(函式|)s:

<!-- [code asset](assets/Genericfunction(函式|).hx) -->
```haxe
class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    method("foo");
    method(1);
  }

  @:generic static(靜態|) function(函式|) method<T>(t:T) {}
}

```

Again, the JavaScript output makes it obvious:

```js
(function(函式|) () { "use strict";
var Main = function(函式|)() { }
Main.method_Int = function(函式|)(t) {
}
Main.method_String = function(函式|)(t) {
}
Main.main = function(函式|)() {
	Main.method_String("foo");
	Main.method_Int(1);
}
Main.main();
})();
```

<!--label:type(型式|)-system-generic-type(型式|)-parameter(參數|)-construct(結構體|)(建構|)ion-->
#### construct(結構體|)(建構|)ion of generic type(型式|) parameter(參數|)s

> ##### define(定義|): Generic type(型式|) parameter(參數|)
>
> A type(型式|) parameter(參數|) is said to be generic if its containing class(類別|) or method is generic.

It is not possible to construct(結構體|)(建構|) normal type(型式|) parameter(參數|)s; for example, `new T()` would register as a compiler(編譯器|) error(錯誤|). The reason for this is that Haxe generates only a single function(函式|) and the construct(結構體|)(建構|) would make no sense in that case. This is different when the type(型式|) parameter(參數|) is generic: since we know that the compiler(編譯器|) will generate a distinct function(函式|) for each type(型式|) parameter(參數|) combination, it is possible to replace the `T` `new T()` with the real type(型式|).

<!-- [code asset](assets/Generictype(型式|)parameter(參數|).hx) -->
```haxe
import haxe.Constraints;

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    var s:String = make();
    var t:haxe.Template = make();
  }

  @:generic
  static(靜態|) function(函式|) make<T:construct(結構體|)(建構|)ible<String->Void>>():T {
    return(回傳|) new T("foo");
  }
}

```

It should be noted that [top-down inference(推斷|又：推定、推理)](type(型式|)-system-top-down-inference(推斷|又：推定、推理)) is used here to determine the actual type(型式|) of `T`. For this kind of type(型式|) parameter(參數|) construct(結構體|)(建構|)ion to work, the construct(結構體|)(建構|)ed type(型式|) parameter(參數|) must meet two requirements:

1. It must be generic.
2. It must be explicitly(明確|) [constrained](type(型式|)-system-type(型式|)-parameter(參數|)-constraints) to have a [construct(結構體|)(建構|)or](type(型式|)s-class(類別|)-construct(結構體|)(建構|)or).

Here, the first requirement is met by `make` having the `@:generic` metadata(元資料|), and the second by `T` being constrained to `construct(結構體|)(建構|)ible`. The constraint holds for both `String` and `haxe.Template` as both have a construct(結構體|)(建構|)or accepting a singular `String` argument(引數|). Sure enough, the relevant JavaScript output looks as expected:

```js
var Main = function(函式|)() { }
Main.__name__ = true(真|);
Main.make_haxe_Template = function(函式|)() {
	return(回傳|) new haxe.Template("foo");
}
Main.make_String = function(函式|)() {
	return(回傳|) new String("foo");
}
Main.main = function(函式|)() {
	var s = Main.make_String();
	var t = Main.make_haxe_Template();
}
```





<!--label:type(型式|)-system-variance-->
### Variance

While variance is relevant in other places, it occurs particularly often with type(型式|) parameter(參數|)s and may come as a surprise in this context. It is very easy to trigger variance error(錯誤|)s:

<!-- [code asset](assets/Variance.hx) -->
```haxe
class(類別|) Base {
  public function(函式|) new() {}
}

class(類別|) Child extend(擴充|又：延伸)s Base {}

class(類別|) Main {
  public static(靜態|) function(函式|) main() {
    var children = [new Child()];
    // array(陣列|)<Child> should be array(陣列|)<Base>
    // type(型式|) parameter(參數|)s are invariant(變體|)
    // Child should be Base
    var bases:array(陣列|)<Base> = children;
  }
}

```

Apparently, an `array(陣列|)<Child>` cannot be assign(賦值|又：指派、指定、分配)ed to an `array(陣列|)<Base>`, even though `Child` can be assign(賦值|又：指派、指定、分配)ed to `Base`. The reason for this might be somewhat unexpected: the assign(賦值|又：指派、指定、分配)ment is not allow(容許|又：允許)ed because array(陣列|)s can be written to, for example, through their `push()` method. It is easy to generate problems by ignoring variance error(錯誤|)s:

<!-- [code asset](assets/Variance2.hx) -->
```haxe
class(類別|) Base {
  public function(函式|) new() {}
}

class(類別|) Child extend(擴充|又：延伸)s Base {}
class(類別|) OtherChild extend(擴充|又：延伸)s Base {}

class(類別|) Main {
  public static(靜態|) function(函式|) main() {
    var children = [new Child()];
    // subvert type(型式|) checker
    var bases:array(陣列|)<Base> = cast(轉換|又：轉型 TODO) children;
    bases.push(new OtherChild());
    for (child in children) {
      trace(child);
    }
  }
}

```

Here, we subvert the type(型式|) checker by using a [cast(轉換|又：轉型 TODO)](expression(表達式|)-cast(轉換|又：轉型 TODO)), thus allow(容許|又：允許)ing the assign(賦值|又：指派、指定、分配)ment after the commented line. With that we hold a reference `bases` to the original array(陣列|), type(型式|)d as `array(陣列|)<Base>`. This allow(容許|又：允許)s pushing another type(型式|) compatible(相容|) with `Base`, in this instance(實例|) `OtherChild`, onto that array(陣列|). However, our original reference `children` is still of type(型式|) `array(陣列|)<Child>`, and things go bad when we encounter the `OtherChild` instance(實例|) in one of its elements while iterating.

If `array(陣列|)` had no `push()` method and no other means of modification, the assign(賦值|又：指派、指定、分配)ment would be safe as no incompatible(相容|) type(型式|) could be added to it. This can be achieved by restricting the type(型式|) accordingly using [struct(結構體|)ural subtyping](type(型式|)-system-struct(結構體|)ural-subtyping):

<!-- [code asset](assets/Variance3.hx) -->
```haxe
class(類別|) Base {
  public function(函式|) new() {}
}

class(類別|) Child extend(擴充|又：延伸)s Base {}

type(型式|)def Myarray(陣列|)<T> = {
  public function(函式|) pop():T;
}

class(類別|) Main {
  public static(靜態|) function(函式|) main() {
    var a = [new Child()];
    var b:Myarray(陣列|)<Base> = a;
  }
}

```

We can safely assign(賦值|又：指派、指定、分配) with `b` being type(型式|)d as `Myarray(陣列|)<Base>` and `Myarray(陣列|)` only having a `pop()` method. There is no method define(定義|)d on `Myarray(陣列|)` which could be used to add incompatible(相容|) type(型式|)s. It is thus said to be **covariant(變體|)**.

> ##### define(定義|): Covariance
>
> A [compound type(型式|)(複合型式|)](define(定義|)-compound-type(型式|)) is considered covariant(變體|) if its component type(型式|)s can be assign(賦值|又：指派、指定、分配)ed to less specific components, i.e. if they are only read, but never written.

> ##### define(定義|): Contravariance
>
> A [compound type(型式|)(複合型式|)](define(定義|)-compound-type(型式|)) is considered contravariant(變體|) if its component type(型式|)s can be assign(賦值|又：指派、指定、分配)ed to less generic components, i.e. if they are only written, but never read.



<!--label:type(型式|)-system-unification(統一|TODO)-->
### unification(統一|TODO)

unification(統一|TODO) is the heart of the type(型式|) system and contributes immensely to the robust(強健|)ness of Haxe programs. It describe(描述|)s the process of checking if a type(型式|) is compatible(相容|) with another type(型式|).

> ##### define(定義|): unification(統一|TODO)
>
> unification(統一|TODO) between two type(型式|)s A and B is a directional process which answers one question: whether A **can be assign(賦值|又：指派、指定、分配)ed to** B. It may **mutate** either type(型式|) if it either is or has a [monomorph(變型|)(單型|)](type(型式|)s-monomorph(變型|)(單型|)).

unification(統一|TODO) error(錯誤|)s are very easy to trigger:

```haxe
class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    // Int should be String
    var s:String = 1;
  }
}
```
We try to assign(賦值|又：指派、指定、分配) a value(值|) of type(型式|) `Int` to a variable(變數|) of type(型式|) `String`, which causes the compiler(編譯器|) to try and **unify Int with String**. This is, of course, not allow(容許|又：允許)ed and makes the compiler(編譯器|) emit the error(錯誤|) `Int should be String`.

In this particular case, the unification(統一|TODO) is triggered by an **assign(賦值|又：指派、指定、分配)ment**, a context in which the "is assign(賦值|又：指派、指定、分配)able to" definition(定義|) is intuitive. It is one of several cases where unification(統一|TODO) is performed:

* assign(賦值|又：指派、指定、分配)ment: If `a` is assign(賦值|又：指派、指定、分配)ed to `b`, the type(型式|) of `a` is unified with the type(型式|) of `b`.
* function(函式|) call: We have briefly seen an example of this while introducing the [function(函式|)](type(型式|)s-function(函式|)) type(型式|). In general, the compiler(編譯器|) tries to unify the first given argument(引數|) type(型式|) with the first expected argument(引數|) type(型式|), the second given argument(引數|) type(型式|) with the second expected argument(引數|) type(型式|), and so on until all argument(引數|) type(型式|)s are handled.
* function(函式|) return(回傳|): Whenever a function(函式|) has a `return(回傳|) e` expression(表達式|), the type(型式|) of `e` is unified with the function(函式|) return(回傳|) type(型式|). If the function(函式|) has no explicit return(回傳|) type(型式|), it is inferred to the type(型式|) of `e` and subsequent `return(回傳|)` expression(表達式|)s are inferred against it.
* array(陣列|) declaration(宣告|): The compiler(編譯器|) tries to find a minimal type(型式|) between all given type(型式|)s in an array(陣列|) declaration(宣告|). Refer to [common base type(型式|)(共同基底型式|)](type(型式|)-system-unification(統一|TODO)-common-base-type(型式|)) for details.
* Object declaration(宣告|): If an object is declare(宣告|)d "against" a given type(型式|), the compiler(編譯器|) unifies each given field(欄位|) type(型式|) with each expected field(欄位|) type(型式|).
* operator(運算子|) unification(統一|TODO): Certain operator(運算子|)s expect certain type(型式|)s which the given type(型式|)s are unified against. For instance(實例|), the expression(表達式|) `a && b` unifies both `a` and `b` with `Bool` and the expression(表達式|) `a == b` unifies `a` with `b`.

<!--label:type(型式|)-system-unification(統一|TODO)-between-class(類別|)es-and-interface(介面|)s-->
#### Between class(類別|)/interface(介面|)

When defining unification(統一|TODO) behavior(行為|) between class(類別|)es, it is important to remember that unification(統一|TODO) is directional: we can assign(賦值|又：指派、指定、分配) a more specialized class(類別|) to a generic class(類別|), but the reverse is not valid(有效|).

The following assign(賦值|又：指派、指定、分配)ments are allow(容許|又：允許)ed:

* child class(類別|)(子類別|) to parent class(父類別|)(類別|).
* class(類別|) to implement(實作|)ing interface(介面|).
* interface(介面|) to base interface(介面|).

These rules are transitive(遞移|), meaning that a child class(類別|)(子類別|) can also be assign(賦值|又：指派、指定、分配)ed to the base class(類別|) of its base class(類別|), an interface(介面|) its base class(類別|) implement(實作|)s, the base interface(介面|) of an implement(實作|)ing interface(介面|), and so on.



<!--label:type(型式|)-system-struct(結構體|)ural-subtyping-->
#### struct(結構體|)ural Subtyping

> ##### define(定義|): struct(結構體|)ural Subtyping
>
> struct(結構體|)ural subtyping define(定義|)s an implicit(隱含|) relationship between type(型式|)s that have the same struct(結構體|)ure(結構|).

struct(結構體|)ural sub-typing(結構子型態|TODO) in Haxe is allow(容許|又：允許)ed when unifying:

* a [class(類別|)](type(型式|)s-class(類別|)-instance(實例|)) with a [struct(結構體|)ure(結構|)](type(型式|)s-anonymous(匿名|)-struct(結構體|)ure(結構|)) and
* a struct(結構體|)ure(結構|) with another struct(結構體|)ure(結構|).

The following example is part of the `Lambda` class(類別|) in the [Haxe standard library(標準函式庫|)](std):

```haxe
public static(靜態|) function(函式|) empty<T>(it : Iterable<T>):Bool {
  return(回傳|) !it.iterator().hasNext();
}
```
The `empty`-method checks if an `Iterable` has an element. For this purpose, it is not necessary to know anything about the argument(引數|) type(型式|) other than the fact that it is considered an iterable. This allow(容許|又：允許)s calling the `empty`-method with any type(型式|) that unifies with `Iterable<T>`, which applies to many type(型式|)s in the Haxe standard library(標準函式庫|).

This kind of typing can be very convenient, but extensive use may be detrimental to performance(效能|) on static(靜態|) target(目標|)s, which is detailed in [Impact on performance(效能|)](type(型式|)s-struct(結構體|)ure(結構|)-performance(效能|)).



<!--label:type(型式|)-system-monomorph(變型|)(單型|)s-->
#### monomorph(變型|)(單型|)s

unification(統一|TODO) of type(型式|)s having or being a [monomorph(變型|)(單型|)](type(型式|)s-monomorph(變型|)(單型|)) is detailed in [type(型式|) inference(推斷|又：推定、推理)](type(型式|)-system-type(型式|)-inference(推斷|又：推定、推理)).



<!--label:type(型式|)-system-unification(統一|TODO)-function(函式|)-return(回傳|)-->
#### function(函式|) return(回傳|)

unification(統一|TODO) of function(函式|) return(回傳|) type(型式|)s may involve the [`Void`](type(型式|)s-void) type(型式|) and requires a clear definition(定義|) of what unifies with `Void`. With `Void` describing the absence of a type(型式|), it is not assign(賦值|又：指派、指定、分配)able to any other type(型式|), not even `dynamic(動態|)`. This means that if a function(函式|) is explicitly(明確|) declare(宣告|)d as return(回傳|)ing `dynamic(動態|)`, it cannot return(回傳|) `Void`.

The opposite applies as well: if a function(函式|) declare(宣告|)s a return(回傳|) type(型式|) of `Void`, it cannot return(回傳|) `dynamic(動態|)` or any other type(型式|). However, this direction of unification(統一|TODO) is allow(容許|又：允許)ed when assign(賦值|又：指派、指定、分配)ing function(函式|) type(型式|)s:

```haxe
var func:Void->Void = function(函式|)() return(回傳|) "foo";
```

The right-hand function(函式|) is clearly of type(型式|) `Void->String`, yet we can assign(賦值|又：指派、指定、分配) it to the variable(變數|) `func` of type(型式|) `Void->Void`. This is because the compiler(編譯器|) can safely assume that the return(回傳|) type(型式|) is irrelevant, given that it could not be assign(賦值|又：指派、指定、分配)ed to any non-`Void` type(型式|).



<!--label:type(型式|)-system-unification(統一|TODO)-common-base-type(型式|)-->
#### common base type(型式|)(共同基底型式|)

Given a set of multiple type(型式|)s, a **common base type(型式|)(共同基底型式|)** is a type(型式|) which all type(型式|)s of the set unify against:

<!-- [code asset](assets/UnifyMin.hx) -->
```haxe
class(類別|) Base {
  public function(函式|) new() {}
}

class(類別|) Child1 extend(擴充|又：延伸)s Base {}
class(類別|) Child2 extend(擴充|又：延伸)s Base {}

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    var a = [new Child1(), new Child2()];
    $type(型式|)(a); // array(陣列|)<Base>
  }
}

```

Although `Base` is not mentioned, the Haxe compiler(編譯器|) manages to infer it as the common type(型式|) of `Child1` and `Child2`. The Haxe compiler(編譯器|) employs this kind of unification(統一|TODO) in the following situations:

* array(陣列|) declaration(宣告|)s.
* `if`/`else`.
* Cases of a `switch`.





<!--label:type(型式|)-system-type(型式|)-inference(推斷|又：推定、推理)-->
### type(型式|) inference(推斷|又：推定、推理)

The effects of type(型式|) inference(推斷|又：推定、推理) have been seen throughout this document and will continue to be important. A simple example shows type(型式|) inference(推斷|又：推定、推理) at work:

<!-- [code asset](assets/type(型式|)inference(推斷|又：推定、推理).hx) -->
```haxe
class(類別|) Main {
  public static(靜態|) function(函式|) main() {
    var x = null(空|);
    $type(型式|)(x); // Unknown<0>
    x = "foo";
    $type(型式|)(x); // String
  }
}

```

The special construct(結構體|)(建構|) `$type(型式|)` was previously mentioned in order to simplify the explanation of the [function(函式|) type(型式|)](type(型式|)s-function(函式|)) type(型式|), so let us now introduce it officially:

> ##### define(定義|): `$type(型式|)`
>
> `$type(型式|)` is a compile-time(編譯期|又：編譯時) mechanism that is called similarly to a function(函式|) with a single argument(引數|). The compiler(編譯器|) evaluates the argument(引數|) expression(表達式|) and then outputs the type(型式|) of that expression(表達式|).

In the example above, the first `$type(型式|)` prints `Unknown<0>`. This is a [monomorph(變型|)(單型|)](type(型式|)s-monomorph(變型|)(單型|)), a type(型式|) that is not yet known. The next line `x = "foo"` assign(賦值|又：指派、指定、分配)s a `String` literal to `x`, which causes the [unification(統一|TODO)](type(型式|)-system-unification(統一|TODO)) of the monomorph(變型|)(單型|) with `String`. We then see that the type(型式|) of `x` has changed to `String`.

Whenever a type(型式|) other than [dynamic(動態|)](type(型式|)s-dynamic(動態|)) is unified with a monomorph(變型|)(單型|), that monomorph(變型|)(單型|) **morph(變型|)s** into that type(型式|), or in simpler terms, **becomes** that type(型式|). Therefore, it cannot morph(變型|) into a different type(型式|) afterwards, a property(屬性|) expressed in the **mono** part of its name.

Following the rules of unification(統一|TODO), type(型式|) inference(推斷|又：推定、推理) can occur in compound type(型式|)(複合型式|)s:

<!-- [code asset](assets/type(型式|)inference(推斷|又：推定、推理)2.hx) -->
```haxe
class(類別|) Main {
  public static(靜態|) function(函式|) main() {
    var x = [];
    $type(型式|)(x); // array(陣列|)<Unknown<0>>
    x.push("foo");
    $type(型式|)(x); // array(陣列|)<String>
  }
}

```

variable(變數|) `x` is first initialize(初始化|)d to an empty `array(陣列|)`. At this point, we can tell that the type(型式|) of `x` is an array(陣列|), but we do not yet know the type(型式|) of the array(陣列|) elements. Consequently, the type(型式|) of `x` is `array(陣列|)<Unknown<0>>`. It is only after pushing a `String` onto the array(陣列|) that we know the type(型式|) to be `array(陣列|)<String>`.

<!--label:type(型式|)-system-top-down-inference(推斷|又：推定、推理)-->
#### Top-down inference(推斷|又：推定、推理)

Most of the time, type(型式|)s are inferred on their own and may then be unified with an expected type(型式|). In a few places, however, an expected type(型式|) may be used to influence inference(推斷|又：推定、推理). We then speak of **top-down inference(推斷|又：推定、推理)**.

> ##### define(定義|): Expected type(型式|)
>
> Expected type(型式|)s occur when the type(型式|) of an expression(表達式|) is known before that expression(表達式|) has been type(型式|)d, such as when the expression(表達式|) is an argument(引數|) to a function(函式|) call. They can influence typing of that expression(表達式|) through [top-down inference(推斷|又：推定、推理)](type(型式|)-system-top-down-inference(推斷|又：推定、推理)).

A good example is an array(陣列|) of mixed type(型式|)s. As mentioned in [dynamic(動態|)](type(型式|)s-dynamic(動態|)), the compiler(編譯器|) refuses `[1, "foo"]` because it cannot determine an element type(型式|). Employing top-down inference(推斷|又：推定、推理), this can be overcome:

<!-- [code asset](assets/TopDowninference(推斷|又：推定、推理).hx) -->
```haxe
class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    var a:array(陣列|)<dynamic(動態|)> = [1, "foo"];
  }
}

```

Here, the compiler(編譯器|) knows while typing `[1, "foo"]` that the expected type(型式|) is `array(陣列|)<dynamic(動態|)>`, so the element type(型式|) is `dynamic(動態|)`. Instead of the usual unification(統一|TODO) behavior(行為|) where the compiler(編譯器|) would attempt (and fail) to determine a [common base type(型式|)(共同基底型式|)](type(型式|)-system-unification(統一|TODO)-common-base-type(型式|)), the individual elements are type(型式|)d against and unified with `dynamic(動態|)`.

We have seen another interesting use of top-down inference(推斷|又：推定、推理) when the [construct(結構體|)(建構|)ion of generic type(型式|) parameter(參數|)s](type(型式|)-system-generic-type(型式|)-parameter(參數|)-construct(結構體|)(建構|)ion) was introduced:

<!-- [code asset](assets/Generictype(型式|)parameter(參數|).hx) -->
```haxe
import haxe.Constraints;

class(類別|) Main {
  static(靜態|) public function(函式|) main() {
    var s:String = make();
    var t:haxe.Template = make();
  }

  @:generic
  static(靜態|) function(函式|) make<T:construct(結構體|)(建構|)ible<String->Void>>():T {
    return(回傳|) new T("foo");
  }
}

```

The explicit type(型式|)s `String` and `haxe.Template` are used here to determine the return(回傳|) type(型式|) of `make`. This works because the method is invoked as `make()`, so we know the return(回傳|) type(型式|) will be assign(賦值|又：指派、指定、分配)ed to the variable(變數|)s. Utilizing this information, it is possible to bind(繫結|) the unknown type(型式|) `T` to `String` and `haxe.Template` respectively.



<!--label:type(型式|)-system-inference(推斷|又：推定、推理)-limitations-->
#### Limitations

type(型式|) inference(推斷|又：推定、推理) reduces manual(手冊|) type(型式|) hinting when working with local variable(變數|)(局部變數|)s, but sometimes the type(型式|) system still needs guidance. It will not try to infer the type(型式|) of a [variable(變數|)](class(類別|)-field(欄位|)-variable(變數|)) or [property(屬性|)](class(類別|)-field(欄位|)-property(屬性|)) field(欄位|) unless it has a direct initialization(初始化|).

There are also cases involving recursion where type(型式|) inference(推斷|又：推定、推理) has limitations. If a function(函式|) calls itself recursively while its type(型式|) is not completely known yet, type(型式|) inference(推斷|又：推定、推理) may infer an incorrect and overly specialized type(型式|).

Another concern to consider is code legibility. If type(型式|) inference(推斷|又：推定、推理) is overused, parts of a program may become difficult to understand due to the lack of visible type(型式|)s. This is particularly true(真|) for method signatures. It is recommended to find a good balance between type(型式|) inference(推斷|又：推定、推理) and explicit type(型式|) hints.





<!--label:type(型式|)-system-modules-and-path(路徑|)s-->
### Modules and path(路徑|)s

> ##### define(定義|): Module
>
> All Haxe code is organized in modules, which are addressed using path(路徑|)s. In essence, each .hx file represents a module which may contain several type(型式|)s. A type(型式|) may be `private`, in which case only its containing module can access it.

The distinction between a module and its containing type(型式|) of the same name is blurry by design. In fact, addressing `haxe.ds.Stringmap(映射|)<Int>` can be considered shorthand for `haxe.ds.Stringmap(映射|).Stringmap(映射|)<Int>`. The latter version consists of four parts:

1. The package `haxe.ds`.
2. The module name `Stringmap(映射|)`.
3. The type(型式|) name `Stringmap(映射|)`.
4. The type(型式|) parameter(參數|) `Int`.

If the module and type(型式|) name are equal, the duplicate can be removed, leading to the `haxe.ds.Stringmap(映射|)<Int>` short version. However, knowing about the extend(擴充|又：延伸)ed version helps with understanding how [module sub-type(型式|)(子型式|)s](type(型式|)-system-module-sub-type(型式|)(子型式|)s) are addressed.

path(路徑|)s can be shortened further by using an [import](type(型式|)-system-import), which typically allow(容許|又：允許)s omitting the package part of a path(路徑|). This may lead to usage of unqualified identifier(識別符|)s, which requires understanding the [resolution order](type(型式|)-system-resolution-order).

> ##### define(定義|): type(型式|) path(路徑|)
>
> The (dot-)path(路徑|) to a type(型式|) consists of the package, the module name and the type(型式|) name. Its general form is `pack1.pack2.packN.ModuleName.type(型式|)Name`.

<!--label:type(型式|)-system-module-sub-type(型式|)(子型式|)s-->
#### Module sub-type(型式|)(子型式|)s

A module sub-type(型式|)(子型式|) is a type(型式|) declare(宣告|)d in a module with a different name than that module. This allow(容許|又：允許)s a single .hx file to contain multiple type(型式|)s, which can be accessed unqualified from within the module, and by using `package.Module.type(型式|)` from other modules:

```haxe
var e:haxe.macro(巨集|).Expr.ExprDef;
```

Here the sub-type(型式|)(子型式|) `ExprDef` within module `haxe.macro(巨集|).Expr` is accessed.

An example sub-type(型式|)(子型式|) declaration(宣告|) would look like the following :

```haxe
// a/A.hx
package a;

class(類別|) A { public function(函式|) new() {} }
// sub-type(型式|)(子型式|)
class(類別|) B { public function(函式|) new() {} }
```

```haxe
// Main.hx
import a.A;

class(類別|) Main {
    static(靜態|) function(函式|) main() {
        var subtype(型式|)1 = new a.A.B();

        // these are also valid(有效|), but require import a.A or import a.A.B :
        var subtype(型式|)2 = new B();
        var subtype(型式|)3 = new a.B();
    }
}
```

The sub-type(型式|)(子型式|) relation is not reflected at run-time(執行期|又：執行時); public sub-type(型式|)(子型式|)s become a member of their containing package, which could lead to conflicts if two modules within the same package tried to define(定義|) the same sub-type(型式|)(子型式|). Naturally, the Haxe compiler(編譯器|) detects these cases and reports them accordingly. In the example above `ExprDef` is generated as `haxe.macro(巨集|).ExprDef`.

sub-type(型式|)(子型式|)s can also be made private:

```haxe
private class(類別|) C { ... }
private enum(枚舉|) E { ... }
private type(型式|)def T { ... }
private abstract(抽象|) A { ... }
```

> ##### define(定義|): Private type(型式|)
>
> A type(型式|) can be made private by using the `private` modifier. Afterwards, the type(型式|) can only be directly accessed from within the [module](define(定義|)-module) it is define(定義|)d in.
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

In this example, we are actually importing a **module**, not just a specific type(型式|) within that module. This means that all type(型式|)s define(定義|)d within the imported module are available:

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

Using the specially named `import.hx` file (note the lowercase name), default(預設|) imports and usings can be define(定義|)d that will be applied for all modules inside a directory, which reduces the number of imports for large code bases with many helpers and static(靜態|) extension(延伸|)s.

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
* The [expected type(型式|)](define(定義|)-expected-type(型式|)).
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

For step 10, it is also necessary to define(定義|) the resolution order of type(型式|)s:

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
