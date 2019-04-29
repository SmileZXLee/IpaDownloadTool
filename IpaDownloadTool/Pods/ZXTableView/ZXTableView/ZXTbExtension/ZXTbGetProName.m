//
//  ZXTbGetProName.m
//  ZXTableView
//
//  Created by 李兆祥 on 2019/3/30.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/ZXTableView

#import "ZXTbGetProName.h"
#import <objc/runtime.h>
@interface ZXTbGetProName()
+(instancetype)shareInstance;
@property(nonatomic,strong)NSMutableDictionary *proCacheMapper;;
@end
@implementation ZXTbGetProName
+ (instancetype)shareInstance{
    static ZXTbGetProName * s_instance_dj_singleton = nil ;
    if (s_instance_dj_singleton == nil) {
        s_instance_dj_singleton = [[self alloc] init];
    }
    return (ZXTbGetProName *)s_instance_dj_singleton;
}

+(NSMutableArray *)zx_getPropertyNames:(id)obj{
    NSMutableDictionary *cacheMapper = [ZXTbGetProName shareInstance].proCacheMapper;
    NSString *objCls = NSStringFromClass([obj class]);
    if([cacheMapper.allKeys containsObject:objCls]){
        return [cacheMapper[objCls] mutableCopy];
    }
    NSMutableArray *propertyNamesArr = [NSMutableArray array];
    u_int count;
    objc_property_t *properties  = class_copyPropertyList([obj class],&count);
    for(NSUInteger i = 0;i < count;i++){
        const char *propertyNameChar = property_getName(properties[i]);
        NSString *propertyNameStr = [NSString stringWithUTF8String: propertyNameChar];
        [propertyNamesArr addObject:propertyNameStr];
        
    }
    [cacheMapper setValue:[propertyNamesArr mutableCopy] forKey:objCls];
    return propertyNamesArr ;
}
+(NSMutableArray *)zx_getRecursionPropertyNames:(id)obj{
    NSMutableArray *propertyNamesArr = [self zx_getPropertyNames:obj];
    if([self isSysClass:obj])return propertyNamesArr;
    Class class = [obj superclass];
    while (true) {
        if(![self isSysClass:[class new]]){
            NSMutableArray *superclassproArr = [self zx_getPropertyNames:class];
            [propertyNamesArr addObjectsFromArray:superclassproArr];
        }else{
            break;
        }
        NSObject *obj = [class new];
        class = obj.superclass;
    }
    return propertyNamesArr;
}
+(BOOL)superclassIsSysClass:(id)obj{
    
    return !([NSBundle bundleForClass:[obj superclass]] == [NSBundle mainBundle]);
}
+(BOOL)isSysClass:(id)obj{
    return !([NSBundle bundleForClass:[obj class]] == [NSBundle mainBundle]);
}

-(NSMutableDictionary *)proCacheMapper{
    if(!_proCacheMapper){
        _proCacheMapper = [NSMutableDictionary dictionary];
    }
    return _proCacheMapper;
}
@end
