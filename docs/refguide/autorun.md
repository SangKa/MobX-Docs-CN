# Autorun

当你想创建一个响应式函数，而函数本身永远不会有观察者，在这类场景下可以使用 `mobx.autorun`。
这通常是当你需要从反应式代码桥接到命令式代码的情况，例如打印日志、持久化或者更新UI的代码。
当使用 `autorun` 时，所提供的函数总是立即被触发一次，然后每次它的一个依赖关系改变时会再次被触发。
相比之下，`computed(function)` 创建的函数只有当它有自己的观察者时才会重新计算，否则它的值会被认为是不相关的。
作为经验法则：如果你有一个函数应该自动运行，但不会产生一个新的值，请使用`autorun`。
其余情况都应该使用 `computed`。 Autoruns 是关于启动 _效果_ 的 ，而不是产生新的值。
如果字符串作为第一个参数传递给 `autorun` ，它将被用作调试名。

传递给 autorun 的函数在调用时将接收一个参数，即当前 reaction(autorun)，可用于在执行期间处理 autorun。

就像 [`@ observer` 装饰器/函数](./ observer-component.md)，`autorun` 只会观察在执行期间提供的函数时所使用的数据。

```javascript
var numbers = observable([1,2,3]);
var sum = computed(() => numbers.reduce((a, b) => a + b, 0));

var disposer = autorun(() => console.log(sum.get()));
// prints '6'
numbers.push(4);
// prints '10'

disposer();
numbers.push(5);
// won't print anything, nor is `sum` re-evaluated
```

## Error handling

Exceptions thrown in autorun and all other types reactions are catched and logged to the console, but not propagated back to the original causing code.
This is to make sure that a reaction in one exception does not prevent the scheduled execution of other, possibly unrelated, reactions.
This also allows reactions to recover from exceptions; throwing an exception does not break the tracking done by MobX,
so as subsequent run of a reaction might complete normally again if the cause for the exception is removed.

It is possible to override the default logging behavior of Reactions by calling the `onError` handler on the disposer of the reaction.
Example:

```javascript
const age = observable(10)
const dispose = autorun(() => {
    if (age.get() < 0)
        throw new Error("Age should not be negative")
    console.log("Age", age.get())
})

age.set(18)  // Logs: Age 18
age.set(-10) // Logs "Error in reaction .... Age should not be negative
age.set(5)   // Recovered, logs Age 5

dispose.onError(e => {
    window.alert("Please enter a valid age")
})

age.set(-5)  // Shows alert box
```

A global onError handler can be set as well through `extras.onReactionError(handler)`. This can be useful in tests or for monitoring.
