//
//  GRNTableContainerVCViewController.m
//  mGRN
//
//  Created by Anum on 28/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNTableContainerVCViewController.h"
#import "GRNContractTableView.h"
#import "GRNOrderItemsTableView.h"


#define self_parentViewController (([self parentViewController] != nil || ![self respondsToSelector:@selector(presentingViewController)]) ? [self parentViewController] : [self presentingViewController])

@interface GRNTableContainerVCViewController ()

@end

@implementation GRNTableContainerVCViewController
@synthesize delegate;

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
    [self.delegate tablecontainerDelegateChangedStatusTo:Contracts];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)displayPurchaseOrders:(int)OrderID
{
    //Ensure purchase order table is visible
    if (self.purchaseOrderTableView.alpha == 0.0 || self.purchaseOrderTableView.hidden)
    {
        self.purchaseOrderTableView.alpha = 0.0;
        self.purchaseOrderTableView.hidden = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.purchaseOrderTableView.alpha = 1.0;
        [UIView commitAnimations];
    }
}

-(void)displayOrderDetails:(int)OrderID
{
    if (self.orderDetailView.alpha == 0.0 || self.orderDetailView.hidden)
    {
        self.orderDetailView.alpha = 0.0;
        self.orderDetailView.hidden = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.orderDetailView.alpha = 1.0;
        [UIView commitAnimations];
    }
}

#pragma mark - IBActions

- (IBAction)createGRNButtonPressed:(id)sender
{
    self.createGrnView.frame = self.view.superview.bounds;
    [self.view.superview addSubview:self.createGrnView];
}


#pragma mark - Table View Delegate

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 10.0)];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:GRNLightBlueColour];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNContractTableView class]])
    {
        //TODO: Send correct Order ID
        [self displayPurchaseOrders:0];
        [[self delegate] tablecontainerDelegateChangedStatusTo:PurchaseOrders];
    }
    else if ([tableView isKindOfClass:[GRNPurchaseOrderTableView class]])
    {
        [self displayOrderDetails:0];
        [self.delegate tablecontainerDelegateChangedStatusTo:ViewOrder];
    }
    NSLog(@"%@",NSStringFromClass([self.delegate class]));
}



- (void)viewDidUnload {
    [self setPurchaseOrderTableView:nil];
    [self setOrderDetailView:nil];
    [self setCreateGrnView:nil];
    [super viewDidUnload];
}
@end
