//
//  GRNLineItemVC.m
//  mGRN
//
//  Created by Anum on 02/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNLineItemVC.h"
#import "PurchaseOrderItem+Management.h"
#import "GRNItem+Management.h"
#import "CoreDataManager.h"
#import "GRNCompleteGRNVC.h"
#import "GRNWbsTableView.h"

@interface GRNLineItemVC() <UITableViewDelegate>
@property (nonatomic, weak) UIPopoverController *pvc;
@property (readonly) GRNItem *selectedItem;
@end

@implementation GRNLineItemVC
@synthesize grn = _grn, selectedItem, pvc;

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [super viewDidLoad];
    self.itemTableView.purchaseOrder = self.grn.purchaseOrder;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self displaySelectedItem];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setItemTableView:nil];
    [self setItemLabel:nil];
    [self setDescriptionLabel:nil];
    [self setQuantityDelivered:nil];
    [self setQuantityRecieved:nil];
    [self setNote:nil];
    [self setExpected:nil];
    [self setWbsButton:nil];
    [self setSdnTextField:nil];
    [super viewDidUnload];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        [self displaySelectedItem];
    }
    else if ([tableView isKindOfClass:[GRNWbsTableView class]])
    {
        [self.pvc dismissPopoverAnimated:YES];
        WBS *wbs = [((GRNWbsTableView*)tableView).dataArray objectAtIndex:indexPath.row];
        [self.wbsButton setTitle:wbs.code forState:UIControlStateNormal];
    }
}
-(void)displaySelectedItem
{
    PurchaseOrderItem *item = self.itemTableView.selectedObject;
    self.itemLabel.text = item.itemNumber;
    self.descriptionLabel.text = item.itemDescription;
    self.expected.text = [NSString stringWithFormat:@"%@ (%i expected)",item.uoq,[item.quantityBalance intValue]];
}

-(GRNItem*)selectedItem
{
    PurchaseOrderItem *item = self.itemTableView.selectedObject;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grn.lineItems filteredSetUsingPredicate:predicate] anyObject];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.view.frame.origin.y == 0)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -264; //height of keyboard
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.note])
    {
        self.selectedItem.notes = textField.text;
    }
    else if ([textField isEqual:self.quantityDelivered])
    {
        self.selectedItem.quantityDelivered = [NSNumber numberWithInt:[textField.text intValue]];
    }
    else if ([textField isEqual:self.quantityRecieved])
    {
        //TODO: needs to be done
    }
    else if ([textField isEqual:self.sdnTextField])
    {
        //TODO: Check if it is valid
        self.grn.supplierReference = textField.text;
    }
    [[CoreDataManager sharedInstance].managedObjectContext save:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"back"])
    {
        //TODO: remove GRN
        [[CoreDataManager sharedInstance].managedObjectContext deleteObject:self.grn];
        [[CoreDataManager sharedInstance].managedObjectContext save:nil];
    }
    else if ([segue.identifier isEqualToString:@"next"])
    {
        GRNCompleteGRNVC *vc = segue.destinationViewController;
        vc.grn = self.grn;
    }
}

-(void)onKeyboardHide:(NSNotification *)notification
{
    if (self.view.frame.origin.y != 0)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

#pragma mark - IBActions

- (IBAction)wbsCodes:(UIButton*)button
{
    GRNWbsTableView *vc = [[GRNWbsTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 500.0)
                                                  contract:self.grn.purchaseOrder.contract];
    vc.tableView.delegate = self;
    self.pvc = [[UIPopoverController alloc] initWithContentViewController:vc];
    [self.pvc presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1)
                              inView:self.view
            permittedArrowDirections:UIPopoverArrowDirectionAny
                            animated:YES];
}

- (IBAction)Reason:(id)sender
{
    
}

@end
