# Expr

`expr` 可以用来在计算值(computed values)中创建临时性的计算值。
嵌套计算值有助于创建低廉的计算以防止运行昂贵的计算。

在下面示例中，如果 selection 在其他地方改变，表达式会阻止 `TodoView` 组件重新渲染。
相反，只有当相关待办事项被(取消)选择时，组件才会重新渲染。

```javascript
const TodoView = observer(({todo, editorState}) => {
    const isSelected = mobx.expr(() => editorState.selection === todo);
    return <div className={isSelected ? "todo todo-selected" : "todo"}>{todo.title}</div>;
});
```

`expr(func)` 是 `computed(func).get()` 的别名。
