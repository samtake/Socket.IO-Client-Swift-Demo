//
//  AppDelegate.m
//  Socket.IO-Client-Swift-Demo
//
//  Created by 黄龙山 on 2019/8/6.
//  Copyright © 2019 黄龙山. All rights reserved.
//

#import "AppDelegate.h"
#import "OFSSockeHandle.h"

@interface AppDelegate ()<OFSSockeHandleDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[OFSSockeHandle shared]connectSocketWithTarget:self];
    return YES;
}

#pragma mark - socket delegate
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


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
