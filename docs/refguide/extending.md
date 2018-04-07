# 创建 observable 数据结构和 reactions(反应)

## Atoms

在某些时候，你可能想要有更多的数据结构或其他可以在响应式计算中使用的东西(如流)。
要实现这个其实非常容易，使用 Atoms 的概念即可。
Atom 可以用来通知 Mobx 某些 observable 数据源被观察或发生了改变。
当数据源被使用或不再使用时，MobX 会通知 atom 。

_提示: 在多数场景下，你可以避免去创建自己的 atoms，创建普通的 observavles 并使用工具 `onBecomeObserved` 或 `onBecomeUnobserved` 在 MobX 开始追踪 observable 时接收通知_

下面的示例演示了如何创建一个 observable `Clock`，它可以用在响应式函数中，并且返回当前时间。
这个 clock 只有当它被观察了才会运行。

此示例演示了 Atom 类的完整API。

```javascript
import {createAtom, autorun} from "mobx";

class Clock {
	atom;
	intervalHandler = null;
	currentDateTime;

	constructor() {
		// 创建一个 atom 用来和 MobX 核心算法交互
		this.atom =	createAtom(
			// 第一个参数: atom 的名字，用于调试
			"Clock",
			// 第二个参数(可选的): 当 atom 从未被观察到被观察时的回调函数
			() => this.startTicking(),
			// 第三个参数(可选的): 当 atom 从被观察到不再被观察时的回调函数
			// 注意同一个 atom 在这两个状态之间转换多次
			() => this.stopTicking()
		);
	}

	getTime() {
		// 让 MobX 知道这个 observable 数据源已经使用了
		// 如果 atom 当前是被某些 reaction 观察的，那么 reportObserved 方法会返回 true
		// 如果需要的话，reportObserved 还会触发 onBecomeObserved 事件处理方法(startTicking)
		if (this.atom.reportObserved()) {
      return this.currentDateTime;
    } else {
			// 显然 getTime 被调用的同时并没有 reaction 正在运行
			// 所以，没有人依赖这个值，因此 onBecomeObserved 处理方法(startTicking)不会被触发
			// 根据 atom 的性质，在这种情况下它可能会有不同的表现(像抛出错误、返回默认值等等)
    	return new Date();
    }
	}

	tick() {
		this.currentDateTime = new Date();
		// 让 MobX 知道这个数据源发生了改变
		this.atom.reportChanged();
	}

	startTicking() {
		this.tick(); // 最初的运行
        this.intervalHandler = setInterval(
			() => this.tick(),
			1000
		);
	}

	stopTicking() {
		clearInterval(this.intervalHandler);
		this.intervalHandler = null;
	}
}

const clock = new Clock();

const disposer = autorun(() => console.log(clock.getTime()));

// ... 输出每一秒的时间

disposer();

// 停止输出。如果没有人使用同一个 `clock` 的话，clock 也将停止运行。
```
