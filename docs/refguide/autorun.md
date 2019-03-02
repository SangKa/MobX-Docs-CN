# Autorun

<details>
    <summary style="color: white; background:green;padding:5px;margin:5px;border-radius:2px">egghead.io 第9课: 自定义反应</summary>
    <br>
    <div style="padding:5px;">
        <iframe style="border: none;" width=760 height=427  src="https://egghead.io/lessons/react-write-custom-mobx-reactions-with-when-and-autorun/embed" />
    </div>
    <a style="font-style:italic;padding:5px;margin:5px;"  href="https://egghead.io/lessons/react-write-custom-mobx-reactions-with-when-and-autorun">在 egghead.io 上观看</a>
</details>

当你想创建一个响应式函数，而该函数本身永远不会有观察者时,可以使用 `mobx.autorun`。
这通常是当你需要从反应式代码桥接到命令式代码的情况，例如打印日志、持久化或者更新UI的代码。
当使用 `autorun` 时，所提供的函数总是立即被触发一次，然后每次它的依赖关系改变时会再次被触发。
相比之下，`computed(function)` 创建的函数只有当它有自己的观察者时才会重新计算，否则它的值会被认为是不相关的。
经验法则：如果你有一个函数应该自动运行，但不会产生一个新的值，请使用`autorun`。
其余情况都应该使用 `computed`。 Autoruns 是关于 _启动效果_ (initiating effects) 的 ，而不是产生新的值。
如果字符串作为第一个参数传递给 `autorun` ，它将被用作调试名。

autorun的返回值是一个清理函数（disposer function），当你不需要 autorun 继续运行的时候，可以用这个清理函数来停止 autorun。传递给 autorun 的函数在调用时会被 autorun 传递唯一一个参数，即当前 reaction(autorun)，可用于在执行期间清理 autorun。这意味着有两种方式在需要的时候停止 autorun。

```javascript
const disposer = autorun( reaction => { /* do some stuff */ } );
disposer();

// 或者

autorun( reaction => {
  /* do some stuff */
  reaction.dispose();
} );
```

就像 [`@ observer` 装饰器/函数](./ observer-component.md)，`autorun` 只会观察在执行提供的函数时所使用的数据。

```javascript
var numbers = observable([1,2,3]);
var sum = computed(() => numbers.reduce((a, b) => a + b, 0));

var disposer = autorun(() => console.log(sum.get()));
// 输出 '6'
numbers.push(4);
// 输出 '10'

disposer();
numbers.push(5);
// 不会再输出任何值。`sum` 不会再重新计算。
```

## 选项

Autorun 接收第二个参数，它是一个参数对象，有如下可选的参数:

* `delay`: 可用于对效果函数进行去抖动的数字(以毫秒为单位)。如果是 0(默认值) 的话，那么不会进行去抖。
* `name`: 字符串，用于在例如像 [`spy`](spy.md) 这样事件中用作此 reaction 的名称。
* `onError`: 用来处理 reaction 的错误，而不是传播它们。
* `scheduler`: 设置自定义调度器以决定如何调度 autorun 函数的重新运行

## `delay` 选项

```javascript
autorun(() => {
    // 假设 profile.asJson 返回的是 observable Json 表示，
    // 每次变化时将其发送给服务器，但发送前至少要等300毫秒。
    // 当发送后，profile.asJson 的最新值会被使用。
	sendProfileToServer(profile.asJson);
}, { delay: 300 });
```

## `onError` 选项

在 autorun 和所有其他类型 reaction 中抛出的异常会被捕获并打印到控制台，但不会将异常传播回原始导致异常的代码。
这是为了确保一个异常中的 reaction 不会阻止其他可能不相关的 reaction 的预定执行。
这也允许 reaction 从异常中恢复; 抛出异常不会破坏 MobX的跟踪，因此如果除去异常的原因，reaction 的后续运行可能会再次正常完成。

可以通过提供 `onError` 选项来覆盖 Reactions 的默认日志行为。
示例:

```javascript
const age = observable.box(10)

const dispose = autorun(() => {
    if (age.get() < 0)
        throw new Error("Age should not be negative")
    console.log("Age", age.get())
}, {
    onError(e) {
        window.alert("Please enter a valid age")
    }
})
```

一个全局的 onError 处理方法可以使用 `onReactionError(handler)` 来设置。这在测试或监控中很有用。
