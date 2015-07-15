//
//  DetailTableViewController.m
//  ShenBluetooth
//
//  Created by shen on 15/5/9.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#define SECTION_NAME @"DeviceDetailInfo"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_centralMgr setDelegate:self];
    if (_discoveredPeripheral)
    {
        NSLog(@"connectPeripheral");
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
    }
    _arrayServices = [[NSMutableArray alloc] init];
    _characteristicNum = 0;
    
    //该定时器设定为了：每隔N秒read一次硬件端数据
    self.updatetimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(todisplay) userInfo:nil repeats:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.centralMgr cancelPeripheralConnection:_discoveredPeripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"start scan Peripherals");
            
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}



- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    [self.arrayServices removeAllObjects];
    [_discoveredPeripheral setDelegate:self];
    
    //查找服务
    [_discoveredPeripheral discoverServices:nil];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        //        [self cleanup];
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        NSLog(@"Service found with UUID : %@", s.UUID);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{SECTION_NAME:s.UUID.description}];
        [self.arrayServices addObject:dic];
        [s.peripheral discoverCharacteristics:nil forService:s];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.characteristicNum--;
    if (self.characteristicNum == 0)
    {
        //[self.tableView reloadData];
    }
    
    if (error)
    {
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    for (NSMutableDictionary *dic in self.arrayServices)
    {
        NSString *service = [dic valueForKey:SECTION_NAME];
        if ([service isEqual:characteristic.service.UUID.description])
        {
            if([characteristic.UUID.description isEqualToString:@"FFF6"]){
                NSData *datavalue=characteristic.value;
                NSData *shidudata=[datavalue subdataWithRange:NSMakeRange(0, 1)];
                NSData *wendudata=[datavalue subdataWithRange:NSMakeRange(2, 1)];
                NSLog(@"\nFind---theValueis:%@   %@-%@",characteristic.value,shidudata,wendudata);
                int i=0,j=0;
                [shidudata getBytes: &i length: sizeof(i)];
                [wendudata getBytes: &j length: sizeof(j)];

                self.current_humitidy=i;
                self.current_temperature=j;

                self.thelabel.text=[NSString stringWithFormat:@"当前\n温度为：%i℃\n湿度：%i%%",j,i];
                
                [dic setValue:characteristic.value forKey:characteristic.UUID.description];

            }else{
                //[dic setValue:characteristic.value forKey:characteristic.UUID.description];

            }
            
        }
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
        self.characteristicNum++;

        NSLog(@"特征字节 UUID: %@ (%@)", c.UUID.data, c.UUID);
        
        //FFF1特征：发送数据控制硬件端
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]){
            self.writeCharacteristic = c;
            NSLog(@"找到WRITE : %@", c);
        }
        
        //FFF6特征：温湿度数据
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF6"]]){
            [peripheral readValueForCharacteristic:c];
        }
    }
}


//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)string{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    
    NSData* value = [self stringToByte:string];
    NSLog(@"Witedata: %@",value);
    
    
    [_discoveredPeripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}

-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}


-(void)todisplay{
    for (CBService *s in self.discoveredPeripheral.services)
    {
        [s.peripheral discoverCharacteristics:nil forService:s];
    }
}

//控制LED1按钮，下同（通讯格式的定义在硬件端）
- (IBAction)led1control:(id)sender {
    UISwitch *swt1= (UISwitch*)sender;
    if (swt1.on) {
        [self writeToPeripheral:@"11"];
    }else{
        [self writeToPeripheral:@"10"];

    }
}

- (IBAction)led2control:(id)sender {
    UISwitch *swt2= (UISwitch*)sender;
    if (swt2.on) {
        [self writeToPeripheral:@"21"];

    }else{
        [self writeToPeripheral:@"20"];

    }
}

- (IBAction)led3control:(id)sender {
    UISwitch *swt3= (UISwitch*)sender;
    if (swt3.on) {
        [self writeToPeripheral:@"41"];

    }else{
        [self writeToPeripheral:@"40"];

    }
}

- (IBAction)jdqcontrol:(id)sender {
    UISwitch *swt4= (UISwitch*)sender;
    if (swt4.on) {
        [self writeToPeripheral:@"44"];

    }else{
        [self writeToPeripheral:@"43"];

    }
}
@end
