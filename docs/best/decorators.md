# 如何(不)使用装饰器

在MobX 中使用 ES.next 装饰器是可选的。本章节将解释如何(避免)使用它们。

使用装饰器语法的优势:

* 样板文件最小化，声明式代码。
* 易于使用和阅读。大多数 MobX 用户都在使用。

使用装饰器语法的劣势:

* ES.next 2阶段特性。
* 需要设置和编译，目前只有 Babel/Typescript 编译器支持。

在 MobX 中使用装饰器有两种方式。

1.  开启编译器的实验性装饰器语法 (详细请参见下面)
2.  不启用装饰器语法，而是利用 MobX 内置的工具 `decorate` 来对类和对象进行装饰。

使用装饰器语法:

```javascript
import { observable, computed, action } from "mobx";

class Timer {
	@observable start = Date.now();
  @observable current = Date.now();

  @computed
  get elapsedTime() {
    return this.current - this.start + "milliseconds";
  }

  @action
  tick() {
    this.current = Date.now();
  }
}
```

使用 `decorate` 工具:

```javascript
import { observable, computed, action, decorate } from "mobx";

class Timer {
	start = Date.now();
	current = Date.now();

	get elapsedTime() {
    return this.current - this.start + "milliseconds";
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

想要在单个属性上应用多个装饰器的话，你可以传入一个装饰器数组。多个装饰器应用的顺序是从从右至左。

```javascript
import { decorate, observable } from "mobx"
import { serializable, primitive } from "serializr"
import persist from "mobx-persist";

class Todo {
    id = Math.random();
    title = "";
    finished = false;
}
decorate(Todo, {
    title: [serializable(primitive), persist("object"), observable],
    finished: [serializable(primitive), observable]
})
```

注意: 并非所有的装饰器都可以在一起组合，此功能只会尽力而为。一些装饰器会直接影响实例，并且可以“隐藏”其他那些只更改原型的装饰器的效果。

---

`mobx-react` 中的 `observer` 函数既是装饰器又是函数，这意味着下面这些语法都可以正常运行:

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
	"presets": ["es2015", "stage-1"],
  "plugins": ["transform-decorators-legacy"]
}
```

注意，插件的顺序很重要: `transform-decorators-legacy` 应该放在**首位**。
babel 设置有问题？请先参考这个 [issue](https://github.com/mobxjs/mobx/issues/105) 。

对于 babel 7, 参见 [issue 1352](https://github.com/mobxjs/mobx/issues/1352) 来查看设置示例。

## 装饰器语法 和 Create React App

* `create-react-app` 目前还没有内置的装饰器支持。要解决这个问题，你可以使用 eject 命令 或使用 [react-app-rewired](https://github.com/timarney/react-app-rewired/tree/master/packages/react-app-rewire-mobx)。

---

## 免责声明: 装饰器语法的局限性:

_当前编译器所实现的装饰器语法是有一些限制的，而且与实际的装饰器语法表现并非完全一致。
此外，在所有编译器都实现第二阶段的提议之前，许多组合模式目前都无法与装饰器一起使用。
由于这个原因，目前在 MobX 中对装饰器语法支持的范围进行了限定，以确保支持的特性在所有环境中始终保持一致。_

MobX 社区并没有正式支持以下模式:

* 重新定义继承树中的装饰类成员
* 装饰静态类成员
* 将 MobX 提供的装饰器与其他装饰器组合
* 热更新 (HMR) / React-hot-loader 可能不能正常运行

在第一次读/写到装饰属性之前，该属性在类实例上可能是不可见的。

(注意: 不支持并不意味着不能运行，它的意义在于如果不能正常运行的话，在官方规范的推进之前，提出的 issues 是不会被处理的。)
