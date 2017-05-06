//
//  YYGifFileHandle.h
//  DDFood
//
//  Created by YZ Y on 16/12/24.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YYGifFileHandle : NSObject
/**获取gif文件信息*/
+ (NSDictionary *)getGifInfo:(NSString *)gifName;
+ (NSArray *)getGifImage:(NSString *)gifName;
/**添加gif水印*/
+ (NSArray *)getGifImage:(NSString *)gifName text:(NSString *)text;
/**直接获取GIF视图*/
+ (UIView *)gifView:(NSString *)gifName text:(NSString *)text;

@end
