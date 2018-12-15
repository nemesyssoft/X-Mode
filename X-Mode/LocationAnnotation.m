//
//  LocationAnnotation.m
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation

- (instancetype)initWithTitle:(NSString *)title andSubTitle:(NSString *)subTitle
{
    if (self = [super init]) {
        _title = title;
        _subtitle = subTitle;
    }
    return self;
}

@end
