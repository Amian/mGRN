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
#import "GRNReasonTableVC.h"

@interface GRNLineItemVC() <UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) UIPopoverController *pvc;
@property (readonly) GRNItem *selectedItem;
@end

@implementation GRNLineItemVC
@synthesize grn = _grn, selectedItem, pvc;
static float KeyboardHeight;

-(void)viewDidLoad
{
    self.grnDict = [NSDictionary dictionary];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [super viewDidLoad];
    self.itemTableView.purchaseOrder = self.grn.purchaseOrder;
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"dict in lvc = %@",self.grnDict);
    [self displaySelectedItem];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setItemTableView:nil];
    [self setItemLabel:nil];
    [self setDescriptionLabel:nil];
    [self setQuantityDelivered:nil];
    [self setQuantityRejected:nil];
    [self setNote:nil];
    [self setExpected:nil];
    [self setWbsButton:nil];
    [self setSdnTextField:nil];
    [self setResonView:nil];
    [self setWbsView:nil];
    [self setReasonButton:nil];
    [self setWbsButton:nil];
    [self setWbsTable:nil];
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
        [self.wbsView removeFromSuperview];
        WBS *wbs = [((GRNWbsTableView*)tableView).dataArray objectAtIndex:indexPath.row];
        [self.wbsButton setTitle:wbs.codeDescription forState:UIControlStateNormal];
        self.selectedItem.wbsCode = wbs.code;
    }
    else if ([tableView isKindOfClass:[GRNReasonTableVC class]])
    {
        GRNReasonTableVC *rtv = (GRNReasonTableVC*)tableView;
        [self.resonView removeFromSuperview];
        [self.reasonButton setTitle:[rtv selectedReason] forState:UIControlStateNormal];
        self.selectedItem.exception = [rtv selectedCode]; //TODO: Confirm this is the right place to put it
    }
}

-(void)displaySelectedItem
{
    PurchaseOrderItem *item = self.itemTableView.selectedObject;
    self.itemLabel.text = item.itemNumber;
    self.descriptionLabel.text = item.itemDescription;
    self.expected.text = [NSString stringWithFormat:@"%@ (%i expected)",item.uoq,[item.quantityBalance intValue]];
    [self.reasonButton setTitle:[GRNReasonTableVC ReasonForCode:self.selectedItem.exception] forState:UIControlStateNormal];
    WBS *wbs = [WBS fetchWBSWithCode:self.selectedItem.wbsCode inMOC:[CoreDataManager sharedInstance].managedObjectContext];
    NSLog(@"%@,%@",self.selectedItem.wbsCode, wbs.codeDescription);
    [self.wbsButton setTitle:wbs.codeDescription.length? wbs.codeDescription : @"Select WBS Code" forState:UIControlStateNormal];
    self.quantityDelivered.text = [NSString stringWithFormat:@"%i",[self.selectedItem.quantityDelivered intValue] ];
    self.quantityRejected.text = [NSString stringWithFormat:@"%i",[self.selectedItem.quantityRejected intValue]];
    self.note.text = self.selectedItem.notes;
}

-(GRNItem*)selectedItem
{
    PurchaseOrderItem *item = self.itemTableView.selectedObject;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grn.lineItems filteredSetUsingPredicate:predicate] anyObject];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.view.frame.origin.y == 0 && ![textField isEqual:self.sdnTextField])
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -KeyboardHeight; //height of keyboard
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.note])
    {
        self.selectedItem.notes = newString;
    }
    else if ([textField isEqual:self.quantityDelivered])
    {
        self.selectedItem.quantityDelivered = [NSNumber numberWithInt:[newString intValue]];
    }
    else if ([textField isEqual:self.quantityRejected])
    {
        self.selectedItem.quantityRejected = [NSNumber numberWithInt:[newString intValue]];
    }
    else if ([textField isEqual:self.sdnTextField])
    {
        //TODO: Check if it is valid
        self.grn.supplierReference = newString;
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"next"])
    {
        [[CoreDataManager sharedInstance].managedObjectContext save:nil];
        GRNCompleteGRNVC *vc = segue.destinationViewController;
        vc.grn = self.grn;
        vc.grnDict = self.grnDict;
    }
}

#pragma mark - Keyboard Notifications

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

-(void)onKeyboardShow:(NSNotification *)notification
{
    KeyboardHeight = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height; //height of keyboard
}

#pragma mark - IBActions

- (IBAction)wbsCodes:(UIButton*)button
{
    self.wbsTable.contract = self.grn.purchaseOrder.contract;
    [self.view addSubview:self.wbsView];
}

- (IBAction)Reason:(UIButton*)button
{
    [self.view addSubview:self.resonView];
}

- (IBAction)dismissReason:(id)sender
{
    [self.resonView removeFromSuperview];
}
- (IBAction)dismissWBS:(id)sender
{
    [self.wbsView removeFromSuperview];
}
    
- (IBAction)back:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Discard GRN"
                                                        message:@"Are you sure you want to discard this GRN?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK",nil];
        [alert show];

}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSManagedObjectContext *moc = [CoreDataManager sharedInstance].managedObjectContext;
        for (GRNItem *i in self.grn.lineItems)
        {
            [moc deleteObject:i];
        }
        [moc deleteObject:self.grn];
        [moc save:nil];
        [GRNItem removeAllObjectsInManagedObjectContext:moc];
        [GRN removeAllObjectsInManagedObjectContext:moc];//TODO:Remove
        [self performSegueWithIdentifier:@"back" sender:self];
    }
}

@end
