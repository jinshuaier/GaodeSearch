//
//  ZYJModel.h
//  Carworld
//
//  Created by 张艳江 on 2018/4/21.
//  Copyright © 2018年 张艳江. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYJModel : NSObject

//首页轮播图
@property (nonatomic, copy) NSString *img;
//活动
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *banner;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *start_date;
@property (nonatomic, copy) NSString *end_date;
@property (nonatomic, copy) NSString *enrollment;
@property (nonatomic, copy) NSString *enrollment_max;
@property (nonatomic, copy) NSString *charge_type;
@property (nonatomic, copy) NSString *activity_expire;
@property (nonatomic, copy) NSString *activity_end;
@property (nonatomic, copy) NSString *audit;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;

@end
