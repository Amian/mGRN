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

#define WBSCodeText @"Select WBS Code"
#define TableHeight 323.0
#define DetailContainerOriginY 434.0

@interface GRNLineItemVC() <UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) UIPopoverController *pvc;
@property (readonly) GRNItem *selectedItem;
@end

@implementation GRNLineItemVC
@synthesize grn = _grn, selectedItem, pvc;
static float KeyboardHeight;

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        CGRect frame = self.itemTableView.frame;
        frame.size.height = TableHeight/2;
        self.itemTableView.frame = frame;
        frame = self.detailContainer.frame;
        frame.origin.y = DetailContainerOriginY - TableHeight/2;
        self.detailContainer.frame = frame;
    }
    else
    {
        CGRect frame = self.itemTableView.frame;
        frame.size.height = TableHeight;
        self.itemTableView.frame = frame;
        frame = self.detailContainer.frame;
        frame.origin.y = DetailContainerOriginY;
        self.detailContainer.frame = frame;
    }
}

-(void)viewDidLoad
{
    if ([self.grn.purchaseOrder.contract.useWBS boolValue])
    {
        self.wbsTable.contract = self.grn.purchaseOrder.contract;
    }
    
    self.searchBar.hidden = YES;
    self.grnDict = [NSDictionary dictionary];
    [super viewDidLoad];
    self.itemTableView.grnItems = [self.grn.lineItems allObjects];
    self.itemTableView.purchaseOrder = self.grn.purchaseOrder;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self didRotateFromInterfaceOrientation:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (![self.grn.purchaseOrder.contract.useWBS boolValue] && !self.wbsButton.hidden)
    {
        self.wbsButton.hidden = YES;
        CGRect frame = self.viewBelowWbsCode.frame;
        frame.origin = self.wbsCodeLabel.frame.origin;
        self.viewBelowWbsCode.frame = frame;
    }
    
    NSLog(@"dict in lvc = %@",self.grnDict);
    [self displaySelectedItem];
    [super viewDidAppear:animated];
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
    [self setSearchBar:nil];
    [self setSearchTextField:nil];
    [self setSerialNumber:nil];
    [self setSerialNumberLabel:nil];
    [self setWbsCodeLabel:nil];
    [self setViewBelowWbsCode:nil];
    [self setDetailContainer:nil];
    [super viewDidUnload];
}

#pragma mark - Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = NULL;
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        // Create label with section title
        UILabel *label = [[UILabel alloc] init] ;
        label.frame = CGRectMake(0, 0, self.itemTableView.frame.size.width, 50);
        label.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
        label.textColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.text = @"     Order Items";
        
        // Create header view and add label as a subview
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
        [headerView addSubview:label];
    }
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        return 50.0;
    }
    return 0.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        [tableView reloadData];
        [tableView selectRowAtIndexPath:indexPath
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionNone
                                 animated:NO];
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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[GRNOrderItemsTableView class]])
    {
        NSString *error = [self checkItem];
        if (error.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error
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
    [self.itemTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
    [self displaySelectedItem];
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
    [self.wbsButton setTitle:wbs.codeDescription.length? wbs.codeDescription : WBSCodeText forState:UIControlStateNormal];
    self.quantityDelivered.text = [NSString stringWithFormat:@"%i",[self.selectedItem.quantityDelivered intValue] ];
    self.quantityRejected.text = [NSString stringWithFormat:@"%i",[self.selectedItem.quantityRejected intValue]];
    self.note.text = self.selectedItem.notes;
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

#pragma mark - Text Field Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.view.frame.origin.y == 0 && ![textField isEqual:self.sdnTextField] && ![textField isEqual:self.searchTextField])
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
    else if ([textField isEqual:self.searchTextField])
    {
        [self.itemTableView searchForString:newString];
    }
    else if ([textField isEqual:self.serialNumber])
    {
        self.selectedItem.serialNumber = textField.text;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.sdnTextField])
    {
        if (![SDN doesSDNExist:textField.text inMOC:[[CoreDataManager sharedInstance] managedObjectContext]])
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.sdnTextField])
    {
        if (![SDN doesSDNExist:textField.text inMOC:[[CoreDataManager sharedInstance] managedObjectContext]])
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
    if ([identifier isEqualToString:@"next"])
    {
        NSString *error = [self checkAllData];
        if (error.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error
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
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    KeyboardHeight = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])? 352.0 : 264.0;
    
}

#pragma mark - IBActions

- (IBAction)wbsCodes:(UIButton*)button
{
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

- (IBAction)doneSearching:(id)sender
{
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
    self.searchBar.hidden = YES;
}
- (IBAction)search:(id)sender
{
    if (self.searchBar.hidden)
    {
        self.searchBar.hidden = NO;
        [self.searchTextField becomeFirstResponder];
        
        CGRect frame = self.searchBar.frame;
        frame.origin.y = self.view.frame.size.height - self.searchBar.frame.size.height;
        self.searchBar.frame = frame;
        
        //animate
        frame.origin.y = self.view.frame.size.height - self.searchBar.frame.size.height - KeyboardHeight;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.searchBar.frame = frame;
        [UIView commitAnimations];
    }
    else
    {
        self.searchTextField.text = @"";
        self.searchBar.hidden = YES;
        [self.searchTextField resignFirstResponder];
    }
}
- (IBAction)refresh:(id)sender
{
    [self.itemTableView doneSearching];
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
        
        //Remove data from nsuserdefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:KeyImage1];
        [defaults removeObjectForKey:KeyImage2];
        [defaults removeObjectForKey:KeyImage3];
        [defaults removeObjectForKey:KeySignature];
        [defaults synchronize];
        [self performSegueWithIdentifier:@"back" sender:self];
    }
}

-(NSString*)checkAllData
{
    NSMutableString *errorString = [NSMutableString string];
    
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
    
    if ([SDN doesSDNExist:self.sdnTextField.text inMOC:[[CoreDataManager sharedInstance] managedObjectContext]])
    {
        [errorString appendFormat:@"A GRN with this Service Delivery Number has already been submitted. Please enter a different SDN.\n"];
    }
    
    return errorString;
}

-(int)stripedTextLength:(NSString*)text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
}

-(NSString*)checkItem
{
    NSMutableString *errorString = [NSMutableString string];
    if ([self stripedTextLength:self.quantityDelivered.text] && [self.quantityDelivered.text intValue] != 0)
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
    return errorString;
}

@end
