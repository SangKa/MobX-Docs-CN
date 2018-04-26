# Expr

由 `mobx-utils` 包提供。

`expr` 可以用来在计算值(computed values)中创建临时性的计算值。
嵌套计算值有助于创建低廉的计算以防止运行昂贵的计算。

在下面示例中，如果 selection 在其他地方改变，表达式会阻止 `TodoView` 组件重新渲染。
相反，只有当相关待办事项被(取消)选择时，组件才会重新渲染，这样发生的频率要低很多。

```javascript
const TodoView = observer(({todo, editorState}) => {
    const isSelected = mobx.expr(() => editorState.selection === todo);
    return <div className={isSelected ? "todo todo-selected" : "todo"}>{todo.title}</div>;
});
```

`expr(func)` 是 `computed(func).get()` 的别名。

请注意，传给 `expr` 的函数将在整个表达式值更改的情况下评估两次。
当它依赖的任何 observables 变化时，它会进行首次评估。
当其值的变化触发外部计算或反应评估时，将对其进行第二次评估，这将重新创建和重新评估表达式。