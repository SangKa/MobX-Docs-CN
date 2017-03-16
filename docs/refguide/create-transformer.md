# createTransformer

`createTransformer<A, B>(transformation: (value: A) => B, onCleanup?: (result: B, value?: A) => void): (value: A) => B`

`createTransformer` 将一个函数(此函数把一个值转换为另一个值)转换为响应式且有记忆功能的函数。
换句话说，如果给 `transformation` 函数一个具体的A值，那么它将计算出B值，只要保持A值不变，那么今后任何时候的转换调用返回的B值也是不变的。
但是，如果A值改变了，将会重新应用转换，以便相应地更新B值。
最后但同样重要的是，如果没有人在使用具体A值的转换，则此条转换将从记忆表中移除。

使用 `createTransformer` 可以很容易的将一个完整数据图转换成另外一个数据图。
转换函数可以组合，这样你可以使用很多小的转换函数来构建一颗树。
结果数据图永远不会失效，它将通过对结果图应用小补丁与源同步。
这使得它很容易实现强大的模式类似于横向数据加载、map-reduce、使用不可变的数据结构跟踪状态历史等等。

可选的 `onCleanup` 函数可用于在不再需要对象的转换时获取通知。
如果需要，可以用于清理附加到结果对象上的资源。

永远在 `@observer` 或 `autorun` 这样的 reaction 中使用转换。
如同任何其他计算值一样，如果没有被某些东西观察的话，转换将会回退到惰性评估，这也算是一种任务失败吧。

这一切可能仍然有点模糊，因此这里用两个示例来解释通过使用小的响应式函数将一个数据结构转换成另一个数据结构的整体思路:

## 使用不可变的、同享的数据结构来追踪可变状态

本示例取自 [Reactive2015 conference demo](https://github.com/mobxjs/mobx-reactive2015-demo):

```javascript
/*
    store 保存了我们的领域对象: boxes 和 arrows
*/
const store = observable({
    boxes: [],
    arrows: [],
    selection: null
});

/**
    每次更改会把 store 序列化成 json 并将其添加到状态列表中
*/
const states = [];

autorun(() => {
    states.push(serializeState(store));
});

const serializeState = createTransformer(store => ({
    boxes: store.boxes.map(serializeBox),
    arrows: store.arrows.map(serializeArrow),
    selection: store.selection ? store.selection.id : null
}));

const serializeBox = createTransformer(box => ({...box}));

const serializeArrow = createTransformer(arrow => ({
    id: arrow.id,
    to: arrow.to.id,
    from: arrow.from.id
}));
```

在本示例中，state 是通过组合三个不同的转换函数序列化过的。
autorunner 触发 `store` 对象的序列化，也就是依次将 boxes 和 arrows 序列化。
我们来仔细看下一个假想的示例 box#3 的生命周期。

1. 首先 box#3 是通过 `map` 传递给 `serializeBox` 的，执行 serializeBox 转换然后包含 box#3 的条目及其序列化表示会被添加到 `serializeBox` 的内部记忆表中。
2. 想象一下，另一个 box 被添加到 `store.boxes` 列表中。
这会导致 `serializeState` 函数再次计算，结果就是所有 boxes 的完全重新映射。
然而，所有的 `serializeBox` 的调用都会返回它们保存在内部记忆表中的旧值，这样它们的转换函数不会(需要)再次运行。
3. 接下来，如果有人改变了 box#3 的属性，这会导致 box#3 的 `serializeBox` 程序重新计算，就像 MobX 中的其他响应式函数一样。
因为转换会产生一个基于 box#3 的新的 json 对象，对应的转换中的所有观察者都被强制重新运行。
在这个示例中对应的是 `serializeState` 转换。
`serializeState` 会依次产生一个新的值并再次映射所有的 boxex 。但除了 box#3，其他所有的 boxes 都是从内部记忆表中直接返回的。
4. 最后，如果 box#3 从 `store.boxes` 移除了，那么 `serializeState` 会重新计算。
但是由于它不再使用 `serializeBox` 的程序操作 box#3，响应式函数会回退成非响应模式。
然后通知内部记忆表，该条目可以被删除，以便它准备好 GC。

So effectively we have achieved state tracking using immutable, shared datas structures here.
All boxes and arrows are mapped and reduced into single state tree.
Each change will result in a new entry in the `states` array, but the different entries will share almost all of their box and arrow representations.

## Transforming a datagraph into another reactive data graph

Instead of returning plain values from a transformation function, it is also possible to return observable objects.
This can be used to transform an observable data graph into a another observable data graph, which can be used to transform... you get the idea.

Here is a small example that encodes a reactive file explorer that will update its representation upon each change.
Data graphs that are built this way will in general react a lot faster and will consist of much more straight-forward code,
compared to derived data graph that are updated using your own code. See the [performance tests](https://github.com/mobxjs/mobx/blob/3ea1f4af20a51a1cb30be3e4a55ec8f964a8c495/test/perf/transform-perf.js#L4) for some examples.

Unlike the previous example, the `transformFolder` will only run once as long as a folder remains visible;
the `DisplayFolder` objects track the associated `Folder` objects themselves.

In the following example all mutations to the `state` graph will be processed automatically.
Some examples:
1. Changing the name of a folder will update its own `path` property and the `path` property of all its descendants.
2. Collapsing a folder will remove all descendant `DisplayFolders` from the tree.
3. Expanding a folder will restore them again.
4. Setting a search filter will remove all nodes that do not match the filter, unless they have a descendant that matches the filter.
5. Etc.



```javascript
function Folder(parent, name) {
	this.parent = parent;
	m.extendObservable(this, {
		name: name,
		children: m.asFlat([]),
	});
}

function DisplayFolder(folder, state) {
	this.state = state;
	this.folder = folder;
	m.extendObservable(this, {
		collapsed: false,
		name: function() {
			return this.folder.name;
		},
		isVisible: function() {
			return !this.state.filter || this.name.indexOf(this.state.filter) !== -1 || this.children.some(child => child.isVisible);
		},
		children: function() {
			if (this.collapsed)
				return [];
			return this.folder.children.map(transformFolder).filter(function(child) {
				return child.isVisible;
			})
		},
		path: function() {
			return this.folder.parent === null ? this.name : transformFolder(this.folder.parent).path + "/" + this.name;
		}
	});
}

var state = m.observable({
	root: new Folder(null, "root"),
	filter: null,
	displayRoot: null
});

var transformFolder = m.createTransformer(function (folder) {
	return new DisplayFolder(folder, state);
});

m.autorun(function() {
    state.displayRoot = transformFolder(state.root);
});
```
