//
//  NSMutableDictionary+SSDKShare.h
//  ShareSDK
//
//  Created by 冯 鸿杰 on 15/2/9.
//  Copyright (c) 2015年 掌淘科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDKTypeDefine.h"
#import "SSDKImage.h"
#import "SSDKData.h"

/**
 *  分享参数构造相关
 */
@interface NSMutableDictionary (SSDKShare)

/**
 *  设置分享标识
 *
 *  @param flags 标识数组，元素为NSString。
 */
- (void)SSDKSetShareFlags:(NSArray *)flags;

/**
 *  使用客户端分享
 */
- (void)SSDKEnableUseClientShare;

/**
 *  设置分享参数
 *
 *  @param text     文本
 *  @param images   图片集合,元素可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage，如: @[@"http://mob.com/Assets/images/logo.png?v=20150320"]
 *  @param url      网页路径/应用路径
 *  @param title    标题
 *  @param type     分享类型
 */
- (void)SSDKSetupShareParamsByText:(NSString *)text
                            images:(NSArray *)images
                               url:(NSURL *)url
                             title:(NSString *)title
                              type:(SSDKContentType)type;

/**
 *  设置新浪微博分享参数
 *
 *  @param text      文本
 *  @param title     标题
 *  @param image     图片对象，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param url       分享链接
 *  @param latitude  纬度
 *  @param longitude 经度
 *  @param objectID  对象ID，标识系统内内容唯一性，应传入系统中分享内容的唯一标识，没有时可以传入nil
 *  @param type      分享类型
 */
- (void)SSDKSetupSinaWeiboShareParamsByText:(NSString *)text
                                      title:(NSString *)title
                                      image:(id)image
                                        url:(NSURL *)url
                                   latitude:(double)latitude
                                  longitude:(double)longitude
                                   objectID:(NSString *)objectID
                                       type:(SSDKContentType)type;

/**
 *  设置腾讯微博分享参数
 *
 *  @param text      文本
 *  @param images    分享图片列表，元素可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param latitude  纬度
 *  @param longitude 经度
 *  @param type      分享类型
 */
- (void)SSDKSetupTencentWeiboShareParamsByText:(NSString *)text
                                        images:(NSArray *)images
                                      latitude:(double)latitude
                                     longitude:(double)longitude
                                          type:(SSDKContentType)type;

/**
 *  设置微信分享参数
 *
 *  @param text         文本
 *  @param title        标题
 *  @param url          分享链接
 *  @param thumbImage   缩略图，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param image        图片，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param musicFileURL 音乐文件链接地址
 *  @param extInfo      扩展信息
 *  @param fileData     文件数据，可以为NSData、UIImage、NSString、NSURL（文件路径）、SSDKData、SSDKImage
 *  @param emoticonData 表情数据，可以为NSData、UIImage、NSURL（文件路径）、SSDKData、SSDKImage
 *  @param type         分享类型，支持SSDKContentTypeText、SSDKContentTypeImage、SSDKContentTypeWebPage、SSDKContentTypeApp、SSDKContentTypeAudio和SSDKContentTypeVideo
 *  @param platformType 平台子类型，只能传入SSDKPlatformTypeWechatSession、SSDKPlatformTypeWechatTimeline和SSDKPlatformTypeWechatFav其中一个
 *
 *  分享文本时：
 *  设置type为SSDKContentTypeText, 并填入text参数
 *
 *  分享图片时：
 *  设置type为SSDKContentTypeImage, 非gif图片时：填入title和image参数，如果为gif图片则需要填写title和emoticonData参数
 *
 *  分享网页时：
 *  设置type为SSDKContentTypeWebPage, 并设置text、title、url以及thumbImage参数，如果尚未设置thumbImage则会从image参数中读取图片并对图片进行缩放操作。
 *
 *  分享应用时：
 *  设置type为SSDKContentTypeApp，并设置text、title、extInfo（可选）以及fileData（可选）参数。
 *
 *  分享音乐时：
 *  设置type为SSDKContentTypeAudio，并设置text、title、url以及musicFileURL（可选）参数。
 *
 *  分享视频时：
 *  设置type为SSDKContentTypeVideo，并设置text、title、url参数
 */
- (void)SSDKSetupWeChatParamsByText:(NSString *)text
                              title:(NSString *)title
                                url:(NSURL *)url
                         thumbImage:(id)thumbImage
                              image:(id)image
                       musicFileURL:(NSURL *)musicFileURL
                            extInfo:(NSString *)extInfo
                           fileData:(id)fileData
                       emoticonData:(id)emoticonData
                               type:(SSDKContentType)type
                 forPlatformSubType:(SSDKPlatformType)platformSubType;

/**
 *  设置Twitter分享参数
 *
 *  @param text      分享内容
 *  @param images    分享图片
 *  @param latitude  地理位置，纬度
 *  @param longitude 地理位置，经度
 *  @param type      分享类型
 */
- (void)SSDKSetupTwitterParamsByText:(NSString *)text
                              images:(NSArray *)images
                            latitude:(double)latitude
                           longitude:(double)longitude
                                type:(SSDKContentType)type;

/**
 *  设置QQ分享参数
 *
 *  @param text            分享内容
 *  @param title           分享标题
 *  @param url             分享链接
 *  @param thumbImage      缩略图，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param image           图片，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param type            分享类型
 *  @param platformSubType 平台子类型，只能传入SSDKPlatformSubTypeQZone或者SSDKPlatformSubTypeQQFriend其中一个
 */
- (void)SSDKSetupQQParamsByText:(NSString *)text
                          title:(NSString *)title
                            url:(NSURL *)url
                     thumbImage:(id)thumbImage
                          image:(id)image
                           type:(SSDKContentType)type
             forPlatformSubType:(SSDKPlatformType)platformSubType;

/**
 *  设置Facebook分享参数
 *
 *  @param text  分享内容
 *  @param image 图片，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
 *  @param type  分享类型
 */
- (void)SSDKSetupFacebookParamsByText:(NSString *)text
                                image:(id)image
                                 type:(SSDKContentType)type;


@end
