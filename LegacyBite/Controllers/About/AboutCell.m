//
//  AboutCell.m
//  LegacyBite
//
//  Created by Grizly on 15.07.26.
//

#import "AboutCell.h"

@implementation AboutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.text = nil;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.nameLabel.text = nil;
}


@end
