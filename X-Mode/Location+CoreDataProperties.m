//
//  Location+CoreDataProperties.m
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//
//

#import "Location+CoreDataProperties.h"


@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Location"];
}

@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;
@dynamic address;

@end
