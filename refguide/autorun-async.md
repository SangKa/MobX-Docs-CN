# autorunAsync

`autorunAsync(action: () => void, minimumDelay?: number, scope?)`

同 `autorun` 一样，除了 `action` 不是同步调用，而是在传入的最小的毫秒数量之后异步调用。
`action` 将会运行和观察。
然而当它观察的值更改时，不是立即运行 `action`，而是等待 `minimumDelay` 后在重新运行 `action`。

如果在等待这段时间内，观察的值发生了多次的变化，`action` 仍然只会触发一次，因此在某种意义上，它实现了与事务类似的效果。
这可能对昂贵的并且不需要同步发生的东西有用，例如去抖的服务端通信。

如果提供了 scope，那么 action 会绑定到这个作用域对象。

`autorunAsync(debugName: string, action: () => void, minimumDelay?: number, scope?)`

如果传给 `autorunAsync` 的第一个参数是字符串的话，它会作为调试的名称。

`autorunAsync` 返回一个清理函数用来取消 autorun 。

```javascript
autorunAsync(() => {
	// 假设 profile.asJson 返回一个用来展现 profile 的 observable json
	// 每次改变都会把它发送到服务端，但发送前至少要等待300毫秒
	// 发送后，将使用 profile.asJson 的最新值
	sendProfileToServer(profile.asJson);
}, 300);
```
