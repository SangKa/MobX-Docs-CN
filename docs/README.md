<img src="docs/mobx.png" alt="logo" height="120" align="right" />
# MobX

_简单、可扩展的状态管理_

[![Build Status](https://travis-ci.org/mobxjs/mobx.svg?branch=master)](https://travis-ci.org/mobxjs/mobx)
[![Coverage Status](https://coveralls.io/repos/mobxjs/mobx/badge.svg?branch=master&service=github)](https://coveralls.io/github/mobxjs/mobx?branch=master)
[![Join the chat at https://gitter.im/mobxjs/mobx](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mobxjs/mobx?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![npm install mobx](https://nodei.co/npm/mobx.png?downloadRank=true&downloads=true)

* 安装: `npm install mobx --save`. React 绑定库: `npm install mobx-react --save`. 要启用 ESNext 的装饰器 (可选), 见下面.
* CDN: https://unpkg.com/mobx/lib/mobx.umd.js

## 入门指南

* [十分钟交互式的 MobX + React 教程](https://mobxjs.github.io/mobx/getting-started.html)
* [官方文档和API概览](https://mobxjs.github.io/mobx/refguide/api.html)
* 视频:
  * [Egghead.io 课程: 在 React 应用中使用 MobX 管理复杂的状态](https://egghead.io/courses/manage-complex-state-in-react-apps-with-mobx) - 30分钟.
  * [ReactNext 2016: 真实世界的 MobX](https://www.youtube.com/watch?v=Aws40KOx90U) - 40分钟 [幻灯片](https://docs.google.com/presentation/d/1DrI6Hc2xIPTLBkfNH8YczOcPXQTOaCIcDESdyVfG_bE/edit?usp=sharing)
  * [React 和 MobX 实战](https://www.youtube.com/watch?v=XGwuM_u7UeQ). OpenSourceNorth 开发者大会上，Matt Ruby 深入介绍和说明如何使用MobX和React(ES5版本) - 42分钟.
  * LearnCode.academy MobX 教程 [第一部分: MobX + React 太棒了 (7分钟)](https://www.youtube.com/watch?v=_q50BXqkAfI) [第二部分: Computed Values and 嵌套/引用的 Observables (12分钟)](https://www.youtube.com/watch?v=nYvNqKrl69s)
  * [录播: MobX 介绍](https://www.youtube.com/watch?v=K8dr8BMU7-8) - 8分钟
  * [访谈: 状态管理很容易 - React Amsterdam 2016 开发者大会](https://www.youtube.com/watch?v=ApmSsu3qnf0&feature=youtu.be) ([幻灯片](https://speakerdeck.com/mweststrate/state-management-is-easy-introduction-to-mobx))
* [样板文件和相关项目](http://mobxjs.github.io/mobx/faq/boilerplates.html)
* 更多教程、博客和视频尽在 [MobX 主页](http://mobxjs.github.io/mobx/faq/blogs.html)


## 入门

MobX 是一个经过战火洗礼的类库，它通过透明的函数响应式编程(transparently applying functional reactive programming - TFRP)使得状态管理变得简单和可扩展。MobX背后的哲学很简单:

_任何源自应用状态的东西都应该自动地获得。_

其中包括UI、数据序列化、服务器通讯，等等。

<img alt="MobX unidirectional flow" src="docs/flow.png" align="center" />

React 和 MobX 是一对强力组合。React 通过提供机制把应用状态转换为可渲染组件树并对其进行渲染。而MobX提供机制来存储和更新应用状态供 React 使用。

对于应用开发中的常见问题，React 和 MobX都提供了最优和独特的解决方案。React 提供了优化UI渲染的机制， 这种机制就是通过使用虚拟DOM来减少昂贵的DOM变化的数量。MobX 提供了优化应用状态与 React 组件同步的机制，这种机制就是使用响应式虚拟依赖状态图表，它只有在真正需要的时候才更新并且永远保持是最新的。

## 核心概念

MobX 的核心概念不多。 下面的代码片段可以在 [JSFiddle](https://jsfiddle.net/mweststrate/wv3yopo0/) (或者 [不使用 ES6 和 JSX](https://jsfiddle.net/rubyred/55oc981v/))中在线试用。

### Observable state(可观察的状态)

MobX 为现有的数据结构(如对象，数组和类实例)添加了可观察的功能。
通过使用 [@observable](http://mobxjs.github.io/mobx/refguide/observable-decorator.html) 装饰器(ES.Next)来给你的类属性添加注解就可以简单地完成这一切。

```javascript
class Todo {
    id = Math.random();
    @observable title = "";
    @observable finished = false;
}
```

使用 `observable` 很像把对象的属性变成excel的单元格。
但和单元格不同的是，这些值不只是原始值，还可以是引用值，比如对象和数组。
你甚至还可以[自定义](http://mobxjs.github.io/mobx/refguide/extending.html)可观察数据源。

### 插曲: 在ES5、ES6 和ES.next环境下使用 MobX

这些 `@` 开头的东西对你来说或许还比较陌生，它们是ES.next装饰器。
在 MobX 中使用它们完全是可选的。参见[装饰器文档](http://mobxjs.github.io/mobx/best/decorators.html)详细了解如何使用或者避免它们。
MobX 可以在任何ES5的环境中运行，但是利用像装饰器这样的ES.next的特性是使用 MobX 的最佳选择。
本自述文件的剩余部分都会使用装饰器，但请牢记，_它们是可选的_。

For example, in good ol' ES5 the above snippet would look like:
例如，上面一段代码的ES5版本应该是这样:

```javascript
function Todo() {
    this.id = Math.random()
    extendObservable(this, {
        title: "",
        finished: false
    })
}
```

### Computed values(计算值)

使用 MobX， 你定义的值可以在相关数据发生变化时自动更新。
通过使用 [`@computed`](http://mobxjs.github.io/mobx/refguide/computed-decorator.html) 装饰器或者当使用 `(extend)Observable` 时使用 getter / setter 函数。

```javascript
class TodoList {
    @observable todos = [];
    @computed get unfinishedTodoCount() {
        return this.todos.filter(todo => !todo.finished).length;
    }
}
```

MobX will ensure that `unfinishedTodoCount` is updated automatically when a todo is added or when one of the `finished` properties is modified.
Computations like these can very well be compared with formulas in spreadsheet programs like MS Excel. They update automatically whenever, and only when, needed.
当添加了一个新的todo或者某个todo的 `finished` 属性发生变化时，MobX 会确保 `unfinishedTodoCount` 自动更新。
这样的计算可以很好地与电子表格程序中的公式(如MS Excel)进行比较。每当只有在需要它们的时候，它们才会自动更新。

### Reactions(反应)

Reactions are similar to a computed value, but instead of producing a new value, a reaction produces a side effect for things like printing to the console, making network requests, incrementally updating the React component tree to patch the DOM, etc.
In short, reactions bridge [reactive](https://en.wikipedia.org/wiki/Reactive_programming) and [imperative](https://en.wikipedia.org/wiki/Imperative_programming) programming.

#### React components
If you are using React, you can turn your (stateless function) components into reactive components by simply adding the [`observer`](http://mobxjs.github.io/mobx/refguide/observer-component.html) function / decorator from the `mobx-react` package onto them.

```javascript
import React, {Component} from 'react';
import ReactDOM from 'react-dom';
import {observer} from "mobx-react";

@observer
class TodoListView extends Component {
    render() {
        return <div>
            <ul>
                {this.props.todoList.todos.map(todo =>
                    <TodoView todo={todo} key={todo.id} />
                )}
            </ul>
            Tasks left: {this.props.todoList.unfinishedTodoCount}
        </div>
    }
}

const TodoView = observer(({todo}) =>
    <li>
        <input
            type="checkbox"
            checked={todo.finished}
            onClick={() => todo.finished = !todo.finished}
        />{todo.title}
    </li>
)

const store = new TodoList();
ReactDOM.render(<TodoListView todoList={store} />, document.getElementById('mount'));
```

`observer` turns React (function) components into derivations of the data they render.
When using MobX there are no smart or dumb components.
All components render smartly but are defined in a dumb manner. MobX will simply make sure the components are always re-rendered whenever needed, but also no more than that. So the `onClick` handler in the above example will force the proper `TodoView` to render, and it will cause the `TodoListView` to render if the number of unfinished tasks has changed.
However, if you would remove the `Tasks left` line (or put it into a separate component), the `TodoListView` will no longer re-render when ticking a box. You can verify this yourself by changing the [JSFiddle](https://jsfiddle.net/mweststrate/wv3yopo0/).

#### Custom reactions
Custom reactions can simply be created using the [`autorun`](http://mobxjs.github.io/mobx/refguide/autorun.html),
[`autorunAsync`](http://mobxjs.github.io/mobx/refguide/autorun-async.html) or [`when`](http://mobxjs.github.io/mobx/refguide/when.html) functions to fit your specific situations.

For example the following `autorun` prints a log message each time the amount of `unfinishedTodoCount` changes:

```javascript
autorun(() => {
    console.log("Tasks left: " + todos.unfinishedTodoCount)
})
```

### What will MobX react to?

Why does a new message get printed each time the `unfinishedTodoCount` is changed? The answer is this rule of thumb:
_MobX reacts to any existing observable property that is read during the execution of a tracked function._

For an in-depth explanation about how MobX determines to which observables needs to be reacted, check [understanding what MobX reacts to](https://github.com/mobxjs/mobx/blob/gh-pages/docs/best/react.md)

### Actions

Unlike many flux frameworks, MobX is unopinionated about how user events should be handled.

* This can be done in a Flux like manner.
* Or by processing events using RxJS.
* Or by simply handling events in the most straightforward way possible, as demonstrated in the above `onClick` handler.

In the end it all boils down to: Somehow the state should be updated.

After updating the state `MobX` will take care of the rest in an efficient, glitch-free manner. So simple statements, like below, are enough to automatically update the user interface.

There is no technical need for firing events, calling dispatcher or what more. A React component is in the end nothing more than a fancy representation of your state. A derivation that will be managed by MobX.

```javascript
store.todos.push(
    new Todo("Get Coffee"),
    new Todo("Write simpler code")
);
store.todos[0].finished = true;
```

Nonetheless, MobX has an optional built-in concept of [`actions`](https://mobxjs.github.io/mobx/refguide/action.html).
Use them to your advantage; they will help you to structure your code better and make wise decisions about when and where state should be modified.

## MobX: Simple and scalable

MobX is one of the least obtrusive libraries you can use for state management. That makes the `MobX` approach not just simple, but very scalable as well:

### Using classes and real references

With MobX you don't need to normalize your data. This makes the library very suitable for very complex domain models (At Mendix for example ~500 different domain classes in a single application).

### Referential integrity is guaranteed

Since data doesn't need to be normalized, and MobX automatically tracks the relations between state and derivations, you get referential integrity for free. Rendering something that is accessed through three levels of indirection?

No problem, MobX will track them and re-render whenever one of the references changes. As a result staleness bugs are a thing of the past. As a programmer you might forget that changing some data might influence a seemingly unrelated component in a corner case. MobX won't forget.

### Simpler actions are easier to maintain

As demonstrated above, modifying state when using MobX is very straightforward. You simply write down your intentions. MobX will take care of the rest.

### Fine grained observability is efficient

MobX builds a graph of all the derivations in your application to find the least number of re-computations that is needed to prevent staleness. "Derive everything" might sound expensive, MobX builds a virtual derivation graph to minimize the number of recomputations needed to keep derivations in sync with the state.

In fact, when testing MobX at Mendix we found out that using this library to track the relations in our code is often a lot more efficient than pushing changes through our application by using handwritten events or "smart" selector based container components.

The simple reason is that MobX will establish far more fine grained 'listeners' on your data than you would do as a programmer.

Secondly MobX sees the causality between derivations so it can order them in such a way that no derivation has to run twice or introduces a glitch.

How that works? See this [in-depth explanation of MobX](https://medium.com/@mweststrate/becoming-fully-reactive-an-in-depth-explanation-of-mobservable-55995262a254).

### Easy interoperability

MobX works with plain javascript structures. Due to its unobtrusiveness it works with most javascript libraries out of the box, without needing MobX specific library flavors.

So you can simply keep using your existing router, data fetching and utility libraries like `react-router`, `director`, `superagent`, `lodash` etc.

For the same reason you can use it out of the box both server- and client side, in isomorphic applications and with react-native.

The result of this is that you often need to learn fewer new concepts when using MobX in comparison to other state management solutions.

---



<center>
<img src="https://www.mendix.com/styleguide/img/logo-mendix.png" align="center" width="200"/>

__MobX is proudly used in mission critical systems at [Mendix](https://www.mendix.com)__
</center>

## Credits

MobX is inspired by reactive programming principles as found in spreadsheets. It is inspired by MVVM frameworks like in MeteorJS tracker, knockout and Vue.js. But MobX brings Transparent Functional Reactive Programming to the next level and provides a stand alone implementation. It implements TFRP in a glitch-free, synchronous, predictable and efficient manner.

A ton of credits for [Mendix](https://github.com/mendix), for providing the flexibility and support to maintain MobX and the chance to prove the philosophy of MobX in a real, complex, performance critical applications.

And finally kudos for all the people that believed in, tried, validated and even [sponsored](https://github.com/mobxjs/mobx/blob/master/sponsors.md) MobX.

## Further resources and documentation

* [MobX homepage](http://mobxjs.github.io/mobx/faq/blogs.html)
* [API overview](http://mobxjs.github.io/mobx/refguide/api.html)
* [Tutorials, Blogs & Videos](http://mobxjs.github.io/mobx/faq/blogs.html)
* [Boilerplates](http://mobxjs.github.io/mobx/faq/boilerplates.html)
* [Related projects](http://mobxjs.github.io/mobx/faq/related.html)


## What others are saying...

> After using #mobx for lone projects for a few weeks, it feels awesome to introduce it to the team. Time: 1/2, Fun: 2X

> Working with #mobx is basically a continuous loop of me going “this is way too simple, it definitely won’t work” only to be proven wrong

> Try react-mobx with es6 and you will love it so much that you will hug someone.

> I have built big apps with MobX already and comparing to the one before that which was using Redux, it is simpler to read and much easier to reason about.

> The #mobx is the way I always want things to be! It's really surprising simple and fast! Totally awesome! Don't miss it!

## Contributing

* Feel free to send small pull requests. Please discuss new features or big changes in a GitHub issue first.
* Use `npm test` to run the basic test suite, `npm run coverage` for the test suite with coverage and `npm run perf` for the performance tests.

## Bower support

Bower support is available through the infamous unpkg.com:
`bower install https://unpkg.com/mobx/bower.zip`

Then use `lib/mobx.umd.js` or `lib/mobx.umd.min.js`

## MobX was formerly known as Mobservable.

See the [changelog](https://github.com/mobxjs/mobx/blob/master/CHANGELOG.md#200) for all the details about `mobservable` to `mobx`.

## Donating

Was MobX key in making your project a success? Share the victory by using the [donate button](https://mobxjs.github.io/mobx/donate.html)!
MobX is developed largely in free time, so any ROI is appreciated :-).
If you leave a name you will be added to the [sponsors](https://github.com/mobxjs/mobx/blob/master/sponsors.md) list :).
