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

##### Is React Native supported?

Yes, `mobx` and `mobx-react` will work on React Native. The latter through importing `"mobx-react/native"`.
The devtools don't support React Native. Note that if you indend to store state in a component that you want to be able to use with hot reloading, do not use decorators (annotations) in the component, use the functions instead (eg. `action(fn)` instead of `@action`).

##### How does MobX compare to other Reactive frameworks?

See this [issue](https://github.com/mobxjs/mobx/issues/18) for some considerations.

##### Is MobX a framework?

MobX is *not* a framework. It does not tell you how to structure your code, where to store state or how to process events. Yet it might free you from frameworks that poses all kinds of restrictions on your code in the name of performance.

##### Can I combine MobX with Flux?

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
