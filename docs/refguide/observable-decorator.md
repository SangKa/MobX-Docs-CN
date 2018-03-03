# @observable

<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px" href="https://egghead.io/lessons/javascript-sync-the-ui-with-the-app-state-using-mobx-observable-and-observer-in-react">egghead.io 第1课: observable & observer</a>
<a style="color: white; background:green;padding:5px;margin:5px;border-radius:2px"  href="https://egghead.io/lessons/react-use-observable-objects-arrays-and-maps-to-store-state-in-mobx">egghead.io 第4课: observable 对象 & 映射</a>

装饰器可以在 ES7 或者 TypeScript 类属性中属性使用，将其转换成可观察的。
`@observable` 可以在实例字段和属性 getter 上使用。
对于对象的哪部分需要成为可观察的，@observable 提供了细粒度的控制。

```javascript
import { observable, computed } from "mobx";

class OrderLine {
    @observable price = 0;
    @observable amount = 1;

    @computed get total() {
        return this.price * this.amount;
    }
}
```

如果你的环境不支持装饰器或字段初始化器，那么 `@observable key = value;` 会是 [`extendObservable(this, { key: value })`](extend-observable.md) 的语法糖。

注意: 所有的属性都是惰性定义的，直到它们中任何一个属性被访问。在此之前，它们只是定义在类的原型上。

换句话说:

```javascript
const line = new OrderLine();
console.log("price" in line); // true
console.log(line.hasOwnProperty("price")); // false，price 属性是定义在类上的，尽管值会被存储在每个实例上。
line.amount = 2;
console.log(line.hasOwnProperty("price")); // true, 现在所有的属性都定义在实例上了。

```
`@observable` 装饰器可以和像 `asStructure` 这样的调节器共同使用:

```javascript
@observable position = asStructure({ x: 0, y: 0})
```


### 在编译器中启用装饰器

在使用 TypeScript 或 Babel 这些等待ES标准定义的编译器时，默认情况下是不支持装饰器的。
* 对于 _typescript_，启用 `--experimentalDecorators` 编译器标识或者在 `tsconfig.json` 中把编译器属性 `experimentalDecorators` 设置为 `true` (推荐做法)
* 对于 _babel5_，确保把 `--stage 0` 传递给 Babel CLI
* 对于 _babel6_，参见此 [issue](https://github.com/mobxjs/mobx/issues/105) 中建议的示例配置。
