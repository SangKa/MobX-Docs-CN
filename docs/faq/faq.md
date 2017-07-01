## 常见问题

##### 支持哪些浏览器?

MobX 只能在 ES5 环境中运行。这意味着支持 Node.js、Rhino和所有浏览器(除了 IE8及以下)。参见 [caniuse.com](http://caniuse.com/#feat=es5)

##### MobX 可以和 RxJS 一起使用吗?
可以，MobX 可以通过 [mobx-utils 中的 toStream 和 fromStream](https://github.com/mobxjs/mobx-utils#tostream) 使用 RxJS 和其它 TC 39 兼容的 observable。

##### 何时使用 RxJS 替代 MobX?
对于任何涉及明确使用时间的概念，或者当你需要推理一个 observable 历史值/事件(而不仅仅是最新的)时，建议使用 RxJS，因为它提供了更多的低层级的原始类型。
当你想对**状态**作出反应，而不是**事件**时，MobX 提供了一种更容易而且高层级处理方法。
实际上，结合 RxJS 和 MobX 可能会产生真正强大的架构。
例如使用 RxJS 来处理和节流用户事件，并作为更新状态的结果。
如果状态已经被 MobX 转变成 observable ，则它将相应地处理更新 UI 和其它衍生。

##### 支持 React Native 吗?

当然，`mobx` 和 `mobx-react` 都可以在 React Native 中使用。后者通过导入 `"mobx-react/native"` 。
开发者工具还不支持 React Native 。注意，如果你打算将状态存储在你希望能够与热重新加载一起使用的组件中，那么不要在组件中使用装饰器(注解)，使用函数替代(例如，用 `action(fn)` 替代 `@action`)。

##### MobX 如何兼容其它响应式框架?

参见此 [issue](https://github.com/mobxjs/mobx/issues/18) 以了解一些注意事项。

##### MobX 是框架吗?

MobX 不是一个框架。它不会告诉你如何去组织你的代码，在哪存储状态或者如何处理事件。然而，它可能将你从以性能的名义对你的代码提出各种限制的框架中解放出来。

##### MobX 可以和 Flux 一起使用吗?

假设 store 中的数据是不可变的，这很适合使用 MobX，而 Flux 的实现并不能很好的工作。
然而，使用 MobX 时，减少了对 Flux 的需求。
MobX 已经优化了渲染，它适用于大多数类型的数据，包括循环和类。
因此，其他编程范例(如经典MVC)现在也可以轻松应用于使用 ReactJS + MobX 的应用之中。

##### MobX 可以和其它框架一起使用吗?

或许吧。
MobX 是框架无关的，可以应用在任何现代JS环境中。
为了方便起见，它只是用一个小函数来将 ReactJS 组件转换为响应式视图函数。
MobX 同样可以在服务器端使用，并且它已经可以和 jQuery (参见此 [Fiddle](http://jsfiddle.net/mweststrate/vxn7qgdw)) 和 [Deku](https://gist.github.com/mattmccray/d8740ea97013c7505a9b) 一起使用了。


##### 可以记录状态并对其进行补充吗?

可以的, 参见 [createTransformer](http://mobxjs.github.io/mobx/refguide/create-transformer.html) 以查看一些示例。

##### 可以告诉我 MobX 是如何工作的吗?

当然可以，加入 reactiflux 频道或签出代码。或者，提交一个 issue，以激励我做一些更好的规划 :)。
还可以参见这篇 [Medium 文章](https://medium.com/@mweststrate/becoming-fully-reactive-an-in-depth-explanation-of-mobservable-55995262a254)。

##### 我可以在哪找到更多的 MobX 资源?

我们已经在 [官方的 awesome mobx](https://github.com/mobxjs/awesome-mobx#awesome-mobx) 中编辑了大量各种类型的有帮助的资源列表。如果你觉得它缺少某些资源的话，请开启 [issue](https://github.com/mobxjs/awesome-mobx/issues/new) 或 [pull request](https://github.com/mobxjs/awesome-mobx/compare) 来描述你想要寻找或分享您所添加的链接 :) 。
