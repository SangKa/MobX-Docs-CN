#action

用法:
* `action(fn)`
* `action(name, fn)`
* `@action classMethod() {}`
* `@action(name) classMethod () {}`
* `@action boundClassMethod = (args) => { body }`
* `@action(name) boundClassMethod = (args) => { body }`
* `@action.bound classMethod() {}`
* `@action.bound(function() {})`

任何应用都有动作。动作是任何用来修改状态的东西。
使用MobX你可以在代码中显示的标记出动作所在的位置。
动作可以有助于更好的组织代码。
它接收一个函数并在用 `untracked`、`transaction` 和 `allowStateChanges` 包装后返回它。
建议在任何更改 observable 或者有副作用的函数上使用动作。
结合开发者工具的话，动作还能提供非常有用的调试信息。
和 [ES 5.1 setters](http://www.ecma-international.org/ecma-262/5.1/#sec-11.1.5) 一起使用 `@action` 装饰器(例如 `@action set propertyName`) 还不支持，尽管 [计算属性的 setter 是自动地动作](https://github.com/mobxjs/mobx/blob/gh-pages/docs/refguide/computed-decorator.md#setters-for-computed-values)。


注意: 当启用**严格模式**时，需要强制使用 `action`，参见 [`useStrict`](https://github.com/mobxjs/mobx/blob/gh-pages/docs/refguide/api.md#usestrict)。

想要获取更多 `action` 的详细介绍还可以参见 [MobX 2.2 发行说明](https://medium.com/p/45cdc73c7c8d/)。

`contact-list` 项目中的两个 action 示例:

```javascript
	@action	createRandomContact() {
		this.pendingRequestCount++;
		superagent
			.get('https://randomuser.me/api/')
			.set('Accept', 'application/json')
			.end(action("createRandomContact-callback", (error, results) => {
				if (error)
					console.error(error);
				else {
					const data = JSON.parse(results.text).results[0];
					const contact = new Contact(this, data.dob, data.name, data.login.username, data.picture)
					contact.addTag('random-user');
					this.contacts.push(contact);
					this.pendingRequestCount--;
				}
			}));
	}
```

## `async` 动作和 `runInAction`

`action` 只会影响当前运行的函数，而不是由当前函数调度(非调用)的函数。
这意味着如果你有一个 `setTimeout` ，promise 的 `.then` 或 `async` 构造，并且在回调中有一些更多的状态被改变，那些回调也应该应该用 `action` 来包装！
这就是上面的 `"createRandomContact-callback"` 动作所演示的。

如果你使用 `async` / `await`，这个有点棘手，因为你不能在 `action` 中只是包装异步函数体。
在这种情况下，`runInAction` 可以派上用场，把它放在你打算更新状态的地方。
(但不要在这些块中调用 `await`)。

示例:
```javascript
@action /*可选的*/ updateDocument = async () => {
    const data = await fetchDataFromUrl();
    /* 需要严格模式下，以允许更新状态: */
    runInAction("update state after fetching data", () => {
        this.data.replace(data);
        this.isSaving = true;
    })
}
```

`runInAction` 的用法: `runInAction(name?, fn, scope?)`.

如果你使用 babel，这个插件可以帮助你处理异步动作: [mobx-deep-action](https://github.com/mobxjs/babel-plugin-mobx-deep-action)。

## 绑定的动作

`action` 装饰器/函数遵循 javascript 中标准的绑定规则。
但是，Mobx 3引入了 `action.bound` 来自动地将动作绑定到目标对象。
注意，与 `action` 不同的是，`(@)action.bound` 不需要一个name参数，名称将始终基于动作绑定的属性。

示例:

```javascript
class Ticker {
	@observable this.tick = 0

	@action.bound
	increment() {
		this.tick++ // 'this' 永远都是正确的
	}
}

const ticker = new Ticker()
setInterval(ticker.increment, 1000)
```

或

```javascript
const ticker = observable({
	tick: 1,
	increment: action.bound(function() {
		this.tick++ // 绑定 'this'
	})
})

setInterval(ticker.increment, 1000)
```

_注意: *action.bound* 不要和箭头函数一起使用；箭头函数已经是绑定过的并且不能重新绑定。_
