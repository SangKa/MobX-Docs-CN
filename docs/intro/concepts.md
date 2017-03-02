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

在 MobX 中可以显示的定义动作，它可以帮你把代码组织的更清晰。
如果是在**严格模式**下使用 MobX的话，MobX 会强制只有在动作之中才可以修改状态。

## 原则

MobX 支持单向数据流，其中**动作**改变**状态**，而状态的改变会更新所有受影响的**视图**。

![Action, State, View](../images/action-state-view.png)

当**状态**改变时，所有的**推导**都会**自动**和**原子级**的更新。因此永远不可能观察到中间值。

所有**推导**默认都是**同步**更新。这意味着例如**动作**可以在改变**状态**之后直接可以安全地检查计算值。

**计算值** 是**延迟**更新的。任何不在使用状态的计算值将不会更新，直到需要它进行副作用（I / O）操作时。
如果视图不再使用，那么它会自动被垃圾回收。

所有的**计算值**都应该是**纯净**的。它们不应该用来改变**状态**。

## 实例

The following listing illustrates the above concepts and principles:
下面的代码清单举例说明了以上的概念和原则:

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

在[10分钟入门 MobX 和 React](https://mobxjs.github.io/mobx/getting-started.html)中你可以深入本示例并且围绕它使用 [React](https://facebook.github.io/react/) 来构建用户页面。
