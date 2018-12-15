//
//  LocationAnnotation.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

- (instancetype)initWithTitle:(NSString *)title andSubTitle:(NSString *)subTitle;

@end

NS_ASSUME_NONNULL_END
