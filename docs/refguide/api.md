# MobX API参考

Applies to MobX 3 and higher. For MobX 2, the old documentation is still available on [github](https://github.com/mobxjs/mobx/blob/7c9e7c86e0c6ead141bb0539d33143d0e1f576dd/docs/refguide/api.md).
适用于 MobX 3或者更高版本。对于 MobX 2，旧文档依然可以在[github](https://github.com/mobxjs/mobx/blob/7c9e7c86e0c6ead141bb0539d33143d0e1f576dd/docs/refguide/api.md)找到。

# 核心API

_MobX 最重要的API。理解了`observable`、 `computed`、 `reactions` 和 `actions`的话，对于精通 MobX 已经足够了并能在应用中使用它！_

## 创建 observables


### `observable(value)`
用法:
* `observable(value)`
* `@observable classProperty = value`

Observable 值可以是JS基本数据类型、引用类型、普通对象、类实例、数组和映射。
`observable(value)` 是一个方便的重载，总是试图创建最佳匹配的 observable 类型。
还可以直接创建所需的 observable 类型，请参见下文。

匹配类型应用了以下转换规则，但可以通过使用**调节器**进行微调。请参见下文。

1. 如果 **value** 是[ES6 Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)的实例: 会返回一个新的 [Observable Map](map.md)。如果你不想只对一个特定项的更改做出反应，而是对添加或删除该项做出反应的话，那么 Observable map 会非常有用。
1. 如果 **value** 是数组，会返回一个 [Observable Array](array.md)。
1. 如果 **value** 是没有原型的对象，那么对象会被克隆并且所有的属性都会被转换成可观察的。参见 [Observable Object](object.md)。
1. 如果 **value** 是有原型的对象，JavaSript原始数据类型或者函数，会返回一个 [Boxed Observable](boxed.md)。MobX 不会将一个有原型的对象自动转换成可观察的，因为这是它构造函数的职责。在构造函数中使用 `extendObservable` 或者在类定义中使用 `@observable`。

乍看之下，这些规则可能看上去很复杂，但实际上实践当中你会发现他们是非常直观的。

一些便笺:
* 要创建键是动态的对象时永远都使用 maps！该对象只有初始化时便存在的属性会转换成可观察的，但新添加的属性只有通过使用 `extendObservable` 才可以转换成可观察的。
* 要想使用 `@observable` 装饰器，首先要确保 在你的编译器(babel 或者 typescript)中 [装饰器是启用的](http://mobxjs.github.io/mobx/refguide/observable-decorator.html)。
* 默认情况下将一个数据结构转换成可观察的是**有感染性的**，这意味着 `observable` 被自动应用于数据结构包含的任何值，或者将来会被该数据结构包含的值。这个行为可以通过使用 *modifiers* 或 *shallow* 来更改。

[&laquo;`observable`&raquo;](observable.md)  &mdash;  [&laquo;`@observable`&raquo;](observable-decorator.md)

### `@observable property =  value`

`observable` 也可以用作属性装饰器。它需要[启用装饰器](../best/decorators.md)而且它是 `extendObservable(this, { property: value })` 的语法糖。

[&laquo;`详情`&raquo;](observable-decorator.md)

### `observable.box(value)` & `observable.shallowBox(value)`

创建一个 observable 的盒子，它用来存储值的 observable 引用。使用 `get()` 方法可以得到盒子中的当前值，而使用 `set()` 方法可以更新值。
这是所有其它 observable 创建的基础，但实际中你其实很少能使用到它。
通常盒子会自动地尝试把任何还不是 observable 的新值转换成 observable 。使用 `shallowBox` 会禁用这项行为。

[&laquo;`详情`&raquo;](boxed.md)

### `observable.object(value)` & `observable.shallowObject(value)`

为提供的对象创建一个克隆并将其所有的属性转换成 observable 。
默认情况下这些属性中的任何值都会转换成 observable，但当使用 `shallowObject` 时只有属性会转换成 observable 引用，而值不会改变(这也适用于将来分配的任何值)。

[&laquo;`详情`&raquo;](object.md)

### `observable.array(value)` & `observable.shallowArray(value)`

Creates a new observable array based on the provided value. Use `shallowArray` if the values in the array should not be turned into observables.
基于提供的值来创建一个新的 observable 数组。如果不想数组中的值转换成 observable 请使用 `shallowArray`。

[&laquo;`详情`&raquo;](array.md)

### `observable.map(value)` & `observable.shallowMap(value)`

基于提供的值来创建一个新的 observable 映射。如果不想数组中的值转换成 observable 请使用 `shallowMap`。
当想创建动态的键集合并且需要能观察到键的添加和移除时，请使用 `map`。
注意只支持字符串键。

[&laquo;`详情`&raquo;](map.md)

### `extendObservable` & `extendShallowObservable`
用法: `extendObservable(target, ...propertyMaps)`。对于 `propertyMap` 中的每个键值对，都会作为一个(新)的 observable 属性引入到 target 对象中。
还可以在构造函数中使用来引入 observable 属性，这样就不需要用装饰器了。
如果 `propertyMap` 的某个值是一个 getter 函数，那么会引入一个**计算的**属性。

如果新的属性不应该具备感染性(即新分配的值不应该自动地转换成 observable)的话，请使用 `extendShallowObservable`。
注意 `extendObservable` 增强了现有的对象，不像 `observable.object` 是创建一个新对象。

[&laquo;详情&raquo;](extend-observable.md)

### 调节器

调节器可以作为装饰器或者组合 `extendObservable` 和 `observable.object` 使用，以改变特定属性的自动转换规则。

可用的调节器列表:

* `observable.deep`: 任何 observable 都使用的默认的调节器。它把任何分配的、非原始数据类型的、非 observable 的值转换成 observable。
* `observable.ref`: 禁用自动的 observable 转换，只是创建一个 observable 引用。
* `observable.shallow`: 只能与集合组合使用。 将任何分配的集合转换为浅 observable (而不是深 observable)的集合。 换一种说法; 集合中的值将不会自动变为 observable。
* `computed`: 创建一个推导属性, 参见 [`computed`](computed-decorator.md)
* `action`: 创建一个动作, 参见 [`action`](action.md)

调节器可以作为装饰器使用:

```javascript
class TaskStore {
    @observable.shallow tasks = []
}
```

或者作为属性调节器组合 `observable.object` / `observable.extendObservable` 使用。
注意，调节器总是“附着”在属性上的。 因此，即使分配了新值，它们仍将保持有效。

```javascript
const taskStore = observable({
    tasks: observable.shallow([])
})
```

[&laquo;详情&raquo;](modifiers.md)


## Computed values(计算值)

用法:
* `computed(() => expression)`
* `computed(() => expression, (newValue) => void)`
* `computed(() => expression, options)`
* `@computed get classProperty() { return expression; }`
* `@computed.struct get classProperty() { return expression; }`

创建计算值，`expression` 不应该有任何副作用而只是返回一个值。
如果任何 `expression` 中使用的 observable 发生改变，它都会自动地重新计算，但前提是计算值被某些 **reaction** 使用了。

[&laquo;详情&raquo;](computed-decorator.md)

## Actions(动作)

任何应用都有动作。动作是任何用来修改状态的东西。

使用MobX你可以在代码中显示的标记出动作所在的位置。
动作可以有助于更好的组织代码。
建议在任何更改 observable 或者有副作用的函数上使用动作。
结合开发者工具的话，动作还能提供非常有用的调试信息。
注意: 当启用**严格模式**时，需要强制使用 `action`，参见 `useStrict`。

[&laquo;详情&raquo;](action.md)

Usage:
* `action(fn)`
* `action(name, fn)`
* `@action classMethod`
* `@action(name) classMethod`
* `@action boundClassMethod = (args) => { body }`
* `@action(name) boundClassMethod = (args) => { body }`

对于一次性动作，可以使用 `runInAction(name?, fn, scope?)` , 它是 `action(name, fn, scope)()` 的语法糖.

## Reactions(反应) & Derivations(推导)

**计算值** 是自动响应状态变化的**值**。
**反应*** 是自动响应状态变化的**副作用**。
反应可以确保当相关状态发生变化时指定的副作用(主要是 I/O)可以自动地执行，比如打印日志、网络请求、等等。
使用反应最常见的场景是 React 组件的 `observer` 装饰器(参见下文)。

### `observer`
可以用作包裹 React 组件的高阶组件。
组件的 `render` 函数中的任何已使用的 observable 发生变化时，组件都会自动重新渲染。
注意 `observer` 是由 `"mobx-react"` 包提供的，而不是 `mobx` 本身。
[&laquo;详情&raquo;](observer-component.md)

用法:
* `observer(React.createClass({ ... }))`
* `observer((props, context) => ReactElement)`
* `observer(class MyComponent extends React.Component { ... })`
* `@observer class MyComponent extends React.Component { ... })`


### `autorun`
用法：`autorun(debugname?, () => { sideEffect })`。`autorun` 负责运行所提供的 `sideEffect` 并追踪在副作用运行期间访问哪个 observable 状态。
后面当其中一个已使用的 observable 发生变化了，同样的副作用会再运行一遍。
`autorun` 返回一个清理函数用来取消副作用。[&laquo;详情&raquo;](autorun.md)

### `when`
用法: `when(debugname?, () => condition, () => { sideEffect })`。
`condition` 表达式会自动响应任何它所使用的 observable。
一旦表但是返回的是真值，副作用函数便会立即调用，但只会调用一次。
`when` 返回一个清理函数用来提早取消这一切。[&laquo;详情&raquo;](when.md)

### `autorunAsync`
用法: `autorunAsync(debugname?, () => { sideEffect }, delay)`。类似于 `autorun`，但是副作用会有延迟而且根据给定的 `delay` 来进行函数去抖(debounce)。
[&laquo;详情&raquo;](autorun-async.md)

### `reaction`
用法: `reaction(debugname?, () => data, data => { sideEffect }, fireImmediately = false, delay = 0)`.
`reaction` 是 `autorun` 的变种，在如何追踪 observable 方面给予了更细粒度的控制。
它接收两个函数，第一个是追踪并返回数据，该数据用作第二个函数，也就是副作用的输入。
与 'autorun' 不同的是副作用起初不会运行，并且在执行副作用时访问的任何 observable 都不会被追踪。
和 `autorunAsync` 一样，副作用是可以进行函数去抖的。[&laquo;详情&raquo;](reaction.md)

### `expr`
用法: `expr(() => someExpression)`。`computed(() => someExpression).get()` 的简写形式。
`expr` 在一些极少数场景下用来优化另一个计算值函数或者 reaction 是有用的。
通常情况是将函数拆分成一些更小的计算值函数来达到同样的效果，这样做更简单，也更合理。
[&laquo;详情&raquo;](expr.md)

### `onReactionError`

用法: `extras.onReactionError(handler: (error: any, derivation) => void)`

此方法附加一个全局错误监听器，对于从 _reaction_ 抛出的每个错误都调用该错误监听器。
它可以用来监控或者测试。

------

# 实用工具

_有一些工具函数可以使得 observable 或者  计算值用起来更方便。
更多实用工具可以在 [mobx-utils](https://github.com/mobxjs/mobx-utils) 包中找到。_

### `Provider` (`mobx-react` 包)

可以用来使用 React 的上下文机制来传递 store 给子组件。参见[`mobx-react` 文档](https://github.com/mobxjs/mobx-react#provider-experimental)。

### `inject` (`mobx-react` 包)

高阶组件和 `Provider` 的对应物。可以用来从 React 的上下文中挑选 store 作为 prop 传递给目标组件。用法:
* `inject("store1", "store2")(observer(MyComponent))`
* `@inject("store1", "store2") @observer MyComponent`
* `@inject((stores, props, context) => props) @observer MyComponent`
* `@observer(["store1", "store2"]) MyComponent` is a shorthand for the the `@inject() @observer` combo.

### `toJS`
用法: `toJS(observableDataStructure)`。把 observable 数据结构转换成普通的 javascript 对象并忽略计算值。 [&laquo;详情&raquo;](tojson.md)

### `isObservable`
用法: `isObservable(thing, property?)`。如果给定的thing，或者thing指定的属性是 observable 的话返回true。
适用于所有的 observable、计算值和 reaction 的清理函数。[&laquo;详情&raquo;](is-observable)

### `isObservableObject|Array|Map`
用法: `isObservableObject(thing)`, `isObservableArray(thing)`, `isObservableMap(thing)`. 如果类型匹配的话返回true。

### `isArrayLike`
用法: `isArrayLike(thing)`。如果给定的thing是 javascript 数组或者 observable (MobX的)数组的话，返回true。
这是为了方便和简写。
注意，observable 数组可以通过 `.slice()` 转变成 javascript 数组。

### `isAction`
用法: `isAction(func)`。如果给定函数是用`action` 方法包裹的或者是 `@action` 装饰器的话，返回true。

### `isComputed`
用法: `isComputed(thing, property?)`。如果给定的thing是计算值或者thing指定的属性是计算值的话，返回true。

### `createTransformer`
用法: `createTransformer(transformation: A => B, onCleanup?): A = B`。
可以用来使函数将一个值转换为另一个可以反应和记忆的值。
它的行为类似于计算值，可以用于一些高级模式，比如非常高效的数组映射，映射归并或者不是对象的一部分的计算值。
[&laquo;详情&raquo;](create-transformer.md)

### `intercept`
用法: `intercept(object, property?, interceptor)`.
这个API可以在应用 observable 的API之前，拦截更改。对于验证、标准化和取消十分有用。
[&laquo;详情&raquo;](observe.md)

### `observe`
用法: `observe(object, property?, listener, fireImmediately = false)`
这个一个底层API，用来观察一个单个的 observable 值。
[&laquo;详情&raquo;](observe.md)

### `useStrict`
用法: `useStrict(boolean)`。
**全局性** 地启用/禁用严格模式。
在严格模式下，不允许在 [`action`](action.md) 外更改任何状态。
还可以参见 `extras.allowStateChanges`。



# 开发工具

_如果你想在 MobX 的上层构建很酷的工具或如果你想检查 MobX 的内部状态，下列API可能会派上用场。_

### `"mobx-react-devtools"` 包
mobx-react-devtools 是个功能强大的包，它帮助你调查 React 组件的性能和依赖。
还有基于 `spy` 的强大的日志功能。[&laquo;详情&raquo;](../best/devtools.md)

### `spy`
用法: `spy(listener)`.
注册全局侦查监听器可以监听所有 MobX 中发生的时间。
它类似于将一个 `observe` 监听器一次性附加到**所有的** observables 上，而且还负责正在运行的动作和计算的通知。
用于 `mobx-react-devtools` 的示例。
[&laquo;详情&raquo;](spy.md)

### `whyRun`
用法:
* `whyRun()`
* `whyRun(Reaction object / ComputedValue object / disposer function)`
* `whyRun(object, "computed property name")`

`whyRun` 是个可以在计算值或 reaction(`autorun`、 `reaction` 或 使用了 `observer` 的 React 组件的 `render` 方法)中使用的小功能，它还可以打印出 derivation 正在运行的原因和在哪种情况下它会再次运行。
这应该有助于更深入地了解 MobX 运作的时机和原因，并防止一些初学者的错误。


### `extras.getAtom`
用法: `getAtom(thing, property?)`.
返回给定的 observable 对象、属性、reaction 等的背后的原子。

### `extras.getDebugName`
Usage: `getDebugName(thing, property?)`
Returns a (generated) friendly debug name of an observable object, property, reaction etc. Used by for example the `mobx-react-devtools`.

### `extras.getDependencyTree`
Usage: `getDependencyTree(thing, property?)`.
Returns a tree structure with all observables the given reaction / computation currently depends upon.

### `extras.getObserverTree`
Usage: `getObserverTree(thing, property?)`.
Returns a tree structure with all reactions / computations that are observing the given observable.

### `extras.isSpyEnabled`
Usage: `isSpyEnabled()`. Returns true if at least one spy is active

### `extras.spyReport`
Usage: `spyReport({ type: "your type", &laquo;details&raquo; data})`. Emit your own custom spy event.

### `extras.spyReportStart`
Usage: `spyReportStart({ type: "your type", &laquo;details&raquo; data})`. Emit your own custom spy event. Will start a new nested spy event group which should be closed using `spyReportEnd()`

### `extras.spyReportEnd`
Usage: `spyReportEnd()`. Ends the current spy group that was started with `extras.spyReportStart`.

### `"mobx-react"` development hooks
The `mobx-react` package exposes the following additional api's that are used by the `mobx-react-devtools`:
* `trackComponents()`: enables the tracking of `observer` based React components
* `renderReporter.on(callback)`: callback will be invoked on each rendering of an `observer` enabled React component, with timing information etc
* `componentByNodeRegistery`: ES6 WeakMap that maps from DOMNode to a `observer` based React component instance

# Internal functions

_The following methods are all used internally by MobX, and might come in handy in rare cases. But usually MobX offers more declarative alternatives to tackle the same problem. They might come in handy though if you try to extend MobX_

### `transaction`
Usage: `transaction(() => { block })`.
Deprecated, use actions or `runInAction` instead.
Low-level api that can be used to batch state changes.
State changes made inside the block won't cause any computations or reactions to run until the end of the block is reached.
Nonetheless inspecting a computed value inside a transaction block will still return a consistent value.
It is recommended to use `action` instead, which uses `transaction` internally.
[&laquo;details&raquo;](transaction.md)

### `untracked`
Usage: `untracked(() => { block })`.
Low-level api that might be useful inside reactions and computations.
Any observables accessed in the `block` won't cause the reaction / compuations to be recomputed automatically.
However it is recommended to use `action` instead, which uses `untracked` internally.
[&laquo;details&raquo;](untracked.md)

### `Atom`
Utility class that can be used to create your own observable data structures and hook them up to MobX.
Used internally by all observable data types.
[&laquo;details&raquo;](extending.md)

### `Reaction`
Utility class that can be used to create your own reactions and hook them up to MobX.
Used internally by `autorun`, `reaction` (function) etc.
[&laquo;details&raquo;](extending.md)

### `extras.allowStateChanges`
Usage: `allowStateChanges(allowStateChanges, () => { block })`.
Can be used to (dis)allow state changes in a certain function.
Used internally by `action` to allow changes, and by `computed` and `observer` to disallow state changes.

### `extras.resetGlobalState`
Usage: `resetGlobalState()`.
Resets MobX internal global state. MobX by defaults fails fast if an exception occurs inside a computation or reaction and refuses to run them again.
This function resets MobX to the zero state. Existing `spy` listeners and the current value of strictMode will be preserved though.
