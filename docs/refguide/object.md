## Observable 对象

如果把一个普通的 JavaScript 对象传递给 `observable` 方法，对象的所有属性都将被拷贝至一个克隆对象并将克隆对象转换成 observable 。
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
    setAge: action(function() {
        this.age = 21;
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

Some things to keep in mind when making objects observable:

* When passing objects through `observable`, only the properties that exist at the time of making the object observable will be observable.
Properties that are added to the object at a later time won't become observable, unless [`extendObservable`](extend-observable.md) is used.
* Only plain objects will be made observable. For non-plain objects it is considered the responsibility of the constructor to initialize the observable properties.
Either use the [`@observable`](observable.md) annotation or the [`extendObservable`](extend-observable.md) function.
* Property getters will be automatically turned into derived properties, just like [`@computed`](computed-decorator) would do.
* `observable` is applied recursively to a whole object graph automatically. Both on instantiation and to any new values that will be assigned to observable properties in the future. Observable will not recurse into non-plain objects.
* These defaults are fine in 95% of the cases, but for more fine-grained on how and which properties should be made observable, see the [modifiers](modifiers.md) section.

# `observable.object(props)` & `observable.shallowObject(props)`

`observable(object)` is just a shorthand for `observable.object(props)`.
All properties are by default made deep observable.
[modifiers](modifiers.md) can be used to override this behavior for individual properties.
`shallowObject(props)` can be used to make the properties only shallow observables. That is, the reference to the value is observabled, but the value itself won't be made observable automatically.

## Name argument

Both `observable.object` and `observable.shallowObject` take a second parameter which is used as debug name in for example `spy` or the MobX dev tools.
