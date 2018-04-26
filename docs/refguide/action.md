# action (动作)

<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px" href="https://egghead.io/lessons/react-use-mobx-actions-to-change-and-guard-state">egghead.io 第5课: actions</a>

用法:
* `action(fn)`
* `action(name, fn)`
* `@action classMethod() {}`
* `@action(name) classMethod () {}`
* `@action boundClassMethod = (args) => { body }`
* `@action(name) boundClassMethod = (args) => { body }`
* `@action.bound classMethod() {}`

任何应用都有动作。动作是任何用来修改状态的东西。
使用MobX你可以在代码中显式地标记出动作所在的位置。
动作可以有助于更好的组织代码。

它接收一个函数并返回具有同样签名的函数，但是用 `transaction`、`untracked` 和 `allowStateChanges` 包裹起来，尤其是 `transaction` 的自动应用会产生巨大的性能收益，
动作会分批处理变化并只在(最外层的)动作完成后通知计算值和反应。
这将确保在动作完成之前，在动作期间生成的中间值或未完成的值对应用的其余部分是不可见的。

建议对任何修改 observables 或具有副作用的函数使用 `(@)action` 。
结合开发者工具的话，动作还能提供非常有用的调试信息。

不支持使用 setters 的 `@action` 装饰器，但是，[计算属性的 setters 是自动的动作](https://github.com/mobxjs/mobx/blob/gh-pages/docs/refguide/computed-decorator.md#setters-for-computed-values)。

注意: 在将 MobX 配置为需要通过动作来更改状态时，必须使用 `action` ，参见 [`enforceActions`](https://github.com/mobxjs/mobx/blob/gh-pages/docs/refguide/api.md#configure)。

## 何时使用动作？

应该永远只对**修改**状态的函数使用动作。
只执行查找，过滤器等函数**不**应该被标记为动作，以允许 MobX 跟踪它们的调用。

[“强制动作”](https://github.com/mobxjs/mobx/blob/gh-pages/docs/refguide/api.md#configure) 强制所有状态变更都必须通过动作来完成。在大型、长期的项目中，这是十分有用的最佳实践。

## 绑定的动作

`action` 装饰器/函数遵循 javascript 中标准的绑定规则。
但是，`action.bound` 可以用来自动地将动作绑定到目标对象。
注意，与 `action` 不同的是，`(@)action.bound` 不需要一个name参数，名称将始终基于动作绑定的属性。

示例:

```javascript
class Ticker {
	@observable tick = 0

	@action.bound
	increment() {
		this.tick++ // 'this' 永远都是正确的
	}
}

const ticker = new Ticker()
setInterval(ticker.increment, 1000)
```

_注意: *action.bound* 不要和箭头函数一起使用；箭头函数已经是绑定过的并且不能重新绑定。_

## `runInAction(name?, thunk)`

`runInAction` 是个简单的工具函数，它接收代码块并在(异步的)动作中执行。这对于即时创建和执行动作非常有用，例如在异步过程中。`runInAction(f)` 是 `action(f)()` 的语法糖。
