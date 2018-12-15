//
//  LocationTableViewController.m
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import "LocationTableViewController.h"
#import "Location+CoreDataProperties.h"
#import "LocationTableViewCell.h"
#import "LocationMapViewController.h"

@interface LocationTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController<Location *> *fetchedResultsController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LocationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationTableViewCell" forIndexPath:indexPath];
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withLocation:location];
    cell.showOnMapButton.tag = indexPath.row;
    return cell;
}

- (void)configureCell:(LocationTableViewCell *)cell withLocation:(Location *)location
{
    NSString *address = location.address;
    if (address.length == 0) {
        address = @"<Unknown Location>";
    }
    cell.title.text = address;
    cell.subTitle.text = [self.dateFormatter stringFromDate:location.timestamp];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController<Location *> *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest<Location *> *fetchRequest = Location.fetchRequest;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController<Location *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Locations"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self performSelector:@selector(scrollTableViewToBottom) withObject:nil afterDelay:0.5f];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withLocation:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withLocation:anObject];
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Action Methods

- (IBAction)showOnMap:(id)sender
{
    Location *selectedLocation = [self.fetchedResultsController.fetchedObjects objectAtIndex:((UIButton *)sender).tag];
    LocationMapViewController *mapViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    self.tabBarController.selectedIndex = 0;
    [mapViewController showLocationOnMap:selectedLocation];
}

#pragma mark - Private Methods

- (void)scrollTableViewToBottom
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

@end
