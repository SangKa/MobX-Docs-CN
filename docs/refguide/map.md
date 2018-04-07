# Observable 映射

## `observable.map(values, options?)`

`observable.map(values?)` - 创建一个动态键的 observable 映射。
如果你不但想对一个特定项的更改做出反应，而且对添加或删除该项也做出反应的话，那么 observable 映射会非常有用。
`observable.map(values)` 中的 values 可以是对象、 数组或者字符串键的 [ES6 map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)。

通过 ES6 Map 构造函数，你可以使用 `observable(new Map())` 或使用装饰器 `@observable map = new Map()` 的类属性来初始化 observable 映射 。

下列 observable 映射所暴露的方法是依据 [ES6 Map 规范](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map):

* `has(key)` - 返回映射是否有提供键对应的项。注意键的存在本身就是可观察的。
* `set(key, value)` - 把给定键的值设置为 `value` 。提供的键如果在映射中不存在的话，那么它会被添加到映射之中。
* `delete(key)` - 把给定键和它的值从映射中删除。
* `get(key)` - 返回给定键的值(或 `undefined`)。
* `keys()` - 返回映射中存在的所有键。插入顺序会被保留。
* `values()` - 返回映射中存在的所有值。插入顺序会被保留。
* `entries()` - 返回一个(保留插入顺序)的数组，映射中的每个键值对都会对应数组中的一项 `[key, value]`。
* `forEach(callback:(value, key, map) => void, thisArg?)` - 为映射中每个键值对调用给定的回调函数。
* `clear()` - 移除映射中的所有项。
* `size` - 返回映射中项的数量。

以下函数不属于 ES6 规范，而是由 MobX 提供:

* `toJS()` - 将 observable 映射转换成普通映射。
* `toJSON()`. 返回此映射的浅式普通对象表示。(想要深拷贝，请使用 `mobx.toJS(map)`)。
* `intercept(interceptor)` - 可以用来在任何变化作用于映射前将其拦截。参见 [observe & intercept](observe.md)。
* `observe(listener, fireImmediately?)` - 注册侦听器，在映射中的每个更改时触发，类似于为 [Object.observe](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/observe) 发出的事件。想了解更多详情，请参见 [observe & intercept](observe.md)。
* `merge(values)` - 把提供对象的所有项拷贝到映射中。`values` 可以是普通对象、entries 数组或者 ES6 字符串键的映射。
* `replace(values)` - 用提供值替换映射全部内容。是 `.clear().merge(values)` 的简写形式。

## `observable.map(values, { deep: false })`

任何分配给 observable 映射的值都会默认通过 [`observable`](observable.md) 来传递使其转变成可观察的。
创建浅映射以禁用此行为，并按原样存储值。关于此机制的更多详情，请参见 [装饰器](modifiers.md)。

## `observable.map(values, { name: "my map" })`

`name` 选项用来给数组一个友好的调试名称，用于 `spy` 或者 MobX 开发者工具。
