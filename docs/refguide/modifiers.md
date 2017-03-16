# observable 调节器

调节器可以作为装饰器或者组合 `extendObservable` 和 `observable.object` 使用，以改变特定属性的自动转换规则。

* `observable.deep`: 任何 observable 都使用的默认的调节器。它把任何分配的、非原始数据类型的、非 observable 的值转换成 observable。
* `observable.ref`: 禁用自动的 observable 转换，只是创建一个 observable 引用。
* `observable.shallow`: 只能与集合组合使用。 将任何分配的集合转换为浅 observable (而不是深 observable)的集合。 换一种说法; 集合中的值将不会自动变为 observable。
* `computed`: 创建一个推导属性, 参见 [`computed`](computed-decorator.md)
* `action`: 创建一个动作, 参见 [`action`](action.md)

## 深层可观察性

当 MobX 创建一个 observable 对象时，(使用 `observable`、 `observable.object` 或 `extendObservable`)，它引入的 observable 属性默认是使用 `deep` 调节器的。`deep` 调节器主要是为任何新分配的值递归调用 `observable(newValue)`。
会依次使用 `deep` 调节器...你可以想象。

这是一个非常便利的默认设置。无需额外的工作，分配给 observable 的所有值本身也将转变成 observable(除非它们已经是)，因此不需要额外的工作就可使对象转变成深 observable 。

## Reference observability

In some cases however, objects don't need to be converted into observables.
Typical cases are immutable objects, or objects that are not managed by you but by an external library.
Examples are JSX elements, DOM elements, native objects like History, window or etc.
To those kind of objects, you just want to store a reference without turning them into an observable.

For these situations there is the `ref` modifier. It makes sure that an observable property is created, which only tracks the reference but doesn't try to convert its value.
For example:

```javascript
class Message {
    @observable message = "Hello world"

    // fictional example, if author is immutable, we just need to store a reference and shouldn't turn it into a mutable, observable object
    @observable.ref author = null
}
```

Or with just ES5 syntax:

```javascript
function Message() {
    extendObservable({
        message: "Hello world",
        author: observable.ref(null)
    })
}
```

Note that an observable, boxed reference can be created by using `const box = observable.shallowBox(value)`

## Shallow observability

The `observable.shallow` modifier applies observability 'one-level-deep'. You need those if you want to create a _collection_ of observable references.
If a new collection is assigned to a property with this modifier, it will be made observable, but its values will be left as is, so unlike `deep`, it won't recurse.
Example:

```javascript
class AuthorStore {
    @observable.shallow authors = []
}
```
In the above example an assignment of a plain array with authors to the `authors` will update the authors with an observable array, containing the original, non-observable authors.

Note that the following methods can be used to create shallow collections manually: `observable.shallowObject`, `observable.shallowArray`, `observable.shallowMap` and `extendShallowObservable`.

## Action & Computed

`action`, `action.bound`, `computed` and `computed.struct` can be used as modifiers as well.
See [`computed`](computed-decorator.md) respectively [`action`](action.md).

```javascript
const taskStore = observable({
    tasks: observable.shallow([]),
    taskCount: computed(function() {
        return this.tasks.length
    }),
    clearTasks: action.bound(function() {
        this.tasks.clear()
    })
})
```

## asStructure

MobX 2 had the `asStructure` modifier, which in practice was rarely used, or only used in cases where it is used `reference` / `shallow` is often a better fit (when using immutable data for example).
Structural comparision for computed properties and reactions is still possible.

## Effect of modifiers

```javascript
class Store {
    @observable/*.deep*/ collection1 = []

    @observable.ref collection2 = []

    @observable.shallow collection3 = []
}

const todos = [{ test: "value" }]
const store = new Store()

store.collection1 = todos;
store.collection2 = todos;
store.collection3 = todos;
```

After these assignments:

1. `collection1 === todos` is false; the contents of todos will be cloned into a new observable array
2. `collection1[0] === todos[0]` is false; the first todo was a plain object and hence it was cloned into an observable object which is stored in the array
3. `collection2 === todos` is true; the `todos` are kept as is, and are non-observable. Only the `collection2` property itself is observable.
4. `collection2[0] === todos[0]` is true; because of 3.
5. `collection3 === todos` is false; collection 3 is a new observable array
6. `collection3[0] === todos[0]` is true; the value of `collection3` was only shallowly turned into an observable, but the contents of the array is left as is.
