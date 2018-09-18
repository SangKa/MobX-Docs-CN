# 常见陷阱与最佳实践

使用 MobX 遇到坑了？本章节涵盖了一些 MobX 新手可能会遭遇的一些常见问题。

#### 导入的路径有误

因为 MobX 自带了 TypeScript 的 typings ，一些导入自动完成工具(至少在 VSCode 中是这样的)的自动导入会有问题，像这样:

```javascript
// 错误的
import { observable } from "mobx/lib/mobx"
```

这是不正确的，但却不会总是立即导致运行时错误。所以需要注意。导入 `mobx` 包中任何东西的唯一正确方式是:

```javascript
// 正确的
import { observable } from "mobx"
```

#### 装饰器问题?

有关装饰器的设置提示和限制，请参见 [装饰器](decorators.md) 一节。

#### `Array.isArray(observable([1,2,3])) === false`

_此限制只适用于 MobX 4 及以下版本_

在 ES5 中没有继承数组的可靠方法，因此 observable 数组继承自对象。
这意味着一般的库没有办法识别出 observable 数组就是普通数组(像 lodash，或 `Array.concat` 这样的内置操作符)。
这个问题很容易解决，在把 observable 数组传递给其它库之前先调用 `observable.toJS()` 或 `observable.slice()` 将其转化为普通数组。
只要外部库没有修改数组的意图，那么一切都将如预期一样的正常运作。
可以使用 `isObservableArray(observable)` 来检查是否是 observable 数组。

#### `object.someNewProp = value` 不起作用

_此限制只适用于 MobX 4 及以下版本_

_在 MobX 5 中，此限制只适用于类实例及其它并非使用 `observable()` / `observable.object()` 创建的对象。_

对于声明 observable 时未分配的属性，MobX observable **对象**  检测不到，也无法作出反应。
因此 MobX observable 对象充当具有预定义键的记录。
可以使用 `extendObservable(target, props)` 来为一个对象引入新的 observable 属性。
但是像 `for .. in` 或 `Object.keys()` 这样的对象迭代不会自动地对这样的改变作出反应。
如果你需要在 MobX 4 及以下版本中动态键对象，例如通过 id 来存储用户，可以使用 [`observable.map`](../refguide/map.md) 或 由[Object API](../refguide/object-api.md) 提供的工具函数来创建 observable **映射**。
想了解更多详情，请参见 [MobX 会对什么作出反应?](react.md)。

### 在所有渲染 `@observable` 的组件上使用 `@observer`

`@observer` 只会增强你正在装饰的组件，而不是内部使用了的组件。
所以通常你的所有组件都应该是装饰了的。但别担心，这样不会降低效率，相反 `observer` 组件越多，渲染效率越高。

### 不要拷贝 observables 属性并存储在本地

Observer 组件只会追踪在 render 方法中存取的数据。常见的错误的是从 observable 属性中提取数据并存储，这样的数据是不会被追踪的:

```javascript
class User {
  @observable name
}

class Profile extends React.Component {
  name

  componentWillMount() {
    // 错误的
    // 这会间接引用 user.name 并只拷贝值一次！未来的更新不会被追踪，因为生命周期钩子不是响应的
    // 像这样的赋值会创建冗余数据
    this.name = this.props.user.name
  }

  render() {
    return <div>{this.name}</div>
  }
}
```

正确的方法通过不将 observables 的值存储在本地(显然，上面的示例很简单，但却是有意为之的)，或通过将其定义为计算属性:

```javascript
class User {
  @observable name
}

class Profile extends React.Component {
  @computed get name() {
    // 正确的; 计算属性会追踪 `user.name` 属性
    return this.props.user.name
  }

  render() {
    return <div>{this.name}</div>
  }
}
```

### Render 回调函数**不是** render 方法的一部分

因为 `observer` 只作用于当前组件的 `render` 函数，传递一个 render 回调函数或组件给子组件不会自动地变成响应的。
想了解更多详情，请参见 [MobX 会对什么作出反应](https://github.com/SangKa/mobx-docs-cn/blob/master/docs/best/react.md#mobx-只会为-observer-组件追踪数据存取如果数据是直接通过-render-进行存取的) 指南。

### 间接引用值尽可能晚的使用

MobX 可以做许多事，但是它无法将原始类型值转变成 observable(尽管可以用对象来包装它们，参见 [boxed observables](../refguide/boxed.md))。
所以说**值**不是 observable，而对象的**属性**才是。这意味着 `@observer` 实际上是对间接引用值作出反应。
所以如果像下面这样初始化的话，`Timer` 组件是不会作出任何反应的:

```javascript
ReactDom.render(<Timer timerData={timerData.secondsPassed} />, document.body)
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

要强制计算值保持活动, 可以使用 `keepAlive: true` 选项, 但这并不是说这会造成潜在的内存泄漏。

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
        // 这个 autorun 将不会与当前的命令行实例一起进行垃圾回收
        // 因为 VAT 保留了引用以通知这个 autorun
        // 这反过来在作用域中保留了 `this`
        this.handler = autorun(() => {
            doSomethingWith(this.price * this.amount * VAT.get())
        })
        // 所以，为了避免细微的内存问题，总是调用清理函数..
        this.handler()
        // 当 reaction 不再需要时！
    }
}

```

#### 当在 React 组件中使用 `@observable` 时有一个奇怪的异常

如下异常: `Uncaught TypeError: Cannot assign to read only property '__mobxLazyInitializers' of object`
`react-hot-loader` 不支持装饰器，所以当使用时会出现这个错误。
解决方法: 在 `componentWillMount` 中使用 `extendObservable` 替代 `@observable` 或者 把 `react-hot-loader` 更新到 `"^3.0.0-beta.2"` 版本或者更高。

#### 未设置 React 组件的显示名称

如果你使用 `export const MyComponent = observer((props => <div>hi</div>))`，那么在开发者工具中看不到显示名称。
下列方法可以用来解决此问题:

```javascript
// 1 (显示设置 displayName)
export const MyComponent = observer((props => <div>hi</div>))
myComponent.displayName = "MyComponent"

// 2 (MobX 根据函数名推断出组件名)
export const MyComponent = observer(function MyComponent(props) { return <div>hi</div> })

// 3 (编译器根据变量名推断出组件名)
const _MyComponent = observer((props => <div>hi</div>)) //
export const MyComponent = observer(_MyComponent)

// 4 (默认导出)
const MyComponent = observer((props => <div>hi</div>))
export default observer(MyComponent)
```

还可参见: http://mobxjs.github.io/mobx/best/stateless-HMR.html 或 [#141](https://github.com/mobxjs/mobx/issues/141#issuecomment-228457886)。

#### observable 数组的 propType 是对象

Observable 数组实际上是对象，所以它们遵循 `propTypes.object` 而不是 `propTypes.array`。
`mobx-react` 为 observable 数据结构提供了明确的 `PropTypes`。

#### 在 React Native 中渲染 ListViews

React Native 的 `ListView.DataSource` 接收真正的数组。Observable 数组实际上是对象，要确保在传给 ListViews 之前先使用 `.slice()` 方法。
此外，`ListView.DataSource` 本身可以移到 store 之中并且使用 `@computed` 自动地更新，这步操作同样可以在组件层完成。

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

想了解更多信息，请参见 [#476](https://github.com/mobxjs/mobx/issues/476)。

#### 开发模式下声明 propTypes 可能会引起不必要的渲染

参见: https://github.com/mobxjs/mobx-react/issues/56

#### 不要对 `Observer` 过的 React 组件中(某些)生命周期方法装饰成 `action.bound`

正如上面所提到的，所有使用了 observable 数据的 React 组件都可以标记成 `@observer` 。此外，如果在 React 组件的函数中修改任意 observable 数据的话，该函数应该标记成 `@action` 。另外，如果你想要 `this` 指向组件类的实例，你应该使用 `@action.bound` 。参考下面的类:

```js
class ExampleComponent extends React.Component {
  @observable disposer // <--- 此值在 addActed 方法中处理
  
  @action.bound
  addActed() {
    this.dispose()
  }
  
  @action.bound
  componentDidMount() {
    this.disposer = this.observe(....) //<-- 细节不用关心
  }
}
```

如果调用 `ExampleComponent` 的 `addActed()` 方法，`disposer` 会被调用。

换句话说，考虑如下代码:

```js
class ExampleComponent extends React.Component {
  @observable disposer // <--- 此值在 addActed 方法中处理
  
  @action.bound
  componentWillUnmount() {
    this.dispose()
  }
  
  @action.bound
  componentDidMount() {
    this.disposer = this.observe(....) //<-- 细节不用关心
  }
}
```

在这里，`disposer` 永远不会被调用！原因是 mixin 使得 `ExampleComponent` 成为了 `observer` ，它修改了 `componentWillUnmount` 函数，使得 `this` 指向了某个目标之外的 `React.Component` 实例 (不知道是哪个)。要解决此问题，请声明 `componentWillUnmount()`，如下所示：

```js
componentWillUnmount() {
  runInAction(() => this.dispose())
}
```
