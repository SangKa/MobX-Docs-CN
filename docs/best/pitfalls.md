# 常见陷阱与最佳实践

使用 MobX 遇到坑了？本章节涵盖了一些 MobX 新手可能会遭遇的一些常见问题。

#### 装饰器问题?

有关装饰器的设置提示和限制，请参见 [装饰器](decorators.md) 一节。

#### `Array.isArray(observable([1,2,3])) === false`

在 ES5 中没有继承数组的可靠方法，因此 observabl e数组继承自对象。
这意味着一般的库没有办法识别出 observable 数组就是普通数组(像 lodash，或 `Array.concat` 这样的内置操作符)。
这个问题很容易解决，在把 observable 数组传递给其它库之前先调用 `observable.toJS()` 或 `observable.slice()` 将其转化为普通数组。
只要外部库没有修改数组的意图，那么一切都将如预期一样的正常运作。
可以使用 `isObservableArray(observable)` 来检查是否是 observable 数组。

#### `object.someNewProp = value` 不起作用

对于声明 observable 时未分配的属性，MobX observable **对象**  检测不到，也无法作出反应。
因此 MobX observable 对象充当具有预定义键的记录。
可以使用 `extendObservable(target, props)` 来为一个对象引入新的 observable 属性。
但是像 `for .. in` 或 `Object.keys()` 这样的对象迭代不会自动地对这样的改变作出反应。
如果你需要动态键对象，例如通过 id 来存储用户，可以使用 [`observable.map`](../refguide/map.md) 来创建 observable **映射**。
想了解更多详情，请参见 [MobX 会对什么作出反应?](react.md)。

### 在所有渲染 `@observable` 的组件上使用 `@observer`

`@observer` 只会增强你正在装饰的组件，而不是内部使用了的组件。
所以通常你的所有组件都应该是装饰了的。但别担心，这样不会降低效率，相反 `observer` 组件越多，渲染效率越高。

### 间接引用值尽可能晚的使用

MobX 可以做许多事，但是它无法将原始类型值转变成 observable(尽管可以用对象来包装它们，参见 [boxed observables](../refguide/boxed.md))。
所以说**值**不是 observable，而对象的**属性**才是。这意味着 `@observer` 实际上是对间接引用值作出反应。
所以如果像下面这样初始化的话，`Timer` 组件是不会作出任何反应的:

```javascript
React.render(<Timer timerData={timerData.secondsPassed} />, document.body)
```

在这行代码中，只是 `secondsPassed` 的当前值传递给了 `Timer`，这个值是不可变值 `0` (JS中的所有原始类型值都是不可变的)。
这个值永远都不会改变，所以 `Timer` 也永远不会更新。`secondsPassed` 属性将来会改变，所以我们需要在组件**内**访问它。
或者换句话说: 永远只传递拥有 observable 属性的对象。
想了解更多详情，请参见 [MobX 会对什么作出反应?](react.md)。

#### 计算值(Computed values)的运行次数要比预想中频繁的多

如果一个计算属性**没有**被 reaction(`autorun`、`observer` 等) 使用，计算表达式将会延迟执行；每次它们的值被请求(所以它们只是作为正常属性)。
计算值将仅追踪那些它们已被观察的依赖。
这允许 MobX 自动暂停非使用状态的计算。
想深入的了解内部原理，请参见此 [博客](https://medium.com/@mweststrate/becoming-fully-reactive-an-in-depth-explanation-of-mobservable-55995262a254) 或 [issue #356](https://github.com/mobxjs/mobx/issues/356)。
如果你胡乱使用的话，计算属性似乎效率不怎么高。但当使用 `observer`、 `autorun` 等并应用在项目中时，它们会变得非常高效。

MobX 计算也会在事务期间自动地保持活动，参见 PR: [#452](https://github.com/mobxjs/mobx/pull/452) 和 [#489](https://github.com/mobxjs/mobx/pull/489)。

#### 永远要清理 reaction

所有形式的 `autorun`、 `observe` 和 `intercept`， 只有所有它们观察的对象都垃圾回收了，它们才会被垃圾回收。
所以当不再需要使用它们的时候，推荐使用清理函数(这些方法返回的函数)来停止它们继续运行。
对于 `observe` 和 `intercept` 来说，当目标是 `this` 时通常不是必须要清理它们。
对于像 `autorun` 这样的 reaction 要棘手得多，因为它们可能观察到许多不同的 observable，并且只要其中一个仍在作用域内，reaction 将保持在作用域内，这意味着其使用的所有其他 observable 也保持活跃以支持将来的重新计算。
所以当你不再需要 reaction 的时候，千万要清理掉它们！

示例:

```javascript
const VAT = observable(1.20)

class OrderLIne {
    @observable price = 10;
    @observable amount = 1;
    constructor() {
        // 这个 autorun 将与当前的命令行实例一起进行垃圾回收
        this.handler = autorun(() => {
            doSomethingWith(this.price * this.amount)
        })
        // this autorun won't be GC-ed together with the current orderline instance
        // since VAT keeps a reference to notify this autorun,
        // which in turn keeps 'this' in scope
        this.handler = autorun(() => {
            doSomethingWith(this.price * this.amount * VAT.get())
        })
        // So, to avoid subtle memory issues, always call..
        this.handler()
        // When the reaction is no longer needed!
    }
}

```

#### I have a weird exception when using `@observable` in a React component.

The following exception: `Uncaught TypeError: Cannot assign to read only property '__mobxLazyInitializers' of object` occurs when using a `react-hot-loader` that does not support decorators.
Either use `extendObservable` in `componentWillMount` instead of `@observable`, or upgrade to `react-hot-loader` `"^3.0.0-beta.2"` or higher.

#### The display name of react components is not set

If you use `export const MyComponent = observer((props => <div>hi</div>))`, no display name will be visible in the devtools.
The following approaches can be used to fix this:

```javascript
// 1 (set displayName explicitly)
export const MyComponent = observer((props => <div>hi</div>))
myComponent.displayName = "MyComponent"

// 2 (MobX infers component name from function name)
export const MyComponent = observer(function MyComponent(props) { return <div>hi</div> })

// 3 (transpiler will infer component name from variable name)
const _MyComponent = observer((props => <div>hi</div>)) //
export const MyComponent = observer(_MyComponent)

// 4 (with default export)
const MyComponent = observer((props => <div>hi</div>))
export default observer(MyComponent)
```

See also: http://mobxjs.github.io/mobx/best/stateless-HMR.html or [#141](https://github.com/mobxjs/mobx/issues/141#issuecomment-228457886).

#### The propType of an observable array is object

Observable arrays are actually objects, so they comply to `propTypes.object` instead of `array`.
`mobx-react` provides its explicit `PropTypes` for observable data structures.

#### Rendering ListViews in React Native

`ListView.DataSource` in React Native expects real arrays. Observable arrays are actually objects, make sure to `.slice()` them first before passing to list views. Furthermore, `ListView.DataSource` itself can be moved to the store and have it automatically updated with a `@computed`, this step can also be done on the component level.

```javascript
class ListStore {
  @observable list = [
    'Hello World!',
    'Hello React Native!',
    'Hello MobX!'
  ];

  ds = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

  @computed get dataSource() {
    return this.ds.cloneWithRows(this.list.slice());
  }
}

const listStore = new ListStore();

@observer class List extends Component {
  render() {
    return (
      <ListView
        dataSource={listStore.dataSource}
        renderRow={row => <Text>{row}</Text>}
        enableEmptySections={true}
      />
    );
  }
}
```

For more info see [#476](https://github.com/mobxjs/mobx/issues/476)

#### Declaring propTypes might cause unnecessary renders in dev mode

See: https://github.com/mobxjs/mobx-react/issues/56

#### `@observable` properties initialize lazily when using Babel

This issue only occurs when transpiling with Babel and not with Typescript (in which decorator support is more mature).
Observable properties will not be instantiated upon an instance until the first read / write to a property (at that point they all will be initialized).
This results in the following subtle bug:

```javascript
class Todo {
    @observable done = true
    @observable title = "test"
}
const todo = new Todo()

"done" in todo // true
todo.hasOwnProperty("done") // false
Object.keys(todo) // []

console.log(todo.title)
"done" in todo // true
todo.hasOwnProperty("done") // true
Object.keys(todo) // ["done", "title"]
```

In practice this is rarely an issue, only when using generic methods like `Object.assign(target, todo)` or `assert.deepEquals` *before* reading or writing any property of the object.
If you want to make sure that this issue doesn't occur, just initialize the fields in the constructor instead of at the field declaration or use `extendObservable` to create the observable properties.
