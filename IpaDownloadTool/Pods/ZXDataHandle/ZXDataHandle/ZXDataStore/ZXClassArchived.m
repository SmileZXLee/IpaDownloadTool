//
//  ZXArchived.m
//  ZXDataHandleDemo
//
//  Created by 李兆祥 on 2019/1/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  GitHub:https://github.com/SmileZXLee/ZXDataHandle

#import "ZXClassArchived.h"
#import <objc/runtime.h>
@implementation ZXClassArchived 
-(void)encodeWithCoder:(NSCoder *)enCoder{
    u_int count;
    objc_property_t *properties  = class_copyPropertyList([self class],&count);
    for(int i = 0;i < count;i++){
        const char *propertyNameChar = property_getName(properties[i]);
        NSString *propertyNameStr = [NSString stringWithUTF8String: propertyNameChar];
        [enCoder encodeObject:[self valueForKeyPath:propertyNameStr] forKey:propertyNameStr];
    }
    free(properties);
    
}
-(id)initWithCoder:(NSCoder *)decoder{
    if(self = [super init]){
        u_int count;
        objc_property_t *properties  = class_copyPropertyList([self class],&count);
        for(int i = 0;i < count;i++){
            const char *propertyNameChar = property_getName(properties[i]);
            NSString *propertyNameStr = [NSString stringWithUTF8String: propertyNameChar];
            id obj = [decoder decodeObjectForKey:propertyNameStr];
            [self setValue:obj forKeyPath:propertyNameStr];
        }
        free(properties);
    }
    return  self;
}
@end
