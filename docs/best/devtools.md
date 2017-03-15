# MobX + React 开发者工具

MobX 附带的开发者工具可以用来追踪应用的渲染行为和数据依赖关系。

![devtools](../images/devtools.gif)

## 用法:

安装:

`npm install mobx-react-devtools`

要启用开发者工具，导入 DevTools 组件并在代码库的某个地方进行渲染。

```JS
import DevTools from 'mobx-react-devtools'

const App = () => (
  <div>
    ...
    <DevTools />
  </div>
)
```

想了解更多详情，请查看 [mobx-react-devtools](https://github.com/mobxjs/mobx-react-devtools) 仓库。
