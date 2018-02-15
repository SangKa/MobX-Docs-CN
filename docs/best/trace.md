# 使用 `trace` 进行调试

`trace` 是一个小工具，它能帮助你查找为什么计算值、 reactions 或组件会重新计算。

可以通过简单导入 `import { trace } from "mobx"` 来使用它，然后将其放置在 reaction 或计算值中。
它会打印出当前衍生重新计算的原因。

可以通过传入 `true` 作为最后参数来自动地进入 debugger 。
这种方式使得导致 reaction 重新运行的确切变化仍然在堆栈中，通常是〜8个堆栈帧。参见下面的图片。

在 debugger 模式中，调试信息还回透露出影响当前计算或 reaction 的完整衍生树。

![trace](../images/trace-tips2.png)

![trace](../images/trace.gif)

## 在线示例

在 codesandbox 演示的简单 trace 示例: https://codesandbox.io/s/nr58ylyn4m

这是一个用于探索堆栈的部署示例: https://csb-nr58ylyn4m-hontnuliaa.now.sh/
务必要使用 chrome 调试器的黑魔法!

## 用法示例

调用 `trace()` 有几种方式，下面是一些示例:

```javascript
import { observer } from "mobx-react"
import { trace } from "mobx"

@observer
class MyComponent extends React.Component {
    render() {
        trace(true) // 每当 observable 值引起这个组件重新运行时会进入 debugger
        return <div>{this.props.user.name}</name>
    }
}
```

通过使用 reaction 或 autorun 中 `reaction` 参数来启用 trace :

```javascript
mobx.autorun("loggerzz", r => {
    r.trace()
    console.log(user.fullname)
})
```

传入计算属性的名称:

```javascript
trace(user, "fullname")
```
