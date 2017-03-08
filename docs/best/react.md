# MobX 会对什么作出反应?

MobX 通常会对你期望的东西做出反应。
这意味着在90％的场景下，mobx “都可以工作”。
然而，在某些时候，你会遇到一个情况，它可能不会像你所所期望的那样工作。
在这个时候理解 MobX 如何确定对什么有反应就显得尤为重要。

> MobX 会对在执行跟踪函数期间读取的任何**现有的可观察属性**做出反应。

* **“读取”** 是对象属性的间接引用，可以用过 `.` (例如 `user.name`) 或者 `[]` (例如 `user['name']`) 的形式完成。
* **“可追踪函数”** 是 `computed` 表达式、observer 组件的 `render()` 方法和 `when`、`reaction` 和 `autorun` 的第一个入参函数。
* **“其间(during)”** 意味着只追踪那些在函数执行时被读取的 observable 。这些值是否由追踪函数直接或间接使用并不重要。

换句话所，MobX 不会对其作出反应:
 * 从 observable 获取的值，但是在追踪函数之外
 * 在异步调用的代码块中读取的 observable

## MobX 追踪属性访问，而不是值

用一个示例来阐述上述规则，假设你有如下的 observable 数据结构(默认情况下 `observable` 会递归应用，所以本示例中的所有字段都是可观察的)。

```javascript
let message = observable({
    title: "Foo",
    author: {
        name: "Michel"
    },
    likes: [
        "John", "Sara"
    ]
})
```

在内存中看起来像下面这样。 绿色框表示**可观察**属性。 请注意，**值** 本身是不可观察的！

![MobX reacts to changing references](../images/observed-refs.png)

现在 MobX 基本上所做的是记录你在函数中使用的是哪个**箭头**。之后，只要这些箭头中的其中一个改变了(它们开始引用别的东西了)，它就会重新运行。

## 示例

来看下下面这些示例(基于上面定义的 `message` 变量):

#### 正确的: 在追踪函数内进行间接引用

```javascript
autorun(() => {
    console.log(message.title)
})
message.title = "Bar"
```

这将如预期一样会作出反应，`title` 属性会被 autorun 间接引用并且发生了改变，所以这个改变是能检测到的。

你可以通过在追踪函数内调用 `whyRun()` 方法来验证 MobX 在追踪什么。以上面的函数为例，输出结果如下:

```javascript
autorun(() => {
    console.log(message.title)
    whyRun()
})

// 输出:
WhyRun? reaction 'Autorun@1':
 * Status: [running]
 * This reaction will re-run if any of the following observables changes:
    ObservableObject@1.title
```

#### Incorrect: changing a non-observable reference

```javascript
autorun(() => {
    console.log(message.title)
})
message = observable({ title: "Bar" })
```

This will **not** react. `message` was changed, but `message` is not an observable, just a variable which _refers to_ an observable,
but the variable (reference) itself is not observable.


#### Incorrect: dereference outside a tracked function

```javascript
var title = message.title;
autorun(() => {
    console.log(title)
})
message.title = "Bar"
```

This will **not** react. `message.title` was dereferenced outside the `autorun`, and just contains the value of `message.title` at the  moment of dereferencing (the string `"Foo"`).
`title` is not an observable so `autorun` will never react.

#### Correct: dereference inside the tracked function

```javascript
autorun(() => {
    console.log(message.author.name)
})
message.author.name = "Sara";
message.author = { name: "John" };
```

This will react to both changes. Both `author` and `author.name` are dotted into, allowing MobX to track these references.

#### Incorrect: store a local reference to an observable object without tracking

```javascript
const author = message.author;
autorun(() => {
    console.log(author.name)
})
message.author.name = "Sara";
message.author = { name: "John" };
```

The first change will be picked up, `message.author` and `author` are the same object, and the `.name` property is dereferenced in the autorun.
However the second change will **not** be picked up, the `message.author` relation is not tracked by the `autorun`. Autorun is still using the "old" `author`.

#### Correct: access array properties in tracked function


```javascript
autorun(() => {
    console.log(message.likes.length);
})
message.likes.push("Jennifer");
```

This will react as expected. `.length` counts towards a property.
Note that this will react to *any* change in the array.
Arrays are not tracked per index / property (like observable objects and maps) but as a whole.

#### Incorrect: access out-of-bounds indices in tracked function

```javascript
autorun(() => {
    console.log(message.likes[0]);
})
message.likes.push("Jennifer");
```

This will react with the above sample data, array indexers count as property access. But **only** if the provided `index < length`.
MobX will not track not-yet-existing indices or object properties (except when using maps).
So always guard your array index based access with a `.length` check.

#### Correct: access array functions in tracked function

```javascript
autorun(() => {
    console.log(message.likes.join(", "));
})
message.likes.push("Jennifer");
```

This will react as expected. All array functions that do not mutate the array are tracked automatically.

---

```javascript
autorun(() => {
    console.log(message.likes.join(", "));
})
message.likes[2] = "Jennifer";
```

This will react as expected. All array index assignments are detected, but only if `index <= length`.

#### Incorrect: "use" an observable but without accessing any of its properties

```javascript
autorun(() => {
    message.likes;
})
message.likes.push("Jennifer");
```

This will **not** react. Simply because the `likes` array itself is not being used by the `autorun`, only the reference to the array.
So in contrast, `messages.likes = ["Jennifer"]` would be picked up; that statement does not modify the array, but the `likes` property itself.

#### Incorrect: using non-observable object properties


```javascript
autorun(() => {
    console.log(message.postDate)
})
message.postDate = new Date()
```

This will **not** react. MobX can only track observable properties.

#### Incorrect: using not yet existing observable object properties

```javascript
autorun(() => {
    console.log(message.postDate)
})
extendObservable(message, {
    postDate: new Date()
})
```

This will **not** react. MobX will not react to observable properties that did not exist when tracking started.
If the two statements are swapped, or if any other observable causes the `autorun` to re-run, the `autorun` will start tracking the `postDate` as well.

#### Correct: using not yet existing map entries

```javascript
const twitterUrls = observable(asMap({
    "John": "twitter.com/johnny"
}))

autorun(() => {
    console.log(twitterUrls.get("Sara"))
})
twitterUrls.set("Sara", "twitter.com/horsejs")
```

This **will** react. Observable maps support observing entries that may not exist.
Note that this will initially print `undefined`.
You can check for the existence of an entry first by using `twitterUrls.has("Sara")`.
So for dynamically keyed collections, always use observable maps.


## MobX only tracks synchronously accessed data

```javascript
function upperCaseAuthorName(author) {
    const baseName = author.name;
    return baseName.toUpperCase();
}
autorun(() => {
    console.log(upperCaseAuthorName(message.author))
})
message.author.name = "Chesterton"
```
This will react. Even though `author.name` is not dereferenced by the thunk passed to `autorun` itself,
MobX will still track the dereferencing that happens in `upperCaseAuthorName`,
because it happens _during_ the execution of the autorun.

----

```javascript
autorun(() => {
    setTimeout(
        () => console.log(message.likes.join(", ")),
        10
    )
})
message.likes.push("Jennifer");
```

This will **not** react, during the execution of the `autorun` no observables where accessed, only during the `setTimeout`.
In general this is quite obvious and rarely causes issues.
The notable caveat here is passing renderable callbacks to React components, take for example the following example:

```javascript
const MyComponent = observer(({ message }) =>
    <SomeContainer
        title = {() => <div>{message.title}</div>}
    />
)

message.title = "Bar"
```

At first glance everything might seem ok here, except that the `<div>` is actually not rendered by `MyComponent` (which has a tracked rendering), but by `SomeContainer`.
So to make sure that the title of `SomeContainer` correctly reacts to a new `message.title`, `SomeContainer` should be an `observer` as well.
If `SomeContainer` comes from an external lib, you can also fix this by wrapping the `div` in its own stateless `observer` based component, and instantiating that one in the callback:

```javascript
const MyComponent = observer(({ message }) =>
    <SomeContainer
        title = {() => <TitleRenderer message={message} />}
    />
)

const TitleRenderer = observer(({ message }) =>
    <div>{message.title}</div>}
)

message.title = "Bar"
```

## Avoid caching observables in local fields

A common mistake is to store local variables that dereference observables, and then expect components to react. For example:

```javascript
@observer class MyComponent extends React.component {
    author;
    constructor(props) {
        super(props)
        this.author = props.message.author;
    }

    render() {
        return <div>{author.name}</div>
    }
}
```

This component will react to changes in the `author`'s name, but it won't react to changing the `.author` of the `message` itself! Because that dereferencing happened outside `render()`,
which is the only tracked function of an `observer` component.
Note that even marking the `author` component field as `@observable` field does not solve this; that field is still assigned only once.
This can simply be solved by doing the dereferencing inside `render()`, or by introducing a computed property on the component instance:

```javascript
@observer class MyComponent extends React.component {
    @computed get author() {
        return this.props.message.author
    }
// ...
```

## How multiple components will render

Suppose that we use the following components are used to render our above `message` object.

```javascript
const Message = observer(({ message }) =>
    <div>
        {message.title}
        <Author author={ message.author } />
        <Likes likes={ message.likes } />
    </div>
)

const Author = observer(({ author }) =>
    <span>{author.name}</span>
)

const Likes = observer(({ likes }) =>
    <ul>
        {likes.map(like =>
            <li>{like}</li>
        )}
    </ul>
)
```

| change | re-rendering component |
| --- | --- |
| `message.title = "Bar"` | `Message` |
| `message.author.name = "Susan"` | `Author` (`.author` is dereferenced in `Message`, but didn't change)* |
| `message.author = { name: "Susan"}` | `Message`, `Author` |
| `message.likes[0] = "Michel"` | `Likes` |

Notes:
1. \* If the `Author` component was invoked like: `<Author author={ message.author.name} />`. Then `Message` would be the dereferencing component and react to changes to `message.author.name`. Nonetheless `<Author>` would rerender as well, because it receives a new value. So performance wise it is best to dereference as late as possible.
2. \** If likes where objects instead of strings, and if they were rendered by their own `Like` component, the `Likes` component would not rerender for changes happening inside a specific like.

## TL;DR

> MobX reacts to any an _existing_ **observable** _property_ that is read during the execution of a tracked function.
