# MobX API参考

**适用于 MobX 4或者更高版本。**

- 使用的是 MobX 3 ？参考本[迁移指南](https://github.com/mobxjs/mobx/wiki/Migrating-from-mobx-3-to-mobx-4)来进行升级。
- [MobX 3 文档](https://github.com/mobxjs/mobx/blob/54557dc319b04e92e31cb87427bef194ec1c549c/docs/refguide/api.md)
- 对于 MobX 2，旧文档依然可以在 [github](https://github.com/mobxjs/mobx/blob/7c9e7c86e0c6ead141bb0539d33143d0e1f576dd/docs/refguide/api.md) 找到。

# 核心API

**这里都是 MobX 中最重要的 API 。**

> 理解了`observable`、 `computed`、 `reactions` 和 `actions`的话，说明对于 Mobx 已经足够精通了,在你的应用中使用它吧！
## 创建 observables

### `observable(value)`
用法:
* `observable(value)`
* `@observable classProperty = value`

Observable 值可以是JS基本数据类型、引用类型、普通对象、类实例、数组和映射。

**注意:** `observable(value)` 是一个便捷的 API ，此 API 只有在它可以被制作成可观察的数据结构(数组、映射或 observable 对象)时才会成功。对于所有其他值，不会执行转换。

匹配类型应用了以下转换规则，但可以通过使用 [*装饰器*](#decorators) 进行微调。请参见下文。

1. 如果 **value** 是[ES6 Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)的实例: 会返回一个新的 [Observable Map](map.md)。如果你不只关注某个特定entry的更改，而且对添加或删除其他entry时也做出反应的话，那么 Observable map 会非常有用。
1. 如果 **value** 是数组，会返回一个 [Observable Array](array.md)。
1. 如果 **value** 是没有原型的对象或它的原型是 `Object.prototype`，那么对象会被克隆并且所有的属性都会被转换成可观察的。参见 [Observable Object](object.md)。
1. 如果 **value** 是有原型的对象，JavaScript 原始数据类型或者函数，值不会发生变化。如果你需要 [Boxed Observable](boxed.md)，你可以采用下列任意方式:
    - 显式地调用 `observable.box(value)`
    - 在类定义时使用 `@observable`
    - 调用 [`decorate()`](#decorate)
    - 在类中使用 `extendObservable()` 来引入属性

MobX 不会自动带有原型的对象转变成 observable，因为那是 observable 构造函数的职责。在构造函数中使用 `extendObservable` 或在类定义是使用 `@observable` 进行替代。

乍看之下，这些规则可能看上去很复杂，但实际上实践当中你会发现他们是非常直观的。

一些建议:

* 要想使用 `@observable` 装饰器，首先要确保 在你的编译器(babel 或者 typescript)中 [装饰器是启用的](http://mobxjs.github.io/mobx/refguide/observable-decorator.html)。
* 默认情况下将一个数据结构转换成可观察的是**有感染性的**，这意味着 `observable` 被自动应用于数据结构包含的任何值，或者将来会被该数据结构包含的值。这个行为可以通过使用 [*装饰器*](#decorators) 来更改。
* _[MobX 4 及以下版本]_ 要创建键是动态的对象时永远都使用 maps！对象上只有初始化时便存在的属性会转换成可观察的，尽管新添加的属性可以通过使用 `extendObservable` 转换成可观察的。

[&laquo;`observable`&raquo;](observable.md)  &mdash;  [&laquo;`@observable`&raquo;](observable-decorator.md)

### `@observable property =  value`

`observable` 也可以用作属性的装饰器。它需要[启用装饰器](../best/decorators.md)而且它是 `extendObservable(this, { property: value })` 的语法糖。

[&laquo;`详情`&raquo;](observable-decorator.md)

### `observable.box(value, options?)`

创建一个 observable 的盒子，它用来存储value的 observable 引用。使用 `get()` 方法可以得到盒子中的当前value，而使用 `set()` 方法可以更新value。
这是所有其它 observable 创建的基础，但实际中你其实很少能使用到它。

通常盒子会自动地尝试把任何还不是 observable 的新值转换成 observable 。使用 `{deep: false}` 选项会禁用这项行为。

[&laquo;`详情`&raquo;](boxed.md)

### `observable.object(value, decorators?, options?)`

为提供的对象创建一个克隆并将其所有的属性转换成 observable 。
默认情况下这些属性中的任何值都会转换成 observable，但当使用 `{deep: false}` 选项时只有属性会转换成 observable 引用，而值不会改变(这也适用于将来分配的任何值)。

`observable.object()` 的第二个参数可以很好地调整 [装饰器](#decorators) 的可观察性。

[&laquo;`详情`&raquo;](object.md)

### `observable.array(value, options?)`

基于提供的值来创建一个新的 observable 数组。

如果不想数组中的值转换成 observable 请使用 `{deep: false}` 选项。

[&laquo;`详情`&raquo;](array.md)

### `observable.map(value, options?)`

基于提供的值来创建一个新的 observable 映射。如果不想映射中的值转换成 observable 请使用 `{deep: false}` 选项。
当想创建动态的键集合并且需要能观察到键的添加和移除时，请使用 `map`。
因为内部使用了成熟的 _ES6 Map_ ，你可以自由使用任何键而**无需局限**于字符串。

[&laquo;`详情`&raquo;](map.md)

### `extendObservable`

用法: `extendObservable(target, properties, decorators?, options?)`

对于 `propertyMap` 中的每个键值对，都会作为一个(新)的 observable 属性引入到 target 对象中。
还可以在构造函数中使用来引入 observable 属性，这样就不需要用装饰器了。
如果 `propertyMap` 的某个值是一个 getter 函数，那么会引入一个**computed**属性。

如果新的属性不应该具备感染性(即新分配的值不应该自动地转换成 observable)的话，请使用 `extendObservable(target, props, decorators?, {deep: false})` 。
注意 `extendObservable` 增强了现有的对象，不像 `observable.object` 是创建一个新对象。

[&laquo;详情&raquo;](extend-observable.md)

### 装饰器(Decorators)

使用装饰器可以很好地调节通过 `observable`、 `extendObservable` 和 `observable.object` 定义的属性的可观察性。它们还可以控制特定属性的自动转换规则。

可用的装饰器列表:

* **`observable.deep`**: 所有  observable 都使用的默认的装饰器。它可以把任何指定的、非原始数据类型的、非 observable 的值转换成 observable。
* **`observable.ref`**: 禁用自动的 observable 转换，只是创建一个 observable 引用。
* **`observable.shallow`**: 只能与集合组合使用。 将任何分配的集合转换为浅 observable (而不是深 observable)的集合。 换句话说, 集合中的值将不会自动变为 observable。
* **`computed`**: 创建一个衍生属性, 参见 [`computed`](computed-decorator.md)
* **`action`**: 创建一个动作, 参见 [`action`](action.md)
* **`action.bound`**: 创建有范围的动作, 参见 [`action`](action.md)

可以使用 _@decorator_ 语法来应用这些装饰器:

```javascript
import {observable, action} from 'mobx';

class TaskStore {
    @observable.shallow tasks = []
    @action addTask(task) { /* ... */ }
}
```

或者通过 `observable.object` / `observable.extendObservable` 或 [`decorate()`](#decorate) 传入属性装饰器。
注意，装饰器总是“附着”在属性上的。 因此，即使分配了新值，它们仍将保持有效。

```javascript
import {observable, action} from 'mobx';

const taskStore = observable({
    tasks: [],
    addTask(task) { /* ... */ }
}, {
    tasks: observable.shallow,
    addTask: action
})
```

[&laquo;详情&raquo;](modifiers.md)

### `decorate`

用法: `decorate(object, decorators)`

这是将可观察性[装饰器]((#decorators))应用于普通对象或类实例的简便方法。第二个参数是一个属性设置为某些装饰器的对象。

当无法使用 _@decorator_ 语法或需要对可观察性进行更细粒度的控制时使用这个方法。

```js
class TodoList {
    todos = {}
    get unfinishedTodoCount() {
        return values(this.todos).filter(todo => !todo.finished).length
    }
    addTodo() {
        const t = new Todo()
        t.title = 'Test_' + Math.random()
        set(this.todos, t.id, t)
    }
}

decorate(TodoList, {
    todos: observable,
    unfinishedTodoCount: computed,
    addTodo: action.bound
})
```

想要在单个属性上应用多个装饰器的话，你可以传入一个装饰器数组。多个装饰器应用的顺序是从从右至左。

```javascript
import { decorate, observable } from 'mobx'
import { serializable, primitive } from 'serializr'
import persist from 'mobx-persist'

class Todo {
    id = Math.random();
    title = '';
    finished = false;
}

decorate(Todo, {
    title: [serializable(primitive), persist('object'), observable],
    finished: [serializable(primitive), observable]
})
```

注意: 并非所有的装饰器都可以在一起组合，此功能只会尽力而为。一些装饰器会直接影响实例，并且可以“隐藏”其他那些只更改原型的装饰器的效果。

## Computed values(计算值)

用法:
* `computed(() => expression)`
* `computed(() => expression, (newValue) => void)`
* `computed(() => expression, options)`
* `@computed({equals: compareFn}) get classProperty() { return expression; }`
* `@computed get classProperty() { return expression; }`

创建计算值，`expression` 不应该有任何副作用而只是返回一个值。
如果任何 `expression` 中使用的 observable 发生改变，它都会自动地重新计算，但前提是计算值被某些 **reaction** 使用了。

还有各种选项可以控制 `computed` 的行为。包括:

* **`equals: (value, value) => boolean`** 用来重载默认检测规则的比较函数。 内置比较器有: `comparer.identity`, `comparer.default`, `comparer.structural`
* **`requiresReaction: boolean`** 在重新计算衍生属性之前，等待追踪的 observables 值发生变化
* **`get: () => value)`** 重载计算属性的 getter
* **`set: (value) => void`** 重载计算属性的 setter
* **`keepAlive: boolean`** 设置为 true 以自动保持计算值活动，而不是在没有观察者时暂停。

[&laquo;详情&raquo;](computed-decorator.md)

## Actions(动作)

任何应用都有动作。动作是任何用来修改状态的东西。

使用MobX你可以在代码中显式地标记出动作所在的位置。
动作可以有助于更好的组织代码。
建议在任何更改 observable 或者有副作用的函数上使用动作。
结合开发者工具的话，动作还能提供非常有用的调试信息。
注意: 当启用**严格模式**时，需要强制使用 `action`，参见 `enforceActions`。

[&laquo;详情&raquo;](action.md)

用法:
* `action(fn)`
* `action(name, fn)`
* `@action classMethod`
* `@action(name) classMethod`
* `@action boundClassMethod = (args) => { body }`
* `@action.bound boundClassMethod(args) { body }`

对于一次性动作，可以使用 `runInAction(name?, fn)` , 它是 `action(name, fn)()` 的语法糖.

### Flow

用法: `flow(function* (args) { })`

`flow()` 接收 generator 函数作为它唯一的输入

当处理**异步动作**时，回调中执行的代码不会被 `action` 包装。这意味着你修改的 observable state 无法通过 [`enforceActions`](#configure) 检查。保留动作语义的简单方法是使用 flow 来包装异步函数。这将确保所有回调都会被 `action()` 包装。

注意，异步函数必须是 _generator_ ，而且在内部只能 _yield_ promises 。`flow` 会返回一个 promise ，需要的话可以使用 `cancel()` 进行撤销。

```js
import { configure } from 'mobx';

// 不允许在动作外部修改状态
configure({ enforceActions: true });

class Store {
    @observable githubProjects = [];
    @observable state = "pending"; // "pending" / "done" / "error"


    fetchProjects = flow(function* fetchProjects() { // <- 注意*号，这是生成器函数！
        this.githubProjects = [];
        this.state = "pending";
        try {
            const projects = yield fetchGithubProjectsSomehow(); // 用 yield 代替 await
            const filteredProjects = somePreprocessing(projects);

            // 异步代码自动会被 `action` 包装
            this.state = "done";
            this.githubProjects = filteredProjects;
        } catch (error) {
            this.state = "error";
        }
    })
}
```

_提示: 推荐为 generator 函数起个名称，此名称将出现在开发工具中_

**Flows 可以撤销**

Flows 是可以取消的，这意味着调用返回的 promise 的 `cancel()` 方法。这会立即停止 generator ，但是 `finally` 子句仍会被处理。
返回的 promise 本身会使用 `FLOW_CANCELLED` 进行 reject 。

**Flows 支持异步迭代器**

Flows 支持异步迭代器，这意味着可以使用异步 generators :

```javascript
async function* someNumbers() {
    yield Promise.resolve(1)
    yield Promise.resolve(2)
    yield Promise.resolve(3)
}

const count = mobx.flow(async function*() {
    // 使用 await 来循环异步迭代器
    for await (const number of someNumbers()) {
        total += number
    }
    return total
})

const res = await count() // 6
```

## Reactions(反应) & Derivations(衍生)

**计算值** 是自动响应状态变化的**值**。
**反应** 是自动响应状态变化的**副作用**。
反应可以确保当相关状态发生变化时指定的副作用(主要是 I/O)可以自动地执行，比如打印日志、网络请求、等等。
使用反应最常见的场景是 React 组件的 `observer` 装饰器(参见下文)。

### `observer`

可以用作包裹 React 组件的高阶组件。
在组件的 `render` 函数中的任何已使用的 observable 发生变化时，组件都会自动重新渲染。
注意 `observer` 是由 `"mobx-react"` 包提供的，而不是 `mobx` 本身。

[&laquo;详情&raquo;](observer-component.md)

用法:
* `observer(React.createClass({ ... }))`
* `observer((props, context) => ReactElement)`
* `observer(class MyComponent extends React.Component { ... })`
* `@observer class MyComponent extends React.Component { ... }`

### `autorun`

用法：`autorun(() => { sideEffect }, options)` 。`autorun` 负责运行所提供的 `sideEffect` 并追踪在`sideEffect`运行期间访问过的 `observable` 的状态。
将来如果有其中一个已使用的 observable 发生变化，同样的`sideEffect`会再运行一遍。
`autorun` 返回一个清理函数用来取消副作用。

[&laquo;详情&raquo;](autorun.md)

**选项**
- **`name?: string`**: 用于识别和调试的名称
- **`delay?: number`**: 使副作用延迟和防抖的时间。默认为 `0` 
- **`onError?: (error) => void`**: 如果 autorun 函数抛出异常，则触发错误处理函数
- **`scheduler?: (callback) => void`**: 设置自定义调度器以决定如何调度 autorun 函数的重新运行

### `when`

用法: `when(() => condition, () => { sideEffect }, options)` 。
`condition` 表达式会自动响应任何它所使用的 observable。
一旦表达式返回的是真值，副作用函数便会立即调用，但只会调用一次。

**注意:** _副作用函数_ (第二个参数) 其实是可选的。如果不提供副作用函数的话，将返回一个可取消的 promise (即具有 `cancle()` 方法的 promise)

`when` 返回清理器以尽早地取消操作。

如果没有给 `when` 传递副作用函数的话，它将返回一个可以等待条件结束的 promise 。

[&laquo;详情&raquo;](when.md).

**options**
- **`name?: string`**: 用于识别和调试的名称
- **`onError?: (error) => void`**: 如果 _断言函数_ 或 _副作用函数_ 函数抛出异常，则触发错误处理函数
- **`timeout: number`** 以毫秒为单位的延迟，之后将触发 `onError` 处理函数，以通知在指定时间内未满足条件

### `reaction`

用法: `reaction(() => data, data => { sideEffect }, options)`.
`reaction` 是 `autorun` 的变种，在如何追踪 observable 方面给予了更细粒度的控制。
它接收两个函数，第一个是追踪并返回数据，该数据用作第二个函数，也就是副作用的输入。
与 'autorun' 不同的是副作用起初不会运行，并且在执行副作用时访问的任何 observable 都不会被追踪。
和 `autorunAsync` 一样，副作用是可以进行函数去抖的。

[&laquo;详情&raquo;](reaction.md)

**options**
- **`fireImmediately?: boolean`**: 在触发 _副作用函数_ 之前等待变化。默认为 `false`
- **`delay?: number`**: 使副作用延迟和防抖的时间。默认为 `0` 
- **`equals`**. 自定义相等函数来确定 expr 函数是否与之前的结果不同，再决定是否触发副作用。接收与 `computed` 的 equals 选项相同的选项
- 还接收 [`autorun`](#autorun) 的所有选项

### `onReactionError`

用法: `onReactionError(handler: (error: any, derivation) => void)`

此方法附加一个全局错误监听器，对于从 _reaction_ 抛出的每个错误都会调用该错误监听器。
它可以用来监控或者测试。

------

# 实用工具

_有一些工具函数可以使得 observable 或者  计算值用起来更方便。
更多实用工具可以在 [mobx-utils](https://github.com/mobxjs/mobx-utils) 包中找到。_

### `Provider` (`mobx-react` 包)

可以用来使用 React 的`context`机制来传递 store 给子组件。参见[`mobx-react` 文档](https://github.com/mobxjs/mobx-react#provider-experimental)。

### `inject` (`mobx-react` 包)

 相当于`Provider` 的高阶组件。可以用来从 React 的`context`中挑选 store 作为 prop 传递给目标组件。用法:
* `inject("store1", "store2")(observer(MyComponent))`
* `@inject("store1", "store2") @observer MyComponent`
* `@inject((stores, props, context) => props) @observer MyComponent`
* `@observer(["store1", "store2"]) MyComponent` is a shorthand for the the `@inject() @observer` combo.

### `toJS`

用法: `toJS(observableDataStructure, options?)` 。把 observable 数据结构转换成普通的 javascript 对象并忽略计算值。 

`options` 包括:

- **`detectCycles: boolean`**: 检查 observalbe 数据结构中的循环引用。默认为 `true` 
- **`exportMapsAsObjects: boolean`**: 将 ES6 Map 作为普通对象导出。默认为 `true`

[&laquo;详情&raquo;](tojson.md).

### `isObservable` 和 `isObservableProp`

用法: `isObservable(thing)` 或 `isObservableProp(thing, property?)` 。如果给定的 thing，或者 thing 指定的 `property` 是 observable 的话，返回 true。
适用于所有的 observable、计算值和 reaction 的清理函数。

[&laquo;详情&raquo;](is-observable)

### `isObservableObject|Array|Map` 和 `isBoxedObservable`

用法: `isObservableObject(thing)`, `isObservableArray(thing)`, `isObservableMap(thing)`,  `isBoxedObservable(thing)`。 如果类型匹配的话返回true。

### `isArrayLike`

用法: `isArrayLike(thing)`。如果给定的 thing 是 javascript 数组或者 observable (MobX的)数组的话，返回 true。
这个方法更简便。
注意，observable 数组可以通过 `.slice()` 转变成 javascript 数组。

### `isAction`

用法: `isAction(func)`。如果给定函数是用 `action` 方法包裹的或者是用 `@action` 装饰的话，返回 true。

### `isComputed` 或 `isComputedProp`

用法: `isComputed(thing)` 或 `isComputedProp(thing, property?)` 。如果给定的 thing 是计算值或者 thing 指定的 `property` 是计算值的话，返回 true 。

### `intercept`

用法: `intercept(object, property?, interceptor)`.
这个 API 可以在应用 observable 的API之前，拦截更改。对于验证、标准化和取消等操作十分有用。

[&laquo;详情&raquo;](observe.md)

### `observe`

用法: `observe(object, property?, listener, fireImmediately = false)`
这是一个底层API，用来观察一个单个的 observable 值。

[&laquo;详情&raquo;](observe.md)

### `onBecomeObserved` 和 `onBecomeUnobserved`

用法: `onBecomeObserved(observable, property?, listener: () => void): (() => void)` 和
`onBecomeUnobserved(observable, property?, listener: () => void): (() => void)`
这些函数都是与 MobX 的观察体系挂钩的，当 observables _开始_ / _停止_ 被观察时会收到通知。它可以用来执行一些延迟操作或网络资源获取。

返回值为 _清理函数_，用来卸载 _监听器_ 。

```javascript

export class City {
    @observable location
    @observable temperature
    interval

    constructor(location) {
        this.location = location
        // 只有当 temperature 实际使用了才开始获取数据!
        onBecomeObserved(this, 'temperature', this.resume)
        onBecomeUnobserved(this, 'temperature', this.suspend)
    }

    resume = () => {
        log(`Resuming ${this.location}`)
        this.interval = setInterval(() => this.fetchTemperature(), 5000)
    }

    suspend = () => {
        log(`Suspending ${this.location}`)
        this.temperature = undefined
        clearInterval(this.interval)
    }

    @flow fetchTemperature = function*() {
        // 数据获取逻辑
    }
}
```

### `configure`

用法: `configure(options)` 。
对活动的 MobX 实例进行全局行为设置。
使用它来改变 MobX 的整体表现。

```javascript
import { configure } from "mobx";

configure({
    // ...
});
```

#### `arrayBuffer: number`

如果没有最大长度的话，则将可观察数组的默认创建长度增加至 `arrayBuffer` 。

可观察数组会在 `ObservableArray.prototype` 上惰性地创建数组项的 getters ，从第一项开始。
还会继续在数组中创建项，直到数组长度为 `arrayBuffer` (如果项不存在的话) 。
如果你清楚通用的最小数组长度，并且不想在主流程代码中创建这些 getters 的话，请使用 `arrayBuffer` 。
还可以参见 `observable` 。

#### `computedRequiresReaction: boolean`

禁止访问任何未观察的计算值。
如果想检查是否在没有响应式上下文中的使用计算属性的话，请使用它。

```javascript
configure({ computedRequiresReaction: true });
```

#### `disableErrorBoundaries: boolean`

默认情况下，MobX 会捕获并重新抛出代码中发生的异常，从而确保某个异常中的反应 (reaction) 不会阻止其他可能无关的反应的预定执行。这意味着异常不会传播到原始代码中，因此将无法使用 try/catch 来捕获它们。

有时你可能想要捕获这些错误，例如在单元测试反应时。此时可以使用 `disableErrorBoundaries` 来禁用此行为。

```javascript
configure({ disableErrorBoundaries: true });
```

请注意，使用此配置时，MobX 并不会回复错误。出于这个原因，你可能需要在每个异常之后使用 `_resetGlobalState` 。示例如下:

```js
configure({ disableErrorBoundaries: true })

test('Throw if age is negative', () => {
  expect(() => {
    const age = observable.box(10)
    autorun(() => { if (age.get() < 0) throw new Error('Age should not be negative') })
    age.set(-1)
  }).toThrow()
  _resetGlobalState() // 每个异常过后都需要
})
```

> 在 MobX 4 之前，`_resetGlobalState` 名为 `extras.resetGlobalState` 。

#### `enforceActions`

也被称为“严格模式”。

在严格模式下，不允许在 [`action`](action.md) 外更改任何状态。
可接收的值:

* `"never"` (默认): 可以在任意地方修改状态
* `"observed"`: 在某处观察到的所有状态都需要通过动作进行更改。在正式应用中推荐此严格模式。
* `"always"`: 状态始终需要通过动作来更新(实际上还包括创建)。

#### `isolateGlobalState: boolean`

当同一环境中有多个 MobX 实例时，将 MobX 的全局状态隔离。
当使用 MobX 的同时还使用了使用 MobX 的封装库时，这是非常有用的。
当在库中调用 `configure({isolateGlobalState：true})` 时，库内的响应性将保持独立。

使用此选项，如果多个 MobX 实例正在使用的话，内部状态是会共享的。优点就是两个实例的 observables 可以协同运行，缺点是 MobX 的版本必须匹配。

```javascript
configure({ isolateGlobalState: true });
```

#### `reactionScheduler: (f: () => void) => void`

设置一个新函数，用来执行所有 MobX 的反应 (reactions) 。
默认情况下，`reactionScheduler` 只会运行反应 `f` 而没有其他任何行为。
这对于基本的调试或者减慢反应以使用应用的更新更加可视化来说是非常有用的。

```javascript
configure({
    reactionScheduler: (f): void => {
        console.log("Running an event after a delay:", f);
        setTimeout(f, 100);
    }
});
```

## 直接操控 Observable

现在有一个统一的工具 API 可以操控 observable 映射、对象和数组。这些 API 都是响应式的，这意味着如果使用 `set` 进行添加，使用 `values` 或 `keys` 进行迭代，即便是新属性的声明都可以被 MobX 检测到。
  * **`values(thing)`** 将集合中的所有值作为数组返回
  * **`keys(thing)`** 将集合中的所有键作为数组返回
  * **`entries(thing)`** 返回集合中的所有项的键值对数组
  * **`set(thing, key, value)`** 或 **`set(thing, { key: value })`** 使用提供的键值对来更新给定的集合
  * **`remove(thing, key)`** 从集合中移除指定的项。用于数组拼接
  * **`has(thing, key)`** 如果集合中存在指定的 _observable_ 属性就返回 true

# 开发工具

_如果你想在 MobX 的上层构建一些很酷的工具或者想检查 MobX 的内部状态的话，下列API可能会派上用场。_

### `"mobx-react-devtools"` 包
mobx-react-devtools 是个功能强大的包，它帮助你调查 React 组件的性能和依赖。
还有基于 `spy` 的强大的日志功能。

[&laquo;详情&raquo;](../best/devtools.md)

### `trace`

用法:

* `trace(enterDebugger?)`
* `trace(Reaction object / ComputedValue object / disposer function, enterDebugger?)`
* `trace(object, computedValuePropertyName, enterDebugger?)`

`trace` 是一个可以在计算值或 reaction 中使用的小工具。
如果启用了它，那么当值被无效时，它将开始记录，以及为什么。
如果 `enterDebugger` 设置为 true ，并且启用开发者工具的话，JavaScript 引擎会在触发时在此进行断点调试。

[&laquo;trace&raquo;](../best/trace.md)

### `spy`

用法: `spy(listener)` 。
它类似于将一个 `observe` 监听器一次性附加到**所有的** observables 上，而且还负责正在运行的动作和计算的通知。
用于 `mobx-react-devtools` 。

[&laquo;详情&raquo;](spy.md)

### `getAtom`

用法: `getAtom(thing, property?)` 。
返回给定的 observable 对象、属性、reaction 等的背后作用的`Atom`。

### `getDebugName`

用法: `getDebugName(thing, property?)` 。
返回 observable 对象、属性、reaction等(生成的)易读的调试名称。用于 `mobx-react-devtools` 的示例。

### `getDependencyTree`

用法: `getDependencyTree(thing, property?)` 。
返回给定的 reaction / 计算 当前依赖的所有 observable 的树型结构。

### `getObserverTree`

用法: `getObserverTree(thing, property?)` 。
返回正在观察给定的 observable 的所有 reaction / 计算的树型结构。

### `"mobx-react"` 开发钩子
`mobx-react` 包提供了以下几个供 `mobx-react-devtools` 使用的附加API:
* `trackComponents()`: 启用追踪功能,追踪使用了`observer`的 React 组件
* `renderReporter.on(callback)`: 使用 `observer` 的 React 组件每次渲染都会调用callback，并附带相关的时间信息等等
* `componentByNodeRegistery`: 使用ES6 WeakMap 将 DOMNode 映射到使用 `observer` 的 React 组件实例

# 内部函数

_以下方法都在 MobX 内部使用，在极少数情况下可能会派上用场。 但是通常 MobX 提供了更多的声明性替代方法来解决同样的问题。如果你尝试扩展 MobX 的话，它们可能会派上用场。_

### `transaction`

_Transaction 是底层 API , 推荐使用 actions 来代替_

`transaction(worker: () => void)` 可以用来批量更新而不会通知任何观察者，直到事务结束。
`transaction` 接收一个无参的 `worker` 函数作为参数，并运行它。
到这个函数完成前都不会有任何观察者收到通知。
`transaction` 返回 `worker` 函数返回的任意值。
注意，`transaction` 的运行完全是同步的。
transactions 可以是嵌套的。只有当最外层的 `transaction` 完成后，等待中的 reactions 才会运行。

```javascript
import {observable, transaction, autorun} from "mobx";

const numbers = observable([]);

autorun(() => console.log(numbers.length, "numbers!"));
// 输出: '0 numbers!'

transaction(() => {
	transaction(() => {
		numbers.push(1);
		numbers.push(2);
	});
	numbers.push(3);
});
// 输出: '3 numbers!'
```

### `untracked`

untracked 允许你在没有观察者的情况下运行一段代码。
就像 `transaction` ，`untracked` 由 `(@)action` 自动应用，所以通常使用动作要比直接 `untracked` 有意义得多。
示例:

```javascript

const person = observable({
	firstName: "Michel",
	lastName: "Weststrate"
});

autorun(() => {
	console.log(
		person.lastName,
		",",
        // 这个 untracked 代码块会在没有建立依赖的情况下返回 person 的 firstName
		untracked(() => person.firstName)
	);
});
// 输出: Weststrate, Michel

person.firstName = "G.K.";
// 不输出！

person.lastName = "Chesterton";
// 输出: Chesterton, G.K.
```

### `createAtom`

实用程序类，可用于创建你自己的 observable 数据结构，并将它们连接到 MobX。
在所有 observable 数据类型的内部使用。

[&laquo;详情&raquo;](extending.md)
