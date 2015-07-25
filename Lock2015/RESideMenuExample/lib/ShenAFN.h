//
//  ShenAFN.h
//  AFNetworkingDemo
//
//  Created by shen on 15/6/27.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ShenAFN : NSObject
+(ShenAFN *)shenInstance;
-(void)netWorkStatus;
- (void)JSONDataWithUrl:(NSString *)urlStr parameter:(NSDictionary *)parameter success:(void (^)(id jsondata))success fail:(void (^)())fail;
- (void)XMLDataWithUrl:(NSString *)urlStr parameter:(NSDictionary *)parameter  success:(void (^)(id xml))success fail:(void (^)())fail;
- (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail;
- (void)sessionDownloadWithUrl:(NSString *)urlStr success:(void (^)(NSURL*fileURL))success fail:(void (^)())fail;
- (void)uploadimgWithurl:(NSString *)urlStr image:(UIImage *)image fileName:(NSString *)fileName success:(void (^)(id responseObject))success fail:(void (^)())fail;
- (void)uploadMutableimgWithurl:(NSString *)urlStr prename:(NSString*)prename imagearray:(NSMutableArray *)imgarray success:(void (^)(id responseObject))success fail:(void (^)())fail;
- (void)getJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail;
@end
