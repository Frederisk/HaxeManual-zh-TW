<!--label:introduction-->
# 簡介

<!--subtoc-->

<!--label:introduction-what-is-haxe-->

## Haxe 是啥？

Haxe 是一種高階開源的程式語言及其編譯器，其擁有以 ECMAScript 導向語法所編寫程式編譯為多種其他目標語言的能力，並可利用適當的抽象來維護出可以編譯至多種目標語言的單個程式碼庫。

Haxe 是強型的，但在必要時可以打破型式限制。透過型式資訊，Haxe 可以在編譯期檢查出那些目標語言在執行期才會注意到的錯誤。更進一步，這些型式資訊可用於使編譯器產生經過最佳化以及更強健的程式碼。

現已有九種支援的目標語言可用於不同用例：

名稱 | 輸出類別 | 主要用例
--- | --- | ---
JavaScript | 原始碼 | 瀏覽器、桌面、行動裝置、伺服器
Neko | 位元組碼 | 桌面、伺服器、命令列介面
HashLink | 位元組碼 | 桌面、行動裝置、遊戲機
PHP | 原始碼 | 伺服器
Lua | 原始碼 | 桌面、腳本
C++ | 原始碼 | 桌面、行動裝置、伺服器、遊戲機
Flash | 位元組碼 | 桌面、行動裝置
Java | 原始碼 | 桌面、行動裝置、伺服器
JVM | 位元組碼 | 桌面、行動裝置、伺服器
C# | 原始碼 | 桌面、行動裝置、伺服器

本節的其餘部分簡要概述了 Haxe 程式的概覽以及自 2005 年成立以來 Haxe 的發展情況。

[型式](types)介紹了Haxe中的7種不同型式，以及這些型式是如何互動的。在[型式系統](type-system)中則有對型式的更進一步討論，其中解釋了例如<!--TODO--> **unification** 、 **型式參數** 以及 **型式推理** 等的特徵。

[類別欄位](class-field)介紹了有關 Haxe 類別結構的一切以及有關**屬性**、**內聯欄位**、以及**泛型函式**的額外話題。

在[表達式](expression)中，我們將看到如何使用**表達式**來讓程式做某些事情。

[語言特徵](lf)透過詳細描述一些諸如**模式匹配**、**字串插值**和**死碼刪除**來總結了 Haxe 語言參考。

我們與 Haxe 編譯器引用繼續先是處理了基本的[編譯器使用](compiler-usage)隨後是在[編譯器特徵](cr-features)中的進階特徵。最後，我們在[巨集](macro)將冒險進入 **Haxe 巨集**令人興奮的土地，並以此了解如何大大簡化一些共同任務。

在接下來的[標準函式庫](std)章節中，我們將從 Haxe 標準函式庫探索重要的型式和概念。然後我們會在 [Haxelib](haxelib) 中學到有關 Haxe 套件管理員的相關知識。

Haxe 通常會抽象掉許多目標差異，但有時與目標直接交互也很重要，這將會是[目標細節](target-details)中的主題。

<!--label:introduction-about-this-document-->
## 關於該文檔

本文檔是 Haxe 4 的官方手冊，所以，它不是初學者的教材，也不教程式設計。不過這些主題大致上設計為順序閱讀，並會提到「出現過的」和「還未出現」的主題。在某些情況下，如果後一節的內容可以簡化前面的內容，那麼前一節就會引用這些內容中的資訊。這些引用是會相應連結的，通常在其他主題上提前閱讀不會造成問題。

我們使用大量的 Haxe 原始碼來以實際方式說明理論上的問題，這些程式碼樣例通常是具有主要功能的完整程式，並可以按樣編譯。不過有時候也只會顯示最相關的部分。原始碼部分看起來會像是這樣：

```haxe
Haxe code here
```

有時我們會演示目標程式碼是如何產生的，這時通常會選用 JavaScript 目標。

此外，我們在文檔中文檔定義了一組術語，主要而言，這是在引入新型式或者是 Haxe 中特有的術語時完成的。為了避免雜亂，我們不會定義每一個我們所引入的概念，比如說「類別是甚麼」之類的。定義部分看起來會像是這樣：

> #### 定義：定義名稱
>
> 定義的描述

在幾個地方，這個文檔會有一些**瑣事**方塊，在其中會包含一些背景資訊，比如說 Haxe 在開發過程中做出某些決定的原因，或者某些功能隨著 Haxe 發展而變化的過程。這些資訊通常都不是必讀的，如果需要的話可以跳過：

> #### 瑣事：關於瑣事
>
> 這是瑣事

<!--label:introduction-license-->
### 作者和貢獻

這個文檔的大部分內容是由西蒙&middot;克拉耶夫斯基（Simon Krajewski）在為 Haxe 基金會工作時所寫的。我們要感謝這些人的貢獻：

* 丹&middot;科羅斯特列夫（Dan Korostelev）：其他內容和編輯
* 凱萊布&middot;哈珀（Caleb Harper）：其他內容和編輯
* 約瑟芬&middot;佩爾托薩（Josefiene Pertosa）：編輯
* 米哈&middot;盧那（Miha Lunar）：編輯
* 尼古拉斯&middot;坎納斯（Nicolas Cannasse）：Haxe 創造者

### 許可證

[Haxe 基金會](http://haxe.org/foundation)的《Haxe 手冊》是以[CC「姓名標示」 4.0 國際 公眾授權條款](http://creativecommons.org/licenses/by/4.0/)授權的。

基於[github.com/HaxeFoundation/HaxeManual](https://github.com/HaxeFoundation/HaxeManual)。

## Hello World

以下程式在編譯和運行後會列印出「Hello World」：

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

可以將上列內容儲存至以名為 `Main.hx` 的檔案中，並執行比如 `haxe --main Main --interp` 來呼叫 Haxe 編譯器以測試。期將會產生這樣的輸出：`Main.hx:3: Hello world`。此處有個點需要知道：

* Haxe 程式儲存在以 `.hx` 為副檔名的檔案中；
* Haxe 編譯器是一個命令列工具並可以以參數呼叫，例如：`--main Main`、`--interp`
* Haxe 程式具有類別（`Main`，大寫），其中又有函數（`main`，小寫）；
* 包含 Haxe 程式的檔案名稱和類別名稱相同（在此例中是 `Main.hx`）；

### 相關內容

* 《Haxe Code Cookbook》中的[初學者教程和範例](http://code.haxe.org/category/beginner/)。

<!--label:introduction-haxe-history-->
## 歷史

Haxe 專案由法國開發者**尼古拉斯&middot;坎納斯**（Nicolas Cannasse）於 2005 年 10 月 22 日作為流行開源的 ActionScript 2 編譯器 **MTASC**（Motion-Twin Action Script Compiler）以及內部 **MTypes** 語言的繼承者啟動，其中後者實驗了物件導向語言的型式推理的應用。對程式語言設計的持久熱情，以及作為 **Motion-Twin** 遊戲開發員之一，使混和兩種不同技術機會的出現，促使他創造了一種全新語言。

Haxe 起初拚寫作 haXe，其 beta 版本於 2006 年 2 月發布，首先支援的平台是 AVM 位元組碼以及尼古拉斯自己的 **Neko** 虛擬機器。

時至今日依然在作為 Haxe 項目的負責人尼古拉斯&middot;坎納斯繼續以明晰的願景開發 Haxe，並在 2006 年 5 月發布了 Haxe 1.0，這第一個主要版本提供了 JavaScript 程式碼產生支援，並且已經有了一些定義了現在的 Haxe 的功能，例如型式推理和<!--TODO:structural sub-typing-->結構子型態。

Haxe 1 在兩年內迎來了幾個小版本發布，在 2006 年 8 月 Flash AVM2 目標以及 haxelib 工具，2007 年 3 月添加了 ActionScript 3 目標。在此期間，穩定性成為重點，所以又有幾個小錯誤修正版本。

Haxe 2.0 在 2008 年 7 月發布，其包括了由<!--TODO--> **Franco Ponticelli** 提供的 PHP 目標支援，之後 <!--TODO--> **Hugh Sanderson** 在相似的努力下於 2009 年 7 月 Haxe 2.04 版本中添加了 C++ 目標。

與 Haxe 1 相同，接下來的是幾個月的穩定性發布。之後在 2011 年 1 月 Haxe 2.07 與巨集支援一同發布，大約在此時機，<!--TODO-->**Bruno Garcia**以 JavaScript 目標維護者的身分加入了團隊，並在隨後的 2.08 與 2.09 中對其帶來了巨大改進。

2.09 發布之後，<!--TODO-->，**Simon Krajewski**加入了團隊，並開始了 Haxe 3 的工作。此外，**Cauê Waneck**的 Java 和 C# 目標在此時機也入了 Haxe 構建。2012 年 7 月，作為 Haxe 2 的最後一個版本，Haxe 2.10 發布。

2012 年末，Haxe 3 做出了巨大變動，並由 Haxe 編譯器團隊專注於下一個大版本的開發，該團隊現在由 **Haxe 基金會**所支援。隨後 Haxe 3 在 2013 年 5 月發布。
