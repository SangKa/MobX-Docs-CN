# 编写异步 Actions (动作)

`action` 包装/装饰器只会影响当前运行的函数，而不会影响当前函数调度(但不是调用)的函数！
这意味着如果你有一个 `setTimeout`、promise 的 `then` 或 `async` 语句，并且在回调函数中某些状态改变了，这些回调函数也应该包装在 `action` 中。创建异步动作很几种方式。不能说某种方式一定比其他的好，但是本章只是列出编写异步代码所用的不同方式。
我们先从一个基础的示例开始:

### Promises

```javascript
mobx.useStrict(true) // 不允许在动作之外进行状态修改

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

上面的示例会抛出异常，因为传给 `fethGithubProjectsSomehow` promise 的回调函数不是 `fetchProjects` 动作的一部分，因为动作只会应用于当前栈。

首选的简单修复是将回调函数变成动作。(注意绑定在这很重要，以获取正确的 `this`!):


```javascript
class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@action
	fetchProjects() {
		this.githubProjects = []
		this.state = "pending"
		fetchGithubProjectsSomehow().then(this.fetchProjectsSuccess, this.fetchProjectsError)

	}

	@action.bound // 回调动作
	fetchProjectsSuccess(projects) {
		const filteredProjects = somePreprocessing(projects)
		this.githubProjects = filteredProjects
		this.state = "done"
	}
	@action.bound // 回调动作
		fetchProjectsError(error) {
			this.state = "error"
		}
	}
```

尽管这很整洁清楚，但异步流程复杂后可能会略显啰嗦。另外一种方案是你可以使用 `action` 关键字来包装 promises 回调函数。推荐这么做，但不是强制的，还需要给它们命名:

```javascript
mobx.useStrict(true) // 不允许在动作之外进行状态修改

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
mobx.useStrict(true) // 不允许在动作之外进行状态修改

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
mobx.useStrict(true) // 不允许在动作之外进行状态修改

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

### babel-plugin-mobx-deep-action

如果你使用 babel，有一个插件在可以转译期间扫描 `@action` 方法并自动、正确地包装动作中的所有回调函数及 await 语句: [mobx-deep-action](https://github.com/mobxjs/babel-plugin-mobx-deep-action)。

### Generators & asyncAction

最后，在 [`mobx-utils` 包](https://github.com/mobxjs/mobx-utils)中还有一个 `asyncAction` 工具函数，它其实是使用 generators 来自动地在动作中包装 yield 过的 promises 。优点是它在语法上十分接近 async / await (使用不同的关键字)，并且异步部分不需要手动包装成动作，从而代码非常整洁。
只要确保每个 `yield` 返回 promise 。

`asyncAction` 可以作为装饰器和函数使用 (就像 `@action`)。
`asyncAction` 与 MobX 开发者工具结合很好，所以它可以很轻松的追踪异步函数的进程。
想了解更多详情，请参见 [asyncAction](https://github.com/mobxjs/mobx-utils#asyncaction) 的文档。

```javascript
import {asyncAction} from "mobx-utils"

mobx.useStrict(true) // 不允许在动作之外进行状态修改

class Store {
	@observable githubProjects = []
	@observable state = "pending" // "pending" / "done" / "error"

	@asyncAction
	*fetchProjects() { // <- 注意*号，这是一个 generator 函数!
		this.githubProjects = []
		this.state = "pending"
		try {
			const projects = yield fetchGithubProjectsSomehow() // 用 yield 代替 await
			const filteredProjects = somePreprocessing(projects)
			// 异步代码块会被自动包装成动作
			this.state = "done"
			this.githubProjects = filteredProjects
		} catch (error) {
			this.state = "error"
		}
	}
}
```
