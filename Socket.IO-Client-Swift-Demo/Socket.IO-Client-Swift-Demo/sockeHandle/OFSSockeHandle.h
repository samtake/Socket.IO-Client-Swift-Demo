//
//  OFSSockeHandle.h
//  OFStore
//
//  Created by huanglongshan on 2019/5/27.
//  Copyright © 2019 Miyeen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OFSSockeHandleDelegate <NSObject>

-(void)socketDidReceiveMessage:(NSArray *)data;
-(void)socketConnectSuccess:(NSArray *)data;

@end


@interface OFSSockeHandle : NSObject
@property(nonatomic,weak)id<OFSSockeHandleDelegate> delegate;
+(instancetype)shared;
-(void)connectSocketWithTarget:(id)target;
-(void)disconnect;
-(void)logout;
-(void)emitWithParms:(NSDictionary *)parms;
@end

NS_ASSUME_NONNULL_END
