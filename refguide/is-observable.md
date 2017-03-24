# isObservable

如果给定值是通过 MobX 转变成 observable 的话，就返回 true 。
可选地接收第二个字符串参数用来参看具体的属性是否是 observable 。

```javascript
var person = observable({
	firstName: "Sherlock",
	lastName: "Holmes"
});

person.age = 3;

isObservable(person); // true
isObservable(person, "firstName"); // true
isObservable(person.firstName); // false (只是个字符串)
isObservable(person, "age"); // false
```

# isObservableMap

如果给定对象是使用 `mobx.map` 创建的则返回 true 。

# isObservableArray

如果给定对象是使用 `mobx.observable(array)` 转变成 observable 数组的则返回 true 。

# isObservableObject

如果给定对象是使用 `mobx.observable(object)` 转变成 observable 对象的则返回 true 。
