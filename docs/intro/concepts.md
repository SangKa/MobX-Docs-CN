# 概念与原则

## 概念

MobX 区分了以下几个应用中的概念。 在之前的要点中已经见过了，现在让我们更深入地了解它们。

### 1. State(状态)

**状态** 是驱动应用的数据。
通常有像待办事项列表这样的**领域特定状态**，还有像当前已选元素的**视图状态**。
记住，状态就像是有数据的excel表格。

### 2. Derivations(推导)

**任何** 源自**状态**并且不会再有任何进一步的相互作用的东西就是推导。
推导以多种形式存在:

* **用户界面**
* **推导数据**，比如剩下的待办事项的数量。
* **后端集成**，比如把变化发送到服务器端。

MobX 区分了两种类型的推导:
* **Computed values(计算值)** - 它们是永远可以使用纯函数(pure function)从当前可观察状态中推导出的值。
* **Reactions(反应)** - Reactions 是当状态改变时需要自动发生的副作用。需要有一个桥梁来连接命令式编程(imperative programming)和响应式编程(reactive programming)。或者说得更明确一些，它们最终都需要实现I / O 操作。

刚开始使用 MobX 时，人们倾向于频繁的使用 reactions。
黄金法则: 如果你想创建一个基于当前状态的值时，请使用 `computed`。

回到excel表格这个比喻中来，公式是**计算**值的推导。但对于用户来说，能看到屏幕给出的**反应**则需要部分重绘GUI。

### 3. Actions(动作)

**动作** 是任何改变**状态**的一段代码。用户事件、后端数据推送、预定事件、等等。
动作类似于用户在excel单元格中输入一个新的值。

Actions can be defined explicitly in MobX to help you to structure code more clearly.
If MobX is used in *strict mode*, MobX will enforce that no state can be modified outside actions.

## 原则

MobX supports an uni-directional data flow where _actions_ changes the _state_, which in turn updates all affected _views_.

![Action, State, View](../images/action-state-view.png)

All _Derivations_ are updated **automatically** and **atomically** when the _state_ changes. As a result it is never possible to observe intermediate values.

All _Derivations_ are updated **synchronously** by default. This means that for example _actions_ can safely inspect a computed value directly after altering the _state_.

_Computed values_ are updated **lazily**. Any computed value that is not actively in use will not be updated until it is needed for a side effect (I/O).
If a view is no longer in use it will be garbage collected automatically.

All _Computed values_ should be **pure**. They are not supposed to change _state_.

## Illustration

The following listing illustrates the above concepts and principles:

```javascript
import {observable, autorun} from 'mobx';

var todoStore = observable({
	/* some observable state */
	todos: [],

	/* a derived value */
	get completedCount() {
		return this.todos.filter(todo => todo.completed).length;
	}
});

/* a function that observes the state */
autorun(function() {
	console.log("Completed %d of %d items",
		todoStore.completedCount,
		todoStore.todos.length
	);
});

/* ..and some actions that modify the state */
todoStore.todos[0] = {
	title: "Take a walk",
	completed: false
};
// -> synchronously prints 'Completed 0 of 1 items'

todoStore.todos[0].completed = true;
// -> synchronously prints 'Completed 1 of 1 items'

```

In the [10 minute introduction to MobX and React](https://mobxjs.github.io/mobx/getting-started.html) you can dive deeper into this example and build a user interface using [React](https://facebook.github.io/react/) around it.
