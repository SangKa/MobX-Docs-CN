## 直接操控 Observable

现在有一个统一的工具 API 可以操控 observable 映射、对象和数组。这些 API 都是响应式的，这意味着如果使用 `set` 进行添加，使用 `values` 或 `keys` 进行迭代，即便是新属性的声明都可以被 MobX 检测到。

  * **`values(thing)`** 将集合中的所有值作为数组返回
  * **`keys(thing)`** 将集合中的所有键作为数组返回
  * **`set(thing, key, value)`** 或 **`set(thing, { key: value })`** 使用提供的键值对来更新给定的集合
  * **`remove(thing, key)`** 从集合中移除指定的项。用于数组拼接
  * **`has(thing, key)`** 如果集合中存在指定的 _observable_ 属性就返回 true
  * **`get(thing, key)`** 返回指定键下的子项


```javascript
import { get, set, observable, values } from "mobx"

const twitterUrls = observable.object({
    "John": "twitter.com/johnny"
})

autorun(() => {
    console.log(get(twitterUrls, "Sara")) // get 可以追踪尚未存在的属性
})

autorun(() => {
    console.log("All urls: " + values(twitterUrls).join(", "))
})

set(twitterUrls, { "Sara" : "twitter.com/horsejs"})
``` 
