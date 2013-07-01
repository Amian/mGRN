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
#import "PurchaseOrder.h"
#import "NSObject+Blocks.h"
#import "GRNAppDelegate.h"

@interface GRNOrderDetailsVC () <UITableViewDelegate, M1XmGRNDelegate, MyTableDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) M1XmGRNService *service;
@property (readonly) BOOL sessionExpired;
@property BOOL reloading;
@property (nonatomic, strong) NSString *selectedContractNumber;
@property (nonatomic, strong) NSString *selectedPurchaseOrderName;
@end

@implementation GRNOrderDetailsVC
@synthesize service = _service, status = _status, returnedAfterSubmission, sessionExpired = _sessionExpired;

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self checkOrientation];
}

-(void)checkOrientation
{
    CGRect frame = self.containerView.frame;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        frame.size.width = 1300.0;
    }
    else
    {
        frame.size.width = 1125.0;
    }
    self.containerView.frame = frame;
    [self refreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchView.hidden = YES;
    self.status = Contracts;
    [self.view addSubview:self.loadingView];
    
    self.purchaseOrderTableView.hidden = YES;
    self.orderDetailView.hidden = YES;
    
    [self.navContract setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.navContract setTitleColor:GRNLightBlueColour forState:UIControlStateNormal];
    
    [self.navPurchaseOrders setTitleColor:GRNLightBlueColour forState:UIControlStateNormal];
    [self.navPurchaseOrders setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.navPurchaseOrders setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.navViewOrder setTitleColor:GRNLightBlueColour forState:UIControlStateNormal];
    [self.navViewOrder setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.navViewOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    self.navContract.selected = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionHasExpired) name:SessionExpiryNotification object:nil];
    
}

-(void)sessionHasExpired
{
    _sessionExpired = YES;
    self.contractsTableView.sessionExpired = YES;
    self.purchaseOrderTableView.sessionExpired = YES;
    self.orderItemTableView.sessionExpired = YES;
}

-(BOOL)sessionExpired
{
    if (_sessionExpired)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Expired"
                                                        message:SessionExpiryText
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return _sessionExpired;
}

-(void)viewWillAppear:(BOOL)animated
{
    [(GRNAppDelegate*)[UIApplication sharedApplication].delegate setCreatingGRN:NO];
    
    
    [super viewWillAppear:animated];
    if (!self.tablesView.superview)
    {
        self.tablesView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.tablesView];
        self.loadingView.frame = self.view.bounds;
        self.loadingView.hidden = NO;
        [self.view addSubview:self.loadingView];
    }
    else
    {
        self.loadingView.hidden = YES;
    }
    [self checkOrientation];
    [self tablecontainerDelegateChangedStatusTo:self.status];
    if (returnedAfterSubmission && self.orderItemTableView.dataArray.count == 0)
    {
        self.status = PurchaseOrders;
    }
    [self tablecontainerDelegateChangedStatusTo:self.status];
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
    [self setInfoLabel:nil];
    [self setInfoView:nil];
    [self setSearchView:nil];
    [super viewDidUnload];
}

#pragma mark - Table Container Delegate

-(void)refreshView
{
    switch (self.status)
    {
        case Contracts:
            [self moveContainerToTheRight];
            self.purchaseOrderTableView.hidden = YES;
            self.orderDetailView.hidden = YES;
            break;
        case PurchaseOrders:
            [self moveContainerToTheRight];
            self.purchaseOrderTableView.hidden = NO;
            self.orderDetailView.hidden = YES;
            self.purchaseOrderTableView.errorLabel.hidden = self.purchaseOrderTableView.dataArray.count == 0? NO : YES;
            break;
        case ViewOrder:
            [self moveContainerToTheLeft];
            break;
        default:
            break;
    }
}

-(void)tablecontainerDelegateChangedStatusTo:(TableNavigationStatus)newStatus
{
    self.status = newStatus;
    [self.searchTextField resignFirstResponder];
    //[self doneSearching:nil];
    switch (newStatus)
    {
        case Contracts:
            
            self.navContract.selected = YES;
            self.navPurchaseOrders.selected = NO;
            self.navViewOrder.selected = NO;
            
            self.navContract.titleLabel.font = [UIFont systemFontOfSize:22.0];
            self.navPurchaseOrders.titleLabel.font = [UIFont systemFontOfSize:19.0];
            self.navViewOrder.titleLabel.font = [UIFont systemFontOfSize:19.0];
            
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
            
            self.navPurchaseOrders.titleLabel.font = [UIFont systemFontOfSize:22.0];
            self.navContract.titleLabel.font = [UIFont systemFontOfSize:19.0];
            self.navViewOrder.titleLabel.font = [UIFont systemFontOfSize:19.0];
            
            self.navPurchaseOrders.enabled = YES;
            self.navViewOrder.enabled = NO;
            
            self.contractsTableView.hidden = NO;
            self.purchaseOrderTableView.hidden = NO;
            self.orderDetailView.hidden = YES;
            
            [self.purchaseOrderTableView doneSearching];
            [self moveContainerToTheRight];
            
            self.purchaseOrderTableView.errorLabel.hidden = self.purchaseOrderTableView.dataArray.count == 0? NO : YES;
            
            break;
            
        case ViewOrder:
            
            self.navContract.selected = NO;
            self.navPurchaseOrders.selected = NO;
            self.navViewOrder.selected = YES;
            
            self.navViewOrder.titleLabel.font = [UIFont systemFontOfSize:22.0];
            self.navContract.titleLabel.font = [UIFont systemFontOfSize:19.0];
            self.navPurchaseOrders.titleLabel.font = [UIFont systemFontOfSize:19.0];
            
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
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]]) return;
    [cell setBackgroundColor:GRNLightBlueColour];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    GRNBaseTable *table = (GRNBaseTable*)tableView;
    //if selection is on and the row is now selected reduce alpha
    NSLog(@"state = %i, %i, %i",table.state, indexPath.section, table.selectedIndex.section);
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
        [self.contractsTableView rowSelected];
        self.purchaseOrderTableView.contract = [self.contractsTableView selectedObject];
    }
    else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
        //        self.orderItemTableView.purchaseOrder = nil; //To clear the table
        self.loadingView.hidden = NO;
        [self.purchaseOrderTableView rowSelected];
        self.orderItemTableView.purchaseOrder = [self.purchaseOrderTableView selectedObject];
    }
    else if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        [self performSegueWithIdentifier:@"createGRN" sender:self];
    }
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]]) return 44.0;
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
    if (self.sessionExpired) return;
    self.reloading = YES;
    if (self.contractsTableView.state == TableStateSelected)
    {
    self.selectedContractNumber = ((Contract*)[self.contractsTableView selectedObject]).number;
    }
    if (self.purchaseOrderTableView.state == TableStateSelected)
    {
        self.selectedPurchaseOrderName = ((PurchaseOrder*)[self.purchaseOrderTableView selectedObject]).orderNumber;
    }
    [self.contractsTableView getDataFromAPI];
    self.purchaseOrderTableView.hidden = YES;
    self.orderDetailView.hidden = YES;
    [self tablecontainerDelegateChangedStatusTo:Contracts];
}
- (IBAction)search:(id)sender
{
    if (self.searchView.hidden)
    {
        self.searchView.hidden = NO;
        [self.searchTextField becomeFirstResponder];
    }
    else
    {
        self.reloading = YES;
        if (self.contractsTableView.state == TableStateSelected)
        {
            self.selectedContractNumber = ((Contract*)[self.contractsTableView selectedObject]).number;
        }
        if (self.purchaseOrderTableView.state == TableStateSelected)
        {
            self.selectedPurchaseOrderName = ((PurchaseOrder*)[self.purchaseOrderTableView selectedObject]).orderNumber;
        }

        
        [self.contractsTableView searchForString:nil];
        [self.purchaseOrderTableView searchForString:nil];
        [self.orderItemTableView searchForString:nil];
        
        [self tableDidEndLoadingData:self.contractsTableView];
        [self tableDidEndLoadingData:self.purchaseOrderTableView];
        
        self.searchTextField.text = @"";
        [self.searchTextField resignFirstResponder];
        self.searchView.hidden = YES;
    }
}

- (IBAction)logout:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to log out?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES",nil];
    [alert show];
    
}
- (IBAction)showInfo:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *info = [NSString stringWithFormat:@"Username: %@\nMaster Host: %@\nDomain: %@\nVersion: %@",
                      [defaults objectForKey:KeyUserID],[defaults objectForKey:KeySystemURI],[defaults objectForKey:KeyDomainName],[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
    self.infoLabel.text = info;
    self.infoView.frame = self.view.bounds;
    [self.view addSubview:self.infoView];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
    //                                                        message:info
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"OK"
    //                                              otherButtonTitles:nil];
    //    [alert show];
}
- (IBAction)removeInfoView:(UIButton*)sender
{
    [self.infoView removeFromSuperview];
}

- (IBAction)doneSearching:(id)sender
{   
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [CoreDataManager removeData:NO];
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createGRN"])
    {
        
        GRN *grn = [GRN grnForPurchaseOrder:self.orderItemTableView.purchaseOrder
                     inManagedObjectContext:[CoreDataManager moc]
                                      error:nil];
        GRNLineItemVC *vc = segue.destinationViewController;
        vc.grn = grn;
        vc.selectedIndexPath = self.orderItemTableView.indexPathForSelectedRow;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"createGRN"])
    {
        if (self.sessionExpired) return NO;
    }
    return YES;
}

#pragma mark - MyTableDelegate

-(void)tableDidEndLoadingData:(UITableView *)tableView
{
    //TODO:
    if (self.reloading)
    {
        if ([tableView isKindOfClass:[GRNContractTableView class]])
        {
            if (!self.selectedContractNumber.length){
                [self tablecontainerDelegateChangedStatusTo:Contracts];
                self.reloading = NO;
                self.loadingView.hidden = YES;
                return;
            }
            
            self.purchaseOrderTableView.state = TableStateNormal;
            self.loadingView.hidden = NO;
            [self.contractsTableView selectContractWithNumber:self.selectedContractNumber];
            [self.contractsTableView rowSelected];
            [self performBlock:^{
                [self.contractsTableView scrollToRowAtIndexPath:self.contractsTableView.selectedIndex
                                               atScrollPosition:UITableViewScrollPositionMiddle
                                                       animated:NO];
            } afterDelay:0.1];
            
            self.selectedContractNumber = nil;
            self.purchaseOrderTableView.contract = [self.contractsTableView selectedObject];
            //TODO: REmove
            //self.reloading = NO;
        }
        else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
        {
            if (!self.selectedPurchaseOrderName.length){
                [self tablecontainerDelegateChangedStatusTo:PurchaseOrders];
                self.reloading = NO;
                self.loadingView.hidden = YES;
                return;
            }
            else
            {
                [self.purchaseOrderTableView selectPOWithNumber:self.selectedPurchaseOrderName];
                [self.purchaseOrderTableView rowSelected];
                [self performBlock:^{
                [self.purchaseOrderTableView scrollToRowAtIndexPath:self.purchaseOrderTableView.selectedIndex
                                               atScrollPosition:UITableViewScrollPositionMiddle
                                                       animated:NO];
                } afterDelay:0.1];
                self.selectedPurchaseOrderName = nil;
                self.reloading = NO;
                self.orderItemTableView.purchaseOrder = [self.purchaseOrderTableView selectedObject];
            }
        }
    }
    else
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
    }
    [tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)dataReloaded
{
    
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

-(void)failedToGetData:(UITableView *)tableView
{
    self.reloading = NO;
    if ([tableView isKindOfClass:[GRNContractTableView class]])
    {
        [self moveContainerToTheRight];
        self.purchaseOrderTableView.hidden = YES;
        self.orderDetailView.hidden = YES;
    }
    else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
        self.status = PurchaseOrders;
        [self moveContainerToTheRight];
        self.purchaseOrderTableView.errorLabel.hidden = NO;
        self.orderDetailView.hidden = YES;
        [self.purchaseOrderTableView reloadData];
    }
    else if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        self.status = PurchaseOrders;
        [self moveContainerToTheRight];
        self.orderDetailView.hidden = YES;
    }
    self.loadingView.hidden = YES;
}
@end
