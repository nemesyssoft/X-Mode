//
//  LocationMapViewController.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Location;

@interface LocationMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *trackView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)showLocationOnMap:(Location *)aLocation;
- (IBAction)trackUser:(id)sender;

@end

