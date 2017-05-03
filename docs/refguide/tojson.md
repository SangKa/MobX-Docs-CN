# toJS

`toJS(value, supportCycles = true)`

递归地将一个(observable)对象转换为 javascript **结构**。
支持 observable 数组、对象、映射和原始类型。
计算值和其他不可枚举的属性不会成为结果的一部分。
默认情况下可以正确支持检测到的循环，但也可以禁用它来获得性能上的提升。

对于更复杂的(反)序列化场景，可以使用 [serializr](https://github.com/mobxjs/serializr)。

```javascript
var obj = mobx.observable({
    x: 1
});

var clone = mobx.toJS(obj);

console.log(mobx.isObservableObject(obj)); // true
console.log(mobx.isObservableObject(clone)); // false
```

注意: 在 MobX 2.2 版本以前此方法的名称是 `toJSON` 。
