//
//  MyDetailViewController.h
//  MyContacts
//
//  Created by Charles Konkol on 11/10/13.
//  Copyright (c) 2013 Chuck Konkol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *fullname;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *phone;
- (IBAction)btnSave:(id)sender;
- (IBAction)btnBack:(id)sender;
@property (strong) NSManagedObject *contactdb;
@end
