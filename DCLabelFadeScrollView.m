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

@implementation DCLabelFadeScrollView

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

- (void)layoutSubviews;
{
  [super layoutSubviews];
  [self updateLabelsAppearance];
}

@end
