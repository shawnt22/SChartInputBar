//
//  SChartInputBarDelegate.h
//  SChartInputBar
//
//  Created by 滕 松 on 13-4-22.
//  Copyright (c) 2013年 滕 松. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SChartInputBar;

@protocol SChartInputBarDelegate <NSObject>

@optional
- (void)inputBarDidClickDoneButton:(SChartInputBar *)inputBar;

@end
