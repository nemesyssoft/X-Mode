//
//  LocationMapViewController.m
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import "LocationMapViewController.h"
#import "Location+CoreDataProperties.h"
#import "LocationAnnotation.h"
#import <ContactsUI/ContactsUI.h>

@interface LocationMapViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) CLGeocoder *geoDecoder;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) BOOL didInitialMapRegionSetup;

@end

@implementation LocationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy =  kCLLocationAccuracyKilometer;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = 500;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.showsBackgroundLocationIndicator = YES;
    self.geoDecoder = [[CLGeocoder alloc] init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    MKUserTrackingButton *trackingButton = [MKUserTrackingButton userTrackingButtonWithMapView:self.mapView];
    trackingButton.frame = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    [self.trackView addSubview:trackingButton];
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (Location *aLocation in [self.fetchedResultsController fetchedObjects]) {
        NSString *address = aLocation.address;
        if (address.length == 0) {
            address = @"<Unknown Location>";
        }
        LocationAnnotation *annotation = [[LocationAnnotation alloc] initWithTitle:address andSubTitle:[self.dateFormatter stringFromDate:aLocation.timestamp]];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = aLocation.latitude;
        coordinate.longitude = aLocation.longitude;
        annotation.coordinate = coordinate;
        [annotations addObject:annotation];
    }
    if (annotations.count > 0) {
        [self.mapView addAnnotations:annotations];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                     message:@"Can't use this app without giving permission to gather location at all time."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
            
        default:
            break;
    }
    self.mapView.showsUserLocation = YES;
    if ( ! self.didInitialMapRegionSetup) {
        [self recenterMap];
        self.didInitialMapRegionSetup = YES;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    pin.tintColor = [MKPinAnnotationView greenPinColor];
    pin.animatesDrop = YES;
    pin.canShowCallout = YES;
    pin.draggable = NO;
    return pin;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                     message:@"Can't use this app without giving permission to gather location at all time."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
            
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    [[DataSource sharedDataSource] saveLocationWithLongitude:lastLocation.coordinate.longitude andLatitude:lastLocation.coordinate.latitude];
    NELog(@"received new location: %@", lastLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NELog(@"error %ld while trying to get current location: %@", (long)error.code, error.localizedDescription);
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
    NSFetchedResultsController<Location *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                            managedObjectContext:self.managedObjectContext
                                                                                                              sectionNameKeyPath:nil
                                                                                                                       cacheName:@"Locations"];
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

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    Location *newLocation = (Location *)anObject;
    CLLocation *cllocation = [[CLLocation alloc] initWithLatitude:newLocation.latitude longitude:newLocation.longitude];
    [self.geoDecoder reverseGeocodeLocation:cllocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil) {
            NELog(@"error %ld while trying to reverse geocode location: %@", (long)error.code, error.localizedDescription);
        }
        else {
            CLPlacemark *lastPlacemark = [placemarks lastObject];
            CNPostalAddress *postalAddress = lastPlacemark.postalAddress;
            NSString *address = [NSString stringWithFormat:@"%@%@%@", postalAddress.street.length > 0 ? [NSString stringWithFormat:@"%@, ", postalAddress.street] : @"",
                                 postalAddress.city.length > 0 ? [NSString stringWithFormat:@"%@, ", postalAddress.city] : @"",
                                 postalAddress.ISOCountryCode];
            if (address.length == 0) {
                address = @"<Unknown Location>";
            }
            LocationAnnotation *annotation = [[LocationAnnotation alloc] initWithTitle:address andSubTitle:[self.dateFormatter stringFromDate:newLocation.timestamp]];
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = newLocation.latitude;
            coordinate.longitude = newLocation.longitude;
            annotation.coordinate = coordinate;
            [self.mapView addAnnotation:annotation];
        }
    }];


}

#pragma mark - Private Methods

- (void)recenterMap
{
    CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
    MKCoordinateRegion currentRegion;
    currentRegion.center = userLocation;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05f;
    span.longitudeDelta = 0.05f;
    currentRegion.span = span;
    [self.mapView setRegion:currentRegion animated:YES];
}

#pragma mark - Public Methods

- (void)showLocationOnMap:(Location *)aLocation
{
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = aLocation.latitude;
    region.center.longitude = aLocation.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Action Methods

- (void)trackUser:(id)sender
{
    ((UIButton *)sender).selected = ! ((UIButton *)sender).isSelected;
    if (((UIButton *)sender).isSelected) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    else {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}

- (IBAction)mapTypeChanged:(id)sender
{
    UISegmentedControl *mapTypeSegmentedControl = (UISegmentedControl *)sender;
    switch (mapTypeSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
            
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            self.mapView.mapType = MKMapTypeStandard;
            break;
    }
}

@end
