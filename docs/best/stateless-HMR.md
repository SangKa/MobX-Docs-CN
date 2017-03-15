# 使用无状态组件的热加载(Hot Module Reloading)

当刚接触 MobX(和普通的 React) 时有一个挑战就是理解为什么热加载(HMR)有时会失败。当热加载起初工作时，它看起来像魔术一般(确实也是)，但是有一个关于 HMR 和 React 的粗糙边缘，那就是无状态组件。因为无状态组件不会显示地把自己定义为 React 组件，对于它们 HMR 不知道该怎么做，所以你经常会在控制台看到这样的警告:

```
[HMR] The following modules couldn't be hot updated: (Full reload needed)
This is usually because the modules which have changed (and their parents) do not know how to hot reload themselves. See http://webpack.github.io/docs/hot-module-replacement-with-webpack.html for more details.
[HMR]  - ./src/ToDoItem.jsx
```

当你开始使用 MobX 时，这一点尤其明显，因为 observables 使得创建大量的无状态组件变得非常容易。这里有一些小贴士，是关于如何构建无状态组件的同时还能享受HMR带来的便利:

## 使用函数声明来替代箭头函数

函数声明和箭头函数所做的事完全相同，但实际上它们具有在 React 开发者工具中具有名称的关键优势。

举例来说，这是使用箭头函数构建的无状态组件:

```javascript
const ToDoItem = observer(props => <div>{props.item}</div>);

export default ToDoItem;

```

然后在 React 开发者工具中是这样显示的:

![devtools-noname](../images/devtools-noDisplayName.png)

另一方面，使用函数声明允许你构建同样的无状态组件并且可以在开发者工具中看见名称:

```javascript
function ToDoItem(props) {
  return <div>{props.item}</div>
}

export default observer(ToDoItem);

```

现在开发者工具中可以正确的显示组件了:

![devtools-withname](../images/devtools-withDisplayName.png)

## 确保顶层组件是有状态的观察者

通过“有状态的观察者”，我的意思是使用 `React.Component` 或 `React.createClass` 创建的组件并且使用了 `@observer` 装饰器，像这样:

```javascript
import { observer } from 'mobx-react';

@observer
class App extends React.Component {
  constructor(props) {
    super(props);
    this.store = props.store;
  }

  render() {
    return (
      <div className="container">
        <h2>Todos:</h2>
        {
          this.store.todos.map((t, idx) => <ToDoItem key={idx} item={t}/>)
        }
      </div>
    );
  }
}

```

在本案例中，`ToDoItem` 是无状态的，但同样可以正常使用 HMR，因为 UI 树的根级是有状态的观察者。因此，每当我们改变**任何**无状态组件时，它都会热加载，因为观察者同样会在根组件中触发计算。既然根组件是一个正常的老式 React 组件，它会为所有的子组件触发 HMR，瞧！无状态组件、observables 和热加载魔法般的完美融合在一起！
