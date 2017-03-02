# MobX 要点

到目前为止，这一切都可能听起来有点花哨，但使用 MobX 将一个应用变成响应式的可归纳为以下三个步骤:

## 1. 定义状态并使其可观察

可以用任何你喜欢的数据结构来存储状态，如对象、数组、类。
循环数据结构、引用，都没有关系。
只要确保所有会随时间流逝而改变的属性打上 `mobx` 的标记使它们变得可观察即可。

```javascript
import {observable} from 'mobx';

var appState = observable({
    timer: 0
});
```

## 2. 创建视图以响应状态的变化

我们的 `appState` 还没有观察到任何的东西。
你可以创建视图，当 `appState` 中相关数据发生改变时视图会自动更新。
MobX 会以一种最小限度的方式来更新视图。
这一事实节省了你大量的样板文件，它有着[令人匪夷所思的高效](https://mendix.com/tech-blog/making-react-reactive-pursuit-high-performing-easily-maintainable-react-apps/)。

通常来说，任何函数都可以成为可以观察自身数据的响应式视图，MobX 可以任何符合ES5的JavaScript环境中应用。
但是在这所用的示例是 ES6版本的 React 组件视图。

```javascript
import {observer} from 'mobx-react';

@observer
class TimerView extends React.Component {
    render() {
        return (<button onClick={this.onReset.bind(this)}>
                Seconds passed: {this.props.appState.timer}
            </button>);
    }

    onReset () {
        this.props.appState.resetTimer();
    }
};

React.render(<TimerView appState={appState} />, document.body);
```

(`resetTimer` 函数的实现请见下节)

## 3. 更改状态

The third thing to do is to modify the state.
That is what your app is all about after all.
Unlike many other frameworks, MobX doesn't dictate how you do this.
There are best practices, but the key thing to remember is:
***MobX helps you do things in a simple straightforward way***.


The following code will alter your data every second, and the UI will update automatically when needed.
No explicit relations are defined in either the controller functions that _change_ the state or in the views that should _update_.
Decorating your _state_ and _views_ with `observable` is enough for MobX to detect all relationships.
Here are two examples of changing the state:

```javascript
appState.resetTimer = action(function reset() {
    appState.timer = 0;
});

setInterval(action(function tick() {
    appState.timer += 1;
}), 1000);
```

The `action` wrapper is only needed when using MobX in strict mode (by default off).
It is recommended to use action though as it will help you to better structure applications and expresses the intention of a function to modify state.
Also it automatically applies transactions for optimal performance.

Feel free to try this example on [JSFiddle](http://jsfiddle.net/mweststrate/wgbe4guu/) or by cloning the [MobX boilerplate project](https://github.com/mobxjs/mobx-react-boilerplate)
