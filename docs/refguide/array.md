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

Bear in mind however that `Array.isArray(observable([]))` will yield `false`, so whenever you need to pass an observable array to an external library,
it is a good idea to _create a shallow copy before passing it to other libraries or built-in functions_ (which is good practice anyway) by using `array.slice()`.
In other words, `Array.isArray(observable([]).slice())` will yield `true`.

Unlike the built-in implementation of the functions `sort` and `reverse`, observableArray.sort and reverse  will not change the array in-place, but only will return a sorted / reversed copy.

Besides all built-in functions, the following goodies are available as well on observable arrays:

* `intercept(interceptor)`. Can be used to intercept any change before it is applied to the array. See [observe & intercept](observe.md)
* `observe(listener, fireImmediately? = false)` Listen to changes in this array. The callback will receive arguments that express an array splice or array change, conforming to [ES7 proposal](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/observe). It returns a disposer function to stop the listener.
* `clear()` Remove all current entries from the array.
* `replace(newItems)` Replaces all existing entries in the array with new ones.
* `find(predicate: (item, index, array) => boolean, thisArg?, fromIndex?)` Basically the same as the ES7 `Array.find` proposal, except for the additional `fromIndex` parameter.
* `remove(value)` Remove a single item by value from the array. Returns `true` if the item was found and removed.
* `peek()` Returns an array with all the values which can safely be passed to other libraries, similar to `slice()`.

In contrast to `slice`, `peek` doesn't create a defensive copy. Use this in performance critical applications if you know for sure that you use the array in a read-only manner.
In performance critical sections it is recommended to use a flat observable array as well.

## `observable.shallowArray(values)`

Any values assigned to an observable array will be default passed through [`observable`](observable.md) to make them observable.
Create a shallow array to disable this behavior and store are values as-is. See also [modifiers](modifiers.md) for more details on this mechanism.

## Name argument

Both `observable.array` and `observable.shallowArray` take a second parameter which is used as debug name in for example `spy` or the MobX dev tools.
