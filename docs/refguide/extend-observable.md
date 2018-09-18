# extendObservable

`extendObservable(target, properties, decorators?, options?)`

ExtendObservable 用来向已存在的目标对象添加 observable 属性。
属性映射中的所有键值对都会导致目标上的新的 observable 属性被初始化为给定值。
属性映射中的任意 getters 都会转化成计算属性。

`decorators` 参数用来重载用于指定属性的装饰器，类似于 `decorate` 和 `observable.object` 。

使用 `deep: false` 选项可使得新的属性变成浅的。也就是说，阻止它们的值自动转换成 observables 。

```javascript
var Person = function(firstName, lastName) {
	// 在一个新实例上初始化 observable 属性
	extendObservable(this, {
		firstName: firstName,
		lastName: lastName,
		get fullName() {
			return this.firstName + " " + this.lastName
		},
		setFirstName(firstName) {
			this.firstName = firstName
		}
	}, {
		setFirstName: action
	});
}

var matthew = new Person("Matthew", "Henry");

// 向 observable 对象添加 observable 属性
extendObservable(matthew, {
	age: 353
});
```

注意:  `observable.object(object)` 实际上是 `extendObservable({}, object)` 的别名。

注意: 类似于 `extendObservable`，`decorate` 用来为对象引入 observable 属性。不同之处在于 `extendObservable` 被设计为直接在目标实例上引入属性，其中 `decorate` 将它们引入原型; 可以直接将它传递给构造函数 (类)，也可以将其作为其他人的原型。

注意: 不能使用 `extendObservable` 来为 observable 数组或对象上引入新的属性。