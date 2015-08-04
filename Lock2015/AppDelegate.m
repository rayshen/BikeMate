//
//  AppDelegate.m
//  Lock2015
//
//  Created by shen on 15/7/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "AppDelegate.h"
#import "DEMOLeftMenuViewController.h"
#import "DEMORightMenuViewController.h"
#import "IndexViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#define UUIDKEY @"UUID"

static BOOL isAround;
static BOOL isConnect;
static BOOL isOnlock;
static BOOL isRingon;
static NSString* PhoneUUID;
static NSString* LockUUID;
static int Batteryinfo;


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    isConnect=NO;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //第一次用于生成手机的UUID，之后直接读取
    [self uuid];
    [self registshare];
    
    //[CHKeychain deleteData:@"LOCKUUID"];
    //看DIDUSED，是否第一次登陆
    if(![CHKeychain load:@"LOCKUUID"]){
        NSLog(@"未记录锁UUID");
        FirstpageViewController *FPVC=[[FirstpageViewController alloc]init];
        self.window.rootViewController = FPVC;
    }else{
        LockUUID=[CHKeychain load:@"LOCKUUID"];
        NSLog(@"已记录锁UUID：%@",LockUUID);
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[IndexViewController alloc] init]];
        DEMOLeftMenuViewController *leftMenuViewController = [[DEMOLeftMenuViewController alloc] init];
        DEMORightMenuViewController *rightMenuViewController = [[DEMORightMenuViewController alloc] init];
        
        RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:rightMenuViewController];
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
        sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
        sideMenuViewController.delegate = self;
        sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
        sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenuViewController.contentViewShadowOpacity = 0.6;
        sideMenuViewController.contentViewShadowRadius = 12;
        sideMenuViewController.contentViewShadowEnabled = YES;
        self.window.rootViewController = sideMenuViewController;
        [self connectingDiscover];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Notifictiontodo:) name:@"LOCKCMD" object:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

+(BOOL)getisConnect{
    return isConnect;
}

+(BOOL)getisOnlock{
    return isOnlock;
}

+(BOOL)getisRingon{
    return isRingon;
}

+(NSString *)getphoneUUID{
    return PhoneUUID;
}

+(NSString *)getlockUUID{
    return LockUUID;
}

+(int)getBatteryinfo{
    return Batteryinfo;
}

-(void)registshare{
    [ShareSDK registerApp:@"934ca560a424"
          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformTypeTencentWeibo), @(SSDKPlatformTypeFacebook), @(SSDKPlatformTypeTwitter), @(SSDKPlatformTypeWechat), @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                              redirectUri:@"http://www.sharesdk.cn"
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeTencentWeibo:
                      //设置腾讯微博应用信息，其中authType设置为只用Web形式授权
                      [appInfo SSDKSetupTencentWeiboByAppKey:@"801307650"
                                                   appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                                 redirectUri:@"http://www.sharesdk.cn"];
                      break;
                  case SSDKPlatformTypeFacebook:
                      //设置Facebook应用信息，其中authType设置为只用SSO形式授权
                      [appInfo SSDKSetupFacebookByAppKey:@"107704292745179"
                                               appSecret:@"38053202e1a5fe26c80c753071f0b573"
                                                authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeTwitter:
                      [appInfo SSDKSetupTwitterByConsumerKey:@"LRBM0H75rWrU9gNHvlEAA2aOy"
                                              consumerSecret:@"gbeWsZvA9ELJSdoBzJ5oLKX0TU09UOwrzdGfo9Tg7DjyGuMe8G"
                                                 redirectUri:@"http://mob.com"];
                      break;
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                            appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:@"100371282"
                                           appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                         authType:SSDKAuthTypeSSO];
                      break;
                  default:
                      break;
              }
              
          }];

}

#pragma mark--获取设备UUID
-(NSString*)uuid{
    if ([CHKeychain load:UUIDKEY]) {
        NSString *result = [CHKeychain load:UUIDKEY];
        PhoneUUID=result;
        NSLog(@"已存在手机UUID：%@",result);
        return result;
    }
    else
    {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        [CHKeychain save:UUIDKEY data:result];
        NSLog(@"初次创建手机UUID：%@",result);
        PhoneUUID=result;
        return result;
    }
    return nil;
}

#pragma mark--蓝牙连接函数
-(void)connectingDiscover{
    self.centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.arrayBLE = [[NSMutableArray alloc] init];
    isAround=NO;

}

-(void)alertSearchview{
    //设置超时时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(searchResult:) userInfo:nil repeats:NO];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"努力搜索蓝牙设备中";
    [HUD show:YES];
    [self connectingDiscover];
}

-(void)searchResult:(id)sender{
    if (isAround==YES) {
        
    }else{
        [HUD hide:YES];
        UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"提示" message:@"然而并没有找到附近有蓝牙配对设备的存在" delegate:self cancelButtonTitle:@"好吧" otherButtonTitles:@"继续搜索",nil];
        ConnetionTips.tag=3;
        [ConnetionTips show];
    }
}

-(void)alertConnetionTips{
    UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到您的周边" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"一键连接",nil];
    ConnetionTips.tag=2;
    [ConnetionTips show];
    if (HUD) {
        [HUD hide:YES];
    }
}


#pragma alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2&&buttonIndex==1) {
        HUD = [[MBProgressHUD alloc] initWithView:self.window];
        [self.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"连接蓝牙中";
        [HUD show:YES];
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
    }
    if(alertView.tag==3&&buttonIndex==1){
        [self alertSearchview];
    }
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    NSLog(@"loading over");
    [HUD removeFromSuperview];
    HUD = nil;
}

//蓝牙状态delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"蓝牙打开，开始搜索蓝牙");
            break;
        default:
            NSLog(@"蓝牙状态改变");
            NSDictionary *dic = @{
                                  @"ConnectState":@"NO"
                                  };
            [self notifiction:dic forname:@"APPDelegate"];
            isConnect=NO;
            break;
    }
}

//发现设备delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLEInfo *discoveredBLEInfo = [[BLEInfo alloc] init];
    discoveredBLEInfo.discoveredPeripheral = peripheral;
    discoveredBLEInfo.rssi = RSSI;
    
    // update tableview
    [self saveBLE:discoveredBLEInfo];
}

//保存设备信息
- (BOOL)saveBLE:(BLEInfo *)discoveredBLEInfo
{
    for (BLEInfo *info in self.arrayBLE)
    {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString])
        {
            return NO;
        }
    }
    //如果已经记录
    if ([discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString isEqualToString:[CHKeychain load:@"LOCKUUID"]])
    {
        NSLog(@"发现配对的锁");
        _discoveredPeripheral=discoveredBLEInfo.discoveredPeripheral;
        isAround=YES;
        NSDictionary *dic = @{
                              @"AroundState":@"YES"
                              };
        [self notifiction:dic forname:@"APPDelegate"];
        [self alertConnetionTips];
    }

    //NSLog(@"\n发现新的蓝牙设备!\n");
    //NSLog(@"BLEInfo\n UUID：%@\n RSSI:%@\n\n",discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString,discoveredBLEInfo.rssi);
    
    //保存devices到self.arrayBLE
    [self.arrayBLE addObject:discoveredBLEInfo];
    return YES;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
    NSDictionary *dic = @{
                          @"ConnectState":@"NO"
                          };
    [self notifiction:dic forname:@"APPDelegate"];
    isConnect=NO;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSDictionary *dic = @{
                          @"ConnectState":@"NO"
                          };
    [self notifiction:dic forname:@"APPDelegate"];
    UIAlertView *ConnetionTips=[[UIAlertView alloc] initWithTitle:@"提示" message:@"蓝牙连接丢失啦~" delegate:self cancelButtonTitle:@"(⊙o⊙)哦" otherButtonTitles:nil];
    ConnetionTips.tag=4;
    [ConnetionTips show];
    isConnect=NO;
    if(HUD){
        [HUD hide:YES];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"已经连接设备");
    /*
    NSDictionary *dic = @{
                          @"ConnectState":@"YES"
                          };
    [self notifiction:dic forname:@"APPDelegate"];
    [HUD hide:YES];
     */
    isConnect=YES;
    [self.arrayServices removeAllObjects];
    [_discoveredPeripheral setDelegate:self];
    [_discoveredPeripheral discoverServices:nil];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        //NSLog(@"Service found with UUID : %@", s.UUID);
        //搜索该service里的character
        [s.peripheral discoverCharacteristics:nil forService:s];
        //保存services到self.arrayServices
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"ServiceDescription":s.UUID.description}];
        [self.arrayServices addObject:dic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverCharacteristicsForService error : %@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *c in service.characteristics)
     {
         //NSLog(@"Characteristic found with UUID: %@ inService UUID：%@", c.UUID,service.UUID);
         //FFF1特征：发送数据控制硬件端
         if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFE9"]]){
             _writeCharacteristic = c;
             NSLog(@"找到Write Characteristic : %@", c.UUID);
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:newuser:%@\r\n",PhoneUUID]];
         }
         
         //FFF6特征：广播
         if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFE4"]]){
             NSLog(@"找到notify Characteristic : %@", c.UUID);
             [_discoveredPeripheral setNotifyValue:YES forCharacteristic:c];
         }
     }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        return;
    }
    //NSLog(@"Notify:this Character with UUID %@ value is:%@",characteristic.UUID,characteristic.value);
    NSString *getvalue=[[NSString alloc]initWithData:characteristic.value encoding:NSASCIIStringEncoding];
    NSLog(@"Notify Value is %@",getvalue);
    NSArray *list=[getvalue componentsSeparatedByString:@":"];
    NSString *cmd,*value;
    if (list[0]) {
        cmd=list[0];
    }

    if([cmd isEqualToString:@"OK"]){
        if (list[1]) {
            value=list[1];
            NSArray *configlist=[value componentsSeparatedByString:@"#"];
            NSString *battery,*lockstate,*ringstate;
            if(configlist[0]){
                battery=configlist[0];
                Batteryinfo=[battery intValue];
            }
            if(configlist[1]){
                lockstate=configlist[1];
                if ([lockstate isEqualToString:@"1"]) {
                    isOnlock=YES;
                }else{
                    isOnlock=NO;
                }
            }
            if(configlist[2]){
                ringstate=configlist[2];
                if ([ringstate isEqualToString:@"1"]) {
                    isRingon=YES;
                }else{
                    isRingon=NO;
                }
            }
        }
        NSDictionary *dic = @{
                              @"ConnectState":@"YES",
                              @"LockState":[NSString stringWithFormat:@"%d",isOnlock],
                              @"Batteryinfo":[NSString stringWithFormat:@"%i",Batteryinfo],
                              @"RingState":[NSString stringWithFormat:@"%d",isRingon]
                              };
        [self notifiction:dic forname:@"APPDelegate"];
        [HUD hide:YES];
    }

    
    /*
    if ([flag isEqualToString:@"dong14"]) {
     
        if ([cmd isEqualToString:@""]) {
            
        }
        if ([cmd isEqualToString:@""]) {
            
        }
    }*/
}


//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)string{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    
    NSData* value = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"Witedata: %@",value);
    
    [_discoveredPeripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}

-(void)notifiction:(NSDictionary *)dic forname:(NSString *)name{
    NSLog(@"发送通知");
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
}

-(void)Notifictiontodo:(NSNotification*)notification
{
    NSLog(@"接收到通知:%@",[notification userInfo]);
    NSString *Operation;
    if([[notification userInfo] objectForKey:@"LOCKUUID"]){
        LockUUID=[[notification userInfo] objectForKey:@"LOCKUUID"];
        NSLog(@"收到锁的信息:%@",LockUUID);
    }
    if ([[notification userInfo] objectForKey:@"Operation"]) {
        Operation=[[notification userInfo] objectForKey:@"Operation"];
        if([Operation isEqualToString:@"CONNECT"]){
            [self connectingDiscover];
            NSLog(@"收到连接指令");
        }
        if([Operation isEqualToString:@"SEARCH"]){
            [self alertSearchview];
            NSLog(@"收到连接指令");
        }
        if([Operation isEqualToString:@"OPEN"]){
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:open:%@\r\n",PhoneUUID]];
            NSLog(@"收到开锁指令");
        }
        if([Operation isEqualToString:@"CLOSE"]){
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:close:%@\r\n",PhoneUUID]];
            NSLog(@"收到关锁指令");
        }
        if([Operation isEqualToString:@"RINGON"]){
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:ringon:%@\r\n",PhoneUUID]];
            NSLog(@"收到开报警指令");
        }
        if([Operation isEqualToString:@"RINGOFF"]){
            [self writeToPeripheral:[NSString stringWithFormat:@"dong14:ringoff:%@\r\n",PhoneUUID]];
            NSLog(@"收到关报警指令");
        }
    }
}
@end
