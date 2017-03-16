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

## Computed properties

Computed properties can also be written by using a *getter* function. Optionally accompanied with a setter:

```javascript
var Person = function(firstName, lastName) {
	// initialize observable properties on a new instance
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

_Note: getter / setter is valid ES5 syntax and doesn't require a transpiler!_

## `extendShallowObservable`

`extendShallowObservable` is like `extendObservable`, except that by default the properties will by default *not* automatically convert their values into observables.
So it is similar to calling `extendObservable` with `observable.ref` modifier for each property.
Note that `observable.deep` can be used to get the automatic conversion back for a specific property.
