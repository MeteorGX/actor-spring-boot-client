# H5在线游戏

该游戏改用 `WebSocket` 做通讯传输, `Godot` 做客户端开发, 主要做轻度卡牌类型游戏.

这个样例主要是让那些想了解游戏服务端去编写自己的项目, 所以在配置方面尽可能会细致讲解具体为什么要去这样处理.

这里服务端基于 [actor-spring-boot-example](https://github.com/MeteorGX/actor-spring-boot-example) 开发

## 拆分 Scene

按照 [`Godot` 官方文档 - 切换关卡](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/change_scenes_manually.html) 这里有提供方案:

- `SceneTree`: 直接强硬场景手动删除
- `Hidden`: 隐藏场景切换到指定场景

这两种切换场景方式比较考验开发经验, `SceneTree` 切换节约内存空间但是坏处就是重新加载很麻烦且数据不共享, `Hidden` 因为仅仅是隐藏还存在内存加载快且共享数据, 但是对于移动|Web 平台内存优化是考验.

纯关卡 `SceneTree` 机制可能在单机应用广,  因为实际上本身数据是保存在本地存档并且可以被读写, 所以有的单机实际上切换情况的情况就是切换的过程加载本地信息就行了, 不需要直接挂载内存隐藏场景来维护状态.

而 `Hidden` 方式则是会懒加载 `Scene` 到单个场景, 而且会出现大量界面复用切换情况, 特别是网络游戏场景的复用切换及其频繁, 所以对于状态同步要求也最高必须采用隐藏关卡达到复用目的.

> 甚至切换场景服务端会返回所在 X|Y 位置点和场景事件, 所以这个过程中不止本地加载事件, 还有网络下发的数据才能开始渲染.

而且 `Hidden` 方式可以手动卸载释放内存, 不过相对来说更加灵活管理内存( 内部关卡可以靠 `free` 卸载清空内存 ).


## 表数据加载

策划会做表数据来对游戏业务处理, 一般都是负责主导具体业务的游戏服务端来做表生成, 
可以把策划表生成 JSON 同步给客户端|服务端做业务处理.

