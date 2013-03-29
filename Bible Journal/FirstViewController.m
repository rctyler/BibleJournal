/*
 ***************************************************************************************
 *  FILE: FirstViewController.m
 *  PROJECT: SimpleBibleApp
 *
 *  DESCRIPTION: This file implements the FirstViewController class which is tied to the 
 *               first view of the tab bar controller. It's purpose in this app is to
 *               display the text of the bible in a Web View by grabbing the HTML text
 *               from http://wwww.ebible.org (the World English Bible translation),
 *               parsing out unwanted pieces, and then displaying it as a web page. 
 *               A Picker View is used to select the book of the bible and the chapter
 *               desired. This view communicates with the SecondViewController class by
 *               explicitly passing to it the values of book and chapter selected.
 *              
 *  Created by Raymond Tyler on 3/8/13.
 *  Copyright (c) 2013 Raymond Tyler. All rights reserved.
 ***************************************************************************************
 */

#import "FirstViewController.h"

@interface FirstViewController()

@end

@implementation FirstViewController
@synthesize bibleWebView, biblePickerView, bibleBookColumnList, chooseVerseButton, refreshButton, bookListing, nextButton, prevButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupPickerView];
    // Grab Bible text for Genesis 1 (default)
    [self addBibleText:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *************************************************************************************
 *  Name: addBibleText
 *************************************************************************************
 *  Description: This method sends an HMTL request to http://ebbible.org so that it
 *               can grab the bible text for the currently selected bible book and
 *               chapter. Genesis 1 is selected by default when the app is first
 *               initialized
 *  @param   void
 *  @return  void
 *  @warning There is no error checking when grabbing HTML from the ebible.og server
 *  @bug     potential bugs (see warning)
 *************************************************************************************
 */
- (void)addBibleText:(BOOL)clearUserNotesArea
{
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *defaultURL = @"http://ebible.org/web/ROM01.htm";
    NSString *URL;
    SecondViewController *v = (SecondViewController *)[[self.tabBarController viewControllers] objectAtIndex:1];
    
    selectedBook = [biblePickerView selectedRowInComponent:0];
    selectedChapter = [biblePickerView selectedRowInComponent:1];
    
    NSString *book = [bibleBookColumnList objectAtIndex:(selectedBook)];
    NSString *chapter = [[bookListing objectForKey:[bibleBookColumnList objectAtIndex:selectedBook]] objectAtIndex:selectedChapter];
        
    v.bookString = book;
    v.chapterString = chapter;
    
    // If we want to clear the user notes from the text view, than it is the first time we
    // are attempting to load another set of the user's notes 
    v.firstTimeToLoadNotes = clearUserNotesArea;
    
    // This app displays the Bible text by requesting html from http://ebible.org, The
    // URL address to query for a specific text is unique for each book and chapter of the bible/
    // The URL address is usually setup so that it contains the first 3 letters of the book that
    // you want in its address. However, some books like the ones listed below don't follow this
    // format and need to be attended to differently.  Example: Romans 1 is
    // @"http://ebible.org/web/ROM01.htm", but Mark 3 is @"http://ebible.org/web/MRK03.htm", not
    // @http://ebible.org/web/MAR03.htm?
    BOOL createHtmlStringNormalWay = (![book isEqualToString:@"Psalms"] &&
                                      ![book isEqualToString:@"Judges"] &&
                                      ![book isEqualToString:@"Song of Solomon"] &&
                                      ![book isEqualToString:@"Ezekiel"] &&
                                      ![book isEqualToString:@"Joel"] &&
                                      ![book isEqualToString:@"Nahum"] &&
                                      ![book isEqualToString:@"Mark"] &&
                                      ![book isEqualToString:@"John"] &&
                                      ![book isEqualToString:@"Philippians"] &&
                                      ![book isEqualToString:@"Philemon"] &&
                                      ![book isEqualToString:@"James"] &&
                                      ![book isEqualToString:@"1 John"] &&
                                      ![book isEqualToString:@"2 John"] &&
                                      ![book isEqualToString:@"3 John"]);
    
    // Normal case
    if (createHtmlStringNormalWay)
    {
        NSString *newSubstring = [[book substringWithRange:NSMakeRange(0, 3)] uppercaseString];
        
        // if selected book has a space in the first 3 letter of its name (like 1 Corinthians), we need to read in 4 characters and get rid of that space later
        if ([newSubstring rangeOfString:@" "].location != NSNotFound)
        {
            newSubstring = [[book substringWithRange:NSMakeRange(0, 4)] uppercaseString];
        }
        
        // We need to figure out how many leading zeros we need in the substring we're building
        // that will give us proper html string for the book and chapter we want. Example:
        // ROM01.html for Romans 1, ROM12.htm for Romans 12
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        newSubstring = [newSubstring stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Psalms"])
    {
        NSString *newSubstring = [[book substringWithRange:NSMakeRange(0, 3)] uppercaseString];
        
        // We need to figure out how many leading zeros we need in the substring we're building
        // that will give us proper html string for the book and chapter we want. Example:
        // PSA001.html for Psalms 1, PSA012.htm for Psalms 12, PSA128 for Psalms 128
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"00"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
            newSubstring = [newSubstring stringByAppendingString:@".htm"];
        }
        else if ([chapter length] < 3)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
            newSubstring = [newSubstring stringByAppendingString:@".htm"];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
            newSubstring = [newSubstring stringByAppendingString:@".htm"];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 9) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Judges"])
    {
        NSString *newSubstring = @"JDG";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];

    }
    else if ([book isEqualToString:@"Song of Solomon"])
    {
        NSString *newSubstring = @"SNG";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Ezekiel"])
    {
        NSString *newSubstring = @"EZK";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Joel"])
    {
        NSString *newSubstring = @"JOL";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Nahum"])
    {
        NSString *newSubstring = @"NAM";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Mark"])
    {
        NSString *newSubstring = @"MRK";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"John"])
    {
        NSString *newSubstring = @"JHN";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Philippians"])
    {
        NSString *newSubstring = @"PHP";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"Philemon"])
    {
        NSString *newSubstring = @"PHM";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"James"])
    {
        NSString *newSubstring = @"JAS";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"1 John"])
    {
        NSString *newSubstring = @"1JN";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"2 John"])
    {
        NSString *newSubstring = @"2JN";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    else if ([book isEqualToString:@"3 John"])
    {
        NSString *newSubstring = @"3JN";
        
        if ([chapter length] < 2)
        {
            newSubstring = [newSubstring stringByAppendingString:@"0"];
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        else
        {
            newSubstring = [newSubstring stringByAppendingString:chapter];
        }
        
        URL = [defaultURL stringByReplacingCharactersInRange:NSMakeRange (22, 5) withString:newSubstring];
    }
    
    // Send HTML request to server
    [request setURL:[NSURL URLWithString:URL]];
    [request setTimeoutInterval:4.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:NULL error:&error];
    
    
    if (data != nil)
    {
        // Convert returned data to a UTF8 Encoded String
        NSString *html = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    
        // The returned HTML will have code in there that we do not want, so we need to parse the
        // unwanted strings out of there
        NSString *token = @"<body class=\"mainDoc\">";
        NSArray *level1 = [html componentsSeparatedByString:token];
        
        NSString *level1String;
        
        // Before continuing, make sure the string we parsed has the correct number of elements so 
        // that we don't get an out-of-bounds exception
        if ([level1 count] > 0)
        {
            level1String = (NSString *)[level1 objectAtIndex:0];
        }
        else
        {
            goto error;
        }
        
        token = @"<div class=\"main\">";
        NSArray *level2 = [html componentsSeparatedByString:token];
        
        NSString *level2String;
        
        // Before continuing, make sure the string we parsed has the correct number of elements so
        // that we don't get an out-of-bounds exception
        if ([level2 count] > 1)
        {
            level2String = (NSString *)[level2 objectAtIndex:1];
        }
        else
        {
            goto error;
        }
    
        // Get rid of the footer text in the html string
        token = @"<div class=\"pageFooter\">";
        NSArray *level3 = [[level1String stringByAppendingString:level2String] componentsSeparatedByString:token];
    
        NSString *parsedHtmlString;
        
        // Before continuing, make sure the string we parsed has the correct number of elements so
        // that we don't get an out-of-bounds exception
        if ([level3 count] > 0)
        {
            parsedHtmlString = (NSString *)[level3 objectAtIndex:0];
        }
        else
        {
            goto error;
        }
    
        // At this point, there are popups embedded within the received HTML code, so we
        // need to iterate through the HTML string and get rid of them. What's implemented
        // below isn't optimized since this could be done by using a regular expression, however
        // that is a project for another time
        
        token = @"<a href=\"";
        NSArray *level4 = [parsedHtmlString componentsSeparatedByString:token];
        
        if ([level4 count]> 0)
        {
            parsedHtmlString = [level4 objectAtIndex:0];
        }
        else
        {
            goto error;
        }
        
        token = @"</span></a>";
        
        // The embedded popups start with the tag: '<a href ="' and end with the tag
        // '</span></a>'. Knowing that, get rid of everything in between
        for (int i = 1; i < [level4 count]; i++)
        {
            NSArray *level5 = [[level4 objectAtIndex:i] componentsSeparatedByString:token];
            NSString *intermediateString = @"";
            
            // Don't access the 2nd element in the array if the token wasn't found, otherwise
            // we could be trying to access an element out of bounds
            if ([level5 count] > 1)
            {
                intermediateString = [level5 objectAtIndex: 1];
            }
            
            // Piece the two ends together to form the correct string
            parsedHtmlString = [parsedHtmlString stringByAppendingString:intermediateString];
        }
        
        // This string may also show up, get rid of it
        parsedHtmlString = [parsedHtmlString stringByReplacingOccurrencesOfString:@"For answers to frequently asked questions about the World English Bible, please visit WorldEnglishBible.org." withString:@""];
        
        [self.bibleWebView loadHTMLString:parsedHtmlString baseURL:[NSURL URLWithString:URL]];
    }
    else
    {
        // We will also display this 404 error message if there are any problems in parsing the html
        // text with regards to possible index-out-of bounds exceptions. I know using the "goto"
        // statement is bad style, so that can be changed for a later time.
error:
        [bibleWebView loadHTMLString:@"<font color = \"red\"><center><p style=\"font-size:60px\"><b><br><br>ERROR 404</b><p style=\"font-size:50px\">Can't grab Bible text from:<p style=\"font-size:50px\"><t><u>http://www.ebible.org</u><p style=\"font-size:50px\"> please check the internet connection on your mobile device<font></center>." baseURL:nil];
    }
}

/**
 *************************************************************************************
 *  Name: setupPickerView
 *************************************************************************************
 *  Description: This method sets up the biblePickerView.  Genesis 1 is selected by
 *               default.
 *  @param   void
 *  @return  void
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(void) setupPickerView
{
    bookListing = [NSMutableDictionary dictionary];
    
    [self setupBibleDictionary];
        
    [biblePickerView selectRow:0 inComponent:0 animated:YES];
    [biblePickerView selectRow:0 inComponent:1 animated:YES];
}

/**
 *************************************************************************************
 *  Name: verseButtonClicked
 *************************************************************************************
 *  Description: This method sends an HMTL request to http://ebbible.org so that it
 *               can grab the bible text for the currently selected bible book and
 *               chapter. Genesis 1 is selected by default when the app is first
 *               initialized3
 *  @param   void
 *  @return  IBAction
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
- (IBAction)verseButtonClicked:(id)sender
{
    UILabel *title = [chooseVerseButton titleLabel];
    SecondViewController *v = (SecondViewController *)[[self.tabBarController viewControllers] objectAtIndex:1];
    
    NSInteger b = [biblePickerView selectedRowInComponent:0];
    NSInteger c = [biblePickerView selectedRowInComponent:1];
    NSString *book = [bibleBookColumnList objectAtIndex:b];
    NSString *chapter = @"";
    
    // Because we are using a picker view, the user could conceivably select a chapter from
    // the second colun while the the first column is spinnning, which may lead to an out-of-bounds
    // error, so anticipate it with this error-control check.
    if (c < [[bookListing objectForKey:book] count])
    {
        chapter = [[bookListing objectForKey:book] objectAtIndex:c];
    }
    
    if ([title.text isEqualToString:@"Choose Verse"])
    {
        [chooseVerseButton setTitle:@"Go to Verse" forState:UIControlStateNormal];
        [refreshButton setTitle:@"Close" forState:UIControlStateNormal];
        
        prevButton.hidden = YES;
        nextButton.hidden = YES;
        biblePickerView.hidden = NO;
    }
    else if ([title.text isEqualToString:@"Go to Verse"])
    {
        [chooseVerseButton setTitle:@"Choose Verse" forState:UIControlStateNormal];
        [refreshButton setTitle:@"Refresh Page" forState:UIControlStateNormal];
        
        // We only want to request the bible text from ebible.org only if we are not choosing a
        // verse that is not already selected
        if (!([v.bookString isEqualToString:book] &&
            [v.chapterString isEqualToString:chapter]))
        {
            NSInteger bookSelected = [biblePickerView selectedRowInComponent:0];
            NSInteger chapterSelected = [biblePickerView selectedRowInComponent:1];
            NSString *bookString = [bibleBookColumnList objectAtIndex:bookSelected];
            
            
            NSInteger bookSize = [[bookListing objectForKey:bookString] count];
            
            // Because we are using a picker view, the user could conceivably select a chapter from
            // the second colun while the the first column is spinnning, which may lead to an
            // out-of-bounds error, so anticipate it with this error-control check.
            if (chapterSelected < bookSize)
            {
                // Grab bible text based on selected book and chapter from the Picker View
                // Passing "YES" as a parameter tells the Second View Controller to clear the
                // notes view on its screen
                [self addBibleText:YES];
                prevButton.hidden = NO;
                nextButton.hidden = NO;
                biblePickerView.hidden = YES;
            }
        }
        else
        {
            prevButton.hidden = NO;
            nextButton.hidden = NO;
            biblePickerView.hidden = YES;
        }
    }
}

- (IBAction)prevButtonClicked:(id)sender
{
    NSInteger chapter = [biblePickerView selectedRowInComponent:1];
    NSInteger book = [biblePickerView selectedRowInComponent:0];

    // Check bounds
    if (chapter != 0)
    {
        [biblePickerView selectRow:chapter-1 inComponent:1 animated:NO];
        [self addBibleText:YES];
    }
    else
    {
        if (book != 0)
        {
            NSString *newBook = [bibleBookColumnList objectAtIndex:book-1];
            NSInteger chapterCount = [[bookListing objectForKey:newBook] count];
            NSString *chapter = [[bookListing objectForKey:newBook]
                                    objectAtIndex: chapterCount-1];
            NSInteger newChapter = [chapter intValue];
        
            [biblePickerView selectRow:book-1 inComponent:0 animated:NO];
            [biblePickerView reloadComponent:1];
            [biblePickerView selectRow:newChapter-1 inComponent:1 animated:NO];
            [self addBibleText:YES];
        }
    }
}

- (IBAction)nextButtonClicked:(id)sender
{
    NSInteger book = [biblePickerView selectedRowInComponent:0];
    NSInteger chapter = [biblePickerView selectedRowInComponent:1];
    NSString *bookString = [bibleBookColumnList objectAtIndex:(book)];

    // Check bounds
    if (chapter != [[bookListing objectForKey:bookString] count] - 1)
    {
        [biblePickerView selectRow:chapter+1 inComponent:1 animated:NO];
        [self addBibleText:YES];
    }
    else
    {
        if (book != [bibleBookColumnList count] - 1)
        {
            NSString *newBook = [bibleBookColumnList objectAtIndex:book+1];
            NSString *chapter = [[bookListing objectForKey:newBook]
                                     objectAtIndex: 0];
            NSInteger newChapter = [chapter intValue];
            [biblePickerView selectRow:book+1 inComponent:0 animated:NO];
            [biblePickerView reloadComponent:1];
            [biblePickerView selectRow:newChapter-1 inComponent:1 animated:NO];
            [self addBibleText:YES];
        }
    }
}

/**
 *************************************************************************************
 *  Name: refreshButtonClicked
 *************************************************************************************
 *  Description: This method will call addBibleText when clicked. Basically it is here
 *               so that if the user clicks on a popup in the bibleWebView, they can
 *               get rid of it. Not optimal, but sufficient for this quick project
 *  @param   (id)sender : The object that triggered the refreshButtonClicked event.
 *  @return  IBAction
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
- (IBAction)refreshButtonClicked:(id)sender
{
    UILabel *title = [refreshButton titleLabel];
    
    if ([title.text isEqualToString:@"Refresh Page"])
    {
        // Reload the bibleWebView only if the web view shows the "Error 404" message (not
        // needed otherwise
        if ([[bibleWebView stringByEvaluatingJavaScriptFromString:@"document.body.textContent"]rangeOfString:@"ERROR 404"].location != NSNotFound)
        {
            // Grab bible text, passing "NO" as a parameter tells the Second View Controller to 
            // not clear the notes view on its screen
            [self addBibleText:NO];
        }
    }
    else if ([title.text isEqualToString:@"Close"])
    {
        prevButton.hidden = NO;
        nextButton.hidden = NO;
        biblePickerView.hidden = YES;
        
        [chooseVerseButton setTitle:@"Choose Verse" forState:UIControlStateNormal];
        [refreshButton setTitle:@"Refresh Page" forState:UIControlStateNormal];
    }
}

/**
 *************************************************************************************
 *  Name: numberOfRowsInComponent
 *************************************************************************************
 *  Description: Required function for pickerView delegate. This reports the number
 *               of rows in each component of the biblePickerView
 *  @param   (NSInteger)component : The index of the component we want to check
 *  @return  (NSInteger)
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{    
    if (component == 0)
    {
        return [[bookListing allKeys] count];
    }
    else
    {
        NSInteger index = [biblePickerView selectedRowInComponent:0];
        return [[bookListing objectForKey:[bibleBookColumnList objectAtIndex:index]] count];
    }
}

/**
 *************************************************************************************
 *  Name: numberOfComponentsInPickerView
 *************************************************************************************
 *  Description: Required function for pickerView delegate. This reports the number
 *               of components in the biblePickerView
 *  @param   (UIPickerView *)pickerView : The pickerView we want to check
 *  @return  (NSInteger)
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

/**
 *************************************************************************************
 *  Name: titleForRow:
 *************************************************************************************
 *  Description: Required function for pickerView delegate. This reports the string
 *               of the row selected in a component of the biblePickerView
 *  @param   (NSInteger)component : The index of the component we want to check
 *  @return  NSInteger
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [bibleBookColumnList objectAtIndex:row];
    }
    else
    {
        NSInteger index = [biblePickerView selectedRowInComponent:0];
        
        // Since the user could conceivably select the second column on the picker while the
        // first column is still spinning, we make accidently try to access an out of bounds
        // index in the dictionary, so take that into account here for error checking
        if (row < [[bookListing objectForKey:[bibleBookColumnList objectAtIndex:index]] count])
        {
            return [[bookListing objectForKey:[bibleBookColumnList objectAtIndex:index]]
                    objectAtIndex:row];
        }
        else
        {
            return @"";
        }
    }
}

/**
 *************************************************************************************
 *  Name: didSelectRow
 *************************************************************************************
 *  Description: Required function for pickerView delegate. This sets the value
 *               of the row selected in the biblePickerView, and it also passes the
 *               value of the bookString and the chapterString to the
 *               secondViewController
 *  @param   (NSInteger)row inComponent:(NSInteger)component
 *  @return  void
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    if (component == 0)
    {
        [biblePickerView reloadComponent:1];
        [biblePickerView selectRow:0 inComponent:1 animated:YES];
    }

    return;
}

/**
 *************************************************************************************
 *  Name: setupBibleDictionary
 *************************************************************************************
 *  Description: Create the bible dictionary which will be used to set up the picker
 *               view. This is the core of the app.
 *              
 *  @param   (NSInteger)component : The index of the component we want to check
 *  @return  (NSInteger)pickerView:(UIPickerView *)pickerView
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(void)setupBibleDictionary
{
    // Create arrays to store the chapters that are in each book of the Bible
    
    NSArray *genesis = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", nil];
    NSArray *exodus = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", nil];
    NSArray *leviticus = [[NSArray alloc] initWithObjects:
                 @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", nil];
    NSArray *numbers = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", nil];
    NSArray *deuteronomy = [[NSArray alloc] initWithObjects:
                   @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", nil];
    NSArray *joshua = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", nil];
    NSArray *judges = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", nil];
    NSArray *ruth = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", nil];
    NSArray *samuel1 = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", nil];
    NSArray *samuel2 = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", nil];
    NSArray *kings1 = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", nil];
    NSArray *kings2 = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", nil];
    NSArray *chronicles1 = [[NSArray alloc] initWithObjects:
                   @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", nil];
    NSArray *chronicles2 = [[NSArray alloc] initWithObjects:
                   @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", nil];
    NSArray *ezra = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    NSArray *nehemiah = [[NSArray alloc] initWithObjects:
                @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", nil];
    NSArray *esther = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    NSArray *job = [[NSArray alloc] initWithObjects:
           @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", nil];
    NSArray *psalms = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"100",@"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", @"120", @"121", @"122", @"123", @"124", @"125", @"126", @"127", @"128", @"129", @"130", @"131", @"132", @"133", @"134", @"135", @"136", @"137", @"138", @"139", @"140", @"141", @"142", @"143", @"144", @"145", @"146", @"147", @"148", @"149", @"150",  nil];
    NSArray *proverbs = [[NSArray alloc] initWithObjects:
                @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", nil];
    NSArray *ecclesiastes = [[NSArray alloc] initWithObjects:
                    @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
    NSArray *songofsolomon = [[NSArray alloc] initWithObjects:
                     @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
    NSArray *isaiah = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", nil];
    NSArray *jeremiah = [[NSArray alloc] initWithObjects:
                @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", nil];
    NSArray *lamentations = [[NSArray alloc] initWithObjects:
                    @"1", @"2", @"3", @"4", @"5", nil];
    NSArray *ezekiel = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", nil];
    NSArray *daniel = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
    NSArray *hosea = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", nil];
    NSArray *joel = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", nil];
    NSArray *amos = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    NSArray *obadiah = [[NSArray alloc] initWithObjects:
               @"1", nil];
    NSArray *jonah = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", @"4", nil];
    NSArray *micah = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", @"4", @"5", @"6", @"7", nil];
    NSArray *nahum = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", nil];
    NSArray *habakkuk = [[NSArray alloc] initWithObjects:
                @"1", @"2", @"3", nil];
    NSArray *zephaniah = [[NSArray alloc] initWithObjects:
                 @"1", @"2", @"3", nil];
    NSArray *haggai = [[NSArray alloc] initWithObjects:
              @"1", @"2", nil];
    NSArray *zechariah = [[NSArray alloc] initWithObjects:
                 @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", nil];
    NSArray *malachi = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", nil];
    NSArray *matthew = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", nil];
    NSArray *mark = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", nil];
    NSArray *luke = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", nil];
    NSArray *john = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", nil];
    NSArray *acts = [[NSArray alloc] initWithObjects:
            @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", nil];
    NSArray *romans = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", nil];
    NSArray *corinthians1 = [[NSArray alloc] initWithObjects:
                    @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", nil];
    NSArray *corinthians2 = [[NSArray alloc] initWithObjects:
                    @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", nil];
    NSArray *galatians = [[NSArray alloc] initWithObjects:
                 @"1", @"2", @"3", @"4", @"5", @"6", nil];
    NSArray *ephesians = [[NSArray alloc] initWithObjects:
                 @"1", @"2", @"3", @"4", @"5", @"6", nil];
    NSArray *philippians = [[NSArray alloc] initWithObjects:
                   @"1", @"2", @"3", @"4", nil];
    NSArray *colossians = [[NSArray alloc] initWithObjects:
                  @"1", @"2", @"3", @"4", nil];
    NSArray *thessalonians1 = [[NSArray alloc] initWithObjects:
                      @"1", @"2", @"3", @"4", @"5", nil];
    NSArray *thessalonians2 = [[NSArray alloc] initWithObjects:
                      @"1", @"2", @"3", nil];
    NSArray *timothy1 = [[NSArray alloc] initWithObjects:
                @"1", @"2", @"3", @"4", @"5", @"6", nil];
    NSArray *timothy2 = [[NSArray alloc] initWithObjects:
                @"1", @"2", @"3", @"4", nil];
    NSArray *titus = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", nil];
    NSArray *philemon = [[NSArray alloc] initWithObjects:
                @"1", nil];
    NSArray *hebrews = [[NSArray alloc] initWithObjects:
               @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", nil];
    NSArray *james = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", @"4", @"5", nil];
    NSArray *peter1 = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", @"4", @"5", nil];
    NSArray *peter2 = [[NSArray alloc] initWithObjects:
              @"1", @"2", @"3", nil];
    NSArray *john1 = [[NSArray alloc] initWithObjects:
             @"1", @"2", @"3", @"4", @"5", nil];
    NSArray *john2 = [[NSArray alloc] initWithObjects:
             @"1", nil];
    NSArray *john3 = [[NSArray alloc] initWithObjects:
             @"1", nil];
    NSArray *jude = [[NSArray alloc] initWithObjects:
            @"1", nil];
    NSArray *revelation = [[NSArray alloc] initWithObjects:
                  @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22",
                  nil];
    
    // Add each chapter array to the bookListing dictiionary, the book of the bible acts as a key
    
    [bookListing setObject:genesis        forKey:@"Genesis"];
    [bookListing setObject:exodus         forKey:@"Exodus"];
    [bookListing setObject:leviticus      forKey:@"Leviticus"];
    [bookListing setObject:numbers        forKey:@"Numbers"];
    [bookListing setObject:deuteronomy    forKey:@"Deuteronomy"];
    [bookListing setObject:joshua         forKey:@"Joshua"];
    [bookListing setObject:judges         forKey:@"Judges"];
    [bookListing setObject:ruth           forKey:@"Ruth"];
    [bookListing setObject:samuel1        forKey:@"1 Samuel"];
    [bookListing setObject:samuel2        forKey:@"2 Samuel"];
    [bookListing setObject:kings1         forKey:@"1 Kings"];
    [bookListing setObject:kings2         forKey:@"2 Kings"];
    [bookListing setObject:chronicles1    forKey:@"1 Chronicles"];
    [bookListing setObject:chronicles2    forKey:@"2 Chronicles"];
    [bookListing setObject:ezra           forKey:@"Ezra"];
    [bookListing setObject:nehemiah       forKey:@"Nehemiah"];
    [bookListing setObject:esther         forKey:@"Esther"];
    [bookListing setObject:job            forKey:@"Job"];
    [bookListing setObject:psalms         forKey:@"Psalms"];
    [bookListing setObject:proverbs       forKey:@"Proverbs"];
    [bookListing setObject:ecclesiastes   forKey:@"Ecclesiastes"];
    [bookListing setObject:songofsolomon  forKey:@"Song of Solomon"];
    [bookListing setObject:isaiah         forKey:@"Isaiah"];
    [bookListing setObject:jeremiah       forKey:@"Jeremiah"];
    [bookListing setObject:lamentations   forKey:@"Lamentations"];
    [bookListing setObject:ezekiel        forKey:@"Ezekiel"];
    [bookListing setObject:daniel         forKey:@"Daniel"];
    [bookListing setObject:hosea          forKey:@"Hosea"];
    [bookListing setObject:joel           forKey:@"Joel"];
    [bookListing setObject:amos           forKey:@"Amos"];
    [bookListing setObject:obadiah        forKey:@"Obadiah"];
    [bookListing setObject:jonah          forKey:@"Jonah"];
    [bookListing setObject:micah          forKey:@"Micah"];
    [bookListing setObject:nahum          forKey:@"Nahum"];
    [bookListing setObject:habakkuk       forKey:@"Habakkuk"];
    [bookListing setObject:zephaniah      forKey:@"Zephaniah"];
    [bookListing setObject:haggai         forKey:@"Haggai"];
    [bookListing setObject:zechariah      forKey:@"Zechariah"];
    [bookListing setObject:malachi        forKey:@"Malachi"];
    [bookListing setObject:matthew        forKey:@"Matthew"];
    [bookListing setObject:mark           forKey:@"Mark"];
    [bookListing setObject:luke           forKey:@"Luke"];
    [bookListing setObject:john           forKey:@"John"];
    [bookListing setObject:acts           forKey:@"Acts"];
    [bookListing setObject:romans         forKey:@"Romans"];
    [bookListing setObject:corinthians1   forKey:@"1 Corinthians"];
    [bookListing setObject:corinthians2   forKey:@"2 Corinthians"];
    [bookListing setObject:galatians      forKey:@"Galatians"];
    [bookListing setObject:ephesians      forKey:@"Ephesians"];
    [bookListing setObject:philippians    forKey:@"Philippians"];
    [bookListing setObject:colossians     forKey:@"Colossians"];
    [bookListing setObject:thessalonians1 forKey:@"1 Thessalonians"];
    [bookListing setObject:thessalonians2 forKey:@"2 Thessalonians"];
    [bookListing setObject:timothy1       forKey:@"1 Timothy"];
    [bookListing setObject:timothy2       forKey:@"2 Timothy"];
    [bookListing setObject:titus          forKey:@"Titus"];
    [bookListing setObject:philemon       forKey:@"Philemon"];
    [bookListing setObject:hebrews        forKey:@"Hebrews"];
    [bookListing setObject:james          forKey:@"James"];
    [bookListing setObject:peter1         forKey:@"1 Peter"];
    [bookListing setObject:peter2         forKey:@"2 Peter"];
    [bookListing setObject:john1          forKey:@"1 John"];
    [bookListing setObject:john2          forKey:@"2 John"];
    [bookListing setObject:john3          forKey:@"3 John"];
    [bookListing setObject:jude           forKey:@"Jude"];
    [bookListing setObject:revelation     forKey:@"Revelation"];
    
    
    // Even though we are using a Dictionary above, keep this array so that rows in the Picker View
    // stay ordered according to the Biblical order
    bibleBookColumnList = [[NSArray alloc] initWithObjects:
        @"Genesis", @"Exodus", @"Leviticus", @"Numbers", @"Deuteronomy", @"Joshua",
        @"Judges", @"Ruth", @"1 Samuel", @"2 Samuel", @"1 Kings", @"2 Kings",
        @"1 Chronicles", @"2 Chronicles", @"Ezra", @"Nehemiah", @"Esther", @"Job",
        @"Psalms", @"Proverbs", @"Ecclesiastes", @"Song of Solomon", @"Isaiah", @"Jeremiah",
        @"Lamentations", @"Ezekiel", @"Daniel", @"Hosea", @"Joel", @"Amos", @"Obadiah",
        @"Jonah", @"Micah", @"Nahum", @"Habakkuk", @"Zephaniah", @"Haggai", @"Zechariah",
        @"Malachi", @"Matthew", @"Mark", @"Luke", @"John", @"Acts", @"Romans", @"1 Corinthians",
        @"2 Corinthians", @"Galatians", @"Ephesians", @"Philippians", @"Colossians",
        @"1 Thessalonians", @"2 Thessalonians", @"1 Timothy", @"2 Timothy", @"Titus",
        @"Philemon", @"Hebrews", @"James", @"1 Peter", @"2 Peter", @"1 John", @"2 John",
        @"3 John", @"Jude", @"Revelation", nil];
}

@end
