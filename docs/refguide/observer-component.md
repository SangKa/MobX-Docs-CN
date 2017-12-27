# @observer

<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px" href="https://egghead.io/courses/manage-complex-state-in-react-apps-with-mobx">Egghead.io 第1课: observable & observer</a>

`observer` 函数/装饰器可以用来将 React 组件转变成响应式组件。
它用 `mobx.autorun` 包装了组件的 render 函数以确保任何组件渲染中使用的数据变化时都可以强制刷新组件。
`observer` 是由单独的 `mobx-react` 包提供的。


```javascript
import {observer} from "mobx-react";

var timerData = observable({
	secondsPassed: 0
});

setInterval(() => {
	timerData.secondsPassed++;
}, 1000);

@observer class Timer extends React.Component {
	render() {
		return (<span>Seconds passed: { this.props.timerData.secondsPassed } </span> )
	}
};

React.render(<Timer timerData={timerData} />, document.body);
```

小贴士: 当 `observer` 需要组合其它装饰器或高阶组件时，请确保 `observer` 是最深处(第一个应用)的装饰器，否则它可能什么都不做。

注意，使用 `@observer` 装饰器是可选的，它和 `observer(class Timer ... { })` 达到的效果是一样的。

## 陷阱: 组件中的间接引用值

MobX 可以做很多事，但是它无法使原始数据类型值转变成可观察的(尽管它可以用对象来包装它们，参见 [boxed observables](boxed.md))。
所以**值**是不可观察的，但是对象的**属性**可以。这意味着 `@observer` 实际上是对间接引用(dereference)值的反应。
那么在上面的示例中，如果是用下面这种方式初始化的，`Timer` 组件是**不会**有反应的:

```javascript
React.render(<Timer timerData={timerData.secondsPassed} />, document.body)
```
在这个代码片段中只是把 `secondsPassed` 的当前值传递给了 `Timer` 组件，这个值是不可变值`0`(JS中所有的原始类型值都是不可变的)。
这个数值永远都不会改变，因此 `Timer` 组件不会更新。`secondsPassed`的值将来会发生改变，
所以我们需要在组件**中**访问它。或者换句话说: 值需要**通过引用**来传递而不是通过(字面量)值来传递。

## ES5 支持

在ES5环境中，可以简单地使用 `observer(React.createClass({ ...` 来定义观察者组件。还可以参见[语法指南](../best/syntax.md)。

## 无状态函数组件

上面的 `Timer` 组件还可以通过使用 `observer` 传递的无状态函数组件来编写:

```javascript
import {observer} from "mobx-react";

const Timer = observer(({ timerData }) =>
	<span>Seconds passed: { timerData.secondsPassed } </span>
);
```

## 可观察的局部组件状态

就像普通类一样，你可以通过使用 `@observable` 装饰器在React组件上引入可观察属性。
这意味着你可以在组件中拥有功能同样强大的本地状态(local state)，而不需要通过 React 的冗长和强制性的 `setState` 机制来管理。
响应式状态会被 `render` 提取调用，但不会调用其它 React 的生命周期方法，除了 `componentWillUpdate` 和 `componentDidUpdate` 。
如果你需要用到其他 React 生命周期方法 ，只需使用基于 `state` 的常规 React API 即可。

上面的例子还可以这样写:

```javascript
import {observer} from "mobx-react"
import {observable} from "mobx"

@observer class Timer extends React.Component {
	@observable secondsPassed = 0

	componentWillMount() {
		setInterval(() => {
			this.secondsPassed++
		}, 1000)
	}

	render() {
		return (<span>Seconds passed: { this.secondsPassed } </span> )
	}
})

React.render(<Timer />, document.body)
```

对于使用可观察的局部组件状态更多的优势，请参见[为什么我不再使用 `setState` 的三个理由](https://medium.com/@mweststrate/3-reasons-why-i-stopped-using-react-setstate-ab73fc67a42e)。

## 使用 `inject` 将组件连接到提供的 stores

<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px" href="https://egghead.io/lessons/react-connect-mobx-observer-components-to-the-store-with-the-react-provider">Egghead.io 第8课: 使用 Provider 注入 stores</a>

`mobx-react` 包还提供了 `Provider` 组件，它使用了 React 的上下文(context)机制，可以用来向下传递 `stores`。
要连接到这些 stores，需要传递一个 stores 名称的列表给 `inject`，这使得 stores 可以作为组件的 `props` 使用。

_ 注意: 从 mobx-react 4开始，注入 stores 的语法发生了变化，应该一直使用  `inject(stores)(component)` 或 `@inject(stores) class Component...`。
直接传递 store 名称给 `observer` 的方式已废弃。 _

示例:

```javascript
const colors = observable({
   foreground: '#000',
   background: '#fff'
});

const App = () =>
  <Provider colors={colors}>
     <app stuff... />
  </Provider>;

const Button = inject("colors")(observer(({ colors, label, onClick }) =>
  <button style={{
      color: colors.foreground,
      backgroundColor: colors.background
    }}
    onClick={onClick}
  >{label}<button>
));

// 稍后..
colors.foreground = 'blue';
// 所有button都会更新
```

更多资料，请参见 [`mobx-react` 文档](https://github.com/mobxjs/mobx-react#provider-experimental)。


## 何时使用 `observer`?

简单来说: _所有渲染 observable 数据的组件_。
如果你不想将组件标记为 observer，例如为了减少通用组件包的依赖，请确保只传递普通数据。

使用 `@observer` 的话，不再需要从渲染目的上来区分是“智能组件”还是“无脑”组件。
在组件的事件处理、发起请求等方面，它也是一个很好的分离关注点。
当所有组件它们**自己的**依赖项有变化时，组件自己会响应更新。
而它的计算开销是可以忽略的，并且它会确保不管何时,只要当你开始使用 observable 数据时，组件都将会响应它的变化。
更多详情，请参见 [这里](https://www.reddit.com/r/reactjs/comments/4vnxg5/free_eggheadio_course_learn_mobx_react_in_30/d61oh0l)。

## `observer` 和 `PureRenderMixin`
如果传递给组件的数据是响应式的,`observer` 还可以防止当组件的 *props* 只是浅改变时的重新渲染，这是很有意义的。
这个行为与 [React PureRender mixin](https://facebook.github.io/react/docs/pure-render-mixin.html) 相似，不同在于这里的 *state* 的更改仍然会被处理。
如果一个组件提供了它自己的 `shouldComponentUpdate`，这个方法会被优先调用。
想要更详细的解释，请参见这个 [github issue](https://github.com/mobxjs/mobx/issues/101)。

## `componentWillReact` (生命周期钩子)

React 组件通常在新的堆栈上渲染，这使得通常很难弄清楚是什么**导致**组件的重新渲染。
当使用 `mobx-react` 时可以定义一个新的生命周期钩子函数 `componentWillReact`(一语双关)。当组件因为它观察的数据发生了改变，它会安排重新渲染，这个时候 `componentWillReact` 会被触发。这使得它很容易追溯渲染并找到导致渲染的操作(action)。

```javascript
import {observer} from "mobx-react";

@observer class TodoView extends React.Component {
    componentWillReact() {
        console.log("I will re-render, since the todo has changed!");
    }

    render() {
        return <div>this.props.todo.title</div>;
    }
}
```

* `componentWillReact` 不接收参数
* `componentWillReact` 初始化渲染前不会触发 (使用 `componentWillMount` 替代)
* `componentWillReact` 对于 mobx-react@4+, 当接收新的 props 时并在 `setState` 调用后会触发此钩子

## 优化组件

请参见相关[章节](../best/react-performance.md)。

## MobX-React-DevTools

结合 `@observer`，可以使用 MobX-React-DevTools ，它精确地显示了何时重新渲染组件，并且可以检查组件的数据依赖关系。
详情请参见 [开发者工具](../best/devtools.md) 。

## observer 组件特性

* Observer 仅订阅在上次渲染期间活跃使用的数据结构。这意味着你不会订阅不足(under-subscribe)或者过度订阅(over-subscribe)。你甚至可以在渲染方法中使用仅在未来时间段可用的数据。 这是异步加载数据的理想选择。
* 你不需要声明组件将使用什么数据。相反，依赖关系在运行时会确定并以非常细粒度的方式进行跟踪。
* 通常，响应式组件没有或很少有状态，因为在与其他组件共享的对象中封装(视图)状态通常更方便。但你仍然可以自由地使用状态。
* `@observer` 以和 `PureRenderMixin` 同样的方式实现了 `shouldComponentUpdate`，因此子组件可以避免不必要的重新渲染。
* 响应式组件单方面加载数据，即使子组件要重新渲染，父组件也不会进行不必要地重新渲染。
* `@observer` 不依赖于 React 的上下文系统。
* mobx-react@4+ 中，observer 组件的props 对象和 state 对象都会自动地转变为 observable，这使得创建 @computed 属性更容易，@computed 属性是根据组件内部的 props 推导得到的。如果在 `@observer` 组件中包含 reaction(例如 `autorun`) 的话，当 reaction 使用的特定属性不再改变时，reaction 是不会再重新运行的，在 reaction 中使用的特定 props 一定要间接引用(例如 `const myProp = props.myProp`)。不然，如果你在 reaction 中引用了 `props.myProp`，那么 props 的**任何**改变都会导致 reaction 的重新运行。对于 React-Router 的典型用例，请参见[这篇文章](https://alexhisen.gitbooks.io/mobx-recipes/content/observable-based-routing.html)。

## 在编译器中启用装饰器

在使用 TypeScript 或 Babel 这些等待ES标准定义的编译器时，默认情况下是不支持装饰器的。
* 对于 _typescript_，启用 `--experimentalDecorators` 编译器标识或者在 `tsconfig.json` 中把编译器属性 `experimentalDecorators` 设置为 `true` (推荐做法)
* 对于 _babel5_，确保把 `--stage 0` 传递给 Babel CLI
* 对于 _babel6_，参见此 [issue](https://github.com/mobxjs/mobx/issues/105) 中建议的示例配置。
