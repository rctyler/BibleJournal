//
//  SecondViewController.h
//  SimpleBibleApp
//
//  Created by Raymond Tyler on 3/8/13.
//  Copyright (c) 2013 Raymond Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "SBJson.h"

@interface SecondViewController : UIViewController <UITextViewDelegate>
{
    UIButton *saveButton;
    UIButton *loadButton;
    UILabel *notesLabel;
    UILabel *errorLabel;
    UITextView *notesTextView;
    NSString *bookString;
    NSString *chapterString;
    NSString *fileName;
    NSMutableDictionary *bookListing;
    BOOL firstTimeToLoadNotes;
    NSString *savedNote;
}

@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIButton *loadButton;
@property (nonatomic, retain) IBOutlet UITextView *notesTextView;
@property (nonatomic, retain) IBOutlet UILabel *notesLabel;
@property (nonatomic, retain) IBOutlet UILabel *errorLabel;
@property (nonatomic, retain) NSString *bookString;
@property (nonatomic, retain) NSString *chapterString;
@property (nonatomic) BOOL firstTimeToLoadNotes;

-(IBAction)backgroundTouchedHideKeyboard:(id)sender;
-(IBAction)saveButtonClicked:(id)sender;
-(IBAction)loadButtonClicked:(id)sender;
-(void)setupJSONDictionary;
-(void)loadNotes;
-(void)writeToTextFile:(NSData *)data;

@end
