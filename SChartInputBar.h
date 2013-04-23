//
//  SChartInputBar.h
//  SChartInputBar
//
//  Created by 滕 松 on 13-4-22.
//  Copyright (c) 2013年 滕 松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SChartInputBarDelegate.h"

@interface SChartInputBar : UIView <UITextViewDelegate>
@property (nonatomic, assign) id<SChartInputBarDelegate> delegate;
@property (nonatomic, readonly) NSString *text;

+ (SChartInputBar *)defaultChartInputBar;
- (void)clearInput;
@end

@interface SChartInputBar (Util)
+ (BOOL)isEmptyString:(NSString *)string;
@end
