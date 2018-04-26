# observable

<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px" href="https://egghead.io/lessons/javascript-sync-the-ui-with-the-app-state-using-mobx-observable-and-observer-in-react">egghead.io 第1课: observable & observer</a>
<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px"  href="https://egghead.io/lessons/react-use-observable-objects-arrays-and-maps-to-store-state-in-mobx">egghead.io 第4课: observable 对象 & 映射</a>

用法:
* `observable(value)`
* `@observable classProperty = value`

Observable 值可以是JS基本数据类型、引用类型、普通对象、类实例、数组和映射。
匹配类型应用了以下转换规则，但可以通过使用**调节器**进行微调。请参见下文。

1. 如果 **value** 是ES6的 `Map` : 会返回一个新的 [Observable Map](map.md)。如果你不只关注某个特定entry的更改，而且对添加或删除其他entry时也做出反应的话，那么 Observable maps 会非常有用
1. 如果 **value** 是数组，会返回一个 [Observable Array](array.md)。
1. 如果 **value** 是没有原型的对象，那么对象会被克隆并且所有的属性都会被转换成可观察的。参见 [Observable Object](object.md)。

1. 如果 **value** 是有原型的对象，JavaSript 原始数据类型或者函数，会返回一个 [Boxed Observable](boxed.md)。MobX 不会将一个有原型的对象自动转换成可观察的，因为这是它构造函数的职责。在构造函数中使用 `extendObservable` 或者在类定义中使用 `@observable`。
1. 如果 **value** 是有原型的对象，JavaSript 原始数据类型或者函数，`observable` 会抛出。如果想要为这样的值创建一个独立的可观察引用，请使用 [Boxed Observable](boxed.md) observable 代替。MobX 不会将一个有原型的对象自动转换成可观察的，因为这是它构造函数的职责。在构造函数中使用 `extendObservable` 或在类定义上使用 `@observable` / `decorate` 。

乍看之下，这些规则可能看上去很复杂，但实际上实践当中你会发现他们是非常直观的。

一些建议:
* 要创建 **键是动态的对象** 时使用 [Observable Map](map.md)！对象上只有初始化时便存在的属性会转换成可观察的，尽管新添加的属性可以通过使用 extendObservable 转换成可观察的。
* 要想使用 `@observable` 装饰器，首先要确保 在你的编译器(babel 或者 typescript)中 [装饰器是启用的](http://mobxjs.github.io/mobx/refguide/observable-decorator.html)。
* 默认情况下将一个数据结构转换成可观察的是**有感染性的**，这意味着 `observable` 被自动应用于数据结构包含的任何值，或者将来会被该数据结构包含的值。这个行为可以通过使用 *modifiers* 来更改。

一些示例:

```javascript
const map = observable.map({ key: "value"});
map.set("key", "new value");

const list = observable([1, 2, 4]);
list[2] = 3;

const person = observable({
    firstName: "Clive Staples",
    lastName: "Lewis"
});
person.firstName = "C.S.";

const temperature = observable.box(20);
temperature.set(25);
```
