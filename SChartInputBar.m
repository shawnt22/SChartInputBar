//
//  SChartInputBar.m
//  SChartInputBar
//
//  Created by 滕 松 on 13-4-22.
//  Copyright (c) 2013年 滕 松. All rights reserved.
//

#import "SChartInputBar.h"

@interface SChartInputBar ()
@property (nonatomic, assign) UITextView *textView;
@property (nonatomic, assign) UIButton *doneButton;
@end

@implementation SChartInputBar
@synthesize delegate;
@synthesize textView, doneButton;

#define k_chart_input_bar_margin_top    2.0
#define k_chart_input_bar_margin_left   2.0

#define k_chart_input_bar_done_height   26.0
#define k_chart_input_bar_done_width    58.0
#define k_chart_input_bar_min_height    (k_chart_input_bar_done_height + k_chart_input_bar_margin_top * 2)
#define k_chart_input_bar_min_width     (k_chart_input_bar_done_width + 10)

#pragma mark init
- (id)initWithFrame:(CGRect)frame {
    frame.size.width = frame.size.width > k_chart_input_bar_min_width ? frame.size.width : k_chart_input_bar_min_width;
    frame.size.height = frame.size.height > k_chart_input_bar_min_height ? frame.size.height : k_chart_input_bar_min_height;
    
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *_bg = [[UIImageView alloc] initWithFrame:self.bounds];
        _bg.image = [UIImage imageNamed:@"toolbarbg.png"];
        _bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_bg];
        [_bg release];
        
        UIButton *_done = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-k_chart_input_bar_done_width-k_chart_input_bar_margin_left, k_chart_input_bar_margin_top, k_chart_input_bar_done_width, k_chart_input_bar_done_height)];
        _done.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [_done setBackgroundImage:[UIImage imageNamed:@"buttonbg.png"] forState:UIControlStateNormal];
        [_done setTitle:@"Send" forState:UIControlStateNormal];
        [_done addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_done];
        self.doneButton = _done;
        [_done release];
        
        UIImageView *_txtbg = [[UIImageView alloc] initWithFrame:CGRectMake(k_chart_input_bar_margin_left, k_chart_input_bar_margin_top, self.doneButton.frame.origin.x-k_chart_input_bar_margin_left-2, self.bounds.size.height-k_chart_input_bar_margin_top*2)];
        _txtbg.image = [UIImage imageNamed:@"textbg.png"];
        _txtbg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_txtbg aboveSubview:_bg];
        [_txtbg release];
        
        UITextView *_txtv = [[UITextView alloc] initWithFrame:_txtbg.frame];
        _txtv.backgroundColor = [UIColor clearColor];
        _txtv.delegate = self;
        _txtv.autoresizingMask = _txtbg.autoresizingMask;
        [self addSubview:_txtv];
        self.textView = _txtv;
        [_txtv release];
    }
    return self;
}
- (void)dealloc {
    [super dealloc];
}

#pragma mark text delegate
- (NSString *)text {
    return self.textView.text;
}
- (void)textViewDidChange:(UITextView *)textView {
    [self relayout];
}
- (void)relayout {
    
}

#pragma mark action
- (void)doneAction:(id)sender {
    [self notifyInputBarDidClickDoneButton:self];
}

#pragma mark notify 
- (void)notifyInputBarDidClickDoneButton:(SChartInputBar *)inputBar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidClickDoneButton:)]) {
        [self.delegate inputBarDidClickDoneButton:inputBar];
    }
}

@end


