//
//  AboutViewController.m
//  LegacyBite
//
//  Created by Grizly on 15.07.26.
//

#import "AboutViewController.h"
#import "AboutCell.h"
#import "AboutDetailsViewController.h"

typedef enum : NSUInteger {
    AboutTagCellProject,
    AboutTagCellOpenFood,
    AboutTagCellGithub,
    AboutTagCellCount
} AboutTagCell;


@interface AboutViewController () <UITableViewDelegate, UITableViewDataSource>
{
    
}
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView * wrapperView;
@property (weak, nonatomic) IBOutlet UILabel * versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"About";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
 
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", version];
    self.wrapperView.layer.cornerRadius = 10.f;
    self.wrapperView.layer.masksToBounds = YES;
    self.wrapperView.layer.borderWidth = 1.f;
    self.wrapperView.layer.borderColor = [UIColor systemGray5Color].CGColor;
}



#pragma mark: UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return AboutTagCellCount;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AboutCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
    
    NSString * name = @"";
    if(indexPath.row == AboutTagCellProject){
        name = @"About Project";
    } else if (indexPath.row == AboutTagCellOpenFood){
        name = @"Open Food Facts API";
    } else if (indexPath.row == AboutTagCellGithub){
        name = @"GitHub";
    }
    
    cell.nameLabel.text = name;
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    
    
    if(indexPath.row == 0){
        AboutDetailsViewController * vc = [AboutDetailsViewController new];
        vc.type = AboutDetailsTypeProject;
        [self.navigationController pushViewController:vc animated:true];
    } else if (indexPath.row == 1){
        AboutDetailsViewController * vc = [AboutDetailsViewController new];
        vc.type = AboutDetailsTypeApi;
        [self.navigationController pushViewController:vc animated:true];
    }
    
    
}

@end
