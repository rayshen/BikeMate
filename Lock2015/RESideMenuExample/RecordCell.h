//
//  RecordCell.h
//  Lock2015
//
//  Created by shen on 15/7/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nolabel;
@property (weak, nonatomic) IBOutlet UILabel *dislabel;
@property (weak, nonatomic) IBOutlet UILabel *datelabel;
@property (weak, nonatomic) IBOutlet UILabel *fromlabel;
@property (weak, nonatomic) IBOutlet UILabel *tolabel;

@end
