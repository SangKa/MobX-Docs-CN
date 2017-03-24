# Untracked

Untracked 允许你运行一段代码而不建立观察者。
类似于 `transaction`，`untracked` 由 `(@)action` 自动应用，因此通常使用动作比直接使用 `untracked` 更有意义。
示例:

```javascript

const person = observable({
	firstName: "Michel",
	lastName: "Weststrate"
});

autorun(() => {
	console.log(
		person.lastName,
		",",
		// 这个untracked 块将返回 person 的 firstName 而不建立依赖
		untracked(() => person.firstName)
	);
});
// 输出: Weststrate, Michel

person.firstName = "G.K.";
// 没有输出!

person.lastName = "Chesterton";
// 输出: Chesterton, G.K.
```
