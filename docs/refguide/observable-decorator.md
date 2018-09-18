# @observable

<details>
    <summary style="color: white; background:green;padding:5px;margin:5px;border-radius:2px">egghead.io 第1课: observable & observer</summary>
    <br>
    <div style="padding:5px;">
        <iframe style="border: none;" width=760 height=427  src="https://egghead.io/lessons/javascript-sync-the-ui-with-the-app-state-using-mobx-observable-and-observer-in-react/embed" />
    </div>
    <a style="font-style:italic;padding:5px;margin:5px;" href="https://egghead.io/lessons/javascript-sync-the-ui-with-the-app-state-using-mobx-observable-and-observer-in-react">在 egghead.io 上观看</a>
</details>

<details>
    <summary style="color: white; background:green;padding:5px;margin:5px;border-radius:2px">egghead.io 第4课: observable 对象 & 映射</summary>
    <br>
    <div style="padding:5px;">
        <iframe style="border: none;" width=760 height=427  src="https://egghead.io/lessons/react-use-observable-objects-arrays-and-maps-to-store-state-in-mobx/embed" />
    </div>
    <a style="font-style:italic;padding:5px;margin:5px;"  href="https://egghead.io/lessons/react-use-observable-objects-arrays-and-maps-to-store-state-in-mobx">在 egghead.io 上观看</a>
</details>

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

如果你的环境不支持装饰器或字段初始化器，使用 `decorate` 来代替 (想了解更多，参见 [装饰](./modifiers.md))。
