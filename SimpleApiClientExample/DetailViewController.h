//
//  DetailViewController.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/11/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
