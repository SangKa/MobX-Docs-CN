## 原值类型值和引用类型值

JavaScript 中的所有原始类型值都是不可变的，因此它们都是不可观察的。
通常这是好的，因为 MobX 通常可以使包含值的**属性**转变成可观察的。
可参见 [observable objects](object.md)。
在极少数情况下，拥有一个不属于某个对象的可观察的“原始类型值”还是是很方便的。
对于这种情况，可以创建一个 observable 箱子以便管理这样的原始类型值。

### `observable.box(value)`

`observable.box(value)` 接收任何值并把值存储到箱子中。
使用 `.get()` 可以获取当前值，使用 `.set(newValue)` 可以更新值。

此外，还可以使用它的 `.observe` 方法注册回调，以监听对存储值的更改。
但因为 MobX 自动追踪了箱子的变化，在绝大多数情况下最好还是使用像 [`mobx.autorun`](autorun.md) 这样的 reaction 来替代。

`observable.box(scalar)` 返回的对象签名是:
* `.get()` - 返回当前值。
* `.set(value)` - 替换当前存储的值并通知所有观察者。
* `intercept(interceptor)` - 可以用来在任何变化应用前将其拦截。参见 [observe & intercept](observe.md)。
* `.observe(callback: (change) => void, fireImmediately = false): disposerFunction` - 注册一个观察者函数，每次存储值被替换时触发。返回一个函数以取消观察者。参见 [observe & intercept](observe.md)。`change` 参数是一个对象，其中包含 observable 的 `newValue` 和 `oldValue` 。

### `observable.shallowBox(value)`

`shallowBox` 创建一个基于 [`ref`](modifiers.md) 调节器的箱子。这意味着箱子里的任何(将来)值都不会自动地转换成 observable 。


### `observable(primitiveValue)`

When using the generic `observable(value)` method, MobX will create an observable box for any value that could not be turned into an observable automatically..

### Example

```javascript
import {observable} from "mobx";

const cityName = observable("Vienna");

console.log(cityName.get());
// prints 'Vienna'

cityName.observe(function(change) {
	console.log(change.oldValue, "->", change.newValue);
});

cityName.set("Amsterdam");
// prints 'Vienna -> Amsterdam'
```

Array Example:

```javascript
import {observable} from "mobx";

const myArray = ["Vienna"];
const cityName = observable(myArray);

console.log(cityName[0]);
// prints 'Vienna'

cityName.observe(function(observedArray) {
	if (observedArray.type === "update") {
		console.log(observedArray.oldValue + "->" + observedArray.newValue);
	} else if (observedArray.type === "splice") {
		if (observedArray.addedCount > 0) {
			console.log(observedArray.added + " added");
		}
		if (observedArray.removedCount > 0) {
			console.log(observedArray.removed + " removed");
		}
	}
});

cityName[0] = "Amsterdam";
// prints 'Vienna -> Amsterdam'

cityName[1] = "Cleveland";
// prints 'Cleveland added'

cityName.splice(0, 1);
// prints 'Amsterdam removed'
```

## Name argument

Both `observable.box` and `observable.shallowBox` take a second parameter which is used as debug name in for example `spy` or the MobX dev tools.
