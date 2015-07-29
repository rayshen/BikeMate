//
//  ShareSDKConnector.h
//  ShareSDKConnector
//
//  Created by fenghj on 15/6/2.
//  Copyright (c) 2015年 mob. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  ShareSDK连接器
 */
@interface ShareSDKConnector : NSObject

/**
 *  链接微信API已供ShareSDK可以正常使用微信的相关功能（授权、分享）
 *
 *  @param weChatClass 微信SDK中的类型，应先倒入libWXApi.a，再传入[WXApi class]到此参数。注：此参数不能为nil，否则会导致授权、分享无法正常使用
 */
+ (void)connectWeChat:(Class)wxApiClass;

/**
 *  连接微博API以供ShareSDK可以使用微博客户端来分享内容，不调用此方法也不会影响应用内分享、授权等相关功能。
 *
 *  @param weiboClass 微博SDK中的类型，应先导入libWeiboSDK.a,再传入[WeiboSDK class]到此参数.
 */
+ (void)connectWeibo:(Class)weiboSDKClass;

/**
 *  连接QQAPI以供ShareSDK可以正常使用QQ或者QQ空间客户端来授权或者分享内容。
 *
 *  @param qqApiInterfaceClass QQSDK中的类型，应先导入TencentOpenAPI.framework，再传入[QQApiInterface class]到此参数。
 *  @param tencentOAuthClass   QQSDK中的类型，应先导入TencentOpenAPI.framework，再传入[TencentOAuth class]到此参数。
 */
+ (void)connectQQ:(Class)qqApiInterfaceClass tencentOAuthClass:(Class)tencentOAuthClass;

@end
