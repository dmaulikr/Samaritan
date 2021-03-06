//
//  AllCommandsTableViewController.m
//  Samaritan
//
//  Created by YASH on 06/12/15.
//  Copyright © 2015 Dark Army. All rights reserved.
//

#import "AllCommandsTableViewController.h"
#import "AddCommandTableViewController.h"
#import "SamaritanData.h"
#import "Themes.h"
#import "AppDelegate.h"

@interface AllCommandsTableViewController ()
{
    NSMutableArray *commandsArray;
    
    NSFetchRequest *fetchRequest;
    NSManagedObjectContext *managedObjectContext;
    
    Themes *currentTheme;
}

@end

@implementation AllCommandsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SamaritanData"];
    NSError *error = nil;
    
    managedObjectContext = [AppDelegate managedObjectContext];
    
    NSArray *fetchedArray = [[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    commandsArray = [fetchedArray mutableCopy];
    [self.tableView reloadData];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SamaritanData"];
    NSError *error = nil;
    
    managedObjectContext = [AppDelegate managedObjectContext];
    
    NSArray *fetchedArray = [[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    commandsArray = [fetchedArray mutableCopy];
    [self.tableView reloadData];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentTheme = [AppDelegate currentTheme];
    [self setTheme:currentTheme];
	[self.tableView reloadData];
}

-(void)setTheme:(Themes *)theme
{
    self.view.backgroundColor = theme.backgroundColor;
    self.tableView.separatorColor = theme.foregroundColor;
	[[[UIApplication sharedApplication] keyWindow] setTintColor:theme.foregroundColor];
	[[[UIApplication sharedApplication] keyWindow] setBackgroundColor:theme.backgroundColor];
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: theme.foregroundColor, NSFontAttributeName: [UIFont fontWithName:theme.fontName size:18.f]} forState:UIControlStateNormal];
	self.navigationController.navigationBar.barTintColor = theme.backgroundColor;
	self.navigationController.navigationBar.backgroundColor = theme.backgroundColor;
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: theme.foregroundColor, NSFontAttributeName: [UIFont fontWithName:theme.fontName size:18.f]};
	[[UINavigationBar appearance] setBackgroundColor:theme.backgroundColor];
	[[UINavigationBar appearance] setBarTintColor:theme.backgroundColor];
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: theme.foregroundColor, NSFontAttributeName: [UIFont fontWithName:theme.fontName size:18.f]}];
}

- (void)didReceiveMemoryWarning {
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
    
    return [commandsArray count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    SamaritanData *presentData = [commandsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = presentData.displayString;
    cell.detailTextLabel.text = presentData.tags;
    cell.textLabel.font = [UIFont fontWithName:currentTheme.fontName size:18.f];
    cell.detailTextLabel.font = [UIFont fontWithName:currentTheme.fontName size:14.f];
	cell.detailTextLabel.alpha = 0.5;
    cell.backgroundColor = currentTheme.backgroundColor;
    cell.textLabel.textColor = currentTheme.foregroundColor;
    cell.detailTextLabel.textColor = currentTheme.foregroundColor;
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tableView.isEditing)
    {
        
    }
    else
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 60.f;
    
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectZero];
    return blankView;
    
}
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleDone target:self action:@selector(deleteAction:)];
        self.navigationItem.leftBarButtonItem = deleteButton;
        
    }
    
    return YES;
}
*/
- (void) deleteAction:(id)sender
{
    
    NSMutableArray *alteredCommandsArray = [NSMutableArray arrayWithArray:commandsArray];
    NSArray *selectedToBeDeleted = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedToBeDeleted)
    {
        
        SamaritanData *commandToBeDeleted = [commandsArray objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:commandToBeDeleted];
        [alteredCommandsArray removeObject:commandToBeDeleted];
        
    }
    
    commandsArray = [NSMutableArray arrayWithArray:alteredCommandsArray];
    [self.tableView deleteRowsAtIndexPaths:selectedToBeDeleted withRowAnimation:UITableViewRowAnimationMiddle];
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Can't delete: %@, %@", error, [error localizedDescription]);
        return;
    }
    self.editing = NO;
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
    
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        [managedObjectContext deleteObject:[commandsArray objectAtIndex:indexPath.row]];
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Can't delete: %@, %@", error, [[commandsArray objectAtIndex:indexPath.row] localizedDescription]);
            return;
        }
        
        [commandsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (IBAction)cancelAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"CommandEditorSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		AddCommandTableViewController *actvc = [segue destinationViewController];
		actvc.passedData = [commandsArray objectAtIndex:indexPath.row];
	}
}


@end
