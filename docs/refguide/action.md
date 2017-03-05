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

Example:
```javascript
@action /*optional*/ updateDocument = async () => {
    const data = await fetchDataFromUrl();
    /* required in strict mode to be allowed to update state: */
    runInAction("update state after fetching data", () => {
        this.data.replace(data);
        this.isSaving = true;
    })
}
```

The usage of `runInAction` is: `runInAction(name?, fn, scope?)`.

If you use babel, this plugin could help you to handle your async actions: [mobx-deep-action](https://github.com/mobxjs/babel-plugin-mobx-deep-action).

## Bound actions

The `action` decorator / function follows the normal rules for binding in javascript.
However, Mobx 3 introduces `action.bound` to automatically bind actions to the targeted object.
Note that `(@)action.bound` does, unlike `action`, not take a name parameter, the name will always be based on the property the action is bound to.

Example:

```javascript
class Ticker {
	@observable this.tick = 0

	@action.bound
	increment() {
		this.tick++ // 'this' will always be correct
	}
}

const ticker = new Ticker()
setInterval(ticker.increment, 1000)
```

Or

```javascript
const ticker = observable({
	tick: 1,
	increment: action.bound(function() {
		this.tick++ // bound 'this'
	})
})

setInterval(ticker.increment, 1000)
```

_Note: don't use *action.bind* with arrow functions; arrow functions are already bound and cannot be rebound._
