//
//  MyContactsViewController.m
//  MyContacts
//
//  Created by Charles Konkol on 11/10/13.
//  Copyright (c) 2013 Chuck Konkol. All rights reserved.
//

#import "MyContactsViewController.h"
#import "MyDetailViewController.h"
#import "Delegate.h"
@interface MyContactsViewController ()

@property (strong) NSManagedObject *contactdb;

@end

@implementation MyContactsViewController
@synthesize contactdb;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void)executeParsing{
    @autoreleasepool {
        NSString *file = @(__FILE__);
        file = [[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Top_10_Rides_Content_pictureReplaced.csv"];
        
        NSLog(@"Beginning...");
        NSStringEncoding encoding = 0;
        NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:file];
        CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:','];
        [p setRecognizesBackslashesAsEscapes:YES];
        [p setSanitizesFields:YES];
        
        NSLog(@"encoding: %@", CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding)));
        
        Delegate * d = [[Delegate alloc] init];
        [p setDelegate:d];
        
        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
        [p parse];
        NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
        
        NSLog(@"raw difference: %f", (end-start));
        
        NSLog(@"%@", [d lines]);
        
        NSInteger size = [[d lines ]count];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        
        
        for (NSInteger i = 1; i < size; i++){
            NSArray *temp = [[d lines] objectAtIndex:i];
            NSString *str = [temp objectAtIndex:0];
            if (!self.contactdb){
                NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
                [newDevice setValue:str forKey:@"fullname"];
                [newDevice setValue:@"666" forKey:@"email"];
                [newDevice setValue:@"222" forKey:@"phone"];
            }
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self executeParsing];
    NSLog(@"abc");
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Contacts"];
    self.contactarray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.contactarray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSManagedObject *device = [self.contactarray objectAtIndex:indexPath.row];
    //[cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", [device valueForKey:@"fullname"], [device valueForKey:@"email"]]];
     [cell.detailTextLabel setText:[device valueForKey:@"phone"]];
     [cell.textLabel setText:[NSString stringWithFormat:@"%@", [device valueForKey:@"fullname"]]];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.contactarray objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.contactarray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"UpdateContacts"]) {
        NSManagedObject *selectedDevice = [self.contactarray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        MyDetailViewController *destViewController = segue.destinationViewController;
        destViewController.contactdb = selectedDevice;
    }
}

@end
