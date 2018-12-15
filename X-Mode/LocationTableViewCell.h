//
//  LocationTableViewCell.h
//  X-Mode
//
//  Created by Laurent Daudelin on 12/13/18.
//  Copyright © 2018 Nemesys Software. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *subTitle;
@property (nonatomic, strong) IBOutlet UIButton *showOnMapButton;

@end

NS_ASSUME_NONNULL_END
