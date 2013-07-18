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
#import "SDN+Management.h"
#import "RejectionReasons+Management.h"
#import "GRNAppDelegate.h"

#define WBSCodeText @"Select WBS Code"
#define TableHeight 323.0
#define DetailContainerOriginY 381.0
#define QuantityAlertTag 123

@interface GRNLineItemVC() <UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, weak) UIPopoverController *pvc;
@property (readonly) GRNItem *selectedItem;
@property BOOL quantityConfirmed;
@property (nonatomic, strong) NSString *quantityToConfirm;
@end

@implementation GRNLineItemVC
@synthesize grn = _grn,
selectedItem,
pvc,
quantityConfirmed,
quantityDelivered,
quantityRejected,
selectedIndexPath,
quantityToConfirm = _quantityToConfirm;

static float KeyboardHeight;

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self checkOrientation];
}

-(void)viewDidLoad
{
    [(GRNAppDelegate*)[UIApplication sharedApplication].delegate setCreatingGRN:YES];

    if ([self.grn.purchaseOrder.contract.useWBS boolValue])
    {
        self.wbsTable.contract = self.grn.purchaseOrder.contract;
    }
    self.orderNameLabel.text = [NSString stringWithFormat:@"Order Items for %@",self.grn.purchaseOrder.orderNumber];
    self.grnDict = [NSDictionary dictionary];
    [super viewDidLoad];
    self.itemTableView.grnItems = [self.grn.lineItems allObjects];
    self.itemTableView.purchaseOrder = self.grn.purchaseOrder;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkOrientation];
    
    if (![self.grn.purchaseOrder.contract.useWBS boolValue] && !self.wbsButton.hidden)
    {
        self.wbsButton.hidden = YES;
        self.wbsCodeLabel.hidden = YES;
        CGRect frame = self.viewBelowWbsCode.frame;
        frame.origin = self.wbsCodeLabel.frame.origin;
        self.viewBelowWbsCode.frame = frame;
    }
    
    if (!self.selectedIndexPath)
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self performSelector:@selector(selectRow:) withObject:self.selectedIndexPath afterDelay:0.1];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
    [self setSerialNumber:nil];
    [self setSerialNumberLabel:nil];
    [self setWbsCodeLabel:nil];
    [self setViewBelowWbsCode:nil];
    [self setDetailContainer:nil];
    [self setWbsLabel:nil];
    [self setOrderNameLabel:nil];
    [self setTableandSDNContainer:nil];
    [super viewDidUnload];
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        self.selectedIndexPath = indexPath;
        self.quantityConfirmed = NO;
        [self selectCorrectValuesForItemAtIndexPath:indexPath];
        [self selectRow:indexPath];
    }
    else if ([tableView isKindOfClass:[GRNWbsTableView class]])
    {
        [self.wbsView removeFromSuperview];
        WBS *wbs = [((GRNWbsTableView*)tableView).dataArray objectAtIndex:indexPath.row];
        NSString *wbsCode = [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription];
        [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
        self.selectedItem.wbsCode = wbs.code;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if ([tableView isKindOfClass:[GRNReasonTableVC class]])
    {
        GRNReasonTableVC *rtv = (GRNReasonTableVC*)tableView;
        [self.resonView removeFromSuperview];
        [self.reasonButton setTitle:[[rtv selectedReason] codeDescription] forState:UIControlStateNormal];
        self.selectedItem.exception = [[rtv selectedReason] code];
        [rtv deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        GRNItem *item = [self itemForPurchaseOrderItem:[self.itemTableView.dataArray objectAtIndex:indexPath.row]];
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
        NSString *error = [self checkItem:item];
        if (error.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self performSelector:@selector(selectRow:) withObject:indexPath afterDelay:0.1];
            
        }
    }
}

-(void)selectRow:(NSIndexPath*)indexPath
{
    [self.itemTableView beginUpdates];
    [self selectCorrectValuesForItemAtIndexPath:indexPath];
    [self.itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    [self.itemTableView endUpdates];
    [self performSelector:@selector(selectRowAgain:) withObject:indexPath afterDelay:0.1];
}

-(void)selectRowAgain:(NSIndexPath*)indexPath
{
    [self.itemTableView beginUpdates];
    [self.itemTableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    [self displaySelectedItem];
    [self.itemTableView endUpdates];
}

-(void)selectCorrectValuesForItemAtIndexPath:(NSIndexPath*)indexPath
{
    PurchaseOrderItem *item = [self.itemTableView.dataArray objectAtIndex:indexPath.row];
    GRNItem *grnItem = [self itemForPurchaseOrderItem:item];
    
    if ([self.grn.purchaseOrder.contract.useWBS boolValue] && !grnItem.wbsCode.length)
    {
        WBS *wbs = [WBS fetchWBSWithCode:item.wbsCode inMOC:[CoreDataManager moc]];
        grnItem.wbsCode = wbs.code;
    }
    if ([grnItem.quantityDelivered doubleValue] <= 0.0)
    {
        grnItem.quantityDelivered = item.quantityBalance;
    }
}

-(void)displaySelectedItem
{
    PurchaseOrderItem *item = self.itemTableView.selectedObject;
    NSLog(@"index = %i",[self.itemTableView.dataArray indexOfObject:item]);
    self.itemLabel.text = item.itemNumber;
    self.descriptionLabel.text = item.itemDescription;
    self.expected.text = [NSString stringWithFormat:@"EA (%.02f expected)",[item.quantityBalance doubleValue]];
    
    WBS *wbs = [WBS fetchWBSWithCode:self.selectedItem.wbsCode.length? self.selectedItem.wbsCode : item.wbsCode inMOC:[CoreDataManager moc]];
    NSString *wbsCode = wbs.code.length? [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription] : WBSCodeText;
    [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
    
    //Set Delivered and rejected quantities rounded to 2 decimal places
    double delivered = [self.selectedItem.quantityDelivered doubleValue] > 0? [self.selectedItem.quantityDelivered doubleValue] : [item.quantityBalance doubleValue];
    double rejected = [self.selectedItem.quantityRejected doubleValue];
    
    self.quantityDelivered.text = delivered > 0.0? [NSString stringWithFormat:@"%.02f",delivered] : @"";
    self.quantityRejected.text = rejected > 0.0? [NSString stringWithFormat:@"%.02f",rejected] : @"";
    
    //Set Reason: If either rejected quantity is null or rejection code is null show "No Reason" as title
    RejectionReasons *reason = [GRNReasonTableVC ReasonForCode:self.selectedItem.exception];
    [self.reasonButton setTitle:reason == nil || rejected == 0.0 ? @"No Reason" : reason.codeDescription forState:UIControlStateNormal];
    
    self.note.text = self.selectedItem.notes;
    
    //Show or hide serial number
    if ([item.plant boolValue])
    {
        self.serialNumber.hidden = NO;
        self.serialNumberLabel.hidden = NO;
    }
    else
    {
        self.serialNumber.hidden = YES;
        self.serialNumberLabel.hidden = YES;
    }
}

-(GRNItem*)selectedItem
{
    PurchaseOrderItem *item = self.itemTableView.selectedObject;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grn.lineItems filteredSetUsingPredicate:predicate] anyObject];
}

-(GRNItem*)itemForPurchaseOrderItem:(PurchaseOrderItem*)item
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grn.lineItems filteredSetUsingPredicate:predicate] anyObject];
}


-(PurchaseOrderItem*)purchaseOrderItemForGRNItem:(GRNItem*)item
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grn.purchaseOrder.lineItems filteredSetUsingPredicate:predicate] anyObject];
}

#pragma mark - TextView delegate

-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView isEqual:self.note])
    {
        self.selectedItem.notes = textView.text;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ChangeScrollViewContentOffsetNotification object:nil];
}

#pragma mark - Text Field Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    BOOL moveView = NO;
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        if ([textField isEqual:self.serialNumber])
        {
            moveView = YES;
        }
    }
    else if (![textField isEqual:self.sdnTextField])
    {
        moveView = YES;
    }
    if (moveView)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ChangeScrollViewContentOffsetNotification object:nil];
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.quantityRejected])
    {
        self.selectedItem.quantityRejected = [NSNumber numberWithDouble:[newString doubleValue]];
    }
    else if ([textField isEqual:self.quantityDelivered])
    {
        if (!self.quantityConfirmed &&
            [newString doubleValue] > [((PurchaseOrderItem*)self.itemTableView.selectedObject).quantityBalance doubleValue] &&
            [self.grn.purchaseOrder.quantityError doubleValue] == 2)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The quantity delivered exceeds quantity balance."
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Confirm",nil];
            self.quantityToConfirm = newString;
            alert.tag = QuantityAlertTag;
            [alert show];
            return NO;
        }
        else
        {
            self.selectedItem.quantityDelivered = [NSNumber numberWithDouble:[newString doubleValue]];
        }
    }
    else if ([textField isEqual:self.serialNumber])
    {
        self.selectedItem.serialNumber = textField.text;
    }
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    @try {
        if ([textField isEqual:self.sdnTextField])
        {
            if (![SDN doesSDNExist:textField.text inMOC:[CoreDataManager moc]])
            {
                self.grn.supplierReference = textField.text;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A GRN with this Service Delivery Number has already been submitted."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        //This happens when we go back and there is no grn
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.sdnTextField])
    {
        if (![SDN doesSDNExist:textField.text inMOC:[CoreDataManager moc]])
        {
            self.grn.supplierReference = textField.text;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A GRN with this Service Delivery Number has already been submitted."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Segue

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    [self.sdnTextField resignFirstResponder];
    
    if ([identifier isEqualToString:@"next"])
    {
        
        NSLog(@"items:\n");
        for (GRNItem *item in self.grn.lineItems)
        {
            NSLog(@"%@",[item description]);
        }
        
        
        NSString *error = [self checkAllData];
        if (error.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"next"])
    {
        [[CoreDataManager moc] save:nil];
        GRNCompleteGRNVC *vc = segue.destinationViewController;
        vc.grn = self.grn;
    }
}

#pragma mark - Keyboard Notifications

-(void)onKeyboardHide:(NSNotification *)notification
{
    //    if (self.view.frame.origin.y != 0)
    //    {
    //        CGRect frame = self.view.frame;
    //        frame.origin.y = 0.0;
    //        [UIView beginAnimations:nil context:nil];
    //        [UIView setAnimationDuration:0.3];
    //        self.view.frame = frame;
    //        [UIView commitAnimations];
    //    }
}

-(void)onKeyboardShow:(NSNotification *)notification
{
    //    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    KeyboardHeight = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])? 352.0 : 264.0;
    
}

#pragma mark - IBActions


- (IBAction)wbsCodes:(UIButton*)button
{
    self.wbsView.frame = self.view.bounds;
    [self.view addSubview:self.wbsView];
}

- (IBAction)Reason:(UIButton*)button
{
    self.resonView.frame = self.view.bounds;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to discard this GRN?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
    
}
//
//- (IBAction)doneSearching:(id)sender
//{
//    self.searchTextField.text = @"";
//    [self.searchTextField resignFirstResponder];
//    self.searchBar.hidden = YES;
//}
//- (IBAction)search:(id)sender
//{
//    if (self.searchBar.hidden)
//    {
//        self.searchBar.hidden = NO;
//        [self.searchTextField becomeFirstResponder];
//
//        CGRect frame = self.searchBar.frame;
//        frame.origin.y = self.view.frame.size.height - self.searchBar.frame.size.height;
//        self.searchBar.frame = frame;
//
//        //animate
//        frame.origin.y = self.view.frame.size.height - self.searchBar.frame.size.height - KeyboardHeight;
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.3];
//        self.searchBar.frame = frame;
//        [UIView commitAnimations];
//    }
//    else
//    {
//        self.searchTextField.text = @"";
//        self.searchBar.hidden = YES;
//        [self.searchTextField resignFirstResponder];
//    }
//}
- (IBAction)refresh:(id)sender
{
    [self.itemTableView doneSearching];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == QuantityAlertTag)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            self.quantityConfirmed = YES;
            self.quantityDelivered.text = self.quantityToConfirm;
            self.selectedItem.quantityDelivered = [NSNumber numberWithDouble:[self.quantityToConfirm doubleValue]];
        }
    }
    else if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSManagedObjectContext *moc = [CoreDataManager moc];
        for (GRNItem *i in self.grn.lineItems)
        {
            [moc deleteObject:i];
        }
        [moc deleteObject:self.grn];
        [moc save:nil];
        
        //Remove data from nsuserdefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:KeyImage1];
        [defaults setObject:nil forKey:KeyImage2];
        [defaults setObject:nil forKey:KeyImage3];
        [defaults setObject:nil forKey:KeySignature];
        [defaults synchronize];
        [self performSegueWithIdentifier:@"back" sender:self];
    }
    self.quantityToConfirm = nil;
}

-(NSString*)checkAllData
{
    //First check current item then check SDN
    NSMutableString *errorString = [[self checkItem:self.selectedItem] mutableCopy];
    
    if (![self stripedTextLength:self.sdnTextField.text])
    {
        [errorString appendFormat:@"Please enter a valid Supplier Reference Number (SDN).\n"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"quantityDelivered > 0"];
    NSArray *itemsAdded = [[self.grn.lineItems filteredSetUsingPredicate:predicate] allObjects];
    
    if (!itemsAdded.count)
    {
        [errorString appendFormat:@"Please specify quantity delivered for atleast one order item.\n"];
    }
    
    if ([SDN doesSDNExist:self.sdnTextField.text inMOC:[CoreDataManager moc]])
    {
        [errorString appendFormat:@"A GRN with this Service Delivery Number has already been submitted. Please enter a different SDN.\n"];
    }
    
    return errorString;
}

-(int)stripedTextLength:(NSString*)text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
}

-(NSString*)checkItem:(GRNItem*)item
{
    NSMutableString *errorString = [NSMutableString string];
    if ([self stripedTextLength:self.quantityDelivered.text] && [self.quantityDelivered.text doubleValue] != 0.0)
    {
        if (!self.wbsButton.hidden && [self.wbsButton.titleLabel.text isEqualToString:WBSCodeText])
        {
            [errorString appendFormat:@"Please enter WBS Code.\n"];
        }
        if (!self.serialNumber.hidden && ![self stripedTextLength:self.serialNumber.text])
        {
            [errorString appendFormat:@"Please enter serial number.\n"];
        }
    }
    
    if ([self.quantityDelivered.text doubleValue] < [self.quantityRejected.text doubleValue])
    {
        [errorString appendFormat:@"Rejected ￼quantity for item must not exceed the quantity ￼delivered.\n"];
    }
    else if ([self.quantityRejected.text doubleValue] > 0 && item.exception.length == 0)
    {
        [errorString appendFormat:@"Please select a rejection reason.\n"];
    }
    else if ([self.quantityRejected.text doubleValue] == 0)
    {
        item.exception = @"";
        [[CoreDataManager moc] save:nil];
    }
    
    double quantityBalance = [[[self purchaseOrderItemForGRNItem:item] quantityBalance] doubleValue];
    
    if ([self.quantityDelivered.text doubleValue] > quantityBalance && [self.grn.purchaseOrder.quantityError doubleValue] == 1)
    {
        [errorString appendFormat:@"Quantity delivered cannot exceed quantity balance.\n"];
    }
    
    return errorString;
}

//TODO: Implement This
//-(void)saveItem
//{
//    self.selectedItem.notes = self.note.text;
//    self.selectedItem.quantityRejected = [NSNumber numberWithDouble:[self.quantityRejected.text doubleValue]];
//    self.selectedItem.quantityDelivered = [NSNumber numberWithDouble:[self.quantityDelivered.text doubleValue]];
//    self.selectedItem.serialNumber = self.serialNumber.text;
//
//    //If quantity rejected is 0 make sure the reason code is also zero
//    if ([self.quantityRejected.text doubleValue]) self.selectedItem.exception = @"0";
//
//    [[CoreDataManager moc] save:nil];
//}

#pragma mark - Orientation Adjustments

-(void)checkOrientation
{
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        [self showLandscapeView];
    }
    else
    {
        [self showPortraitView];
    }
}

-(void)showPortraitView
{
    CGRect frame = self.tableandSDNContainer.frame;
    frame.origin.x = 41.0;
    frame.origin.y = 133.0;
    frame.size.width = 686.0;
    frame.size.height = 377.0;
    self.tableandSDNContainer.frame = frame;
    
    frame = self.detailContainer.frame;
    frame.origin.x = 41.0;
    frame.origin.y = 518.0;
    frame.size.width = 686.0;
    frame.size.height = 394.0;
    self.detailContainer.frame = frame;
}

-(void)showLandscapeView
{
    CGRect frame = self.tableandSDNContainer.frame;
    frame.origin.x = 13.0;
    frame.origin.y = 133.0;
    frame.size.width = 430.0;
    frame.size.height = 550.0;
    self.tableandSDNContainer.frame = frame;
    
    frame = self.detailContainer.frame;
    frame.origin.x = 465.0;
    frame.origin.y = 133.0;
    frame.size.width = 550.0;
    frame.size.height = 550.0;
    self.detailContainer.frame = frame;
}
- (IBAction)dismissKeyboard:(id)sender
{
    [self.quantityDelivered resignFirstResponder];
    [self.quantityRejected resignFirstResponder];
    [self.note resignFirstResponder];
    [self.serialNumber resignFirstResponder];
}

- (BOOL)findAndResignFirstResponder:(UIView*)view
{
    if (view.isFirstResponder) {
        [view resignFirstResponder];
        return YES;
    }
    for (UIView *subView in view.subviews) {
        if ([self findAndResignFirstResponder:subView])
            return YES;
    }
    return NO;
}

#pragma mark - Alternate functionality for clear all

- (IBAction)acceptOrClear:(UIButton*)sender
{
    BOOL accept = [sender.titleLabel.text hasPrefix:@"Accept"];
    for (GRNItem *li in self.grn.lineItems)
    {
        PurchaseOrderItem *poi = [self purchaseOrderItemForGRNItem:li];
        li.quantityDelivered = accept? poi.quantityBalance : [NSNumber numberWithInt:0];
        li.wbsCode = accept? poi.wbsCode : @"";
        li.exception = @"";
        li.quantityRejected = [NSNumber numberWithInt:0];
    }
    [sender setTitle:accept? @"Clear All" : @"Accept All" forState:UIControlStateNormal];
    [self.itemTableView reloadRowsAtIndexPaths:[self.itemTableView indexPathsForVisibleRows]
                              withRowAnimation:UITableViewRowAnimationNone];
    [self performSelector:@selector(selectRowAfterClearAllOrAcceptAll) withObject:nil afterDelay:0.1];
}


-(void)selectRowAfterClearAllOrAcceptAll
{
    [self.itemTableView beginUpdates];
    [self.itemTableView selectRowAtIndexPath:self.selectedIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    [self.itemTableView endUpdates];
    [self performSelector:@selector(displaySelectedItem) withObject:nil afterDelay:0.1];
}

@end
