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

    // asStructure makes sure observer won't be signaled only if the
    // dimensions object changed in a deepEqual manner
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

## Domain Stores

Your application will contain one or multiple _domain_ stores.
These stores store the data your application is all about.
Todo items, users, books, movies, orders, you name it.
Your application will most probably have at least one domain store.

A single domain store should be responsible for a single concept in your application.
However a single concept might take the form of multiple subtypes and it is often a (cyclic) tree structure.
For example: one domain store for your products, and one for our orders and orderlines.
As a rule of thumb: if the nature of the relationship between two items is containment, they should typically be in the same store.
So a store just manages _domain objects_.

These are the responsibility of a store:
* Instantiate domain objects. Make sure domain objects know the store they belong to.
* Make sure there is only one instance of each of your domain objects.
The same user, order or todo should not be twice in your memory.
This way you can safely use references and also be sure you are looking at the latest instance, without ever having to resolve a reference.
This is fast, straightforward and convenient when debugging.
* Provide backend integration. Store data when needed.
* Update existing instances if updates are received from the backend.
* Provide a stand-alone, universal, testable component of your application.
* To make sure your store is testable and can be run server-side, you probably will move doing actual websocket / http requests to a separate object so that you can abstract over your communication layer.
* There should be only one instance of a store.

### Domain objects

Each domain object should be expressed using its own class (or constructor function).
It is recommended to store your data in _denormalized_ form.
There is no need to treat your client-side application state as some kind of database.
Real references, cyclic data structures and instance methods are powerful concepts in JavaScript.
Domain objects are allowed to refer directly to domain objects from other stores.
Remember: we want to keep our actions and views as simple as possible and needing to manage references and doing garbage collection yourself might be a step backward.
Unlike many Flux architectures, with MobX there is no need to normalize your data, and this makes it a lot simpler to build the _essentially_ complex parts of your application:
your business rules, actions and user interface.

Domain objects can delegate all their logic to the store they belong to if that suits your application well.
It is possible to express your domain objects as plain objects, but classes have some important advantages over plain objects:
* They can have methods.
This makes your domain concepts easier to use stand-alone and reduces the amount of contextual awareness that is needed in your application.
Just pass objects around.
You don't have to pass stores around, or have to figure out which actions can be applied to an object if they are just available as instance methods.
Especially in large applications this is important.
* They offer fine grained control over the visibility of attributes and methods.
* Objects created using a constructor function can freely mix observable properties and functions, and non-observable properties and methods.
* They are easily recognizable and can strictly be type-checked.


### Example domain store

```javascript
import {observable, autorun} from 'mobx';
import uuid from 'node-uuid';

export class TodoStore {
    authorStore;
    transportLayer;
    @observable todos = [];
    @observable isLoading = true;

    constructor(transportLayer, authorStore) {
        this.authorStore = authorStore; // Store that can resolve authors for us
        this.transportLayer = transportLayer; // Thing that can make server requests for us
        this.transportLayer.onReceiveTodoUpdate(updatedTodo => this.updateTodoFromServer(updatedTodo));
        this.loadTodos();
    }

    /**
     * Fetches all todo's from the server
     */
    loadTodos() {
        this.isLoading = true;
        this.transportLayer.fetchTodos().then(fetchedTodos => {
            fetchedTodos.forEach(json => this.updateTodoFromServer(json));
            this.isLoading = false;
        });
    }

    /**
     * Update a todo with information from the server. Guarantees a todo
     * only exists once. Might either construct a new todo, update an existing one,
     * or remove an todo if it has been deleted on the server.
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
     * Creates a fresh todo on the client and server
     */
    createTodo() {
        var todo = new Todo(this);
        this.todos.push(todo);
        return todo;
    }

    /**
     * A todo was somehow deleted, clean it from the client memory
     */
    removeTodo(todo) {
        this.todos.splice(this.todos.indexOf(todo), 1);
        todo.dispose();
    }
}

export class Todo {

    /**
     * unique id of this todo, immutable.
     */
    id = null;

    @observable completed = false;
    @observable task = "";

    /**
     * reference to an Author object (from the authorStore)
     */
    @observable author = null;

    store = null;

    /**
     * Indicates whether changes in this object
     * should be submitted to the server
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
