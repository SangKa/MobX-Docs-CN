# 编写异步 Actions (动作)

`action` 包装/装饰器只会对当前运行的函数作出反应，而不会对当前运行函数所调用的函数（不包含在当前函数之内）作出反应！
这意味着如果 action 中存在 `setTimeout`、promise 的 `then` 或 `async` 语句，并且在回调函数中某些状态改变了，那么这些回调函数也应该包装在 `action` 中。创建异步 action 有几种方式。不能说某种方式一定比其他的好，本章只是列出编写异步代码的几种不同方式而已。
我们先从一个基础的示例开始:

### Promises

```javascript
mobx.configure({ enforceActions: true }) // 不允许在动作之外进行状态修改

class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@action
	fetchProjects() {
		this.githubProjects = []
		this.state = "pending"
		fetchGithubProjectsSomehow().then(
			projects => {
				const filteredProjects = somePreprocessing(projects)
				this.githubProjects = filteredProjects
				this.state = "done"
			},
			error => {
				this.state = "error"
			}
		)
	}
}
```

上面的示例会抛出异常，因为传给 `fetchGithubProjectsSomehow` promise 的回调函数不是 `fetchProjects` 动作的一部分，因为动作只会应用于当前栈。

首选的简单修复是将回调函数变成动作。(注意使用 `action.bound` 绑定在这很重要，以获取正确的 `this`!):


```javascript
mobx.configure({ enforceActions: true })

class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@action
	fetchProjects() {
		this.githubProjects = []
		this.state = "pending"
		fetchGithubProjectsSomehow().then(this.fetchProjectsSuccess, this.fetchProjectsError)

	}

	@action.bound
	fetchProjectsSuccess(projects) {
		const filteredProjects = somePreprocessing(projects)
		this.githubProjects = filteredProjects
		this.state = "done"
	}
	@action.bound
		fetchProjectsError(error) {
			this.state = "error"
		}
	}
```

尽管这很整洁清楚，但异步流程复杂后可能会略显啰嗦。另外一种方案是你可以使用 `action` 关键字来包装 promises 回调函数。推荐这么做，但不是强制的，还需要给它们命名:

```javascript
mobx.configure({ enforceActions: true })

class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@action
	fetchProjects() {
		this.githubProjects = []
		this.state = "pending"
		fetchGithubProjectsSomehow().then(
			// 内联创建的动作
			action("fetchSuccess", projects => {
				const filteredProjects = somePreprocessing(projects)
				this.githubProjects = filteredProjects
				this.state = "done"
			}),
			// 内联创建的动作
			action("fetchError", error => {
				this.state = "error"
			})
		)
	}
}
```

### `runInAction` 工具函数

内联动作的缺点是 TypeScript 无法对其进行类型推导，所以你应该为所有的回调函数定义类型。
你还可以只在动作中运行回调函数中状态修改的部分，而不是为整个回调创建一个动作。
这种模式的优势是它鼓励你不要到处写 `action`，而是在整个过程结束时尽可能多地对所有状态进行修改：

```javascript
mobx.configure({ enforceActions: true })

class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@action
	fetchProjects() {
		this.githubProjects = []
		this.state = "pending"
		fetchGithubProjectsSomehow().then(
			projects => {
				const filteredProjects = somePreprocessing(projects)
				// 将‘“最终的”修改放入一个异步动作中
				runInAction(() => {
					this.githubProjects = filteredProjects
					this.state = "done"
				})
			},
			error => {
				// 过程的另一个结局:...
				runInAction(() => {
					this.state = "error"
				})
			}
		)
	}
}
```

注意，`runInAction` 还可以给定第一个参数作为名称。`runInAction(f)` 实际上是 `action(f)()` 的语法糖。

### async / await

基于 async / await 的函数当开始使用动作时起初似乎会令人感到困惑。
因为在词法上它们看起来是同步函数，它给人的印象是 `@action` 应用于整个函数。
但事实并非若此，因为 async / await 只是围绕基于 promise 过程的语法糖。
结果是 `@action` 仅应用于代码块，直到第一个 `await` 。
在每个 `await` 之后，一个新的异步函数将启动，所以在每个 `await` 之后，状态修改代码应该被包装成动作。
这正是 `runInAction` 再次派上用场的地方:

```javascript
mobx.configure({ enforceActions: true })

class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@action
	async fetchProjects() {
		this.githubProjects = []
		this.state = "pending"
		try {
			const projects = await fetchGithubProjectsSomehow()
			const filteredProjects = somePreprocessing(projects)
			// await 之后，再次修改状态需要动作:
			runInAction(() => {
				this.state = "done"
				this.githubProjects = filteredProjects
			})
		} catch (error) {
			runInAction(() => {
				this.state = "error"
			})
		}
	}
}
```

### flows

然而，更好的方式是使用 `flow` 的内置概念。它们使用生成器。一开始可能看起来很不适应，但它的工作原理与 `async` / `await` 是一样的。只是使用 `function *` 来代替 `async`，使用 `yield` 代替 `await` 。
使用 `flow` 的优点是它在语法上基本与 `async` / `await` 是相同的 (只是关键字不同)，并且不需要手动用 `@action` 来包装异步代码，这样代码更简洁。

`flow` 只能作为函数使用，不能作为装饰器使用。
`flow` 可以很好的与 MobX 开发者工具集成，所以很容易追踪 `async` 函数的过程。

```javascript
mobx.configure({ enforceActions: true })

class Store {
	@observable githubProjects = []
	@observable state = "pending"

	fetchProjects = flow(function * () { // <- 注意*号，这是生成器函数！
		this.githubProjects = []
		this.state = "pending"
		try {
			const projects = yield fetchGithubProjectsSomehow() // 用 yield 代替 await
			const filteredProjects = somePreprocessing(projects)
			// 异步代码块会被自动包装成动作并修改状态
			this.state = "done"
			this.githubProjects = filteredProjects
		} catch (error) {
			this.state = "error"
		}
	})
}
```
