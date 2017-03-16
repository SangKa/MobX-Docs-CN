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

In this example the state is serialized by composing three different transformation functions.
The autorunner triggers the serialization of the `store` object, which in turn serializes all boxes and arrows.
Let's take closer look at the life of an imaginary example box#3.

1. The first time box#3 is passed by `map` to `serializeBox`,
the serializeBox transformation is executed and an entry containing box#3 and its serialized representation is added to the internal memoization table of `serializeBox`.
2. Imagine that another box is added to the `store.boxes` list.
This would cause the `serializeState` function to re-compute, resulting in a complete remapping of all the boxes.
However, all the invocations of `serializeBox` will now return their old values from the memoization tables since their transformation functions didn't (need to) run again.
3. Secondly, if somebody changes a property of box#3 this will cause the application of the `serializeBox` to box#3 to re-compute, just like any other reactive function in MobX.
Since the transformation will now produce a new Json object based on box#3, all observers of that specific transformation will be forced to run again as well.
That's the `serializeState` transformation in this case.
`serializeState` will now produce a new value in turn and map all the boxes again. But except for box#3, all other boxes will be returned from the memoization table.
4. Finally, if box#3 is removed from `store.boxes`, `serializeState` will compute again.
But since it will no longer be using the application of `serializeBox` to box#3,
that reactive function will go back to non-reactive mode.
This signals the memoization table that the entry can be removed so that it is ready for GC.

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
