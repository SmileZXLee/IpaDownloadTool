//
//  ZXHttpIPGet.m
//  ZXRequestBlock
//
//  Created by 李兆祥 on 2018/8/26.
//  Copyright © 2018年 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXRequestBlock
//  V1.0.3

#import "ZXHttpIPGet.h"
#import <resolv.h>
#include <arpa/inet.h>

#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <stdio.h>
@implementation ZXHttpIPGet
+(NSString *)getIPArrFromLocalDnsWithUrlStr:(NSString *)urlStr{
    urlStr = [[urlStr stringByReplacingOccurrencesOfString:@"http://" withString:@""]stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    Boolean result,bResolved;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    NSMutableArray * ipsArr = [[NSMutableArray alloc] init];
    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, [urlStr cStringUsingEncoding:NSASCIIStringEncoding], kCFStringEncodingASCII);
    
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    if (result == TRUE) {
        addresses = CFHostGetAddressing(hostRef, &result);
    }
    bResolved = result == TRUE ? true : false;
    
    if(bResolved){
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++){
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            if(remoteAddr != NULL){
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
                NSString * ipStr = [NSString stringWithCString:ip encoding:NSUTF8StringEncoding];
                [ipsArr addObject:ipStr];
            }
        }
    }
    if(ipsArr.count){
        return ipsArr[0];
    }else{
        return nil;
    }
}
+(NSString *)getIPArrFromDnsPodWithUrlStr:(NSString *)urlStr{
    urlStr = [[urlStr stringByReplacingOccurrencesOfString:@"http://" withString:@""]stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    NSString *dnsUrl = [NSString stringWithFormat:@"http://119.29.29.29/d?ttl=1&dn=%@",urlStr];
    NSMutableURLRequest * dnsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dnsUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *data = [NSURLConnection sendSynchronousRequest:dnsRequest returningResponse:nil error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
