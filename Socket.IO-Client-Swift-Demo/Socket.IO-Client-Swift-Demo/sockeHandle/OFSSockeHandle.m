//
//  OFSSockeHandle.m
//  OFStore
//
//  Created by huanglongshan on 2019/5/27.
//  Copyright © 2019 Miyeen. All rights reserved.
//

#import "OFSSockeHandle.h"
#import "Socket.IO-Client-Swift-Demo-Bridging-Header.h"

static OFSSockeHandle *_OFSSockeHandleManager = nil;

@interface OFSSockeHandle()
@property(nonatomic,strong)SocketManager *manager;
@property(nonatomic,strong)SocketIOClient *socket;
@end

@implementation OFSSockeHandle

-(instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+(instancetype)shared {
    static dispatch_once_t socketHandleManager_once_Token;
    dispatch_once(&socketHandleManager_once_Token, ^{
        _OFSSockeHandleManager = [[OFSSockeHandle alloc] init];
    });
    return _OFSSockeHandleManager;
}


-(void)connectSocketWithTarget:(id)target{
    self.delegate=target;
    NSString *strApi = @"在这里配置你的域名";//[OFRHttpSessionManager httpSessionManager].currentBaseSocketHost;
    NSString *strUrl = [NSString stringWithFormat:@"%@:3000",strApi];
    NSURL* url = [[NSURL alloc] initWithString:strUrl];
    if (!url) {
        NSLog(@"请准确配置你的域名");
        return;
    }
        
    
    NSDictionary *dic =@{@"log": @YES,
                         @"forceWebsockets": @NO,
                         @"forcePolling": @NO,
                         @"compress": @NO,
                         @"reconnectAttempts":@(-1),
                         @"forceNew": @YES,
                         @"reconnectAttempts": @5,
                         @"extraHeaders": @{@"User-Agent": @"User-Agent"},
                         };
    SocketManager *manager = [[SocketManager alloc] initWithSocketURL:url config:dic];
    self.manager = manager ;
    
    
    SocketIOClient *socket = [manager socketForNamespace:@"/merchant"];
    self.socket=socket;
    
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect data:%@",data);
        if (self.delegate&&[self.delegate respondsToSelector:@selector(socketConnectSuccess:)]) {
            [self.delegate socketConnectSuccess:data];
        }
        
    }];
    
    [socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"message data:%@",data);
        if (data.count==0) {
            return ;
        }
        if (self.delegate&&[self.delegate respondsToSelector:@selector(socketDidReceiveMessage:)]) {
            [self.delegate socketDidReceiveMessage:data];
        }
        
    }];
    
    [socket on:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"connect data:%@",data);
    }];
    
    
    [socket on:@"error" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        //errorcode处理
    }];
    
    
    [socket connect];
}


-(void)emitWithParms:(NSDictionary *)parms{
    NSLog(@"emitWithParms parms:%@",parms);
    [self.socket emit:@"set_connect" with:@[parms]];
}

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

@end
