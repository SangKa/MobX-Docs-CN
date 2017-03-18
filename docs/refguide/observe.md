# Intercept & Observe

`observe` 和 `intercept` 可以用来监测单个 observable(它们**不**追踪嵌套的 observable) 的变化。
`intercept` 可以在变化作用于 observable 之前监测和修改变化。
`observe` 允许你在 observable 变化之后拦截改变。

## Intercept
用法: `intercept(target, propertyName?, interceptor)`

* `target`: 监测的 observable
* `propertyName`: 可选参数，用来指定某个属性进行拦截。注意，`intercept(user.name, interceptor)` 和 `intercept(user, "name", interceptor)` 根本是完全不同的。前者尝试给 `user.name`(或许根本不是一个 observable) 里面的**当前值**添加一个拦截器，而后者拦截 `user` 的 `name` 属性的变化。
* `interceptor`: 在**每次**变化作用于 observable 后调用的回调函数。接收一个用来描述变化的对象。

`intercept` 应该告诉 MobX 对于当前变化需要做些什么。
因此，它应该做下列事情中的某个:
1. 把从函数中接收到的 `change` 对象原样返回，这样变化会被应用。
2. 修改 `change` 对象并将其返回，例如数据标准化。但不是所有字段都是可以修改的，参见下面。
3. 返回 `null`，这表示此次变化可以被忽略而且不会应用。这是一个强大的概念，例如可以使你的对象临时性的不可改变。
4. 抛出异常，例如如果一些不变量未被满足。

该函数返回一个 `disposer` 函数，当调用时可以取消拦截器。
可以为同一个 observable 注册多个拦截器。
它们会按照注册的顺序串联起来。
如果一个拦截器返回 `null` 或抛出异常，其它的拦截器不会再执行。
还可以注册一个拦截器同时作用于父对象和某个属性。
在这种情况下，父对象的拦截器在属性拦截器之前运行。

```javascript
const theme = observable({
  backgroundColor: "#ffffff"
})

const disposer = intercept(theme, "backgroundColor", change => {
  if (!change.newValue) {
    // 忽略取消设置背景颜色
    return null;
  }
  if (change.newValue.length === 6) {
    // 补全缺少的 '#' 前缀
    change.newValue = '#' + change.newValue;
    return change;
  }
  if (change.newValue.length === 7) {
      // 这一定是格式正确的颜色代码！
      return change;
  }
  if (change.newValue.length > 10) disposer(); // 不再拦截今后的任何变化
  throw new Error("This doesn't like a color at all: " + change.newValue);
})
```

## Observe
用法: `observe(target, propertyName?, listener, invokeImmediately?)`

* `target`: 观察的 observable
* `propertyName`: 可选参数，用来指定某个属性进行观察。注意，`observe(user.name, listener)` 和 `observe(user, "name", listener)` 根本是完全不同的。前者观察 `user.name`(或许根本不是一个 observable) 里面的**当前值**，而后者观察 `user` 的 `name` 属性。
* `listener`: 在**每次**变化作用于 observable 后调用的回调函数。接收一个用来描述变化的对象，除了装箱的 observable，它调用 `listener` 有两个参数: `newValue、oldValue`。
* `invokeImmediately`: 默认是 false。如果你想 `observe` 直接使用 observable 的状态(而不是等待第一次变化)调用 `listener` 的话，把它设置为 true。不是所有类型的 observable 都支持。

该函数返回一个 `disposer` 函数，当调用时可以取消观察者。
注意，`transaction` 不影响 `observe` 方法工作。
意味着即使在一个 `transaction` 中，`observe` 也会触发每个变化的监听器。
因此，`autorun` 通常是一个更强大的和更具声明性的 `observe` 替代品。

_当 `observe` 被创建出来后就会对**变化**作出反应，而像 `autorun` 或 `reaction` 这样的反应当，它们变得可用时，它们会对**新值**做出反应。在大多数情况下，后者就足够了。_

示例:

```javascript
import {observable, observe} from 'mobx';

const person = observable({
	firstName: "Maarten",
	lastName: "Luther"
});

const disposer = observe(person, (change) => {
	console.log(change.type, change.name, "from", change.oldValue, "to", change.object[change.name]);
});

person.firstName =  "Martin";
// 输出: 'update firstName from Maarten to Martin'

disposer();
// 忽略任何未来的变化

// 观察单个字段
const disposer2 = observe(person, "lastName", (change) => {
	console.log("LastName changed to ", change.newValue);
});
```
Related blog: [Object.observe is dead. Long live mobx.observe](https://medium.com/@mweststrate/object-observe-is-dead-long-live-mobservable-observe-ad96930140c5)

## Event overview

The callbacks of `intercept` and `observe` will receive an event object which has at least the following properties:
* `object`: the observable triggering the event
* `type`: (string) the type of the current event

These are the additional fields that are available per type:

| observable type | event type | property | description | available during intercept | can be modified by intercept |
| -- | --- | ---| --| --| -- |
| Object | add | name | name of the property being added | √ | |
| | | newValue | the new value being assigned | √ | √ |
| | update\* | name | name of the property being updated | √ |  |
| | | newValue | the new value being assigned | √ | √ |
| | | oldValue | the value that is replaced |  |  |
| Array | splice | index | starting index of the splice. Splices are also fired by `push`, `unshift`, `replace` etc. | √ | |
| | | removedCount | amount of items being removed | √ | √ |
| | | added | array with items being added | √ | √ |
| | | removed | array with items that where removed | | |
| | | addCount | amount of items that where added | | |
| | update | index | index of the single entry that is being updated | √ | |
| | | newValue | the newValue that is / will be assigned | √ | √ |
| | | oldValue | the old value that was replaced | | |
| Map | add | name | the name of the entry that was added | √ | |
| | | newValue | the new value that is being assigned | √ | √ |
| | update | name | the name of the entry that is being updated | √ | |
| | | newValue | the new value that is being assigned | √ | √ |
| | | oldValue | the value that has been replaced | | |
| | delete | name | the name of the entry that is being removed | √ | |
| | | oldValue | the value of the entry that was removed | | |
| Boxed & computed observables | create | newValue | the value that was assigned during creation. Only available as `spy` event for boxed observables | | |
| | update | newValue | the new value being assigned | √ | √ |
| | | oldValue | the previous value of the observable | | |

_\* Note that object `update` events won't fire for updated computated values (as those aren't mutations). But it is possible to observe them by explicitly subscribing to the specific property using `observe(object, 'computedPropertyName', listener)`._
