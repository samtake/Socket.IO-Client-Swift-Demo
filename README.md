# Socket.IO-Client-Swift-Demo
Socket.IO-Client-Swift 的简单使用以及封装
公司之前用的消息推送是google的firebase,但是因为业务场景firebase总是不理想，后面就改成了socket长连接+ firebase双通道，先看后台的连接说明：
- 系统主要包括了三个端： cusomer(用户端) 、rider(骑手端) 和 merchant(商家端)
- 商家端细分： app、pos 和 pad
- 主要端的管理通过namespace 进行区分管理

###连接说明
用户端连接：
```
// beaseUrl/socket/customer
var customerSocket = io('http://xxx/socket/customer', {path: '/socket/socket.io'});
let params = {
    uid: uid, // 用户的id
    type: client, // client 代表是哪个客户端 - 这里应该填写 customer
    token: token
}
customerSocket.emit('set_connect', params) // 建立连接
```

骑手端连接
```
// beaseUrl/socket/rider
var riderSocket = io('http://xxx/socket/rider', {path: '/socket/socket.io'});
let params = {
    uid: uid, // 骑手id
    type: client, // 客户端 - rider表示 骑手端
    topic: topic, // 把该骑手加入哪个主题 - 用于区域广播（新订单通知） 如：rider_Tianhe_Qu_notification
    token: token
}
riderSocket.emit('set_connect', params) // 建立连接
```

商家端连接
```
// beaseUrl/socket/merchant
var merchantSocket = io('http://xxx/socket/merchant', {path: '/socket/socket.io'});
let params = {
    uid: uid, // 骑手id
    type: client, // 客户端 - rider表示 骑手端
    topic: topic, // 把该用户加入哪个主题, 如： store_1_base_notification
    client: client, // 在哪个细分的客户端登录 pos app pad
    device_id: device_id, // 如果是pos登录，需要把设备id填上
    token: token
}
merchantSocket.emit('set_connect', params) // 建立连接
```

h5 连接
```
// beaseUrl/socket/h5
var h5Socket = io('http://xxx/socket/h5', {path: '/socket/socket.io'});
let params = {
    uid: id, // 用户id/桌台id, 如果是桌台id的话需要 变成  {store_id}_{table_id} 这种格式
    type: client, // 客户端 - h5 表示h5端,
    connect_type: connect_type // 连接类型 table - 桌台 person - 登录用户
}
h5Socket.emit('set_connect', params) // 建立连接
```

###推送说明
 单设备推送 [POST baseUrl/socket/device_push]
```
参数示例 - json格式：
push_data = [
    'type' => 'rider',
    'uid' => '1',
    'data' => [
        'title' => 'New Order',
        'id' => 1,
        "order_status" => 7,
        "push_type" => 'store_get_order' // 推送类型
    ]
];
```

参数
```
type: (required) - 客户端类型 骑手 - rider 用户 - customer
uid: (integer, required) - 需要推送的用户id
data: (array, required) - 推送的内容
```
Response 200 (application/json)
```
  {
      "code": 0,
      "message": "",
  }
```

###iOS连接（以商家端为例子）
这里我使用的是[Socket.IO-Client-Swift]([https://github.com/socketio/socket.io-client-swift](https://github.com/socketio/socket.io-client-swift)
)，因为编译器版本等环境因素这里需要指定版本是15.0.0，否则高了swift5.0不支持（顺便一提，如果你的项目是纯Object-C，在这之前都没有swift文件的话还需要新建一个swift文件，这时候桥接点击默认即可）
`pod 'Socket.IO-Client-Swift', '~> 15.0.0'`

创建socket工具类OFSSockeHandle，并定义对应代理
接收信息`-(void)socketDidReceiveMessage:(NSArray *)data;`
连接成功`-(void)socketConnectSuccess:(NSArray *)data;`

在上面也有提到了，我们这里的同域名，多个接口，所以需要用到命名空间，这里的关键代码是
```
SocketIOClient *socket = [manager socketForNamespace:@"/merchant"];
```
监听连接，成功则调用代理
```
[socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect data:%@",data);
        if (self.delegate&&[self.delegate respondsToSelector:@selector(socketConnectSuccess:)]) {
            [self.delegate socketConnectSuccess:data];
        }
        
    }];
```
监听消息
 ```
[socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"message data:%@",data);
        if (data.count==0) {
            return ;
        }
        if (self.delegate&&[self.delegate respondsToSelector:@selector(socketDidReceiveMessage:)]) {
            [self.delegate socketDidReceiveMessage:data];
        }
        
    }];
```
发起连接
 ```
[socket connect];
```

连接成功之后需要发起emit，并传入对应的参数
```
-(void)emitWithParms:(NSDictionary *)parms{
    NSLog(@"emitWithParms parms:%@",parms);
    [self.socket emit:@"set_connect" with:@[parms]];
}
```

断开连接和退出
```
-(void)disconnect{
    [self.socket on:@"disconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"disconnect data:%@",data);
    }];
}


-(void)logout{
    [self.socket on:@"logout" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"logout data:%@",data);
        [self disconnect];
    }];
}
```

剩下的就是在调用的地方遵守代理，以及处理对应的业务逻辑了，demo里面是写在了AppDelegate
```
-(void)socketDidReceiveMessage:(NSArray *)data{
    NSLog(@"接收到的数据data=%@",data);
    NSString *strJson = data[0];
}
-(void)socketConnectSuccess:(NSArray *)data{
    NSLog(@"data=%@",data);
    NSString *store_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"storeIdSaveInDefaultKey"];
    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"socketUidSaveInDefaultKey"];
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:@"FCMToken"];
    if(token.length==0||token==nil){
        token = @"这是时间戳+随机数";
    }
    if (uid.length>0&&uid.length>0/*&&token.length>0*/) {
        NSMutableDictionary *parms = [NSMutableDictionary new];
        [parms setValue:[NSString stringWithFormat:@"store_%@_base_notification",store_id] forKey:@"topic"];
        [parms setValue:uid forKey:@"uid"];
        [parms setValue:@"merhant" forKey:@"type"];
        [parms setValue:@"app" forKey:@"client"];
        [parms setValue:token forKey:@"token"];
        [[OFSSockeHandle shared]emitWithParms:parms];
    }
}
```

具体demo链接[参考]( [https://github.com/samtake/Socket.IO-Client-Swift-Demo](https://github.com/samtake/Socket.IO-Client-Swift-Demo)
)

[我的简书](https://www.jianshu.com/u/95eaa7893b88)
