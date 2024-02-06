# H5在线游戏

该游戏改用 `WebSocket` 做通讯传输, `Godot` 做客户端开发, 主要做轻度卡牌类型游戏.

这个样例主要是让那些想了解游戏服务端去编写自己的项目, 所以在配置方面尽可能会细致讲解具体为什么要去这样处理.

这里服务端基于 [actor-spring-boot-example](https://github.com/MeteorGX/actor-spring-boot-example) 开发

## 拆分 Scene

按照 [`Godot` 官方文档 - 切换关卡](https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/change_scenes_manually.html) 这里有提供方案:

- `SceneTree`: 直接强硬场景手动删除
- `Hidden`: 隐藏场景切换到指定场景

这两种切换场景方式比较考验开发经验, `SceneTree` 切换节约内存空间但是坏处就是重新加载很麻烦且数据不共享, `Hidden` 因为仅仅是隐藏还存在内存加载快且共享数据, 但是对于移动|Web 平台内存优化是考验.

这里如果无论网游还是单机最好采用以下处理:

1. 登录首页优先独立生成 `Scene` 之后跳转采用 `SceneTree` 切换, 网络游戏创角页面也在此场景.
2. 登录进入玩家其他页面独立 `Scene`, 里面的逻辑相对泛用, 所以采用 `Hidden` 方式保持所有场景挂载.

纯关卡 `SceneTree` 机制可能在单机应用广, 因为网络游戏不止占用加载事件还需要回报服务端目前玩家的场景位置.

> 甚至切换场景服务端会返回所在 X|Y 位置点和场景事件, 所以这个过程中不止本地加载事件, 还有网络下发的数据才能开始渲染.






