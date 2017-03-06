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

For more advantages of using observable local component state, see [3 reasons why I stopped using `setState`](https://medium.com/@mweststrate/3-reasons-why-i-stopped-using-react-setstate-ab73fc67a42e).

## Connect `observer` to stores

The `mobx-react` package also provides the `Provider` component that can be used to pass down stores using React's context mechanism.
To connect to those stores, pass an array of store names to `observer`, which will make the stores available as props.
This is supported when using the decorator (`@observer(["store"]) class ...`, or the function `observer(["store"], React.createClass({ ...``.

Example:

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

// later..
colors.foreground = 'blue';
// all buttons updated
```

See for more information the [`mobx-react` docs](https://github.com/mobxjs/mobx-react#provider-experimental).


## When to apply `observer`?

The simple rule of thumb is: _all components that render observable data_.
If you don't want to mark a component as observer, for example to reduce the dependencies of a generic component package, make sure you only pass it plain data.

With `@observer` there is no need to distinguish 'smart' components from 'dumb' components for the purpose of rendering.
It is still a good separation of concerns for where to handle events, make requests etc.
All components become responsible for updating when their _own_ dependencies change.
Its overhead is neglectable and it makes sure that whenever you start using observable data the component will respond to it.
See this [thread](https://www.reddit.com/r/reactjs/comments/4vnxg5/free_eggheadio_course_learn_mobx_react_in_30/d61oh0l) for more details.

## `observer` and `PureRenderMixin`
`observer` also prevents re-renderings when the *props* of the component have only shallowly changed, which makes a lot of sense if the data passed into the component is reactive.
This behavior is similar to [React PureRender mixin](https://facebook.github.io/react/docs/pure-render-mixin.html), except that *state* changes are still always processed.
If a component provides its own `shouldComponentUpdate`, that one takes precedence.
See for an explanation this [github issue](https://github.com/mobxjs/mobx/issues/101)

## `componentWillReact` (lifecycle hook)

React components usually render on a fresh stack, so that makes it often hard to figure out what _caused_ a component to re-render.
When using `mobx-react` you can define a new life cycle hook, `componentWillReact` (pun intended) that will be triggered when a component will be scheduled to re-render because
data it observes has changed. This makes it easy to trace renders back to the action that caused the rendering.

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

* `componentWillReact` doesn't take arguments
* `componentWillReact` won't fire before the initial render (use `componentWillMount` instead)
* `componentWillReact` for mobx-react@4+, the hook will fire when receiving new props and after `setState` calls

## Optimizing components

See the relevant [section](../best/react-performance.md).

## MobX-React-DevTools

In combination with `@observer` you can use the MobX-React-DevTools, it shows exactly when your components are re-rendered and you can inspect the data dependencies of your components.
See the [DevTools](../best/devtools.md) section.

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
