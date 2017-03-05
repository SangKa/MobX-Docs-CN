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
// 输出 '6'
numbers.push(4);
// 输出 '10'

disposer();
numbers.push(5);
// 不会再输入任何值。`sum` 不会再重新计算。
```

## 错误处理

在 autorun 和所有其他类型 reaction 中抛出的异常会被捕获并打印到控制台，但不会传播回原始导致异常的代码。
这是为了确保一个异常中的 reaction 不会阻止其他可能不相关的 reaction 的预定执行。
这也允许 reaction 从异常恢复; 抛出异常不会破坏 MobX的跟踪，因此如果除去异常的原因，reaction 的后续运行可能会再次正常完成。

可以通过调用 reaction 的disposer的 `onError` 处理方法来覆盖 Reactions 的默认日志行为。
示例:

```javascript
const age = observable(10)
const dispose = autorun(() => {
    if (age.get() < 0)
        throw new Error("Age should not be negative")
    console.log("Age", age.get())
})

age.set(18)  // 输出: Age 18
age.set(-10) // 输出: Age should not be negative
age.set(5)   // 已恢复; 输出: Age 5

dispose.onError(e => {
    window.alert("Please enter a valid age")
})

age.set(-5)  // 显示alert弹出框
```

一个全局的 onError 处理方法可以通过 `extras.onReactionError(handler)` 来设置。这在测试或监控中很有用。
