//
//  DCLabelFadeScrollView.m
//  DCLabelFadeScrollView
//
//  Created by Peter Hare on 29/04/2014.
//  Copyright (c) 2014 Pete Hare. All rights reserved.
//

#import "DCLabelFadeScrollView.h"

static CGFloat const DCStatusBarHeight = 20.;


@interface UIView (DCRecursiveSubviews)
@end

@implementation UIView (DCRecursiveSubviews)

- (NSArray *)dc_recursiveSubviews;
{
  if ([[self subviews] count] == 0) return @[];

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:[[self subviews] count]];
  for (NSUInteger idx = 0; idx < [[self subviews] count]; idx++)
  {
    id obj = [[self subviews] objectAtIndex:idx];
    id instance = [obj dc_recursiveSubviews];

    if (nil != instance)
    {
      [result addObjectsFromArray:instance];
    }
  }
  return [result arrayByAddingObjectsFromArray:[self subviews]];
}

@end


@interface DCLabelFadeScrollView () <UIScrollViewDelegate>

@property (nonatomic, weak) id<UIScrollViewDelegate> realDelegate;

@end

@implementation DCLabelFadeScrollView

- (id)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit;
{
  [self setDelegate:self];
}

- (void)updateLabelsAppearance;
{
  NSArray *subviews = [self dc_recursiveSubviews];

  [subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger i, BOOL *stop) {
    if (NO == [view isKindOfClass:[UILabel class]]) return;

    UILabel *label = (UILabel *)view;
    CGRect relativeFrame = [self convertRect:[label frame] toView:[[[UIApplication sharedApplication] windows] firstObject]];
    CGFloat alpha = MIN(MAX((relativeFrame.origin.y - DCStatusBarHeight / 2.) / DCStatusBarHeight, 0.), 1.);
    label.alpha = alpha;
  }];
}

#pragma mark - Override

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate;
{
  [super setDelegate:self];
  self.realDelegate = delegate != self ? delegate : nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector;
{
  return [super respondsToSelector:aSelector] || [self.realDelegate respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
{
  return [super methodSignatureForSelector:aSelector] ?: [(id)self.realDelegate methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation;
{
  id delegate = self.realDelegate;
  if ([delegate respondsToSelector:anInvocation.selector])
  {
    [anInvocation invokeWithTarget:delegate];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
  id<UIScrollViewDelegate> delegate = self.realDelegate;
  if ([delegate respondsToSelector:_cmd])
  {
    [delegate scrollViewDidScroll:scrollView];
  }

  [self updateLabelsAppearance];
}

@end
