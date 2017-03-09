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

**Babel:**

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

Note that the order of plugins is important: `transform-decorators-legacy` should be listed *first*.
Having issues with the babel setup? Check this [issue](https://github.com/mobxjs/mobx/issues/105) first.

When using react native, the following preset can be used instead of `transform-decorators-legacy`:
```
{
  "presets": ["stage-2", "react-native-stage-0/decorator-support"]
}
```

## Limitations on decorators

* reflect-metadata https://github.com/mobxjs/mobx/issues/534
* decorators are not supported out of the box in `create-react-app`. To fix this, you can either eject, or use [custom-react-scripts](https://www.npmjs.com/package/custom-react-scripts) for `create-react-app` ([blog](https://medium.com/@kitze/configure-create-react-app-without-ejecting-d8450e96196a#.n6xx12p5c))
* decorators are currently not yet support in Next.JS [issue](https://github.com/zeit/next.js/issues/26)


## Creating observable properties without decorators

Without decorators `extendObservable` can be used to introduce observable properties on an object.
Typically this is done inside a constructor function.
The following example introduces observable properties, a computed property and an action in a constructor function / class:

```javascript
function Timer() {
	extendObservable(this, {
		start: Date.now(),
		current: Date.now(),
		get elapsedTime() {
			return (this.current - this.start) + "seconds"
		},
        tick: action(function() {
          	this.current = Date.now()
        })
	})
}
```

Or, when using classes:

```javascript
class Timer {
	constructor() {
		extendObservable(this, {
			/* See previous listing */
		})
	}
}
```

## Creating observable properties with decorators

Decorators combine very nicely with classes.
When using decorators, observables, computed values and actions can be simply introduced by using the decorators:

```javascript
class Timer {
	@observable start = Date.now();
	@observable current = Date.now();

	@computed get elapsedTime() {
		return (this.current - this.start) + "seconds"
	}

	@action tick() {
		this.current = Date.now()
	}
}
```

## Creating observer components

The `observer` function / decorator from the mobx-package converts react components into observer components.
The rule to remember here is that `@observer class ComponentName {}` is simply sugar for `const ComponentName = observer(class { })`.
So all the following forms of creating observer components are valid:

Stateless function component, ES5:

```javascript
const Timer = observer(function(props) {
	return React.createElement("div", {}, props.timer.elapsedTime)
})
```

Stateless function component, ES6:

```javascript
const Timer = observer(({ timer }) =>
	<div>{ timer.elapsedTime }</div>
)
```

React component, ES5:

```javascript
const Timer = observer(React.createClass({
	/* ... */
}))
```

React component class, ES6:

```javascript
const Timer = observer(class Timer extends React.Component {
	/* ... */
})
```

React component class with decorator, ES.next:

```javascript
@observer
class Timer extends React.Component {
	/* ... */
}
```
