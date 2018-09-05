//
//  ZYJMapSearchController.h
//  yihuodong
//
//  Created by 张艳江 on 2018/6/7.
//  Copyright © 2018年 张艳江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ZYJMapSearchController : UIViewController

@property(nonatomic, copy) NSString *cityName;
@property(nonatomic, copy) void(^chooseAddress)(CLLocationCoordinate2D pt);


@end
