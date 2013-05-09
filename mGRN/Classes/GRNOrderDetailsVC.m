//
//  GRNOrderDetailsVC.m
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNOrderDetailsVC.h"
#import "Enums.h"
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

@interface GRNOrderDetailsVC () <UITableViewDelegate, M1XmGRNDelegate, MyTableDelegate>
{
}
@property (nonatomic, strong) M1XmGRNService *service;
@end

@implementation GRNOrderDetailsVC
@synthesize service = _service;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.loadingView];
    self.loadingView.hidden = YES;

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
    [self setCreateGrnView:nil];
    [self setTablesView:nil];
    [self setSdnTextField:nil];
    [self setContractsTableView:nil];
    [self setOrderItemTableView:nil];
    [self setLoadingView:nil];
    [self setNavContract:nil];
    [self setNavPurchaseOrders:nil];
    [self setNavViewOrder:nil];
    [super viewDidUnload];
}

#pragma mark - Table Container Delegate

-(void)tablecontainerDelegateChangedStatusTo:(TableNavigationStatus)newStatus
{
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
            [self.contractsTableView reloadData];
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
            
            self.purchaseOrderTableView.state = TableStateNormal;
            [self.purchaseOrderTableView reloadData];
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

            [self moveContainerToTheLeft];
            break;
        default:
            break;
    }
}

#pragma mark - View methods

-(void)moveContainerToTheLeft
{
    if (self.tablesView.frame.origin.x == 0) {
        CGRect newFrame = self.tablesView.frame;
        newFrame.origin.x -= (self.tablesView.frame.size.width - self.view.frame.size.width);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.tablesView.frame = newFrame;
        [UIView commitAnimations];
    }
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

//-(void)displayPurchaseOrders:(int)OrderID
//{
//    //Ensure purchase order table is visible
//    if (self.purchaseOrderTableView.alpha == 0.0 || self.purchaseOrderTableView.hidden)
//    {
//        self.purchaseOrderTableView.alpha = 0.0;
//        self.purchaseOrderTableView.hidden = NO;
//        
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        self.purchaseOrderTableView.alpha = 1.0;
//        [UIView commitAnimations];
//    }
//}
//
//-(void)displayOrderDetails:(int)OrderID
//{
//    if (self.orderDetailView.alpha == 0.0 || self.orderDetailView.hidden)
//    {
//        self.orderDetailView.alpha = 0.0;
//        self.orderDetailView.hidden = NO;
//        
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        self.orderDetailView.alpha = 1.0;
//        [UIView commitAnimations];
//    }
//}

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
        self.purchaseOrderTableView.contract = nil;
        self.loadingView.hidden = NO;
        self.purchaseOrderTableView.contract = [self.contractsTableView selectedObject];
        [self.contractsTableView rowSelected];
    }
    else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
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
            height = table.frame.size.height/5.8;
        }
        else
        {
            height = table.frame.size.height/6.4;
        }
    }
    else if ([tableView isKindOfClass:[GRNContractTableView class]])
    {
        height = tableView.frame.size.height/8;
    }
    return height;
}

#pragma mark - IBActions

- (IBAction)createGRNButtonPressed:(id)sender
{
    //TODO:Do this
    self.createGrnView.frame = self.view.bounds;
    [self.view addSubview:self.createGrnView];
}

- (IBAction)closeCreateGrnView:(id)sender
{
    [self.createGrnView removeFromSuperview];
}

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

#pragma mark - Get Contracts

-(void)reloadContracts
{
    //TODO:Do this
//    self.purchaseOrderTableView.contract = nil;
//    self.orderItemTableView.purchaseOrder = nil;
    [self.contractsTableView getDataFromAPI];
    self.purchaseOrderTableView.alpha = 0.0;
    self.orderDetailView.alpha = 0.0;
    [self tablecontainerDelegateChangedStatusTo:Contracts];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createGRN"])
    {
        GRN *grn = [GRN grnWithSDNRef:self.sdnTextField.text
                     forPurchaseOrder:self.orderItemTableView.purchaseOrder
               inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext
                                error:nil];
            GRNLineItemVC *vc = segue.destinationViewController;
            vc.grn = grn;

    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //TODO:Display error
    if ([identifier isEqualToString:@"createGRN"] && !self.sdnTextField.text.length)
    {
        //TODO: trim text
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter a supplier Delivery Number"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    else if ([identifier isEqualToString:@"createGRN"] &&
        [GRN grnExistsWithSDNRef:self.sdnTextField.text
          inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext])
    {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"SDN already used."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
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
}

-(void)tableWillGetDataFromAPI
{
    self.loadingView.hidden = NO;
}




@end
