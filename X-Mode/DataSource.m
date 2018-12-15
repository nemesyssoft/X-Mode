//
//  DataSource.m
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import "DataSource.h"
#import "Location+CoreDataProperties.h"
#import <Contacts/Contacts.h>

static DataSource *sharedDataSource = nil;

@interface DataSource ()

@property (strong, nonatomic) CLGeocoder *geoDecoder;
@property (strong, nonatomic) Location *locationBeingSaved;

@end

@implementation DataSource

+ (id)sharedDataSource
{
    static dispatch_once_t dataSourcePredicate;
    dispatch_once(&dataSourcePredicate, ^{
        sharedDataSource = [[super allocWithZone:NULL] init];
        sharedDataSource.geoDecoder = [[CLGeocoder alloc] init];
    });
    
    return sharedDataSource;
}

- (void)saveLocationWithLongitude:(double)longitude andLatitude:(double)latitude
{
    NSFetchRequest<Location *> *fetchRequest = Location.fetchRequest;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %Lf AND %K = %Lf", @"longitude", longitude, @"latitude", latitude];
    NSError *error = nil;
    NSUInteger duplicationLocationsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NELog(@"error %ld while trying to get the duplication locations: %@", (long)error.code, error.localizedDescription);
    }
    if (duplicationLocationsCount == 0) {
        if (self.locationBeingSaved != nil) {
            if (self.locationBeingSaved.longitude == longitude && self.locationBeingSaved.latitude == latitude) {
                return;
            }
        }
        self.locationBeingSaved = [[Location alloc] initWithEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        self.locationBeingSaved.longitude = longitude;
        self.locationBeingSaved.latitude = latitude;
        self.locationBeingSaved.timestamp = [NSDate date];
        CLLocation *cllocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
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
                self.locationBeingSaved.address = address;
                if ( ! [self.managedObjectContext save:&error]) {
                    NELog(@"error %ld while trying to save new location: %@", (long)error.code, error.localizedDescription);
                }
                self.locationBeingSaved = nil;
            }
        }];
    }
}

@end
