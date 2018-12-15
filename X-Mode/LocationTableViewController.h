//
//  LocationTableViewController.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

NS_ASSUME_NONNULL_END
