# when

`when(debugName?, predicate: () => boolean, effect: () => void, scope?)`

`when` 观察并运行给定的 `predicate`，直到返回true。
一旦返回 true，给定的 `effect` 就会被执行，然后 autorunner(自动运行程序) 会被清理。
该函数返回一个清理器以提前取消自动运行程序。

对于以响应式方式来进行处理或者取消，此函数非常有用。
示例:

```javascript
class MyResource {
	constructor() {
		when(
			// 一旦...
			() => !this.isVisible,
			// ... 然后
			() => this.dispose()
		);
	}

	@computed get isVisible() {
		// 标识此项是否可见
	}

	dispose() {
		// 清理
	}
}

```
