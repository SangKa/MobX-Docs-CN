# 构建大型可扩展可维护项目的最佳实践

本章节主要是在 Mendix 使用 MobX 工作中发现的一些最佳实践。
本章节完全是出于个人见解的，你完全不必强行应用这些实践。
有很多种使用 MobX 和 React 的方式，这仅仅只是其中的一个。

# Stores(存储)

让我们先从 _store_ 开始。
在下节中我们还会讨论**动作**(action)和 React **组件**。
Store 可以在任何 Flux 系架构中找到，可以与 MVC 模式中的控制器进行比较。
Store 的主要职责是将**逻辑**和**状态**从组件中移至一个独立的，可测试的单元，这个单元在 JavaScript 前端和后端中都可以使用。

## 用户界面状态的 store

至少两个 store 可以让绝大多数应用从中受益。
一个用于 **UI 状态**，一个或多个用于**领域状态**。
分离这两个 store 的优点是可以重用和测试**领域状态**，并且可以很好地在其他应用中重用它。
然而，**UI 状态 store** 对于你的应用来说通常非常特别。
但通常也很简单。
这个 store 通常没有太多的逻辑，但会存储大量的松散耦合的 UI 相关的信息。
这是理想状况下的，因为大多数应用在开发过程中会经常性地改变 UI 状态。

通常可以在 UI stores 中找到的:
* Session 信息
* 应用已经加载了的相关信息
* 不会存储到后端的信息
* 全局性影响 UI 的信息
  * 窗口尺寸
  * 可访问性信息
  * 当前语言
  * 当前活动主题
* 用户界面状态瞬时影响多个、毫不相关的组件:
  * 当前选择
  * 工具栏可见性, 等等
  * 向导的状态
  * 全局叠加的状态

这些信息开始作为某个特定组件的内部状态会是不错的选择(例如工具栏的可见性)。
但过了一段时间，你发现应用中的其他地方也需要这些信息。
您只需将状态移动到 **UI 状态 store**，而不是在组件树中向上推动状态，就像在普通的 React 应用中所做的那样。

请确保这个状态是个单例。
对于同构应用程序，你可能还希望使用正常默认值提供这个 store 的存根实现，以便所有组件按预期呈现。
可以通过在应用中传递属性到组件树中来分发 **UI 状态 store**。
还可以通过使用上下文或将其作为模块全局使用来传递这个 store。
为了测试，我推荐只是通过组件树来传递。

store 示例 (使用 ES6 语法):

```javascript
import {observable, computed, asStructure} from 'mobx';
import jquery from 'jquery';

class UiState {
    @observable language = "en_US";
    @observable pendingRequestCount = 0;

    // asStructure 确保仅当尺寸对象以深度相等的方式更改时才会通知观察者
    @observable windowDimensions = asStructure({
        width: jquery(window).width(),
        height: jquery(window).height()
    });

	constructor() {
        jquery.resize(() => {
            this.windowDimensions = getWindowDimensions();
        });
    }

    @computed get appIsInSync() {
        return this.pendingRequestCount === 0
    }
}

singleton = new UiState();
export default singleton;
```

## 领域 store

你的应用应该包含一个或多个**领域** store。
这些 store 存储你的应用所关心的数据。
待办事项、用户、书、电影、订单、凡是你能说出的。
你的应用很有可能至少有一个领域 store。

单个领域 store 应该负责应用中的单个概念。
然而，单个概念可以采取多个子类型的形式，并且它通常是(循环)树结构。
举例来说，一个领域 store 负责产品，一个负责订单。
根据经验来说，如果两个概念之间的关系的本质是包含的，则它们通常应在同一个 store 中。
所以说一个 store 只是管理 **领域对象**。

Store 的职责:
* 实例化领域对象， 确保领域对象知道它们所属的 store。
* 确保每个领域对象只有一个实例。
同一个用户、订单或者待办事项在内存中不应该在内存中出现两次。
这样，可以安全地使用引用，并确保正在查看的实例是最新的，而无需解析引用。
当调试时这十分快速、简单、方便。
* 提供后端集成，当需要时存储数据。
* 如果从后端接收到更新，则更新现有实例。
* 为你的应用提供一个独立、通用、可测试的组件。
* 要确保 store 是可测试的并且可以在服务端运行，你可能需要将实际的 websocket/http 请求移到单独的对象，以便你可以通过通信层抽象。
* Store 应该只有一个实例。

### 领域对象

每个领域对象应使用自己的类(或构造函数)来表示。
建议以**非规范化**形式存储数据。
不必把客户端应用的状态看做数据库的一种。
真实引用、循环数据结构和实例方法都是 JavaScript 中非常强大的概念。
允许领域对象直接引用来自其他 store 的领域对象。
记住: 我们想保持我们的操作和视图尽可能简单，并且需要管理引用和自己做垃圾回收可能是一种倒退。
不同于其他 Flux 系统架构，使用 MobX 不需要对数据进行标准化，而且这使得构建应用**本质上**复杂的部分变得更简单:
你的业务规则、操作和用户界面。

领域对象可以将其所有逻辑委托给它们所属的 store，如果这更符合你的应用的话。
可以将领域对象表示成普通对象，但类比普通对象有一些重要的优势:
* 它们可以有方法。
这使得领域概念更容易独立使用，并减少应用所需的上下文感知的数量。
只是传递对象。
你不需要传递 store，或者必须弄清楚哪些操作可以在对象上应用，如果它们只是作为实例方法可用。
* 对于属性和方法的可见性，它们提供了细粒度的控制。
* 使用构造函数创建的对象可以自由地混合 observable 属性和函数，以及非 observable 属性和方法。
* 它们易于识别，并且可以进行严格的类型检查。


### 领域 store 示例

```javascript
import {observable, autorun} from 'mobx';
import uuid from 'node-uuid';

export class TodoStore {
    authorStore;
    transportLayer;
    @observable todos = [];
    @observable isLoading = true;

    constructor(transportLayer, authorStore) {
        this.authorStore = authorStore; // 可以为我们提供 author 的 store
        this.transportLayer = transportLayer; // 可以为我们发起服务端请求的东西
        this.transportLayer.onReceiveTodoUpdate(updatedTodo => this.updateTodoFromServer(updatedTodo));
        this.loadTodos();
    }

    /**
     * 从服务端拉取所有的 todo
     */
    loadTodos() {
        this.isLoading = true;
        this.transportLayer.fetchTodos().then(fetchedTodos => {
            fetchedTodos.forEach(json => this.updateTodoFromServer(json));
            this.isLoading = false;
        });
    }

    /**
     * 使用服务器中的信息更新 todo。保证一个 todo 只存在一次。
     * 可能构造一个新的 todo，更新现有的 todo,
     * 或删除 todo，如果它已经在服务器上被删除的话。
     */
    updateTodoFromServer(json) {
        var todo = this.todos.find(todo => todo.id === json.id);
        if (!todo) {
            todo = new Todo(this, json.id);
            this.todos.push(todo);
        }
        if (json.isDeleted) {
            this.removeTodo(todo);
        } else {
            todo.updateFromJson(json);
        }
    }

    /**
     * 在客户端和服务端都都创建一个新的 todo
     */
    createTodo() {
        var todo = new Todo(this);
        this.todos.push(todo);
        return todo;
    }

    /**
     * 如果一个 todo 被删除了，将其从客户端内存中清理掉
     */
    removeTodo(todo) {
        this.todos.splice(this.todos.indexOf(todo), 1);
        todo.dispose();
    }
}

export class Todo {

    /**
     * todo 的唯一 id, 不可改变。
     */
    id = null;

    @observable completed = false;
    @observable task = "";

    /**
     * 引用一个 author 对象(来自 authorStore)
     */
    @observable author = null;

    store = null;

    /**
     * 指示此对象的更改是否应提交到服务器
     */
    autoSave = true;

    /**
     * Disposer for the side effect that automatically
     * stores this Todo, see @dispose.
     */
    saveHandler = null;

    constructor(store, id=uuid.v4()) {
        this.store = store;
        this.id = id;

        this.saveHandler = reaction(
            // observe everything that is used in the JSON:
            () => this.asJson,
            // if autoSave is on, send json to server
            (json) => {
                if (this.autoSave) {
                    this.store.transportLayer.saveTodo(json);
                }
            }
        );
    }

    /**
     * Remove this todo from the client and server
     */
    delete() {
        this.store.transportLayer.deleteTodo(this.id);
        this.store.removeTodo(this);
    }

    @computed get asJson() {
        return {
            id: this.id,
            completed: this.completed,
            task: this.task,
            authorId: this.author ? this.author.id : null
        };
    }

    /**
     * Update this todo with information from the server
     */
    updateFromJson(json) {
        // make sure our changes aren't send back to the server
        this.autoSave = false;
        this.completed = json.completed;
        this.task = json.task;
        this.author = this.store.authorStore.resolveAuthor(json.authorId);
        this.autoSave = true;
    }

    dispose() {
        // clean up the observer
        this.saveHandler();
    }
}
```
