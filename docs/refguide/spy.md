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
| reaction | object (Reaction instance), fn (source of the reaction) | 是
| compute | object (ComputedValue instance), target (scope), fn (source) | 否
| error | message | 否 |
| update (array) | object (the array), index, newValue, oldValue | 是
| update (map) | object (observable map instance), name, newValue, oldValue | 是
| update (object) | object (instance), name, newValue, oldValue | 是
| splice (array) | object (the array), index, added, removed, addedCount, removedCount | 是
| add (map) | object, name, newValue | 是
| add (object) | object, name, newValue | 是
| delete (map) | object, name, oldValue | 是
| create (boxed observable) | object (ObservableValue instance), newValue | 是 |

Note that there are events with the signature `{ spyReportEnd: true, time? }`.
These events might not have a `type` field, but they are part of an earlier fired event that had `spyReportStart: true`.
This event indicates the end of an event and this way groups of events with sub-events are created.
This event might report the total execution time as well.

The spy events for observable values are identical to the events passed to `observe`. See [intercept & observe](observe.md) for an extensive overview.

It is possible to emit your own spy events as well. See `extras.spyReport`, `extras.spyReportStart` and `extras.spyReportEnd`
