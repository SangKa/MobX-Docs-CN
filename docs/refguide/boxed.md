## 原值类型值和引用类型值

JavaScript 中的所有原始类型值都是不可变的，因此它们都是不可观察的。
通常这是好的，因为 MobX 通常可以使包含值的**属性**转变成可观察的。
可参见 [observable objects](object.md)。
在极少数情况下，拥有一个不属于某个对象的可观察的“原始类型值”还是是很方便的。
对于这种情况，可以创建一个 observable 箱子以便管理这样的原始类型值。

### `observable.box(value)`

So `observable.box(value)` accepts any value and stores it inside a box.
The current value can be accessed through `.get()` and updated using `.set(newValue)`.

Furthermore you can register a callback using its `.observe` method to listen to changes on the stored value.
But since MobX tracks changes to boxes automatically, in most cases it is better to use a reaction like [`mobx.autorun`](autorun.md) instead.

So the signature of object returned by `observable.box(scalar)` is:
* `.get()` Returns the current value.
* `.set(value)` Replaces the currently stored value. Notifies all observers.
* `intercept(interceptor)`. Can be used to intercept changes before they are applied. See [observe & intercept](observe.md)
* `.observe(callback: (change) => void, fireImmediately = false): disposerFunction`. Registers an observer function that will fire each time the stored value is replaced. Returns a function to cancel the observer. See [observe & intercept](observe.md). The `change` parameter is an object containing both the `newValue` and `oldValue` of the observable.

### `observable.shallowBox(value)`

`shallowBox` creates a box based on the [`ref`](modifiers.md) modifier. This means that any (future) value of box wouldn't be converted into an observable automatically.


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
