//
//  DetailViewController.m
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/11/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailViewController ()
{
    float _aspectRatioLandscape;
    float _aspectRatioPortrait;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    __weak DetailViewController *weakself = self;
    
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"title"] description];
        
        UIImage *placeHolderImage = [UIImage imageNamed:@"steveo.jpg"];
        
        [self.posterView setImageWithURL:[NSURL URLWithString:[self.detailItem valueForKey:@"poster_path"]]
                        placeholderImage:placeHolderImage
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                                   
                                   if (error) {
                                       NSLog(@"Error: %@ \n // [%@ %@]",
                                             error.localizedDescription,
                                             NSStringFromClass([weakself class]),
                                             NSStringFromSelector(_cmd));
                                       
                                       [weakself calcAspectRatioForImage:placeHolderImage];
                                       
                                   } else {
                                       weakself.detailDescriptionLabel.hidden = YES;
                                       [weakself calcAspectRatioForImage:image];
                                   }
                               }];
    }
}

- (void)calcAspectRatioForImage:(UIImage *)image
{
    _aspectRatioLandscape = image.size.height / image.size.width;
    _aspectRatioPortrait = image.size.width / image.size.height;
    
}

- (void)setConstraintsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageViewWidthConstraint.constant = self.scrollView.bounds.size.width;
        self.imageViewHeightConstraint.constant = self.scrollView.bounds.size.width * _aspectRatioLandscape;
    } else {
        self.imageViewWidthConstraint.constant = self.scrollView.bounds.size.height * _aspectRatioPortrait;
        self.imageViewHeightConstraint.constant = self.scrollView.bounds.size.height;
    }
}

#pragma mark - Lifecycle
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self setConstraintsForOrientation:toInterfaceOrientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _aspectRatioLandscape = 1.0;
    _aspectRatioPortrait = 1.0;
    
    self.scrollView.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureView];

    [self setConstraintsForOrientation:self.interfaceOrientation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
