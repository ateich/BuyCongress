//
//  TableViewController.m
//  MyCongress
//
//  Created by HackReactor on 1/5/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "TableViewController.h"
#import "Politician.h"
#import "PoliticianDetailViewController.h"

@interface TableViewController (){
    PoliticianDetailViewController *detailViewController;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //TEST DATA
    self.politicians = [[NSMutableArray alloc] init];
//    [self.politicians addObject:@"TEST"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.politicians.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        Politician *thisPolitician = (Politician*)[self.politicians objectAtIndex:indexPath.row];
        int pictureWidth = 75;
        
        //Politician's Title and Name
        UILabel *name = [[UILabel alloc] init];
        [name setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell addSubview:name];
        
        name.text = [NSString stringWithFormat:@"%@. %@ %@", thisPolitician.title, thisPolitician.firstName, thisPolitician.lastName];
        
        //LEFT
        NSLayoutConstraint *nameLeftConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:pictureWidth];
        
        //RIGHT
        NSLayoutConstraint *nameRightConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        //TOP
        NSLayoutConstraint *nameTopConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        
        //HEIGHT
        NSLayoutConstraint *nameHeightConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:cell.frame.size.height/2];
        
        [cell addConstraint:nameLeftConstraint];
        [cell addConstraint:nameRightConstraint];
        [cell addConstraint:nameTopConstraint];
        [cell addConstraint:nameHeightConstraint];
        
        
        //Politician's Party and State
        UILabel *state = [[UILabel alloc] init];
        [state setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell addSubview:state];
        
        state.text = [NSString stringWithFormat:@"%@ - %@", thisPolitician.party, thisPolitician.state];
        
        //LEFT
        NSLayoutConstraint *stateLeftConstraint = [NSLayoutConstraint constraintWithItem:state attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:pictureWidth];
        
        //RIGHT
        NSLayoutConstraint *stateRightConstraint = [NSLayoutConstraint constraintWithItem:state attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        //TOP
        NSLayoutConstraint *stateTopConstraint = [NSLayoutConstraint constraintWithItem:state attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:name attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        
        //HEIGHT
        NSLayoutConstraint *stateHeightConstraint = [NSLayoutConstraint constraintWithItem:state attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:cell.frame.size.height/2];
        
        [cell addConstraint:stateLeftConstraint];
        [cell addConstraint:stateRightConstraint];
        [cell addConstraint:stateTopConstraint];
        [cell addConstraint:stateHeightConstraint];
        
    }
    
    return cell;
}

/* Show more details about the selected politician */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    detailViewController = [[PoliticianDetailViewController alloc] init];
    [detailViewController setPolitician:[self.politicians objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:detailViewController animated:YES];
}

-(void)updateTableViewWithNewData:(NSMutableArray *)data{
    self.politicians = data;
    [self.tableView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
