//
//  SettingsViewController.m
//  Reposit
//
//  Created by Morgan Chen on 1/2/15.
//  Copyright (c) 2015 Morgan Chen. All rights reserved.
//

#import "SettingsViewController.h"
#import "GitHubHelper.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@end

@implementation SettingsViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userNameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *currentUser = [GitHubHelper sharedHelper].currentUser;
    if (currentUser) {
        self.userNameTextField.text = currentUser;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Interface Builder Outlets

- (IBAction)saveButtonPressed:(id)sender {
    NSString *userNameTrimmed = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL userNameIsValid = ([userNameTrimmed rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location == NSNotFound);
    
    // save current user if field is valid (does not contain whitespace)
    if (userNameIsValid) {
        [GitHubHelper sharedHelper].currentUser = userNameTrimmed;
    }
    
    // transition back to main view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    // transition back to main view controller
    [self.navigationController popViewControllerAnimated:YES];
}

@end
