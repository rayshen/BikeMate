//
//  ShenAFN.m
//  AFNetworkingDemo
//
//  Created by shen on 15/6/27.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "ShenAFN.h"
#import "AFNetworking.h"
@implementation ShenAFN
//创建单例
+(ShenAFN *)shenInstance
{
    static ShenAFN *SingleShenAFN;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SingleShenAFN = [[ShenAFN alloc] init];
    });
    return SingleShenAFN;
}

-(void)netWorkStatus
{
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // WiFi
     */
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"%ld", status);
    }];
}


#pragma mark - JSON方式获取数据
- (void)JSONDataWithUrl:(NSString *)urlStr parameter:(NSDictionary *)parameter success:(void (^)(id jsondata))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置接收格式
    [manager GET:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}


#pragma mark - JSON方式get提交数据
- (void)getJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //查看返回数据
        //NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}

#pragma mark - xml方式获取数据
- (void)XMLDataWithUrl:(NSString *)urlStr parameter:(NSDictionary *)parameter  success:(void (^)(id xml))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [manager GET:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}

#pragma mark - JSON方式post提交数据
- (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //查看返回数据
        //NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}


#pragma mark - Session 下载下载文件
- (void)sessionDownloadWithUrl:(NSString *)urlStr success:(void (^)(NSURL *fileURL))success fail:(void (^)())fail
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    
    NSString *urlString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //指定下载文件保存的路径
        NSLog(@"%@ %@", targetPath, response.suggestedFilename);
        //将下载文件保存在缓存路径中
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
        
        //URLWithString返回的是网络的URL,如果使用本地URL,需要注意
        //NSURL *fileURL1 = [NSURL URLWithString:path];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        //NSLog(@"== %@ |||| %@", fileURL1, fileURL);
        if (success) {
            success(fileURL);
        }
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"%@ %@", filePath, error);
        if (fail) {
            fail();
        }
    }];
    [task resume];
}

#pragma mark - 单个图片上传
- (void)uploadimgWithurl:(NSString *)urlStr image:(UIImage *)image fileName:(NSString *)fileName success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    //需要传递的参数,jason格式
    NSDictionary *parameter = @{@"Driverid": @"10000"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        /*文件命名参考代码
         // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
         // 要解决此问题，
         // 可以在上传时使用当前的系统事件作为文件名
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         // 设置时间格式
         formatter.dateFormat = @"yyyyMMddHHmmss";
         NSString *str = [formatter stringFromDate:[NSDate date]];
         NSString *newfileName = [NSString stringWithFormat:@"%@.png", str];
         */
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:fileName mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            //NSLog(@"success\n");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            //NSLog(@"fail\n");
            fail();
        }
    }];
}

#pragma mark - 多个图片上传
- (void)uploadMutableimgWithurl:(NSString *)urlStr prename:(NSString*)prename imagearray:(NSMutableArray *)imgarray success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    //需要传递的参数,jason格式
    NSDictionary *parameter = @{@"Driverid": @"10000"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
         // 要解决此问题，
         // 可以在上传时使用当前的系统事件作为文件名
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         // 设置时间格式
         formatter.dateFormat = @"yyyyMMddHHmmss";
         NSString *str = [formatter stringFromDate:[NSDate date]];
        for (int i=0; i<[imgarray count]; i++) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation([imgarray objectAtIndex:i],0.5) name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"%@-%@%d.jpg",prename,str,i] mimeType:@"image/jpg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            //NSLog(@"success\n");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            //NSLog(@"fail\n");
            fail();
        }
    }];
}

#pragma mark - 文件上传 自己定义文件名
- (void)postUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    // NSURL *fileURL1 = [[NSBundle mainBundle] URLForResource:@"头像1.png" withExtension:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURL name:@"uploadFile" fileName:fileName mimeType:fileTye error:NULL];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail();
        }
    }];
}
@end
