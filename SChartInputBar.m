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
@property (nonatomic, assign) UILabel *placeHolderLabel;
@property (nonatomic, assign) CGFloat barMaxHeight;
@property (nonatomic, assign) CGRect currentKeyboardFrame;
@end

@interface SChartInputBar (OverWrite)
- (CGFloat)defaultBarMaxWidth;
- (CGFloat)defaultBarMaxHeight;
- (CGFloat)defaultBarBottomY;
- (CGFloat)defaultBarTopY;
@end

@implementation SChartInputBar
@synthesize delegate;
@synthesize textView, doneButton, placeHolderLabel;
@synthesize barMaxHeight, currentKeyboardFrame;

#define k_chart_input_bar_margin_top    5.0
#define k_chart_input_bar_margin_left   3.0

#define k_chart_input_bar_done_height   26.0
#define k_chart_input_bar_done_width    58.0
#define k_chart_input_bar_min_height    (k_chart_input_bar_done_height + k_chart_input_bar_margin_top * 2)
#define k_chart_input_bar_min_width     (k_chart_input_bar_done_width + 10)
#define k_chart_input_bar_text_inset    3.0

#pragma mark init
+ (SChartInputBar *)defaultChartInputBar {
    return [[[SChartInputBar alloc] init] autorelease];
}
- (id)initWithFrame:(CGRect)frame {
    return [self init];
}
- (id)init {
    CGRect _f = CGRectMake(0, [self defaultBarBottomY], [self defaultBarMaxWidth], k_chart_input_bar_min_height);
    self = [super initWithFrame:_f];
    if (self) {
        self.barMaxHeight = [self defaultBarMaxHeight];
        
        UIImageView *_bg = [[UIImageView alloc] initWithFrame:self.bounds];
        _bg.image = [[UIImage imageNamed:@"toolbarbg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
        _bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_bg];
        [_bg release];
        
        UIButton *_done = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-k_chart_input_bar_done_width-k_chart_input_bar_margin_left, k_chart_input_bar_margin_top, k_chart_input_bar_done_width, k_chart_input_bar_done_height)];
        _done.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        _done.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_done setBackgroundImage:[UIImage imageNamed:@"buttonbg.png"] forState:UIControlStateNormal];
        [_done setTitle:@"Send" forState:UIControlStateNormal];
        [_done addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_done];
        self.doneButton = _done;
        [_done release];
        
        UIImageView *_txtbg = [[UIImageView alloc] initWithFrame:CGRectMake(k_chart_input_bar_margin_left, k_chart_input_bar_margin_top, [self textMaxWidth], self.bounds.size.height-k_chart_input_bar_margin_top*2)];
        _txtbg.image = [[UIImage imageNamed:@"textbg.png"] stretchableImageWithLeftCapWidth:15.0 topCapHeight:13.0];
        _txtbg.contentMode = UIViewContentModeRedraw;
        _txtbg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_txtbg aboveSubview:_bg];
        [_txtbg release];
        
        UITextView *_txtv = [[UITextView alloc] initWithFrame:CGRectInset(_txtbg.frame, k_chart_input_bar_text_inset, k_chart_input_bar_text_inset)];
        _txtv.backgroundColor = [UIColor clearColor];
        _txtv.delegate = self;
        _txtv.autoresizingMask = _txtbg.autoresizingMask;
        _txtv.font = [UIFont systemFontOfSize:15];
        [self addSubview:_txtv];
        self.textView = _txtv;
        [_txtv release];
        
        UILabel *_ph = [[UILabel alloc] initWithFrame:CGRectInset(_txtv.frame, 8, 0)];
        _ph.backgroundColor = [UIColor clearColor];
        _ph.font = [UIFont systemFontOfSize:13];
        _ph.textColor = [UIColor grayColor];
        _ph.lineBreakMode = NSLineBreakByTruncatingTail;
        [self insertSubview:_ph belowSubview:_txtv];
        self.placeHolderLabel = _ph;
        [_ph release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self refreshButtonState];
        [self refreshTextViewState];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [super dealloc];
}

#pragma mark observer
- (void)responseNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:UIKeyboardWillChangeFrameNotification]) {
        CGRect _kb_begin_rect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect _kb_end_rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval _kb_animation_duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        self.currentKeyboardFrame = _kb_end_rect;
        self.barMaxHeight = _kb_end_rect.origin.y - [self defaultBarTopY];
        
        [self moveBarFromBottom:_kb_begin_rect.origin.y ToBottom:_kb_end_rect.origin.y AnimationDuration:_kb_animation_duration];
    }
}

#pragma mark layout
- (CGFloat)textMaxHeight {
    return [self defaultBarMaxHeight] - k_chart_input_bar_margin_top * 2;
}
- (CGFloat)textMaxWidth {
    return self.doneButton.frame.origin.x - k_chart_input_bar_margin_left - 4;
}
- (CGSize)textMaxSize {
    return CGSizeMake([self textMaxWidth] - k_chart_input_bar_text_inset * 2, [self textMaxHeight] - k_chart_input_bar_text_inset * 2);
}
- (void)relayout {
    CGSize _size = [self.text sizeWithFont:self.textView.font constrainedToSize:[self textMaxSize] lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat _delta_height = _size.height - self.textView.bounds.size.height;
    CGFloat _bar_height = self.bounds.size.height + _delta_height;
    _bar_height = _bar_height > self.barMaxHeight ? self.barMaxHeight : _bar_height;
    _bar_height = _bar_height < k_chart_input_bar_min_height ? k_chart_input_bar_min_height : _bar_height;
    CGFloat _bar_y = self.frame.origin.y - _delta_height;
    _bar_y = _bar_y < [self defaultBarTopY] ? [self defaultBarTopY] : _bar_y;
    _bar_y = _bar_y+_bar_height > self.currentKeyboardFrame.origin.y ? self.currentKeyboardFrame.origin.y-_bar_height : _bar_y;
    NSTimeInterval _duration = _delta_height != 0 && self.frame.size.height != self.barMaxHeight ? 0.25 : 0;
    CGRect _bar_rect = CGRectMake(self.frame.origin.x, _bar_y, self.frame.size.width, _bar_height);
    [self reheightBarTo:_bar_rect AnimationDuration:_duration];
}
- (void)reheightBarTo:(CGRect)rect AnimationDuration:(NSTimeInterval)duration {
    BOOL _animated = duration > 0 ? YES : NO;
    if (_animated) {
        [UIView animateWithDuration:duration
                         animations:^(){
                             self.frame = rect;
                         }
                         completion:^(BOOL finished){
                             [self finishedReheightBarAnimation:YES];
                         }];
    } else {
        self.frame = rect;
        [self finishedReheightBarAnimation:NO];
    }
}
- (void)finishedReheightBarAnimation:(BOOL)animated {
    [self refreshTextViewState];
}
- (void)moveBarFromBottom:(CGFloat)from ToBottom:(CGFloat)to AnimationDuration:(NSTimeInterval)duration {
    BOOL _animated = duration > 0 ? YES : NO;
    CGRect _rect_from = CGRectMake(self.frame.origin.x, from - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    CGRect _rect_to = CGRectMake(self.frame.origin.x, to - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    self.frame = _rect_from;
    if (_animated) {
        [UIView animateWithDuration:duration
                         animations:^(){
                             self.frame = _rect_to;
                         }
                         completion:^(BOOL finished){
                             [self finishedMoveBarAnimation:YES];
                         }];
    } else {
        self.frame = _rect_to;
        [self finishedMoveBarAnimation:NO];
    }
}
- (void)finishedMoveBarAnimation:(BOOL)animated {}

#pragma mark text delegate
- (NSString *)text {
    return self.textView.text;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self refreshPlaceHolderState:YES];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self refreshPlaceHolderState:NO];
}
- (void)textViewDidChange:(UITextView *)textView {
    if ([SChartInputBar isEmptyString:self.text]) {
        return;
    }
    [self relayout];
    [self refreshButtonState];
}
- (void)refreshButtonState {
    self.doneButton.enabled = ![SChartInputBar isEmptyString:self.text];
}
- (void)refreshTextViewState {
    self.textView.scrollEnabled = self.frame.size.height < self.barMaxHeight ? NO : YES;
    if (self.textView.scrollEnabled) {
        [self.textView flashScrollIndicators];
    }
}
- (void)refreshPlaceHolderState:(BOOL)isBeginEditing {
    if (isBeginEditing) {
        self.placeHolderLabel.hidden = YES;
    } else {
        self.placeHolderLabel.hidden = [SChartInputBar isEmptyString:self.text] ? NO : YES;
    }
}

#pragma mark action
- (void)doneAction:(id)sender {
    [self clearInput];
    [self notifyInputBarDidClickDoneButton:self];
}
- (void)clearInput {
    [self.textView resignFirstResponder];
    self.textView.text = nil;
    [self relayout];
    [self refreshButtonState];
    [self refreshTextViewState];
    [self refreshPlaceHolderState:NO];
}
- (void)setPlaceHolder:(NSString *)placeHolder {
    self.placeHolderLabel.text = placeHolder;
}

#pragma mark notify 
- (void)notifyInputBarDidClickDoneButton:(SChartInputBar *)inputBar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidClickDoneButton:)]) {
        [self.delegate inputBarDidClickDoneButton:inputBar];
    }
}

@end

#import "AppDelegate.h"
@implementation SChartInputBar (OverWrite)
- (CGFloat)defaultBarMaxWidth {
    AppDelegate *_delegate = [UIApplication sharedApplication].delegate;
    return _delegate.window.bounds.size.width;
}
- (CGFloat)defaultBarMaxHeight {
    AppDelegate *_delegate = [UIApplication sharedApplication].delegate;
    return _delegate.window.bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
}
- (CGFloat)defaultBarBottomY {
    AppDelegate *_delegate = [UIApplication sharedApplication].delegate;
    return _delegate.window.bounds.size.height - k_chart_input_bar_min_height;
}
- (CGFloat)defaultBarTopY {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}
@end


@implementation SChartInputBar (Util)
+ (BOOL)isEmptyString:(NSString *)string {
    if (string && [string respondsToSelector:@selector(length)] && [string length] > 0) {
        return NO;
    }
    return YES;
}
@end

