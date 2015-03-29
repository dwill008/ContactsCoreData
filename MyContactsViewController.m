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
        //NSString *file = @(__FILE__);
        //file = [[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Top_10_Rides_Content_pictureReplaced.csv"];
        //NSString *file;
        //file = @"https://drive.google.com/file/d/0BzxR2Xc3LZ7MRl9CSkJrUm5iLVU/view?usp=sharing";
        
        NSString *url = @"https://www.filepicker.io/api/file/w5eur5N6QmuK8znclVWf";
        NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSString *file = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] ;
        //NSString *robots = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://www.filepicker.io/api/file/w5eur5N6QmuK8znclVWf"] encoding:NSUTF8StringEncoding error:nil];
        //NSString *file = @"/var/mobile/Containers/Bundle/Application/31AB2441-9139-43B2-9722-C08C037EF052/MyContacts.app/Top_10_Rides_Content_pictureReplaced.csv";
        //NSString *file = @"https://www.filepicker.io/api/file/w5eur5N6QmuK8znclVWf";
        
        
        NSLog(@"Beginning...");
        NSStringEncoding encoding = 0;
        //NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:file];
        CHCSVParser * p = [[CHCSVParser alloc] initWithCSVString:file];
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
            NSString *imgURL = [temp objectAtIndex:10];
            NSNumber *number = [NSNumber numberWithInt:i];
            if (!self.contactdb){
                NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
                [newDevice setValue:number forKey:@"id"];
                [newDevice setValue:str forKey:@"fullname"];
                [newDevice setValue:@"666" forKey:@"email"];
                [newDevice setValue:@"222" forKey:@"phone"];
                [newDevice setValue:imgURL forKey:@"imgURL"];
            }else{
                [self.contactdb setValue:number forKey:@"id"];
                [self.contactdb setValue:str forKey:@"fullname"];
                [self.contactdb setValue:imgURL forKey:@"imgURL"];
            }
        }
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self dataCount] == 0){
        [self executeParsing];
        [self dataCount];
    }
    
    [self.tableView reloadData];
    NSLog(@"abc");
    
}
/*- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Contacts"];
    self.contactarray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}*/

- (NSInteger)dataCount{
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Contacts"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.contactarray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    return self.contactarray.count;
}

- (void)requestData{
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Contacts"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

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
    tableView.rowHeight = 250;
    // Configure the cell...
    NSManagedObject *device = [self.contactarray objectAtIndex:indexPath.row];
    //[cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", [device valueForKey:@"fullname"], [device valueForKey:@"email"]]];
     [cell.detailTextLabel setText:[device valueForKey:@"phone"]];
     [cell.textLabel setText:[NSString stringWithFormat:@"%@", [device valueForKey:@"fullname"]]];
    //UIImage *bgImage = [UIImage imageNamed:@"IDMXMmPB.jpeg"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IDMXMmPB" ofType:@"jpeg"];
    UIImage *bgImage =[[UIImage alloc] initWithContentsOfFile:path];
    NSString *url = [NSString stringWithFormat:@"%@", [device valueForKey:@"imgURL"]];
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
    //cell.backgroundView = [[UIImageView alloc] initWithImage: bgImage];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
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
        self.tableView.separatorColor=[UIColor clearColor];
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
