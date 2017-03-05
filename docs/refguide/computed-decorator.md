# (@)computed

计算值(computed values)是可以根据现有的状态或其它计算值推导出的值。
概念上来说，它们与excel表格中的公式十分相似。
不要低估计算值，因为它们有助于使实际可修改的状态尽可能的小。
此外计算值还是高度优化过的，所以尽可能的多使用它们。

不要把 `computed` 和 `autorun` 搞混。它们都是响应式调用的表达式，但是，如果你想响应式的产生一个可以被其它 observer 使用的**值**，请使用 `@computed`，如果你不想产生一个新值，而想要达到一个**效果**，请使用 `autorun`。
举例来说，效果是像打印日志、发起网络请求等这样命令式的副作用。

如果任何影响计算值的值发生变化了，计算值将根据状态自动推导。
计算值在大多数情况下可以被 MobX 优化的，因为它们被认为是纯函数。
例如，如果前一个计算中使用的数据没有更改，计算属性将不会重新运行。
如果某个其它计算属性或 reaction 未使用该计算属性，也不会重新运行。
在这种情况下，它将被暂停。

这个自动地暂停是非常方便的。如果一个计算值不再被观察了，例如使用它的UI不复存在了，MobX 可以自动地将其垃圾回收。而 `autorun` 中的值必须要手动清理才行，这点和计算值是有所不同的。
如果你创建一个计算属性，但不在 reaction 中的任何地方使用它，它不会缓存值并且有些重新计算看起来似乎是没有必要的。这点有时候会让刚接触 MobX 的人们很困惑。
然而，在现实开发场景中，这是迄今为止最好的默认逻辑。如果你需要的话，可以使用 [`observe`](observe.md) 或 [`keepAlive`](https://github.com/mobxjs/mobx-utils#keepalive) 来强制保持计算值总是处于唤醒状态。

注意计算属性是不可枚举的，它们也不能在继承链中被覆盖。

## `@computed`

如果已经[启用 decorators](../best/decorators.md) 的话，可以在任意类属性的 getter 上使用 `@computed` 装饰器来声明式的创建计算属性。

```javascript
import {observable, computed} from "mobx";

class OrderLine {
    @observable price = 0;
    @observable amount = 1;

    constructor(price) {
        this.price = price;
    }

    @computed get total() {
        return this.price * this.amount;
    }
}
```

## `computed` 调节器

如果你的环境不支持装饰器，请使用 `computed(expression)` 调节器组合 `extendObservable` / `observable` 以引入新的计算属性。

从本质上来说，`@computed get propertyName() { }` 在构造函数中调用的 [`extendObservable(this, { propertyName: get func() { } })`](extend-observable.md) 的语法糖。

```javascript
import {extendObservable, computed} from "mobx";

class OrderLine {
    constructor(price) {
        extendObservable(this, {
            price: price,
            amount: 1,
            // 有效:
            get total() {
                return this.price * this.amount
            },
            // 同样有效:
            total: computed(function() {
                return this.price * this.amount
            })
        })
    }
}
```

## 计算值的 setter

还可以为计算值定义 setter。注意这些 setters 不能用来直接改变计算属性的值，但是它们可以用来作为推导的“反转”。例如:

```javascript
const box = observable({
    length: 2,
    get squared() {
        return this.length * this.length;
    },
    set squared(value) {
        this.length = Math.sqrt(value);
    }
});
```

And similarly

```javascript
class Foo {
    @observable length: 2,
    @computed get squared() {
        return this.length * this.length;
    }
    set squared(value) { //this is automatically an action, no annotation necessary
        this.length = Math.sqrt(value);
    }
}
```

_Note: always define the setter *after* the getter, some TypeScript versions are known to declare two properties with the same name otherwise._

_Note: setters require MobX 2.5.1 or higher_

## `computed(expression)` as function

`computed` can also be invoked directly as function.
Just like `observable.box(primitive value)` creates a stand-alone observable.
Use `.get()` on the returned object to get the current value of the computation, or `.observe(callback)` to observe its changes.
This form of `computed` is not used very often, but in some cases where you need to pass a "boxed" computed value around it might prove useful.

Example:

```javascript
import {observable, computed} from "mobx";
var name = observable("John");

var upperCaseName = computed(() =>
	name.get().toUpperCase()
);

var disposer = upperCaseName.observe(change => console.log(change.newValue));

name.set("Dave");
// prints: 'DAVE'
```

## Options for `computed`

When using `computed` as modifier or as box, it accepts a second options argument with the following optional arguments:

* `name`: String, the debug name used in spy and the MobX devtools
* `context`: The `this` that should be used in the provided expression
* `setter`: The setter function to be used. Without setter it is not possible to assign new values to a computed value. If the second argument passed to `computed` is a function, this is assumed to be a setter.
* `compareStructural`: By default `false`. When true, the output of the expression is structurally compared with the previous value before any observer is notified about a change. This makes sure that observers of the computation don't re-evaluate if new structures are returned that are structurally equal to the original ones. This is very useful when working with point, vector or color structures for example.

## `@computed.struct` for structural comparison

The `@computed` decorator does not take arguments. If you want to to create a computed property which does structural comparison, use `@computed.struct`.

## Note on error handling

If a computed value throws an exception during its computation, this exception will be catched and rethrown any time its value is read.
It is strongly recommended to always throw `Error`'s, so that the original stack trace is preserved. E.g.: `throw new Error("Uhoh")` instead of `throw "Uhoh"`.
Throwing exceptions doesn't break tracking, so it is possible for computed values to recover from exceptions.

Example:

```javascript
const x = observable(3)
const y = observable(1)
const divided = computed(() => {
    if (y.get() === 0)
        throw new Error("Division by zero")
    return x.get() / y.get()
})

divided.get() // returns 3

y.set(0) // OK
divided.get() // Throws: Division by zero
divided.get() // Throws: Division by zero

y.set(2)
divided.get() // Recovered; Returns 1.5
```
