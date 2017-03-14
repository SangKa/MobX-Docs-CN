# 编写 Actions(动作)

使用 MobX 来编写动作是很直观的。
只是简单地创建、更改或删除数据，MobX 将确保变化会由 store 和依赖于这些数据的组件捕获。
在前一章节中我们所创建的 store 基础上，动作可以如此简单:

```javascript
var todo = todoStore.createTodo();
todo.task = "make coffee";
```

这足以创建一个待办事项，提交到服务器，并相应地更新我们的用户界面。

## 何时使用动作?

动作只应该在**修改**状态的函数上使用。
仅执行查找，过滤等操作的函数**不**应该标记为动作，以允许 MobX 追踪它们的调用。

## 异步动作

Writing asynchronous actions is pretty simple as well.
You can use observable data structures as a promise.
This is what happens with the `isLoading` property in the `todoStore` for example:
编写异步动作同样非常的简单。
可以使用 observable 数据结构作为 promise。
示例中 `todoStore` 的 `isLoading` 属性就是这样的:

```javascript
// ...
	this.isLoading = true;
	this.transportLayer.fetchTodos().then(fetchedTodos => {
		fetchedTodos.forEach(json => this.updateTodoFromServer(json));
		this.isLoading = false;
	});
// ...
```

After completing the asynchronous action, just update your data and your views will update.
The render function of a React component could become as simple as:

```javascript
import {observer} from "mobx-react";

var TodoOverview = observer(function(props) {
	var todoStore = props.todoStore;
	if (todoStore.isLoading) {
		return <div>Loading...</div>;
	} else {
		return <div>{
			todoStore.todos.map(todo => <TodoItem key={todo.id} todo={todo} />)
		}</div>
	}
});
```

The above `TodoOverview` component will now update whenever `isLoading` changes, or when `isLoading` is true and the `todos` list changes.
Note that we could have expressed `todoStore.isLoading` as `todoStore.todos.length` as well.
The result would be exactly the same.
