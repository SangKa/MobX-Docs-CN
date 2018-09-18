# 优化 React 组件渲染

MobX 非常快，[甚至比 Redux 更快](https://twitter.com/mweststrate/status/718444275239882753)。但本章节提供一些小贴士，以便充分利用 React 和 MobX。
请注意，大多数小贴士都适用于普通的 React，而非 MobX 专用的。

## 使用大量的小组件

`@observer` 组件会追踪它们使用的所有值，并且当它们中的任何一个改变时重新渲染。
所以你的组件越小，它们需要重新渲染产生的变化则越小;这意味着用户界面的更多部分具备彼此独立渲染的可能性。

## 在专用组件中渲染列表

这点在渲染大型数据集合时尤为重要。
React 在渲染大型数据集合时表现非常糟糕，因为协调器必须评估每个集合变化的集合所产生的组件。
因此，建议使用专门的组件来映射集合并渲染这个组件，且不再渲染其他组件:

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

在上面的示例中，当 `user.name` 改变时，React 会不必要地协调所有的 TodoView 组件。尽管TodoView 组件不会重新渲染，但是协调的过程本身是非常昂贵的。

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

## 不要使用数组的索引作为 key

不用使用数组索引或者任何将来可能会改变的值作为 key 。如果需要的话为你的对象生成 ids。
还可以参见这篇 [博客](https://medium.com/@robinpokorny/index-as-a-key-is-an-anti-pattern-e0349aece318)。

## 晚一点使用间接引用值

使用 `mobx-react` 时，推荐尽可能晚的使用间接引用值。
这是因为当使用 observable 间接引用值时 MobX 会自动重新渲染组件。
如果间接引用值发生在组件树的层级越深，那么需要重新渲染的组件就越少。

快的:

`<DisplayName person={person} />`

慢的:

`<DisplayName name={person.name} />`.

后者并没有什么错，但是当 `name` 属性变化时，第一种情况只会触发 `DisplayName` 组件重新渲染，而第二种情况组件的拥有者需要重新渲染，如果组件的拥有者渲染足够快的话，这种方式也能很好的运行。
、
你或许注意到了，为了获得最佳的性能，你不得不创建大量小的 observer 组件，它们每个都用来渲染特定数据的不同部分，例如:

`const PersonNameDisplayer = observer((props) => <DisplayName name={props.person.name} />)`

`const CarNameDisplayer = observer((props) => <DisplayName name={props.car.model} />)`

`const ManufacturerNameDisplayer = observer((props) => <DisplayName name={props.car.manufacturer.name} />)`

这是一种有效的选项，但如果数据模型比较庞大的话，这会变得冗长。另外一种选择是使用函数来返回想要渲染 `*Displayer` 的数据:

`const GenericNameDisplayer = observer((props) => <DisplayName name={props.getNameTracked()} />)`

然后，你可以使用类似这样的组件:

```javascript
render() {
  const { person, car } = this.props;
  return (
    <>
      <GenericNameDisplayer getNameTracked={() => person.name} />
      <GenericNameDisplayer getNameTracked={car.getModelTracked} />
      <GenericNameDisplayer getNameTracked={this.getManufacturerNameTracked} />
    </>
  );
}

getManufacturerNameTracked = () => this.props.car.manufacturer.name;

...
class Car {
  @observable model
  getModelTracked = () => this.model
}
```

这种方式允许 `GenericNameDisplayer` 渲染任何名称的组件，从而整个应用中复用。现在，还需要解决的是这些函数的放置问题: 示例中展示了三种可能性，你可以直接在 render 方法里创建函数 (这不是一个好的做法)，也可以将函数放置在组件中 (`getManufacturerNameTracked`)，或者将函数直接放在包含数据的对象之中 (`getModelTracked`)。

## 尽早绑定函数

此贴士适用于普通的 React 和特别是使用了 `PureRenderMixin` 的库，尽量避免在 render 方法中创建新的闭包。

还可参见一下资源:
* [使用属性初始化程序进行自动绑定](https://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html#autobinding)
* [用于 no-bind 的 ESLint 规则](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-bind.md)


不好的:

```javascript
render() {
    return <MyWidget onClick={() => { alert('hi') }} />
}
```

好的:

```javascript
render() {
    return <MyWidget onClick={this.handleClick} />
}

handleClick = () => {
    alert('hi')
}
```

不好的那个示例中， `MyWidget` 里使用的 `PureRenderMixin` 中的 `shouldComponent` 的返回值永远是 false，因为每当父组件重新渲染时你传递的都是一个新函数。
