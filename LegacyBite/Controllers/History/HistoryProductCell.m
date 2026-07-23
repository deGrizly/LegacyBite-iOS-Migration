//
//  HistoryProductCell.m
//  LegacyBite
//
//  Created by Grizly on 20.07.26.
//

#import "HistoryProductCell.h"

@implementation HistoryProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self preInit];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [self preInit];
}

-(void)preInit{
    self.nameLabel.text = nil;
    self.brandLabel.text = nil;
    self.dateLabel.text = nil;
    
    self.nameLabel.hidden = false;
    self.brandLabel.hidden = false;
    self.dateLabel.hidden = false;
    
    [self.imageTask cancel];

    self.imageTask = nil;
    self.representedImageURL = nil;
    
    self.productImage.image = nil;
}

@end
