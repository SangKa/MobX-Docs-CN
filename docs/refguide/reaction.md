# Reaction

用法: `reaction(() => data, (data, reaction) => { sideEffect }, options?)`。

`autorun` 的变种，对于如何追踪 observable 赋予了更细粒度的控制。
它接收两个函数参数，第一个(*数据* 函数)是用来追踪并返回数据作为第二个函数(*效果* 函数)的输入。
不同于 `autorun` 的是当创建时*效果* 函数不会直接运行，只有在数据表达式首次返回一个新值后才会运行。
在执行 *效果* 函数时访问的任何 observable 都不会被追踪。

`reaction` 返回一个清理函数。
传入 `reaction` 的函数当调用时会接收两个参数，即当前的 reaction，可以用来在执行期间清理 `reaction` 。

值得注意的是 *效果* 函数**仅**对数据函数中**访问**的数据作出反应，这可能会比实际在效果函数使用的数据要少。
此外，*效果* 函数只会在表达式返回的数据发生更改时触发。
换句话说: `reaction`需要你生产 *效果* 函数中所需要的东西。

## 选项

Reaction 接收第三个参数，它是一个参数对象，有如下可选的参数:

* `fireImmediately`: 布尔值，用来标识效果函数是否在数据函数第一次运行后立即触发。默认值是 `false`，如果一个布尔值作为传给 `reaction` 的第三个参数，那么它会被解释为 `fireImmediately` 选项。
* `delay`: 可用于对效果函数进行去抖动的数字(以毫秒为单位)。如果是 0(默认值) 的话，那么不会进行去抖。
* `equals`: 默认值是 `comparer.default` 。如果指定的话，这个比较器函数被用来比较由 *数据* 函数产生的前一个值和后一个值。只有比较器函数返回 true *效果* 函数才会被调用。此选项如果指定的话，会覆盖 `compareStructural` 选项。
* `name`: 字符串，用于在例如像 [`spy`](spy.md) 这样事件中用作此 reaction 的名称。
* `onError`: 用来处理 reaction 的错误，而不是传播它们。
* `scheduler`: 设置自定义调度器以决定如何调度 autorun 函数的重新运行

## 示例

在下面的示例中，`reaction1`、`reaction2` 和 `autorun1` 都会对 `todos` 数组中的 todo 的添加、删除或替换作出反应。
但只有 `reaction2` 和 `autorun` 会对某个 todo 的 `title` 变化作出反应，因为在 `reaction2` 的数据表达式中使用了 `title`，而 `reaction1` 的数据表达式没有使用。
`autorun` 追踪完整的副作用，因此它将始终正确触发，但也更容易意外地访问相关数据。
还可参见 [MobX 会对什么作出反应?](../best/react).

```javascript
const todos = observable([
    {
        title: "Make coffee",
        done: true,
    },
    {
        title: "Find biscuit",
        done: false
    }
]);

// reaction 的错误用法: 对 length 的变化作出反应, 而不是 title 的变化!
const reaction1 = reaction(
    () => todos.length,
    length => console.log("reaction 1:", todos.map(todo => todo.title).join(", "))
);

// reaction 的正确用法: 对 length 和 title 的变化作出反应
const reaction2 = reaction(
    () => todos.map(todo => todo.title),
    titles => console.log("reaction 2:", titles.join(", "))
);

// autorun 对它函数中使用的任何东西作出反应
const autorun1 = autorun(
    () => console.log("autorun 1:", todos.map(todo => todo.title).join(", "))
);

todos.push({ title: "explain reactions", done: false });
// 输出:
// reaction 1: Make coffee, find biscuit, explain reactions
// reaction 2: Make coffee, find biscuit, explain reactions
// autorun 1: Make coffee, find biscuit, explain reactions

todos[0].title = "Make tea"
// 输出:
// reaction 2: Make tea, find biscuit, explain reactions
// autorun 1: Make tea, find biscuit, explain reactions
```

在下面的示例中，`reaction3` 会对 `counter` 中的 count 作出反应。
当调用 `reaction` 时，第二个参数会作为清理函数使用。
下面的示例展示了 `reaction` 只会调用一次。

```javascript
const counter = observable({ count: 0 });

// 只调用一次并清理掉 reaction : 对 observable 值作出反应。
const reaction3 = reaction(
    () => counter.count,
    (count, reaction) => {
        console.log("reaction 3: invoked. counter.count = " + count);
        reaction.dispose();
    }
);

counter.count = 1;
// 输出:
// reaction 3: invoked. counter.count = 1

counter.count = 2;
// 输出:
// (There are no logging, because of reaction disposed. But, counter continue reaction)

console.log(counter.count);
// 输出:
// 2
```

粗略地讲，reaction 是 `computed(expression).observe(action(sideEffect))` 或 `autorun(() => action(sideEffect)(expression)` 的语法糖。
