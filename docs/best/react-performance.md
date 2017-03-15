# 优化 React 组件渲染

MobX 非常快，[甚至比 Redux 更快](https://twitter.com/mweststrate/status/718444275239882753)。但本章节一些小贴士，以便充分利用 React 和 MobX。
请注意，大多数小贴士适用与普通的 React，而非 MobX 专用的。

## 使用大量的小组件

`@observer` 组件会追踪它们使用的所有值，并且当它们中的任何一个改变时重新渲染。
所以你的组件越小，它们需要重新渲染产生的变化则越小。这意味着用户界面的更多部分具备彼此独立渲染的可能性。

## 在专用组件中渲染列表

这点在渲染大型数据集合时尤为重要。
React 在渲染大型数据集合时表现非常糟糕，因为协调器必须评估每个集合变化的集合所产生的组件。
因此，建议使用专门的组件来映射集合并渲染这个组件，而不再渲染其他组件:

不好的:

```javascript
@observer class MyComponent extends Component {
    render() {
        const {todos, user} = this.props;
        return (<div>
            {user.name}
            <ul>
                {todos.map(todo => <TodoView todo={todo} key={todo.id} />)}
            </ul>
        </div>)
    }
}
```

在上来的示例中，当 `user.name` 改变时，React 会不必要地协调所有的 TodoView 组件。尽管TodoView 组件不会重新渲染，但是协调的过程本身是非常昂贵的。

好的:

```javascript
@observer class MyComponent extends Component {
    render() {
        const {todos, user} = this.props;
        return (<div>
            {user.name}
            <TodosView todos={todos} />
        </div>)
    }
}

@observer class TodosView extends Component {
    render() {
        const {todos} = this.props;
        return <ul>
            {todos.map(todo => <TodoView todo={todo} key={todo.id} />)}
        </ul>)
    }
}
```

## Don't use array indexes as keys

Don't use array indexes or any value that might change in the future as key. Generate id's for your objects if needed.
See also this [blog](https://medium.com/@robinpokorny/index-as-a-key-is-an-anti-pattern-e0349aece318).

## Dereference values late

When using `mobx-react` it is recommended to dereference values as late as possible.
This is because MobX will re-render components that dereference observable values automatically.
If this happens deeper in your component tree, less components have to re-render.

Fast:

`<DisplayName person={person} />`

Slower:

`<DisplayName name={person.name} />`.

There is nothing wrong to the latter.
But a change in the `name` property will, in the first case, trigger the `DisplayName` to re-render, while in the latter, the owner of the component has to re-render.
However, it is more important for your components to have a comprehensible API than applying this optimization.
To have the best of both worlds, consider making smaller components:

`const PersonNameDisplayer = observer(({ props }) => <DisplayName name={props.person.name} />)`

## Bind functions early

This tip applies to React in general and libraries using `PureRenderMixin` especially, try to avoid creating new closures in render methods.

See also these resources:
* [Autobinding with property initializers](https://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html#autobinding)
* [ESLint rule for no-bind](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-bind.md)


Bad:

```javascript
render() {
    return <MyWidget onClick={() => { alert('hi') }} />
}
```

Good:

```javascript
render() {
    return <MyWidget onClick={this.handleClick} />
}

handleClick = () => {
    alert('hi')
}
```

The bad example will always yield the `shouldComponent` of `PureRenderMixin` used in `MyWidget` to always yield false as you pass a new function each time the parent is re-rendered.
