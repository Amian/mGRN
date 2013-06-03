//
//  GRNOrderDetailsVC.m
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNOrderDetailsVC.h"
#import "GRNContractTableView.h"
#import "GRNPurchaseOrderTableView.h"
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "Contract+Management.h"
#import "CoreDataManager.h"
#import "GRNOrderItemsTableView.h"
#import "GRNLineItemVC.h"
#import "GRNBaseTable.h"
#import "GRN+Management.h"

@interface GRNOrderDetailsVC () <UITableViewDelegate, M1XmGRNDelegate, MyTableDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@property (nonatomic, strong) M1XmGRNService *service;
@end

@implementation GRNOrderDetailsVC
@synthesize service = _service, status = _status, returnedAfterSubmission;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.hidden = YES;
    self.status = Contracts;
    [self.view addSubview:self.loadingView];
    self.loadingView.hidden = YES;
    self.orderDetailView.hidden = YES;
    
    [self.navContract setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.navContract setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [self.navPurchaseOrders setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.navPurchaseOrders setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.navPurchaseOrders setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.navViewOrder setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.navViewOrder setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.navViewOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    self.navContract.selected = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.tablesView.window)
    {
        self.tablesView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.tablesView];
    }
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [self tablecontainerDelegateChangedStatusTo:self.status];
    
    if (returnedAfterSubmission && self.orderItemTableView.dataArray.count == 0)
    {
        [self tablecontainerDelegateChangedStatusTo:PurchaseOrders];
    }
    returnedAfterSubmission = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardWillHideNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContainerView:nil];
    [self setOrderDetailView:nil];
    [self setPurchaseOrderTableView:nil];
    [self setTablesView:nil];
    [self setContractsTableView:nil];
    [self setOrderItemTableView:nil];
    [self setLoadingView:nil];
    [self setNavContract:nil];
    [self setNavPurchaseOrders:nil];
    [self setNavViewOrder:nil];
    [self setSearchTextField:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"new y = %f, new height = %f",[self.view viewWithTag:109].frame.origin.y, self.orderItemTableView.frame.size.height);
    [self tablecontainerDelegateChangedStatusTo:self.status];
}

#pragma mark - Table Container Delegate

-(void)tablecontainerDelegateChangedStatusTo:(TableNavigationStatus)newStatus
{
    self.status = newStatus;
    [self doneSearching:nil];
    switch (newStatus)
    {
        case Contracts:
            
            self.navContract.selected = YES;
            self.navPurchaseOrders.selected = NO;
            self.navViewOrder.selected = NO;
            
            self.navContract.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
            self.navPurchaseOrders.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            self.navViewOrder.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            
            self.navPurchaseOrders.enabled = NO;
            self.navViewOrder.enabled = NO;
            
            self.contractsTableView.hidden = NO;
            self.purchaseOrderTableView.hidden = YES;
            self.orderDetailView.hidden = YES;
            
            self.contractsTableView.state = TableStateNormal;
            [self.contractsTableView doneSearching];
            [self moveContainerToTheRight];
            break;
        case PurchaseOrders:
            
            self.navPurchaseOrders.selected = YES;
            self.navContract.selected = NO;
            self.navViewOrder.selected = NO;
            
            self.navPurchaseOrders.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
            self.navContract.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            self.navViewOrder.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            
            self.navPurchaseOrders.enabled = YES;
            self.navViewOrder.enabled = NO;
            
            self.contractsTableView.hidden = NO;
            self.purchaseOrderTableView.hidden = NO;
            self.orderDetailView.hidden = YES;
            
            [self.purchaseOrderTableView doneSearching];
            [self moveContainerToTheRight];
            break;
        case ViewOrder:
            
            self.navContract.selected = NO;
            self.navPurchaseOrders.selected = NO;
            self.navViewOrder.selected = YES;
            
            self.navViewOrder.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
            self.navContract.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            self.navPurchaseOrders.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            
            self.navPurchaseOrders.enabled = YES;
            self.navViewOrder.enabled = YES;
            
            self.contractsTableView.hidden = NO;
            self.purchaseOrderTableView.hidden = NO;
            self.orderDetailView.hidden = NO;
            
            [self.orderItemTableView doneSearching];
            [self moveContainerToTheLeft];
            break;
        default:
            break;
    }
}

#pragma mark - View methods

-(void)moveContainerToTheLeft
{
    //    if (self.tablesView.frame.origin.x == 0) {
    CGRect newFrame = self.tablesView.frame;
    newFrame.origin.x = -(self.tablesView.frame.size.width - self.view.frame.size.width);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.tablesView.frame = newFrame;
    [UIView commitAnimations];
    //    }
}

-(void)moveContainerToTheRight
{
    if (self.tablesView.frame.origin.x != 0) {
        CGRect newFrame = self.tablesView.frame;
        newFrame.origin.x = 0.0;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.tablesView.frame = newFrame;
        [UIView commitAnimations];
    }
}

#pragma mark - Table View Delegate

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 10.0)];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:GRNLightBlueColour];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    GRNBaseTable *table = (GRNBaseTable*)tableView;
    //if selection is on and the row is now selected reduce alpha
    if (table.state == TableStateSelected && indexPath.section != table.selectedIndex.section)
    {
        cell.alpha = 0.4;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNContractTableView class]])
    {
        self.purchaseOrderTableView.state = TableStateNormal;
        //        self.purchaseOrderTableView.contract = nil; //To clear the table
        self.loadingView.hidden = NO;
        self.purchaseOrderTableView.contract = [self.contractsTableView selectedObject];
        [self.contractsTableView rowSelected];
    }
    else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
        //        self.orderItemTableView.purchaseOrder = nil; //To clear the table
        self.loadingView.hidden = NO;
        self.orderItemTableView.purchaseOrder = [self.purchaseOrderTableView selectedObject];
        [self.purchaseOrderTableView rowSelected];
    }
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
        GRNPurchaseOrderTableView *table = (GRNPurchaseOrderTableView*)tableView;
        if (table.state == TableStateSelected && table.selectedIndex.section == indexPath.section)
        {
            height = 215.0;
        }
        else
        {
            height = 170.0;
        }
    }
    else if ([tableView isKindOfClass:[GRNContractTableView class]])
    {
        height = 110.0;
    }
    return height;
}

#pragma mark - IBActions

- (IBAction)contract:(id)sender
{
    [self tablecontainerDelegateChangedStatusTo:Contracts];
}
- (IBAction)purchaseOrders:(id)sender
{
    [self tablecontainerDelegateChangedStatusTo:PurchaseOrders];
}
- (IBAction)viewDetails:(id)sender
{
    [self tablecontainerDelegateChangedStatusTo:ViewOrder];
}
- (IBAction)reload:(id)sender
{
    [self.contractsTableView getDataFromAPI];
    self.purchaseOrderTableView.hidden = YES;
    self.orderDetailView.hidden = YES;
    [self tablecontainerDelegateChangedStatusTo:Contracts];
}
- (IBAction)search:(id)sender
{
    if (self.searchBar.hidden)
    {
        self.searchBar.hidden = NO;
        [self.searchTextField becomeFirstResponder];
    }
    else
    {
        self.searchTextField.text = @"";
        self.searchBar.hidden = YES;
        [self.searchTextField resignFirstResponder];
    }
}

- (IBAction)logout:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                    message:@"Are you sure you want to log out?"
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES",nil];
    [alert show];
    
}

- (IBAction)doneSearching:(id)sender
{
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
    self.searchBar.hidden = YES;
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        //[CoreDataManager clearAllDataOnLogout];//TODO:Uncomment
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createGRN"])
    {
        GRN *grn = [GRN grnForPurchaseOrder:self.orderItemTableView.purchaseOrder
                     inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext
                                      error:nil];
        GRNLineItemVC *vc = segue.destinationViewController;
        vc.grn = grn;
        
    }
}

#pragma mark - MyTableDelegate

-(void)tableDidEndLoadingData:(UITableView *)tableView
{
    if ([tableView isKindOfClass:[GRNContractTableView class]])
    {
        [self tablecontainerDelegateChangedStatusTo:Contracts];
    }
    else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
        [self tablecontainerDelegateChangedStatusTo:PurchaseOrders];
    }
    else if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        [self tablecontainerDelegateChangedStatusTo:ViewOrder];
    }
    self.loadingView.hidden = YES;
    [tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)tableWillGetDataFromAPI
{
    self.loadingView.hidden = NO;
}

#pragma mark - Keyboard Notifications

//-(void)onKeyboardHide:(NSNotification *)notification
//{
////    if (self.searchBar.frame.origin.y != 0)
////    {
//        CGRect frame = self.searchBar.frame;
//        frame.origin.y = self.view.frame.size.height - self.searchBar.frame.size.height;
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.3];
//        self.searchBar.frame = frame;
//        [UIView commitAnimations];
////    }
//}

-(void)onKeyboardShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    CGRect frame = self.searchBar.frame;
    frame.origin.y = self.view.bounds.size.height - self.searchBar.frame.size.height - ( UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])? 352.0 : 264.0);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.searchBar.frame = frame;
    [UIView commitAnimations];
}


#pragma  mark - Text Field Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (self.status)
    {
        case Contracts:
            [self.contractsTableView searchForString:newString];
            break;
        case PurchaseOrders:
            [self.purchaseOrderTableView searchForString:newString];
            break;
        case ViewOrder:
            [self.orderItemTableView searchForString:newString];
            break;
        default:
            break;
    }
    return YES;
}

-(void)failedToGetData
{
    self.loadingView.hidden = YES;
    [self tablecontainerDelegateChangedStatusTo:self.status];
}

@end
