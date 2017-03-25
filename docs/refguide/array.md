## Observable 数组

和对象类似，可以使用 `observable.array(values?)` 或者将数组传给 `observable`，可以将数组转变为可观察的。
这也是递归的，所以数组中的所有(未来的)值都会是可观察的。

```javascript
import {observable, autorun} from "mobx";

var todos = observable([
	{ title: "Spoil tea", completed: true },
	{ title: "Make coffee", completed: false }
]);

autorun(() => {
	console.log("Remaining:", todos
		.filter(todo => !todo.completed)
		.map(todo => todo.title)
		.join(", ")
	);
});
// 输出: 'Remaining: Make coffee'

todos[0].completed = false;
// 输出: 'Remaining: Spoil tea, Make coffee'

todos[2] = { title: 'Take a nap', completed: false };
// 输出: 'Remaining: Spoil tea, Make coffee, Take a nap'

todos.shift();
// 输出: 'Remaining: Make coffee, Take a nap'
```

由于 ES5 中的原生数组的局限性，`observable.array` 会创建一个人造数组(类数组对象)来代替真正的数组。
实际上，这些数组能像原生数组一样很好的工作，并且支持所有的原生方法，包括从索引的分配到包含数组长度。

请记住无论如何 `Array.isArray(observable([]))` 都将返回 `false` ，所以无论何时当你需要传递 observable 数组到外部库时，通过使用 `array.slice()` **在 observable 数组传递给外部库或者内置方法前创建一份浅拷贝**(无论如何这都是最佳实践)总会是一个好主意。
换句话说，`Array.isArray(observable([]).slice())` 会返回 `ture`。

不同于 `sort` 和 `reverse` 函数的内置实现，observableArray.sort 和 observableArray.reverse 不会改变数组本身，而只是返回一个排序过/反转过的拷贝。

除了所有内置函数，observable 数组还可以使用下面的好东西:

* `intercept(interceptor)` - 可以用来在任何变化作用于数组前将其拦截。参见 [observe & intercept](observe.md)
* `observe(listener, fireImmediately? = false)` - 监听数组的变化。回调函数将接收表示数组拼接或数组更改的参数，它符合 [ES7 提议](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/observe)。它返回一个清理函数以用来停止监听器。
* `clear()` - 从数组中删除所有项。
* `replace(newItems)` - 用新项替换数组中所有已存在的项。
* `find(predicate: (item, index, array) => boolean, thisArg?, fromIndex?)` - 基本上等同于 ES7 的 `Array.find` 提议，除了多了一个 `fromIndex` 参数。
* `remove(value)` - 通过值从数组中移除一个单个的项。如果项被找到并移除的话，返回 `true` 。
* `peek()` - 和 `slice()` 类似， 返回一个有所有值的数组并且数组可以放心的传递给其它库。

与 `slice` 相反，`peek` 不创建保护性拷贝。如果你确定是以只读方式使用数组，请在性能关键的应用中使用此方法。
在性能关键的部分，还建议使用一个扁平的 `observable` 数组。

## `observable.shallowArray(values)`

任何分配给 observable 数组的值都会默认通过 [`observable`](observable.md) 来使其转变成可观察的。
创建浅数组以禁用此行为，并按原样存储值。关于此机制的更多详情，请参见 [调节器](modifiers.md)。

## 名称参数

`observable.array` 和 `observable.shallowArray` 都接收第二个参数作为 `spy` 或者 MobX 开发者工具中的调试名称。
