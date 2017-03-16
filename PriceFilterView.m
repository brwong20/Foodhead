//
//  PriceFilterView.m
//  Foodhead
//
//  Created by Brian Wong on 3/8/17.
//  Copyright © 2017 Brian Wong. All rights reserved.
//

#import "PriceFilterView.h"
#import "FoodWiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

@interface PriceFilterView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

//Prompt labels
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *sepLine;

//Current price container
@property (nonatomic, strong) UIView *priceContainer;
@property (nonatomic, strong) UILabel *containerTitle;
@property (nonatomic, strong) UILabel *restaurantName;

//Price input field
@property (nonatomic, strong) UILabel *updateLabel;
@property (nonatomic, strong) UILabel *updateDescription;
@property (nonatomic, strong) UILabel *dollarSign;
@property (nonatomic, strong) UIView *period;

@property (nonatomic, strong) UITextField *priceField;
@property (nonatomic, strong) UIView *digitContainer;
@property (nonatomic, strong) UILabel *digitOne;
@property (nonatomic, strong) UILabel *digitTwo;
@property (nonatomic, strong) UILabel *digitThree;
@property (nonatomic, strong) UILabel *digitFour;

@end

@implementation PriceFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPriceContainer:frame];
        [self addObservers];
    }
    
    return self;
}

- (void)dealloc{
    [self removeObservers];
}

- (void)setupPriceContainer:(CGRect)frame{
    CGRect viewRect = frame;
    
    self.backgroundColor = [UIColor clearColor];

    self.promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(viewRect.size.width/2 - viewRect.size.width * 0.2, viewRect.size.height - viewRect.size.height * 0.07, viewRect.size.width * 0.4, viewRect.size.height * 0.05)];
    self.promptLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.font = [UIFont nun_lightFontWithSize:frame.size.height * 0.04];
    self.promptLabel.text = @"Price";
    self.promptLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.promptLabel];
    
    self.sepLine = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.43, CGRectGetMinY(self.promptLabel.frame) - frame.size.height * 0.02, frame.size.width * 0.86, 5.0)];
    self.sepLine.backgroundColor = [UIColor clearColor];
    [self.sepLine setImage:[UIImage imageNamed:@"separate_line"]];
    [self addSubview:self.sepLine];
    
    self.detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(viewRect.size.width/2 - viewRect.size.width * 0.3, CGRectGetMinY(self.sepLine.frame) - viewRect.size.height * 0.05, viewRect.size.width * 0.6, viewRect.size.height * 0.03)];
    self.detailLabel.backgroundColor = [UIColor clearColor];
    self.detailLabel.textColor = [UIColor whiteColor];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.font = [UIFont nun_semiboldFontWithSize:self.frame.size.height * 0.02];
    self.detailLabel.text = @"(per person, tax & tip included)";
    [self addSubview:self.detailLabel];
    
    //Putting our labels in this makes aligning them with the priceContainer easier.
    self.digitContainer = [[UIView alloc]initWithFrame:CGRectMake(viewRect.size.width/2 - viewRect.size.width * 0.37, CGRectGetMinY(self.detailLabel.frame) - viewRect.size.height * 0.12, viewRect.size.width * 0.74, viewRect.size.height * 0.12)];
    self.digitContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.digitContainer];
    
    self.dollarSign = [[UILabel alloc]initWithFrame:CGRectMake(viewRect.size.width * 0.03, CGRectGetMidY(self.digitContainer.frame) - viewRect.size.height * 0.035, viewRect.size.width * 0.1, viewRect.size.height * 0.07)];
    self.dollarSign.text = @"$";
    self.dollarSign.textAlignment = NSTextAlignmentCenter;
    self.dollarSign.font = [UIFont nun_fontWithSize:self.frame.size.height * 0.04];
    self.dollarSign.textColor = [UIColor whiteColor];
    self.dollarSign.backgroundColor = [UIColor clearColor];
    [self addSubview:self.dollarSign];
    
    UITapGestureRecognizer *keypadGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showKeypad)];
    keypadGesture.numberOfTapsRequired = 1;
    [self.digitContainer addGestureRecognizer:keypadGesture];
    
    UITapGestureRecognizer *dismissKeypadGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeypad)];
    dismissKeypadGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:dismissKeypadGesture];
    
    //In order to not let the user edit the price and keep things behaving cleaner. We will use this textfield to populate the labels/"fake fields".
    self.priceField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 0.0, 0.0)];
    self.priceField.keyboardType = UIKeyboardTypeNumberPad;
    self.priceField.backgroundColor = [UIColor clearColor];
    self.priceField.tintColor = [UIColor clearColor];
    self.priceField.delegate = self;
    [self.digitContainer addSubview:self.priceField];
    
    self.digitOne = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitOne.tag = 1;
    //self.digitOne.userInteractionEnabled = NO;
    self.digitOne.textAlignment = NSTextAlignmentCenter;
    self.digitOne.font = [UIFont nun_lightFontWithSize:self.digitContainer.frame.size.height * 0.67];
    self.digitOne.tintColor = [UIColor clearColor];
    self.digitOne.layer.cornerRadius = self.digitOne.frame.size.height * 0.15;
    self.digitOne.backgroundColor = [UIColor whiteColor];
    self.digitOne.clipsToBounds = YES;
    [self.digitContainer addSubview:self.digitOne];
    
    //Set up first and last digit to bound the textviews in the digit container then space them into the center proportionally (used 0.5 between digit 1 & 2/3 & 4).
    self.digitFour = [[UILabel alloc]initWithFrame:CGRectMake(self.digitContainer.frame.size.width - self.digitContainer.frame.size.width * 0.2, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitFour.tag = 4;
    //self.digitFour.userInteractionEnabled = NO;
    self.digitFour.textAlignment = NSTextAlignmentCenter;
    self.digitFour.font = [UIFont nun_lightFontWithSize:self.digitContainer.frame.size.height * 0.67];
    self.digitFour.tintColor = [UIColor clearColor];
    self.digitFour.layer.cornerRadius = self.digitOne.frame.size.height * 0.15;
    self.digitFour.backgroundColor = [UIColor whiteColor];
    self.digitFour.clipsToBounds = YES;
    [self.digitContainer addSubview:self.digitFour];
    
    self.digitTwo = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.digitOne.frame) + self.digitContainer.frame.size.width * 0.05, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitTwo.tag = 2;
    //self.digitTwo.userInteractionEnabled = NO;
    self.digitTwo.textAlignment = NSTextAlignmentCenter;
    self.digitTwo.font = [UIFont nun_lightFontWithSize:self.digitContainer.frame.size.height * 0.67];
    self.digitTwo.tintColor = [UIColor clearColor];
    self.digitTwo.layer.cornerRadius = self.digitOne.frame.size.height * 0.15;
    self.digitTwo.backgroundColor = [UIColor whiteColor];
    self.digitTwo.clipsToBounds = YES;
    [self.digitContainer addSubview:self.digitTwo];
    
    self.digitThree = [[UILabel alloc]initWithFrame:CGRectMake(self.digitFour.frame.origin.x - self.digitContainer.frame.size.width * 0.25, 0, self.digitContainer.frame.size.width * 0.2, self.digitContainer.frame.size.height)];
    self.digitThree.tag = 3;
    //self.digitThree.userInteractionEnabled = NO;
    self.digitThree.textAlignment = NSTextAlignmentCenter;
    self.digitThree.font = [UIFont nun_lightFontWithSize:self.digitContainer.frame.size.height * 0.67];
    self.digitThree.tintColor = [UIColor clearColor];
    self.digitThree.layer.cornerRadius = self.digitOne.frame.size.height * 0.15;
    self.digitThree.backgroundColor = [UIColor whiteColor];
    self.digitThree.clipsToBounds = YES;
    [self.digitContainer addSubview:self.digitThree];
    
    self.period = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetMinX(self.digitTwo.frame) + CGRectGetMaxX(self.digitThree.frame))/2 - viewRect.size.width * 0.005, CGRectGetMaxY(self.digitTwo.frame) - viewRect.size.width * 0.03, viewRect.size.width * 0.01, viewRect.size.width * 0.01)];
    self.period.layer.shouldRasterize = YES;
    self.period.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.period.backgroundColor = [UIColor whiteColor];
    self.period.layer.cornerRadius = self.period.frame.size.height/2;
    [self.digitContainer addSubview:self.period];

    //[LayoutBounds drawBoundsForAllLayers:self];
}

- (void)showKeypad{
    if ([self.priceField canBecomeFirstResponder]) {
        [self.priceField becomeFirstResponder];
    }
}

- (void)dismissKeypad{
    if ([self.priceField isFirstResponder]) {
        [self.priceField resignFirstResponder];
        [self didUpdatePrice];
    }
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif{
    CGRect padFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat animDuration = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]floatValue];
    if ([self.delegate respondsToSelector:@selector(keypadWillShow:)]) {
        [self.delegate keypadWillShow:notif];
    }
    [UIView animateWithDuration:animDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect priceFrame = self.promptLabel.frame;
        CGRect containerFrame = self.digitContainer.frame;
        CGRect dollarFrame = self.dollarSign.frame;
        CGRect lineFrame = self.sepLine.frame;
        CGRect detailFrame = self.detailLabel.frame;
        
        priceFrame.origin.y -= padFrame.size.height;
        containerFrame.origin.y -= padFrame.size.height;
        dollarFrame.origin.y -= padFrame.size.height;
        detailFrame.origin.y -= padFrame.size.height;
        lineFrame.origin.y -= padFrame.size.height;

        self.promptLabel.frame = priceFrame;
        self.digitContainer.frame = containerFrame;
        self.dollarSign.frame = dollarFrame;
        self.sepLine.frame = lineFrame;
        self.detailLabel.frame = detailFrame;
    } completion:nil];
}
     
- (void)keyboardWillHide:(NSNotification *)notif{
    CGRect padFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat animDuration = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]floatValue];
    if ([self.delegate respondsToSelector:@selector(keypadWillHide:)]) {
        [self.delegate keypadWillHide:notif];
    }
    [UIView animateWithDuration:animDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect priceFrame = self.promptLabel.frame;
        CGRect containerFrame = self.digitContainer.frame;
        CGRect dollarFrame = self.dollarSign.frame;
        CGRect lineFrame = self.sepLine.frame;
        CGRect detailFrame = self.detailLabel.frame;
        
        priceFrame.origin.y += padFrame.size.height;
        containerFrame.origin.y += padFrame.size.height;
        dollarFrame.origin.y += padFrame.size.height;
        detailFrame.origin.y += padFrame.size.height;
        lineFrame.origin.y += padFrame.size.height;
        
        
        self.promptLabel.frame = priceFrame;
        self.digitContainer.frame = containerFrame;
        self.detailLabel.frame = detailFrame;
        self.dollarSign.frame = dollarFrame;
        self.sepLine.frame = lineFrame;
    } completion:nil];
}

- (void)didUpdatePrice{
    //Animate here as well - check if there's a valid price - if there is animate onto top and call delegate method
    NSNumber *priceToSubmit = [NSNumber numberWithDouble:(self.priceField.text.doubleValue/100)];
    if ([priceToSubmit doubleValue] > 0.0) {
        if ([self.delegate respondsToSelector:@selector(priceWasUpdated:)]) {
            [self.delegate priceWasUpdated:priceToSubmit];
        }
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        //Delete numbers from last to first
        switch (range.location) {
            case 0:
                self.digitFour.text = nil;
                break;
            case 1:
                self.digitFour.text = self.digitThree.text;
                self.digitThree.text = nil;
                break;
            case 2:
                self.digitFour.text = self.digitThree.text;
                self.digitThree.text = self.digitTwo.text;
                self.digitTwo.text = nil;
                break;
            case 3:
                self.digitFour.text = self.digitThree.text;
                self.digitThree.text = self.digitTwo.text;
                self.digitTwo.text = self.digitOne.text;
                self.digitOne.text = nil;
                break;
            default:
                break;
        }
        return YES;
    } else if (textField.text.length == 4) {
        return NO;
    } else {
        //Since we're dealing with price, the way we input numbers are reversed so it looks better (numbers come in from the right)
        switch (range.location) {
            case 0:
                self.digitFour.text = string;
                break;
            case 1:
                self.digitThree.text = self.digitFour.text;
                self.digitFour.text = string;
                break;
            case 2:
                self.digitTwo.text = self.digitThree.text;
                self.digitThree.text = self.digitFour.text;
                self.digitFour.text = string;
                break;
            case 3:
                self.digitOne.text = self.digitTwo.text;
                self.digitTwo.text = self.digitThree.text;
                self.digitThree.text = self.digitFour.text;
                self.digitFour.text = string;
                break;
            default:
                break;
        }
        
        return YES;
    }
}

- (void)setPrice:(NSNumber *)price{
    NSString *priceStr = [price stringValue];
    priceStr = [priceStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSUInteger start = 4 - priceStr.length;//Must start on appropriate digit if not 4 (e.g. 3 digits, must start filling in from second not first)
    
    for (int i = 0; i < priceStr.length; ++i) {
        NSString *digit = [NSString stringWithFormat:@"%c", [priceStr characterAtIndex:i]];
        if (start == 0) {
            self.digitOne.text = digit;
        }else if (start == 1){
            self.digitTwo.text = digit;
        }else if (start == 2){
            self.digitThree.text = digit;
        }else{
            self.digitFour.text = digit;
        }
        ++start;
    }
    
}

@end
