# 如何(不)使用装饰器

在MobX 中使用 ES.next 装饰器是可选的。本章节将解释如何(避免)使用它们。

使用装饰器的优势:
* 样板文件最小化，声明式代码。
* 易于使用和阅读。大多数 MobX 用户都在使用。

使用装饰器的劣势:
* ES.next 2阶段特性。
* 需要设置和编译，目前只有 Babel/Typescript 编译器支持。

在 MobX 中使用装饰器有两种方式。

1. 开启编译器的实验性装饰器语法 (详细请参见下面)
2. 不启用装饰器语法，而是利用 MobX 内置的工具 `decorate` 来对类和对象进行装饰。

使用装饰器语法:

```javascript
import { observable, computed, action } from "mobx"

class Timer {
	@observable start = Date.now();
	@observable current = Date.now();

	@computed get elapsedTime() {
		return (this.current - this.start) + "milliseconds"
	}

	@action tick() {
		this.current = Date.now()
	}
}
```

使用 `decorate` 工具:

```javascript
import { observable, computed, action } from "mobx"

class Timer {
	start = Date.now();
	current = Date.now();

	get elapsedTime() {
		return (this.current - this.start) + "milliseconds"
	}

	tick() {
		this.current = Date.now()
	}
}
decorate(Timer, {
	start: observable,
	current: observable,
	elapsedTime: computed,
	tick: action
})
```

注意， `mobx-react` 中的 `observer` 函数既是装饰器又是函数，这意味着下面这些语法都可以正常运行:

```javascript
@observer
class Timer extends React.Component {
	/* ... */
}

const Timer = observer(class Timer extends React.Component {
	/* ... */
})

const Timer = observer((props) => (
	/* 渲染 */
))
```

## 启用装饰器语法

如果想使用装饰器，需要按照下列步骤。

**TypeScript**

在 `tsconfig.json` 中启用编译器选项 `"experimentalDecorators": true` 。

**Babel: 使用 `babel-preset-mobx`**

另外一种在 Babel 中配置 MobX 的方式是使用 [`mobx`](https://github.com/zwhitchcox/babel-preset-mobx) preset，这种方式更方便，其中包含了装饰器及其他几个经常与 mobx 一起使用的插件:

```
npm install --save-dev babel-preset-mobx
```

.babelrc:
```json
{
  "presets": ["mobx"]
}
```

**Babel: 手动启用装饰器**

要启用装饰器的支持而不使用 mobx preset 的话，需要按照下列步骤。
安装支持装饰器所需依赖: `npm i --save-dev babel-plugin-transform-decorators-legacy` 。
并在 `.babelrc` 文件中启用:

```json
{
  "presets": [
    "es2015",
    "stage-1"
  ],
  "plugins": ["transform-decorators-legacy"]
}
```

注意，插件的顺序很重要: `transform-decorators-legacy` 应该放在**首位**。
babel 设置有问题？请先参考这个 [issue](https://github.com/mobxjs/mobx/issues/105) 。

对于 babel 7, 参见 [issue 1352](https://github.com/mobxjs/mobx/issues/1352) 来查看设置示例。

## 装饰器语法 和 Create React App

* `create-react-app` 目前还没有内置的装饰器支持。要解决这个问题，你可以使用 eject 命令 或使用 [react-app-rewired](https://github.com/timarney/react-app-rewired/tree/master/packages/react-app-rewire-mobx)。

