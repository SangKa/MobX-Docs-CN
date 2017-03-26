# createTransformer

`createTransformer<A, B>(transformation: (value: A) => B, onCleanup?: (result: B, value?: A) => void): (value: A) => B`

`createTransformer` 将一个函数(此函数把一个值转换为另一个值)转换为响应式且有记忆功能的函数。
换句话说，如果给 `transformation` 函数一个具体的A值，那么它将计算出B值，只要保持A值不变，那么今后任何时候的转换调用返回的B值也是不变的。
但是，如果A值改变了，将会重新应用转换，以便相应地更新B值。
最后但同样重要的是，如果没有人在使用具体A值的转换，则此条转换将从记忆表中移除。

使用 `createTransformer` 可以很容易的将一个完整数据图转换成另外一个数据图。
转换函数可以组合，这样你可以使用很多小的转换函数来构建一棵响应树。
生成的数据图会一直保持更新，它将通过对结果图应用小补丁来与源同步。
这使得它很容易实现强大的模式类似于 `sideways data loading`、map-reduce、使用不可变的数据结构跟踪状态历史等等。

可选的 `onCleanup` 函数可用于在不再需要对象的转换时获取通知。
如果需要，这可以用于清理附加到结果对象上的资源。

永远在 `@observer` 或 `autorun` 这样的 reaction 中使用转换。
如同任何其他计算值一样，如果没有被某些东西观察的话，这些转换也将会回退到惰性求值，尽管有点违背使用它们的初衷。

这一切可能仍然有点模糊，因此这里通过用两个使用小的响应式函数将一个数据结构转换成另一个数据结构的示例来解释这转换的整体思路:

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
我们来仔细看下一个示例 box#3 假想的生命周期。

1. 首先 box#3 是通过 `map` 传递给 `serializeBox` 的，执行 serializeBox 转换然后包含 box#3 的条目及其序列化表示会被添加到 `serializeBox` 的内部记忆表中。
2. 假如有另一个 box 被添加到 `store.boxes` 列表中。
这会导致 `serializeState` 函数再次计算，结果就是所有 boxes 的完全重新映射。
然而，所有的 `serializeBox` 的调用都会返回它们保存在内部记忆表中的旧值，这样它们的转换函数不会(需要)再次运行。
3. 接下来，如果有人改变了 box#3 的属性，这会导致 box#3 的 `serializeBox` 程序重新计算，就像 MobX 中的其他响应式函数一样。
因为转换会产生一个基于 box#3 的新的 json 对象，对应的转换中的所有观察者都被强制重新运行。
在这个示例中对应的是 `serializeState` 转换。
`serializeState` 会依次产生一个新的值并再次映射所有的 boxex 。但除了 box#3，其他所有的 boxes 都是从内部记忆表中直接返回的。
4. 最后，如果 box#3 从 `store.boxes` 移除了，那么 `serializeState` 会重新计算。
但是由于它不再使用 `serializeBox` 的程序操作 box#3，响应式函数会回退成非响应模式。
然后通知内部记忆表，该条目可以被删除，以便它准备好 GC。

所以在这里我们使用不可变的、共享的数据结构有效地实现了状态追踪。
所有的 boxes 和 arrows 都映射并简化到一个状态树。
每次变化都会导致 `states` 数组中产生一个新条目，但不同的条目将分享几乎所有的 box 和 arrow 状态表现。

## 将数据图转换为响应式数据图

转换函数返回的是普通值，作为替代还可以返回 observable 对象。
这个可以用来把一个 observable 数据图转换成另外一个 observable 数据图，得到的又可以进行转换...你懂得。

这有个小示例，是对一个响应式文件探测器进行编码，它将在每次更改时进行更新。
以这种方式构建的数据图通常反应更快，并且与使用你自己的代码更新的推导数据图相比,代码会更为直观，。参见一些示例的[性能测试](https://github.com/mobxjs/mobx/blob/3ea1f4af20a51a1cb30be3e4a55ec8f964a8c495/test/perf/transform-perf.js#L4)。

不同于前一个示例的是，`transformFolder` 在文件夹保持可见的情况下只会运行一次。
`DisplayFolder` 对象追踪 `Folder` 对象本身相关的东西。

在下面的示例中， `state` 图的所有变化都会被自动处理。
一些示例:
1. 改变文件夹的名称会更新对应的 `path` 属性和其所有后代的 `path` 属性。
2. 折叠文件夹会将从树中删除所有后代的 `DisplayFolders`。
3. 展开文件夹将再次恢复。
4. 设置搜索过滤器将删除不匹配过滤器的所有节点，除非它们有与过滤器匹配的后代节点。
5. 等等...


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
