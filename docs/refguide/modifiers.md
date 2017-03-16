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

## 引用可观察性

然后在某些情况下，不需要将对象转变成 observable 。
典型案例就是不可变对象，或者不是由你管理，而是由外部库管理的对象。
例如 JSX 元素、DOM 元素、像 History、window 这样的原生对象，等等。
对于这类对象，只需要存储引用而不用把它们转变成 observable 。

对于这些情况，可以使用 `ref` 调节器。它会确保创建 observable 属性时，只追踪引用而不会把它的值转变成 observable 。
示例:

```javascript
class Message {
    @observable message = "Hello world"

    // 虚构的例子，如果 author 是不可变的，我们只需要存储一个引用，不应该把它变成一个可变的 observable 对象
    @observable.ref author = null
}
```

或者使用 ES5 语法:

```javascript
function Message() {
    extendObservable({
        message: "Hello world",
        author: observable.ref(null)
    })
}
```

注意，可以通过使用 `const box = observable.shallowBox（value）` 来创建一个装箱的 observable 引用

## 浅层可观察性

`observable.shallow` 调节器会应用“单层”可观察性。如果想创建一个 observable 引用的**集合**，那你会需要它。
如果新集合分配给具有此调节器的属性，那么它会转变成 observable，但它的值将保持原样，不同于 `deep` 的是它不会递归。
示例:

```javascript
class AuthorStore {
    @observable.shallow authors = []
}
```
在上面的示例中，使用普通的 author 数组分配给 `authors` 的话，会使用 observables 数组来更新 author，observables 数组包含原始的、非 observable 的 author 。

注意这些方法可用于手动创建浅集合: `observable.shallowObject`、 `observable.shallowArray`、 `observable.shallowMap` 和 `extendShallowObservable`。

## Action & Computed

`action`、`action.bound`、`computed` 和 `computed.struct` 同样可以作为调节器使用。
参见 [`computed`](computed-decorator.md) 和 [`action`](action.md)。

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

MobX 2 中有 `asStructure` 调节器，它在实践中极少被使用，或者只能在使用 `reference` / `shallow` 更适合(例如使用不可变数据)的情况下使用。
计算属性和 reaction 的结构比较仍是可能的。

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
