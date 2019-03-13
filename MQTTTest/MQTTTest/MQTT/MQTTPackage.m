//
//  MQTTPackage.m
//  MQTTTest
//
//  Created by 朱天聪 on 2018/7/3.
//  Copyright © 2018年 朱天聪. All rights reserved.
//

#import "MQTTPackage.h"

@implementation MQTTPackage
/** * 校验和 */
UInt8 CheckSum(UInt8 *bytes, NSUInteger size) {
    UInt8 sum = 0;
    for (int i = 0; i < size ; ++ i) {
        sum += bytes[i];
    }
    return sum;
}

/** 字节数组转十六进制字符串 */
NSString *UInt8s2Hex(UInt8 *bytes, NSUInteger size) {
    unsigned char map[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    NSMutableData *data = [NSMutableData dataWithCapacity:(size << 1)];
    for (int i = 0; i < size; ++ i) {
        UInt8 byte = bytes[i];
        UInt8 high = ((byte >> 4) & 0x0F);
        UInt8 low = (byte & 0x0F);
        [data appendBytes:map + high length:1];
        [data appendBytes:map + low length:1];
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

/** 字节数转十六进制字符串*/
NSString *UInt8ToHex(UInt8 byte) {
    return UInt8s2Hex(&byte, 1);
}

/** 字节数转十六进制字符串*/
NSString *UInt16ToHex(UInt16 byte) {
    UInt8 bytes[] = {((byte >> 8) & 0xFF), ((byte >> 0) & 0xFF)};
    return UInt8s2Hex(bytes, 2);
}

/** 十六进制字符串转字节数组 */
void Hex2UInt8s(NSString *str, UInt8 *bytes) {
    NSUInteger size = str.length;
    NSData *data = [[str uppercaseString] dataUsingEncoding:NSASCIIStringEncoding];
    UInt8 *buffer = (UInt8 *)[data bytes];
    for (int i = 0, j = 0; j < size - 1; ++ i, j += 2) {
        UInt8 a = buffer[j], b = buffer[j + 1];
        UInt8 high = (a >= 'A') ? (a - 'A' + 10) : (a - '0' + 0);
        UInt8 low = (b >= 'A') ? (b - 'A' + 10) : (b - '0' + 0);
        bytes[i] = (high << 4 | low);
    }
}

/** 十六进制字符串转字节数 */
UInt8 Hex2UInt8(NSString *str) {
    UInt8 byte = 0x00;
    Hex2UInt8s(str, &byte);
    return byte;
}

/** 十六进制字符串转字节数 */
UInt16 Hex2UInt16(NSString *str) {
    UInt8 bytes[2] = {0x00};
    Hex2UInt8s(str, bytes);
    return (bytes[0] << 8) + bytes[1];
}

/**
 *  二进制字符串转换成十六进制 */
NSString *Hex2ToInt8(NSString *str) {
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (str.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - str.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        str = [mStr stringByAppendingString:str];
    }
    NSString *hex = @"";
    for (int i=0; i<str.length; i+=4) {
        
        NSString *key = [str substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}

@end
