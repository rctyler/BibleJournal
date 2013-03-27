//
//  FirstViewController.h
//  SimpleBibleApp
//
//  Created by Raymond Tyler on 3/8/13.
//  Copyright (c) 2013 Raymond Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SecondViewController.h"

@interface FirstViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate, UIWebViewDelegate>
{
    UIView *transparentView;
    UIWebView * bibleWebView;
    UIPickerView *biblePickerView;
    UIButton *chooseVerseButton;
    UIButton *prevButton;
    UIButton *nextButton;
    UIButton *refreshButton;
    NSArray *bibleBookColumnList;
    NSMutableDictionary *bookListing;
    NSInteger selectedBook;
    NSInteger selectedChapter;
    
    int offsetY;
}

@property (nonatomic, retain) IBOutlet UIWebView *bibleWebView;
@property (nonatomic, retain) IBOutlet UIPickerView *biblePickerView;
@property (nonatomic, retain) IBOutlet UIButton *chooseVerseButton;
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *refreshButton;
@property (nonatomic, retain) IBOutlet NSMutableDictionary *bookListing;
@property (strong, nonatomic) NSArray *bibleBookColumnList;

- (void)addBibleText;
- (void) setupPickerView;
- (IBAction)verseButtonClicked:(id)sender;
- (IBAction)prevButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;
- (void)setupBibleDictionary;

@end
