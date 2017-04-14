# extendObservable

与 `Object.assign` 十分类似，`extendObservable` 接收两个或者更多的参数，一个是 `target` 对象，一个或多个 `properties` 映射。
它会把 `properties` 映射中的所有键值对添加到 `target` 对象中作为 observable 属性。

```javascript
var Person = function(firstName, lastName) {
	// 在一个新实例上初始化 observable 属性
	extendObservable(this, {
		firstName: firstName,
		lastName: lastName
	});
}

var matthew = new Person("Matthew", "Henry");

// 为已存在的 observable 对象添加一个 observable 属性
extendObservable(matthew, {
	age: 353
});
```

注意:  `observable.object(object)` 实际上是 `extendObservable({}, object)` 的别名。


注意，属性映射并不总是复制到目标上，但它们被视为属性描述符。
大多数值按原样复制，但包装在调节器中的值会作为特殊处理。有 getter 的属性也是如此。

## 调节器

[调节器](modifiers.md)可以用来为某个属性定义特殊的行为。
举例来说， `observable.ref` 创建一个 observable 引用，此引用不用自动将值转变为 observable，并且 `computed` 引入了推导属性:

```javascript
var Person = function(firstName, lastName) {
	// 在一个新实例上初始化 observable 属性
	extendObservable(this, {
		firstName: observable.ref(firstName),
		lastName: observable.ref(lastName),
		fullName: computed(function() {
			return this.firstName + " " + this.lastName
		})
	});
}
```

所有可用调节器的概览可以在 [调节器](modifiers.md) 章节中找到。

## 计算属性

计算属性还可以通过使用 *getter* 函数来写。可选地伴随一个 setter:

```javascript
var Person = function(firstName, lastName) {
	// 在一个新实例上初始化 observable 属性
	extendObservable(this, {
		firstName: firstName,
		lastName: lastName,
		get fullName() {
			return this.firstName + " " + this.lastName
		},
		set fullName(newValue) {
			var parts = newValue.split(" ")
			this.firstName = parts[0]
			this.lastName = parts[1]
		}
	});
}
```

_注意: getter / setter 是合法的 ES5 语法，并不需要编译器！_

## `extendShallowObservable`

`extendShallowObservable` 很像 `extendObservable`，除了默认情况下属性**不会**自动地将值转变为 observable 。
所以这和调用 `extendObservable` 并且每个属性都使用 `observable.ref` 很类似。
注意，`observable.deep` 可以用来让特定属性进行自动转换。
