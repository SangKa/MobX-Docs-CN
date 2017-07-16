# Reaction

用法: `reaction(() => data, data => { sideEffect }, options?)`.

`autorun` 的变种，对于如何追踪 observable 赋予了更细粒度的控制。
它接收两个函数参数，第一个(**数据** 函数)是用来追踪并返回数据作为第二个函数(**效果** 函数)的输入。
不同于 `autorun` 的是当创建时副作用不会直接运行，只有在数据表达式首次返回一个新值后才会运行。
在执行副作用时访问的任何 observable 都不会被追踪。

副作用是可以去抖的，就像 `autorunAsync`。
`reaction` 返回一个清理函数。
传入 `reaction` 的函数当调用时会接收一个参数，即当前的 reaction，可以用来在执行期间进行清理。

值得注意的是副作用**仅**对数据函数中**访问**的数据作出反应，这可能会比实际在效果函数使用的数据要少。
此外，副作用只会在表达式返回的数据发生更改时触发。
换句话说: reaction 需要你生产副作用中所需要的东西。

## 选项

Reaction 接收第三个参数，它是一个参数对象，有如下可选的参数:

* `context`: 传给 `reaction` 的函数所使用的 `this`。默认是 undefined(使用箭头函数代替!)。
* `fireImmediately`: 布尔值，用来标识效果函数是否在数据函数第一次运行后立即触发。默认值是 `false`，如果一个布尔值作为传给 `reaction` 的第三个参数，那么它会被解释为 `fireImmediately` 选项。
* `delay`: 可用于对效果函数进行去抖动的数字(以毫秒为单位)。如果是 0(默认值) 的话，那么不会进行去抖。
* `compareStructural`: 默认值是 `false`。如果是 `true` 的话，**数据** 函数的返回值会在结构上与前一个返回值进行比较，并且**效果**函数只有在输出结构改变时才会被调用。也可以通过将 `equals` 选项设置为 `comparer.structural` 来指定同样的行为。
* `equals`: 默认值是 `comparer.default` 。如果指定的话，这个比较器函数被用来比较由**数据**函数产生的前一个值和后一个值。只有比较器函数返回 true **效果** 函数才会被调用。此选项如果指定的话，会覆盖 `compareStructural` 选项。
* `name`: 字符串，用于在例如像 [`spy`](spy.md) 这样事件中用作此 reaction 的名称。

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

粗略地讲，reaction 是 `computed(expression).observe(action(sideEffect))` 或 `autorun(() => action(sideEffect)(expression)` 的语法糖。
