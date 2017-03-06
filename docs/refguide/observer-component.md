# @observer

`observer` 函数/装饰器可以用来将 React 组件转变成响应式组件。
它用 `mobx.autorun` 包装了组件的 render 函数以确保任何组件渲染中使用的数据变化时可以强制刷新组件。
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
});

React.render(<Timer timerData={timerData} />, document.body);
```

小贴士: 当 `observer` 需要组合其它装饰器或高阶组件时，请确保 `observer` 是最深处(第一个应用)的装饰器，否则它可能什么都不做。

注意，使用 `@observer` 装饰器是可选的，它和 `observer(class Timer ... { })` 达到的效果是一样的。

## 陷阱: 组件中的间接引用值
MobX 可以做很多事，但是它无法使原始数据类型值转变成可观察的(尽管它可以用对象来包装它们，参见 [boxed observables](boxed.md))。
所以**值**是不可观察的，但是对象的**属性**可以。这意味着 `@observer` 实际上是对间接引用值的反应。
那么在上面的示例中，如果是用下面这种方式初始化的，`Timer` 组件是**不会**有反应的:

```javascript
React.render(<Timer timerData={timerData.secondsPassed} />, document.body)
```
在这个代码片段中只是把 `secondsPassed` 的当前值传递给了 `Timer` 组件，这个值是不可变值`0`(JS中所有的原始类型值都是不可变的)。
这个数值永远都不会改变，因此 `Timer` 组件不会更新。只是 `secondsPassed` 将来会发生改变。
所以我们需要在组件**中**访问它。或者换句话说: 值需要**通过引用**来传递而不少通过值来传递。

## ES5 支持

在ES5环境中，可以简单地使用 `observer(React.createClass({ ... ` 来定义观察者组件。还可以参见[语法指南](../best/syntax.md)。

## 无状态函数组件

上面的 `Timer` 组件还可以通过使用 `observer` 传递的无状态函数组件来编写:

```javascript
import {observer} from "mobx-react";

const Timer = observer(({ timerData }) =>
	<span>Seconds passed: { timerData.secondsPassed } </span>
);
```

## 可观察的局部组件状态

就像普通类一样，你可以通过使用 `@observable` 装饰器在组件上引入可观察属性。
这意味着你可以在组件中拥有本地状态，而不需要通过 React 的冗长和强制性的 `setState` 机制来管理，但是功能同样强大。
响应式状态会被 `render` 提取，但不会显示调用其它 React 声明周期方法，像 `componentShouldUpdate` 或 `componentWillUpdate`。
如果你需要用到这些，只是使用正常的基于 `state` 的API就好了。

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

## 将 `observer` 连接到 store

`mobx-react` 包还提供了 `Provider` 组件，它使用了 React 的上下文机制，可以用来向下传递 store。
要连接到这些 store，传一个 store 名称的数组给 `observer`，这使得 store 可以作为 props 使用。
支持使用装饰器 `@observer(["store"]) class ...` 或者函数 `observer(["store"], React.createClass({ ...`。

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

const Button = observer(["colors"], ({ colors, label, onClick }) =>
  <button style={{
      color: colors.foreground,
      backgroundColor: colors.background
    }}
    onClick={onClick}
  >{label}<button>
);

// 稍后..
colors.foreground = 'blue';
// 所有button都会更新
```

更多资料，请参见 [`mobx-react` 文档](https://github.com/mobxjs/mobx-react#provider-experimental)。


## 何时使用 `observer`?

最简单的经验法则是: _所有渲染 observable 数据的组件_。
如果你不想将组件标记为 observer，例如为了减少通用组件包的依赖性，请确保只传递普通数据。

使用 `@observer` 的话，不再需要从渲染目的上来区分是“智能组件”还是“无脑”组件。
在事件处理、发起请求等方面，它仍然是一个很好的概念分离。
当所有组件它们**自己的**依赖改变时，组件自己负责更新。
它的开销是可以忽略的，它确保每当你开始使用 observable 数据时，组件将响应它。
更多详情，请参见 [这里](https://www.reddit.com/r/reactjs/comments/4vnxg5/free_eggheadio_course_learn_mobx_react_in_30/d61oh0l)。

## `observer` 和 `PureRenderMixin`
`observer` 还可以防止当组件的 *props* 只是浅改变时的重新渲染，如果传递给组件的数据是响应式的，这是很有意义的。
这个行为与 [React PureRender mixin](https://facebook.github.io/react/docs/pure-render-mixin.html) 相似，除了 *state* 的更改仍然总是被处理。
如果一个组件提供了它自己的 `shouldComponentUpdate`，那么这个是高优先级的。
想要更详细的解释，请参见这个 [github issue](https://github.com/mobxjs/mobx/issues/101)。

## `componentWillReact` (生命周期钩子)

React 组件通常在新的堆栈上渲染，这使得通常很难弄清楚是什么**导致**组件的重新渲染。
当使用 `mobx-react` 时可以定义一个新生命周期钩子 `componentWillReact`(一语双关)。当组件因为它观察的数据发生了改变，它会安排重新渲染，这个时候 `componentWillReact` 会被触发。这使得它很容易追溯渲染并找到导致渲染的操作。

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

## Characteristics of observer components

* Observer only subscribe to the data structures that were actively used during the last render. This means that you cannot under-subscribe or over-subscribe. You can even use data in your rendering that will only be available at later moment in time. This is ideal for asynchronously loading data.
* You are not required to declare what data a component will use. Instead, dependencies are determined at runtime and tracked in a very fine-grained manner.
* Usually reactive components have no or little state, as it is often more convenient to encapsulate (view) state in objects that are shared with other component. But you are still free to use state.
* `@observer` implements `shouldComponentUpdate` in the same way as `PureRenderMixin` so that children are not re-rendered unnecessary.
* Reactive components sideways load data; parent components won't re-render unnecessarily even when child components will.
* `@observer` does not depend on React's context system.
* In mobx-react@4+, the props object and the state object of an observer component are automatically made observable to make it easier to create @computed properties that derive from props inside such a component. If you have a reaction (i.e. `autorun`) inside your `@observer` component that must _not_ be re-evaluated when the specific props it uses don't change, be sure to derefence those specific props for use inside your reaction (i.e. `const myProp = props.myProp`). Otherwise, if you reference `props.myProp` inside the reaction, then a change in _any_ of the props will cause the reaction to be re-evaluated. For a typical use case with React-Router, see [this article](https://alexhisen.gitbooks.io/mobx-recipes/content/observable-based-routing.html).

## Enabling ES6 decorators in your transpiler

Decorators are not supported by default when using TypeScript or Babel pending a definitive definition in the ES standard.
* For _typescript_, enable the `--experimentalDecorators` compiler flag or set the compiler option `experimentalDecorators` to `true` in `tsconfig.json` (Recommended)
* For _babel5_, make sure `--stage 0` is passed to the Babel CLI
* For _babel6_, see the example configuration as suggested in this [issue](https://github.com/mobxjs/mobx/issues/105)
