# Spy

用法: `spy(listener)`.
注册一个全局间谍监听器，用来监听所有 MobX 中的事件。
它类似于同时在**所有的** observable 上附加了一个 `observe` 监听器，而且还通知关于运行中的事务/反应和计算。
举例来说，`mobx-react-devtools` 中使用了 `spy`。

侦察所有动作的示例用法:
```
spy((event) => {
    if (event.type === 'action') {
        console.log(`${event.name} with args: ${event.arguments}`)
    }
})
```

间谍监听器永远接收一个对象，通常至少有一个 `type` 字段。默认情况下，spy 会发出以下事件。

| 事件 | 字段 | 嵌套的 |
| --- | --- |--- |
| action | name, target (作用域), arguments, fn (action 的原始函数 | 是 |
| transaction | name, target (作用域) | 是 |
| scheduled-reaction | object (Reaction 实例) | 否 |
| reaction | object (Reaction 实例), fn (reaction 的原始函数) | 是
| compute | object (ComputedValue 实例), target (作用域), fn (原始函数) | 否
| error | message | 否 |
| update (数组) | object (数组), index, newValue, oldValue | 是
| update (映射) | object (observable map 实例), name, newValue, oldValue | 是
| update (对象) | object (实例), name, newValue, oldValue | 是
| splice (数组) | object (数组), index, added, removed, addedCount, removedCount | 是
| add (映射) | object, name, newValue | 是
| add (对象) | object, name, newValue | 是
| delete (映射) | object, name, oldValue | 是
| create (boxed observable) | object (ObservableValue 实例), newValue | 是 |

注意签名是 `{ spyReportEnd: true, time? }` 的事件。
这些事件可能没有 `type` 字段，但是它们是具有 `spyReportStart：true` 的早期触发事件的一部分。
该事件指示事件的结束，并且以这种方式创建具有子事件的事件组。
此事件同样也可以报告总执行时间。

Observable 值的间谍事件与传递给 `observe` 的事件相同。想了解更多，请参见 [intercept & observe](observe.md)。

也可以发出你自己的间谍事件。参见 `extras.spyReport`、`extras.spyReportStart` 和 `extras.spyReportEnd` 。
