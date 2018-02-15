# 如何(不)使用装饰器

在MobX 中使用 ES.next 装饰器是可选的。本章节将解释如何(避免)使用它们。

使用装饰器的优势:
* 样板文件最小化，声明式代码。
* 易于使用和阅读。大多数 MobX 用户都在使用。

使用装饰器的劣势:
* ES.next 2阶段特性。
* 需要设置和编译，目前只有 Babel/Typescript 编译器支持。

## 启用装饰器

如果想使用装饰器，请按照以下步骤操作。

**TypeScript**

启用 `tsconfig.json` 文件中的 `experimentalDecorators` 编译器选项，或者把 `--experimentalDecorators` 作为标识传给编译器。
你必须将 `target` 选项配置成 `es5`+ (es5, es6, ...) 或通过 `--target` 标识。

**Babel: 启用装饰器**

安装装饰器支持: `npm i --save-dev babel-plugin-transform-decorators-legacy`。然后在 `.babelrc` 文件中启用它:

```
{
  "presets": [
    "es2015",
    "stage-1"
  ],
  "plugins": ["transform-decorators-legacy"]
}
```

请注意， `plugins` 的属性非常重要: `transform-decorators-legacy` 应该放在**最前面**。
babel 设置有问题？请先查看这个 [issue](https://github.com/mobxjs/mobx/issues/105) 。

当使用 react native 时，可以用下面的预设来代替 `transform-decorators-legacy`:
```
{
  "presets": ["stage-2", "react-native-stage-0/decorator-support"]
}
```

**Babel: 使用 `babel-preset-mobx`**

另外一种在 Babel 中配置 MobX 的方式是使用 [`mobx`](https://github.com/zwhitchcox/babel-preset-mobx) preset，这种方式更方便，其中包含了装饰器及其他几个经常与 mobx 一起使用的插件:

```
npm install --save-dev babel-preset-mobx
```

.babelrc:
```
{
  "presets": ["mobx"]
}
```

## 装饰器的局限性

* typescript target 配置最低限度必须是 es5
* reflect-metadata https://github.com/mobxjs/mobx/issues/534
* `create-react-app` 本身不支持装饰器。为了解决这个问题，可以使用 eject 或 [custom-react-scripts](https://www.npmjs.com/package/custom-react-scripts) ([博客](https://medium.com/@kitze/configure-create-react-app-without-ejecting-d8450e96196a#.n6xx12p5c))
* Next.JS 目前还不支持装饰器，参见这个 [issue](https://github.com/zeit/next.js/issues/26)


## 不使用装饰器创建 observable 属性

不使用装饰器，可以用 `extendObservable` 来为对象引入 observable 属性。
通常都是在构造函数中来完成这件事。
下面的示例在构造函数/类中引入了 observable 属性、计算属性和动作:

```javascript
function Timer() {
	extendObservable(this, {
		start: Date.now(),
		current: Date.now(),
		get elapsedTime() {
			return (this.current - this.start) + "milliseconds"
		},
        tick: action(function() {
          	this.current = Date.now()
        })
	})
}
```

或者当使用类时:

```javascript
class Timer {
	constructor() {
		extendObservable(this, {
			/* 参见上面 */
		})
	}
}
```

## 使用装饰器创建 observable 属性

装饰器可以非常好的与类结合。
当使用装饰器时，observables、计算值和动作可以通过使用装饰器简单地引入:

```javascript
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

## 创建 observer 组件

mobx 包中的 `observer` 函数/装饰器用来将 react 组件转变为 observer 组件。
这里需要记住的规则是 `@observer class ComponentName {}` 只是 `const ComponentName = observer(class { })` 的语法糖而已。
所以下面 observer 组件的所有创建形式都是有效的:

ES5 版本的无状态组件函数:

```javascript
const Timer = observer(function(props) {
	return React.createElement("div", {}, props.timer.elapsedTime)
})
```

ES6 版本的无状态组件函数:

```javascript
const Timer = observer(({ timer }) =>
	<div>{ timer.elapsedTime }</div>
)
```

ES5 版本的 React 组件:

```javascript
const Timer = observer(React.createClass({
	/* ... */
}))
```

ES6 版本的 React 组件:

```javascript
const Timer = observer(class Timer extends React.Component {
	/* ... */
})
```

ES.next 版本的使用装饰器的 React 组件:

```javascript
@observer
class Timer extends React.Component {
	/* ... */
}
```
