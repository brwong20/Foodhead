//
//  UserProfileViewController.m
//  FoodWise
//
//  Created by Brian Wong on 2/19/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ImageCollectionCell.h"
#import "UserAuthManager.h"
#import "AppDelegate.h"

@interface UserProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIButton *logoutButton;

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) UILabel *reviewsLabel;
@property (nonatomic, strong) UILabel *reviewsCount;

@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) UILabel *pointsCount;

@property (nonatomic, strong) UICollectionView *userPhotoCollection;

@end

static NSString *cellId = @"userPhoto";

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.1, self.view.frame.size.height * 0.17 - self.view.frame.size.width * 0.1, self.view.frame.size.width * 0.2, self.view.frame.size.width * 0.2)];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    self.profileImageView.backgroundColor = [UIColor whiteColor];
    [self.profileImageView setImage:[UIImage imageNamed:@"fukboi"]];
    [self.view addSubview:self.profileImageView];
    
    self.usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width * 0.2, CGRectGetMaxY(self.profileImageView.frame), self.view.frame.size.width * 0.4, self.view.frame.size.height * 0.2)];
    self.usernameLabel.text = @"USERNAME";
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    [self.usernameLabel setFont:[UIFont systemFontOfSize:22.0]];
    [self.view addSubview:self.usernameLabel];
    
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
    self.exitButton.backgroundColor = [UIColor cyanColor];
    [self.exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
    
    self.logoutButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 50.0, self.view.frame.size.width, 50.0)];
    self.logoutButton.backgroundColor = [UIColor redColor];
    [self.logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logoutButton];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.33);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.userPhotoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.6, self.view.frame.size.width, self.view.frame.size.height * 0.28) collectionViewLayout:flowLayout];
    self.userPhotoCollection.delegate = self;
    self.userPhotoCollection.dataSource= self;
    self.userPhotoCollection.showsHorizontalScrollIndicator = NO;
    self.userPhotoCollection.backgroundColor = [UIColor blueColor];
    [self.userPhotoCollection registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.userPhotoCollection];
}

- (void)exitProfile{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)logout{
    UserAuthManager *authManager = [UserAuthManager sharedInstance];
    [authManager logoutUser:^(id completed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Logout successful");
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            [appDelegate changeRootViewControllerFor:RootViewTypeLogin];
        });
    } failureHandler:^(id error) {
        NSLog(@"Logout failed: %@", error);
    }];
}


#pragma mark - UICollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    imageCell.backgroundColor = [UIColor lightGrayColor];
    return imageCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
