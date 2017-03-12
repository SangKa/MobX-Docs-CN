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
如果状态已经被 MobX 转变成 observable ，则它将相应地处理更新 UI 和其他推导。

##### 支持 React Native 吗?

当然，`mobx` 和 `mobx-react` 都可以在 React Native 中使用。后者通过导入 `"mobx-react/native"` 。
开发者工具还不支持 React Native 。注意，如果你打算将状态存储在你希望能够与热重新加载一起使用的组件中，那么不要在组件中使用装饰器(注解)，使用函数替代(例如，用 `action(fn)` 替代 `@action`)。

##### MobX 如何兼容其它响应式框架?

参见这个 [issue](https://github.com/mobxjs/mobx/issues/18) 以了解一些注意事项。

##### MobX 是框架吗?

MobX 不是一个框架。它不会告诉你如何去组织你的代码，在哪存储状态或者如何处理事件。然而，它可能将你从以性能的名义对你的代码提出各种限制的框架中解放出来。

##### MobX 可以和 Flux 一起使用吗?

Flux implementations that do not work on the assumption that the data in their stores is immutable should work well with MobX.
However, the need for Flux is reduced when using MobX.
MobX already optimizes rendering, and it works with most kinds of data, including cycles and classes.
So other programming paradigms like classic MVC can now be easily applied in applications that combine ReactJS with MobX.

##### Can I use MobX together with framework X?

Probably.
MobX is framework agnostic and can be applied in any modern JS environment.
It just ships with a small function to transform ReactJS components into reactive view functions for convenience.
MobX works just as well server side, and is already combined with jQuery (see this [Fiddle](http://jsfiddle.net/mweststrate/vxn7qgdw)) and [Deku](https://gist.github.com/mattmccray/d8740ea97013c7505a9b).

##### Can I record states and re-hydrate them?

Yes, see [createTransformer](http://mobxjs.github.io/mobx/refguide/create-transformer.html) for some examples.

##### Can you tell me how it works?

Sure, join the reactiflux channel or checkout the code. Or, submit an issue to motivate me to make some nice drawings :).
And look at this [Medium article](https://medium.com/@mweststrate/becoming-fully-reactive-an-in-depth-explanation-of-mobservable-55995262a254).
