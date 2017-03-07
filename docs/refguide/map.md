# Observable 映射

## `observable.map(values)`

`observable.map(values?)` - 创建一个动态键的 observable 映射。
如果你不想只对一个特定项的更改做出反应，而是对添加或删除该项做出反应的话，那么 observable 映射会非常有用。
`observable.map(values)` 中的 values 可以是对象、 数组或者字符串键的 [ES6 map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)。
与 ES6 map 不同的是，键只能是字符串。

下列 observable 映射所暴露的方法是依据 [ES6 Map 规格](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map):

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

The following functions are not in the ES6 spec but are available in MobX:
* `toJS()`. Returns a shallow plain object representation of this map. (For a deep copy use `mobx.toJS(map)`).

* `intercept(interceptor)`. Registers an interceptor that will be triggered before any changes are applied to the map. See [observe & intercept](observe.md).
* `observe(listener, fireImmediately?)`. Registers a listener that fires upon each change in this map, similarly to the events that are emitted for [Object.observe](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/observe). See [observe & intercept](observe.md) for more details.
* `merge(values)`. Copies all entries from the provided object into this map. `values` can be a plain object, array of entries or string-keyed ES6 Map.
* `replace(values)`. Replaces the entire contents of this map with the provided values. Short hand for `.clear().merge(values)`

## `observable.shallowMap(values)`

Any values assigned to an observable map will be default passed through [`observable`](observable.md) to make them observable.
Create a shallow map to disable this behavior and store are values as-is. See also [modifiers](modifiers.md) for more details on this mechanism.

## Name argument

Both `observable.map` and `observable.shallowMap` take a second parameter which is used as debug name in for example `spy` or the MobX dev tools.
