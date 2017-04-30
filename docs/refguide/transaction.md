# Transaction(事务)

_Transaction 已经废弃，建议使用 *action* 或 *runInAction*。_

`transaction(worker: () => void)` 可以用来批量更新，而不通知任何观察者，直到事务结束。
`transaction` 接收一个无参数的 `worker` 函数作为参数并运行它。
不会通知任何观察者知道这个函数完成运行。
`transaction` 返回 `worker` 函数返回的任何值。
注意 `transaction` 完全是同步运行的。
Transactions 可以嵌套。只有在完成最外面的 `transaction` 后，reaction 才会运行。

```javascript
import {observable, transaction, autorun} from "mobx";

const numbers = observable([]);

autorun(() => console.log(numbers.length, "numbers!"));
// 输出: '0 numbers!'

transaction(() => {
	transaction(() => {
		numbers.push(1);
		numbers.push(2);
	});
	numbers.push(3);
});
// 输出: '3 numbers!'
```
