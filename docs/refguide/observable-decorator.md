# @observable

装饰器可以在 ES7 或者 TypeScript 类属性中属性使用，将其转换成可观察的。
@observable 可以在实例字段和属性 getter 上使用。
对于对象的哪部分成为可观察的，@observable 提供了细粒度的控制。

```javascript
import {observable} from "mobx";

class OrderLine {
    @observable price = 0;
    @observable amount = 1;

    constructor(price) {
        this.price = price;
    }

    @computed get total() {
        return this.price * this.amount;
    }
}
```

如果你的环境不支持装饰器或字段初始化器，那么 `@observable key = value;` 会是 [`extendObservable(this, { key: value })`](extend-observable.md) 的语法糖。

可枚举性: 使用 `@observable` 的属性装饰器是可枚举的，但是定义在类原型和不在类实例上定义的不可枚举。
换句话说:

```javascript
const line = new OrderLine();
console.log("price" in line); // true
console.log(line.hasOwnProperty("price")); // false, the price _property_ is defined on the class, although the value will be stored per instance.
```

The `@observable` decorator can be combined with modifiers like `asStructure`:

```javascript
@observable position = asStructure({ x: 0, y: 0})
```


### Enabling decorators in your transpiler

Decorators are not supported by default when using TypeScript or Babel pending a definitive definition in the ES standard.
* For _typescript_, enable the `--experimentalDecorators` compiler flag or set the compiler option `experimentalDecorators` to `true` in `tsconfig.json` (Recommended)
* For _babel5_, make sure `--stage 0` is passed to the Babel CLI
* For _babel6_, see the example configuration as suggested in this [issue](https://github.com/mobxjs/mobx/issues/105)
