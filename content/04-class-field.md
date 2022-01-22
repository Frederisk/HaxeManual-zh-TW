<!--label:class-field-->
## class(類別|) field(欄位|)s

> ##### define(定義|): class(類別|) field(欄位|)
>
> A class(類別|) field(欄位|) is a variable(變數|), property(屬性|) or method(方法|) of a class(類別|) which can either be static(靜態|) or non-static(靜態|). Non-static(靜態|) field(欄位|)s are referred to as **member(成員|)** field(欄位|)s, so we speak of e.g. a **static(靜態|) method(方法|)** or a **member(成員|) variable(變數|)**.

So far we have seen how type(型式|n. 又：型別)s and Haxe programs, in general, are structure(結構|)d. This section about class(類別|) field(欄位|)s concludes the struct(結構體|)ural part and at the same time bridges to the behavior(行為|)al part of Haxe. This is because class(類別|) field(欄位|)s are the place where [expression(表達式|)s](expression) are at home.

There are three kinds of class(類別|) field(欄位|)s:

* variable(變數|): A [variable(變數|)](class-field-variable) class(類別|) field(欄位|) holds a value(值|) of a certain type(型式|n. 又：型別), which can be read or written.
* property(屬性|): A [property(屬性|)](class-field-property) class(類別|) field(欄位|) define(定義|)s a custom(客製|) access(存取|) behavior(行為|) for something that, outside the class(類別|), looks like a variable(變數|) field(欄位|).
* method(方法|): A [method(方法|)](class-field-method) is a function(函式|) which can be called to execute code.

Strictly speaking, a variable(變數|) could be considered to be a property(屬性|) with certain access(存取|) modifier(修飾符|)s. Indeed, the Haxe compiler(編譯器|) does not distinguish variable(變數|)s and properties during its typing(型態/型式|n./adj.) phase, but they remain separated(分隔|) at the syntax(語法|) level.

Regarding terminology, a method(方法|) is a (static(靜態|) or non-static(靜態|)) function(函式|) belonging to a class(類別|). Other function(函式|)s, such as a [local function(函式|)s](expression-arrow-function) in expression(表達式|)s, are not considered method(方法|)s.

<!--label:class-field-variable-->
### variable(變數|)

We have already seen variable(變數|) field(欄位|)s in several code examples of previous sections. variable(變數|) field(欄位|)s hold value(值|)s, a characteristic which they share with most (but not all) properties:

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

We can learn from this that a variable

1. has a name (here: `member`),
2. has a type (here: `String`),
3. may have a constant initialization (here: `"bar"`) and
4. may have [access modifiers](class-field-access-modifier) (here: `static`)

The example first prints the initialization value of `member`, then sets it to `"foo"` before printing its new value(值|). The effect of access(存取|) modifier(修飾符|)s is shared by all three class(類別|) field(欄位|) kinds and explained in a separate section.

It should be noted that the explicit type(型式|n. 又：型別) is not required if there is an initialization(初始化|) value(值|). The compiler(編譯器|) will [infer](type-system-type-inference) it in this case.

![](assets/figures/class(類別|)-field(欄位|)-variable(變數|)-init-value(值|)s.svg)

_Figure: initialization(初始化|) value(值|)s of a variable(變數|) field(欄位|)._



<!--label:class-field-property-->
### property(屬性|)

Next to [variable(變數|)s](class-field-variable), properties are the second option for dealing with data on a class(類別|). Unlike variable(變數|)s, however, they offer more control of which kind of field(欄位|) access(存取|) should be allow(容許|又：允許)ed and how it should be generate(產生|)d. Common use case(使用案例|)s include:

* Have a field(欄位|) which can be read from anywhere but only be written from within the defining class(類別|).
* Have a field(欄位|) which invoke(引動|)s a **getter(取得器|TODO:)**-method(方法|) upon read-access(存取|).
* Have a field(欄位|) which invoke(引動|)s a **setter(設定器|又：寫入器 TODO:)**-method(方法|) upon write-access(存取|).

When dealing with properties, it is import(匯入|)ant to understand the two kinds of access(存取|):

> ##### define(定義|): Read access(存取|)
>
> A read access(存取|) to a field(欄位|) occurs when a right-hand side [field(欄位|) access(存取|) expression(表達式|)](expression-field-access) is used. This includes calls in the form of `obj.field()`, where `field` is access(存取|)ed to be read.

> ##### define(定義|): Write access(存取|)
>
> A write access(存取|) to a field(欄位|) occurs when a [field(欄位|) access(存取|) expression(表達式|)](expression-field-access) is assign(賦值|又：指派、指定、分配)ed a value(值|) in the form of `obj.field = value`. It may also occur in combination with [read access](define-read-access) for special assignment operators such as `+=` in expression(表達式|)s like `obj.field += value`.


Read access and write access are directly reflected in the syntax, as the following example shows:

<!-- [code asset](assets/Property.hx) -->
```haxe
class Main {
  public var x(default, null):Int;

  static public function main() {}
}

```

For the most part, the syntax is similar to variable syntax, and the same rules indeed apply. Properties are identified by

* the opening parenthesis `(` after the field(欄位|) name,
* followed by a special **access(存取|) identifier(識別符|)** (here: `default`),
* with a comma `,` separating
* another special access(存取|) identifier(識別符|) (here: `null`)
* before a closing parenthesis `)`.

The access identifiers define the behavior when the field is read (first identifier) and written (second identifier). The accepted values are:

* `default`: Allows normal field access if the field has public visibility, otherwise equal to `null` access(存取|).
* `null`: Allows access only from within the defining class.
* `get`/`set`: Access is generated as a call to an **accessor method**. The compiler ensures that the accessor is available.
* `dynamic`: Like `get`/`set` access(存取|), but does not verify the existence of the access(存取|)or field(欄位|).
* `never`: Allows no access at all.

> ##### Define: Accessor method
>
> An **accessor method** (or short **accessor**) for a field named `field` of type(型式|n. 又：型別) `T` is a **getter(取得器|TODO:)** named `get_field` of type(型式|n. 又：型別) `Void->T` or a **setter(設定器|又：寫入器 TODO:)** named `set_field` of type(型式|n. 又：型別) `T->T`.

> ##### Trivia: Accessor names
>
> In Haxe 2, arbitrary identifiers were allowed as access identifiers and would lead to custom accessor method names to be admitted. This made parts of the implementation quite tricky to deal with. In particular, `Reflect.getProperty()` and `Reflect.setProperty()` had to assume(假設|) that any name could have been used, requiring the target(目標|) generators to generate(產生|) meta-information and perform lookups.
>
> We disallow(容許|又：允許)ed these identifier(識別符|)s and went for the `get_` and `set_` naming convention which greatly simplified implementation(實作|). This was one of the breaking change(重大變更|)s between Haxe 2 and 3.

<!--label:class-field-property-common-combinations-->
#### Common access(存取|)or identifier(識別符|) combinations

The next example shows common access(存取|) identifier(識別符|) combinations for properties:

<!-- [code asset](assets/Property2.hx) -->
```haxe
class Main {
  // read from outside, write only within Main
  public var ro(default, null):Int;

  // write from outside, read only within Main
  public var wo(null, default):Int;

  // access through getter get_x and setter
  // set_x
  public var x(get, set):Int;

  // read access through getter, no write
  // access
  public var y(get, never):Int;

  // required by field x
  function get_x() return 1;

  // required by field x
  function set_x(x) return x;

  // required by field y
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

The JavaScript output helps understand what the field access in the `main`-method is compiled to:

```js
var Main = function() {
	var v = this.get_x();
	this.set_x(2);
	var _g = this;
	_g.set_x(_g.get_x() + 1);
};
```

As specified, the read access generates a call to `get_x()`, while the write access generates a call to `set_x(2)` where `2` is the value(值|) being assign(賦值|又：指派、指定、分配)ed to `x`. The way the `+=` is being generate(產生|)d might look a little odd at first, but can easily be justified by the following example:

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

What happens here is that the expression part of the field access to `x` in the `main` method(方法|) is **complex**: It has potential side-effects, such as the construct(建構/構造|v./n.)ion of `Main` in this case. Thus, the compiler(編譯器|) cannot generate(產生|) the `+=` operation(運算|) as `new Main().x = new Main().x + 1` and has to cache the complex expression(表達式|) in a local variable(局部變數|):

```js
Main.main = function() {
	var _g = new Main();
	_g.set_x(_g.get_x() + 1);
}
```



<!--label:class-field-property-type-system-impact-->
#### Impact on the type system

The presence of properties has several consequences on the type system. Most importantly, it is necessary to understand that properties are a compile-time feature and thus **require the types to be known**. If we were to assign a class with properties to `Dynamic`, field access would **not** respect accessor methods. Likewise, access restrictions no longer apply and all access is virtually public.

When using `get` or `set` access(存取|) identifier(識別符|), the compiler(編譯器|) ensures that the getter(取得器|TODO:) and setter(設定器|又：寫入器 TODO:) actually exists. The following code snippet does not compile:

<!-- [code asset](assets/Property4.hx) -->
```haxe
class Main {
  // Method get_x required by property x is missing
  public var x(get, null):Int;

  static public function main() {}
}

```

The method `get_x` is missing, but it need not be declare(宣告|)d on the class(類別|) defining the property(屬性|) itself as long as a parent class(父類別|) define(定義|)s it:

<!-- [code asset](assets/Property5.hx) -->
```haxe
class Base {
  public function get_x() return 1;
}

class Main extends Base {
  // ok, get_x is declared by parent class
  public var x(get, null):Int;

  static public function main() {}
}

```

The `dynamic` access(存取|) modifier(修飾符|) works exactly like `get` or `set`, but does not check for the existence



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
> * a [property](class-field-property) with the read-access or write-access identifier being `default` or `null`
> * a [property](class-field-property) with `:isVar` [metadata(元資料|)](lf-metadata)
>
>

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


