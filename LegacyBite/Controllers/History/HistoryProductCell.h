//
//  HistoryProductCell.h
//  LegacyBite
//
//  Created by Grizly on 20.07.26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView * productImage;

@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UILabel * brandLabel;
@property (weak, nonatomic) IBOutlet UILabel * dateLabel;

@property (nonatomic, strong, nullable) NSURLSessionDataTask * imageTask;
@property (nonatomic, strong, nullable) NSURL * representedImageURL;

@end

NS_ASSUME_NONNULL_END
