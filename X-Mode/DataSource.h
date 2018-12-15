//
//  DataSource.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataSource : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (id)sharedDataSource;

- (void)saveLocationWithLongitude:(double)longitude andLatitude:(double)latitude;

@end

NS_ASSUME_NONNULL_END
