## Observable 对象

如果把一个普通的 JavaScript 对象传递给 `observable` 方法，对象的所有属性都将被拷贝至一个克隆对象并将克隆对象转变成可观察的。
(普通对象是指不是使用构造函数创建出来的对象，而是以 `Object` 作为其原型，或者根本没有原型。)
默认情况下，`observable` 是递归应用的，所以如果对象的某个值是一个对象或数组，那么该值也将通过 `observable` 传递。

```javascript
import {observable, autorun, action} from "mobx";

var person = observable({
    // observable 属性:
	name: "John",
	age: 42,
	showAge: false,

    // 计算属性:
	get labelText() {
		return this.showAge ? `${this.name} (age: ${this.age})` : this.name;
	},

    // 动作:
    setAge: action(function(age) {
        this.age = age;
    })
});

// 对象属性没有暴露 'observe' 方法,
// 但不用担心, 'mobx.autorun' 功能更加强大
autorun(() => console.log(person.labelText));

person.name = "Dave";
// 输出: 'Dave'

person.setAge(21);
// 等等
```

当使对象转变成 observable 时，需要记住一些事情:

* 当通过 `observable` 传递对象时，只有在把对象转变 observable 时存在的属性才会是可观察的。
稍后添加到对象的属性不会变为可观察的，除非使用 [`extendObservable`](extend-observable.md)。
* 只有普通的对象可以转变成 observable 。对于非普通对象，构造函数负责初始化 observable 属性。
要么使用 [`@observable`](observable.md) 注解，要么使用 [`extendObservable`](extend-observable.md) 函数。
* 属性的 getter 会自动转变成衍生属性，就像 [`@computed`](computed-decorator) 所做的。
* `observable` 是自动递归到整个对象的。在实例化过程中和将来分配给 observable 属性的任何新值的时候。Observable 不会递归到非普通对象中。
* 这些默认行为能应对95%的场景，但想要更细粒度的控制，比如哪些属性应该转变成可观察的和如何变成可观察的，请参见[调节器](modifiers.md)。

# `observable.object(props)` & `observable.shallowObject(props)`

`observable(object)` 只是 `observable.object(props)` 的简写形式。
默认所有属性都会转变成深 observable。
[调节器](modifiers.md) 可以用来为个别的属性覆盖此行为。
`shallowObject(props)` 可以用来把属性只是转变成浅 observable 。也就是说，对值的引用是可观察的，但是值本身不会自动转变成可观察的。

## 名称参数

`observable.object` 和 `observable.shallowObject` 都接收第二个参数作为 `spy` 或者 MobX 开发者工具中的调试名称。
