# (@)computed

<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px" href="https://egghead.io/lessons/javascript-derive-computed-values-and-manage-side-effects-with-mobx-reactions">egghead.io 第3课: 计算值</a>

计算值(computed values)是可以根据现有的状态或其它计算值衍生出的值。
概念上来说，它们与excel表格中的公式十分相似。
不要低估计算值，因为它们有助于使实际可修改的状态尽可能的小。
此外计算值还是高度优化过的，所以尽可能的多使用它们。

不要把 `computed` 和 `autorun` 搞混。它们都是响应式调用的表达式，但是，如果你想响应式的产生一个可以被其它 observer 使用的**值**，请使用 `@computed`，如果你不想产生一个新值，而想要达到一个**效果**，请使用 `autorun`。
举例来说，效果是像打印日志、发起网络请求等这样命令式的副作用。

如果任何影响计算值的值发生变化了，计算值将根据状态自动进行衍生。
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

要不使用 `decorate` 来引入:

```javascript
import {decorate, observable, computed} from "mobx";

class OrderLine {
    price = 0;
    amount = 1;
    constructor(price) {
        this.price = price;
    }

    get total() {
        return this.price * this.amount;
    }
}
decorate(OrderLine, {
    price: observable,
    amount: observable,
    total: computed
})
```

`observable.object` 和 `extendObservable` 都会自动将 getter 属性推导成计算属性，所以下面这样就足够了:

```javascript
const orderLine = observable.object({
    price: 0,
    amount: 1,
    get total() {
        return this.price * this.amount
    }
})
```

## 计算值的 setter

还可以为计算值定义 setter。注意这些 setters 不能用来直接改变计算属性的值，但是它们可以用来作“逆向”衍生。例如:

```javascript
const orderLine = observable.object({
    price: 0,
    amount: 1,
    get total() {
        return this.price * this.amount
    },
    set total(total) {
        this.price = total / this.amount // 从 total 中推导出 price
    }
})
```

同样的

```javascript
class Foo {
    @observable length = 2;
    @computed get squared() {
        return this.length * this.length;
    }
    set squared(value) { // 这是一个自动的动作，不需要注解
        this.length = Math.sqrt(value);
    }
}
```

_注意: 永远在 getter **之后** 定义 setter，一些 TypeScript 版本会知道声明了两个具有相同名称的属性。_

## `computed(expression)` 函数

`computed` 还可以直接当做函数来调用。
就像 `observable.box(primitive value)` 创建一个独立的 observable。
在返回的对象上使用 `.get()` 来获取计算的当前值，或者使用 `.observe(callback)` 来观察值的改变。
这种形式的 `computed` 不常使用，但在某些情况下，你需要传递一个“在box中”的计算值时，它可能是有用的。

示例:

```javascript
import {observable, computed} from "mobx";
var name = observable.box("John");

var upperCaseName = computed(() =>
	name.get().toUpperCase()
);

var disposer = upperCaseName.observe(change => console.log(change.newValue));

name.set("Dave");
// 输出: 'DAVE'
```
## `computed` 的选项

当使用 `computed` 作为调节器或者盒子，它接收的第二个选项参数对象，选项参数对象有如下可选参数:

* `name`: 字符串, 在 spy 和 MobX 开发者工具中使用的调试名称
* `context`: 在提供的表达式中使用的 `this`
* `set`: 要使用的setter函数。 没有 setter 的话无法为计算值分配新值。 如果传递给 `computed` 的第二个参数是一个函数，那么就把会这个函数作为 setter
* `equals`: 默认值是 `comparer.default` 。它充当比较前一个值和后一个值的比较函数。如果这个函数认为前一个值和后一个值是相等的，那么观察者就不会重新评估。这在使用结构数据和来自其他库的类型时很有用。例如，一个 computed 的 [moment](https://momentjs.com/) 实例可以使用 `(a, b) => a.isSame(b)` 。如果想要使用结构比较来确定新的值是否与上个值不同 (并作为结果通知观察者)，`comparer.deep` 十分便利。
* `requiresReaction`: 对于非常昂贵的计算值，推荐设置成 `true` 。如果你尝试读取它的值，但某些观察者没有跟踪该值（在这种情况下，MobX 不会缓存该值），则会导致计算结果丢失，而不是进行昂贵的重新评估。
* `keepAlive`: 如果没有任何人观察到，则不要使用此计算值。 _请注意，这很容易导致内存泄漏，因为它会导致此计算值使用的每个 observable ，并将计算值保存在内存中！_

## `@computed.struct` 用于比较结构

`@computed` 装饰器不需要接收参数。如果你想创建一个能进行结构比较的计算属性时，请使用 `@computed.struct`。

## 内置比较器

MobX 提供了三个内置 `comparer` (比较器) ，它们应该能满足绝大部分需求：
- `comparer.identity`: 使用恒等 (`===`) 运算符来判定两个值是否相同。
- `comparer.default`: 等同于 `comparer.identity`，但还认为 `NaN` 等于 `NaN` 。
- `comparer.structural`: 执行深层结构比较以确定两个值是否相同。

## 错误处理

如果计算值在其计算期间抛出异常，则此异常将捕获并在读取其值时重新抛出。
强烈建议始终抛出“错误”，以便保留原始堆栈跟踪。 例如：`throw new Error（“Uhoh”）`, 而不是`throw "Uhoh"`。
抛出异常不会中断跟踪，所有计算值可以从异常中恢复。

示例:

```javascript
const x = observable.box(3)
const y = observable.box(1)
const divided = computed(() => {
    if (y.get() === 0)
        throw new Error("Division by zero")
    return x.get() / y.get()
})

divided.get() // 返回 3

y.set(0) // OK
divided.get() // 报错: Division by zero
divided.get() // 报错: Division by zero

y.set(2)
divided.get() // 已恢复; 返回 1.5
```
