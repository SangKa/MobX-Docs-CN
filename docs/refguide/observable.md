# observable

用法:
* `observable(value)`
* `@observable classProperty = value`

Observable 值可以是JS基本数据类型、引用类型、普通对象、类实例、数组和映射。
匹配类型应用了以下转换规则，但可以通过使用**调节器**进行微调。请参见下文。

1. 如果 **value** 是包裹在**调节器** `asMap` 中: 会返回一个新的 [Observable Map](map.md)。如果你不想只对一个特定项的更改做出反应，而是对添加或删除该项做出反应的话，那么 Observable map 会非常有用。
1. 如果 **value** 是数组，会返回一个 [Observable Array](array.md)。
1. 如果 **value** 是没有原型的对象，那么对象会被克隆并且所有的属性都会被转换成可观察的。参见 [Observable Object](object.md)。
1. 如果 **value** 是有原型的对象，JavaSript原始数据类型或者函数，会返回一个 [Boxed Observable](boxed.md)。MobX 不会将一个有原型的对象自动转换成可观察的，因为这是它构造函数的职责。在构造函数中使用 `extendObservable` 或者在类定义中使用 `@observable`。

乍看之下，这些规则可能看上去很复杂，但实际上实践当中你会发现他们是非常直观的。

一些便笺:
* 要创建键是动态的对象时使用 `asMap` 调节器！该对象只有初始化时便存在的属性会转换成可观察的，但新添加的属性只有通过使用 `extendObservable` 才可以转换成可观察的。
* 要想使用 `@observable` 装饰器，首先要确保 在你的编译器(babel 或者 typescript)中 [装饰器是启用的](http://mobxjs.github.io/mobx/refguide/observable-decorator.html)。
* 默认情况下将一个数据结构转换成可观察的是**有感染性的**，这意味着 `observable` 被自动应用于数据结构包含的任何值，或者将来会被该数据结构包含的值。这个行为可以通过使用 *modifiers* 来更改。

一些示例:

```javascript
const map = observable(asMap({ key: "value"}));
map.set("key", "new value");

const list = observable([1, 2, 4]);
list[2] = 3;

const person = observable({
    firstName: "Clive Staples",
    lastName: "Lewis"
});
person.firstName = "C.S.";

const temperature = observable(20);
temperature.set(25);
```
