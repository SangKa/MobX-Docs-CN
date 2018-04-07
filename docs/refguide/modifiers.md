# 装饰器

MobX 有一组装饰器来定义 observable 属性的行为。

* `observable`: `observable.deep` 的别名
* `observable.deep`: 任何 observable 都使用的默认的调节器。它将任何(尚未成为 observable )数组，映射或纯对象克隆并转换为 observable 对象，并将其赋值给给定属性
* `observable.ref`: 禁用自动的 observable 转换，只是创建一个 observable 引用
* `observable.shallow`: 只能与集合组合使用。 将任何分配的集合转换为 observable，但该集合的值将按原样处理
* `observable.struct`: 就像 `ref`, 但会忽略结构上等于当前值的新值
* `computed`: 创建一个衍生属性, 参见 [`computed`](computed-decorator.md)
* `computed(options)`: 同 computed , 可设置选项
* `computed.struct`: 与 `computed` 相同，但是只有当视图产生的值与之前的值结构上有不同时，才通知它的观察者
* `action`: 创建一个动作, 参见 [`action`](action.md)
* `action(name)`: 创建一个动作，重载了名称
* `action.bound`: 创建一个动作, 并将 `this` 绑定到了实例

装饰器可以使用 API `decorate`、`observable.object`、`extendObservable` 和 `observable` (创建对象时) 来指定对象成员的行为。
如果没有传入装饰器，默认为对任意键值对使用 `observable.deep`，对 getters 使用 `computed` 。

```javascript
import {observable, autorun, action} from "mobx";

var person = observable({
	name: "John",
	age: 42,
	showAge: false,

	get labelText() {
		return this.showAge ? `${this.name} (age: ${this.age})` : this.name;
	},

    // 动作:
    setAge(age) {
        this.age = age;
    }
}, {
    setAge: action
    // 其他属性默认为 observables / computed
});
```

```javascript
class Person {
	name = "John"
	age = 42
	showAge = false

	get labelText() {
		return this.showAge ? `${this.name} (age: ${this.age})` : this.name;
	}

    setAge(age) {
        this.age = age;
    }
}
// 使用 decorate 时，所有字段都应该指定 (毕竟，类里的非 observable 字段可能会更多)
decorate(Person, {
    name: observable,
    age: observable,
    showAge: observable,
    labelText: computed,
    setAge: action
})
```

## 深层可观察性

当 MobX 创建一个 observable 对象时，(使用 `observable`、 `observable.object` 或 `extendObservable`)，它引入的 observable 属性默认是使用 `deep` 调节器的。`deep` 调节器主要是为任何新分配的值递归调用 `observable(newValue)`。
会依次使用 `deep` 调节器...你可以想象。

这是一个非常便利的默认设置。无需额外的工作，分配给 observable 的所有值本身也将转变成 observable(除非它们已经是)，因此不需要额外的工作就可使对象转变成深 observable 。

## 引用可观察性

然后在某些情况下，不需要将对象转变成 observable 。
典型案例就是不可变对象，或者不是由你管理，而是由外部库管理的对象。
例如 JSX 元素、DOM 元素、像 History、window 这样的原生对象，等等。
对于这类对象，只需要存储引用而不用把它们转变成 observable 。

对于这些情况，可以使用 `ref` 调节器。它会确保创建 observable 属性时，只追踪引用而不会把它的值转变成 observable 。
示例:

```javascript
class Message {
    @observable message = "Hello world"

    // 虚构的例子，如果 author 是不可变的，我们只需要存储一个引用，不应该把它变成一个可变的 observable 对象
    @observable.ref author = null
}
```

或者使用 ES5 语法:

```javascript
function Message() {
    extendObservable({
        message: "Hello world",
        author: null
    }, {
        author: observable.ref
    })
}
```

注意，可以通过使用 `const box = observable.shallowBox（value）` 来创建一个装箱的 observable 引用

## 浅层可观察性

`observable.shallow` 调节器会应用“单层”可观察性。如果想创建一个 observable 引用的**集合**，那你会需要它。
如果新集合分配给具有此调节器的属性，那么它会转变成 observable，但它的值将保持原样，不同于 `deep` 的是它不会递归。
示例:

```javascript
class AuthorStore {
    @observable.shallow authors = []
}
```
在上面的示例中，使用普通的 author 数组分配给 `authors` 的话，会使用 observables 数组来更新 author，observables 数组包含原始的、非 observable 的 author 。

注意， `{ deep: false }` 了作为选项传给 `observable`、`observable.object`、`observable.array`、`observable.map` 和 `extendObservable` 来创建浅集合。
