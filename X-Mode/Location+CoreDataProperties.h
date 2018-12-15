//
//  Location+CoreDataProperties.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//
//

#import "Location+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, copy) NSString *address;

@end

NS_ASSUME_NONNULL_END
