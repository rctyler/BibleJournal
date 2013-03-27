/*
 ***************************************************************************************
 *  FILE: SecondViewController.m
 *  PROJECT: SimpleBibleApp
 *
 *  DESCRIPTION: This file implements the SecondViewController class which is tied to
 *               the second view of the tab bar controller. It's purpose in this app is
 *               to save and load notes that the user writes for the passage selected
 *               by the FirstViewController class. When a user selects a bible book
 *               and chapter from the firstview that the tab bar controller points to,
 *               and then navigates to the second view, the passage is identified, and
 *               the user has the option to either load existing notes, or save their
 *               own notes to that passage. This uses the JSON protocol to store the notes
 *               in an organized and efficient manner (only requires one text file). 
 *               The FirstViewController class communicates with this class by upadating
 *               the values of the bookString and chapterString values for this class 
 *               depending on what the user selects in the first view of the tab
 *               controller
 *
 *  Created by Raymond Tyler on 3/8/13.
 *  Copyright (c) 2013 Raymond Tyler. All rights reserved.
 ***************************************************************************************
 */

#import "SecondViewController.h"

@implementation SecondViewController
@synthesize saveButton, loadButton, notesTextView, bookString, chapterString,
            notesLabel, errorLabel, firstTimeToLoadNotes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstTimeToLoadNotes = YES;
    [self setupJSONDictionary];
    notesLabel.text = [NSString stringWithFormat:@"     My Notes for %@ %@:",
                       bookString, chapterString];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // Update the notes Label to show the passage we are wanting to write notes for
    notesLabel.text = [NSString stringWithFormat:@"     My Notes for %@ %@:",
                       bookString, chapterString];
    
    // Clear the error label just in case, unless it is telling us about an initialization error
    if ([errorLabel.text rangeOfString:@"INIT"].location == NSNotFound)
    {
        errorLabel.text = @"";
    }
    
    if (![notesTextView.text isEqualToString:savedNote] && firstTimeToLoadNotes == NO)
    {
        errorLabel.text = @"* SAVE NOTES";
    }
    else
    {
        errorLabel.text = @"";
    }
    
    // Load existing notes, if any, unless the user has already typed notes in there
    if (firstTimeToLoadNotes == YES)
    {
        [self loadNotes];
        firstTimeToLoadNotes = NO;
        errorLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backgroundTouchedHideKeyboard:(id)sender
{
    [notesTextView resignFirstResponder];
    
    if ([notesTextView.text isEqualToString:@""] == YES)
    {
        notesTextView.text = @"Click here to add your notes...";
        [notesTextView setTextColor:[UIColor lightGrayColor]];
    }
}

/**
 *************************************************************************************
 *  Name: saveButtonClicked
 *************************************************************************************
 *  Description: This method is called whenever the save button is clicked. It will
 *               take the notes written in notesTextView area and save it to the
 *               merge it to a JSON file, overriting any existing saved for the
 *               passage selected by the user.
 *  @param   (id)sender : The object that triggered the saveButtonClicked event.
 *  @return  IBAction
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(IBAction)saveButtonClicked:(id)sender
{
    NSError* error = nil;
    
    // We are also using the error label to notify the user if they need to save their notes.
    // So clear that, upon saving them
    errorLabel.text = @"";
    
    // Initialie JSON Parser
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    
    // Get the files path to the notes.json file we are saving the JSON structure to
    NSArray *filePathList =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filePath = [filePathList objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:@"notes.json"];
    
    // Populate jsonString with the contents of the notes.json file
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    // Continue grabbing existing notes only if we haven't encountered in error up to this point.
    // Otherwise, notify the user that there was an error somewhere
    if (error == nil)
    {
        // Pass the jsonString to the JSON parser which returns a dictionary object
        NSDictionary *jsonObjects = [jsonParser objectWithString:jsonString error:&error];
    
        // Continue with parsing the JSON file only if we haven't encountered in error up to this 
        // point. Otherwise, notify the user that there was an error somewhere
        if (error == nil)
        {
            // Take the dictionary object, and overwrite the value pointed to by the keys:
            // bookString and chapterString. This is how the notes are saved and are accessed
            // NOTE: we need to check for the color of the text so we don't end of saving the
            //       placeholder accidently, but instead save a "blank" to the text file in
            //       the case that nothing is typed into the text area
            if (notesTextView.textColor != [UIColor lightGrayColor])
            {
                [[jsonObjects objectForKey:bookString] setObject:notesTextView.text
                                                      forKey:chapterString];
            }
            else
            {
                [[jsonObjects objectForKey:bookString] setObject:@""
                                                          forKey:chapterString];
            }
    
            // Now re-create the JSON structure with the updated dictionary and write to notes.json
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObjects
                                options:NSJSONWritingPrettyPrinted error:&error];
            
            // Continue writing to the notes.json file only if we haven't encountered in error up to
            // this point. Otherwise, notify the user that there was an error somewhere
            if (error == nil)
            {
                if ([errorLabel.text rangeOfString:@"INIT"].location == NSNotFound)
                {
                    errorLabel.text = @"";
                }
                
                [self writeToTextFile:jsonData];
            }
            else
            {
                errorLabel.text = [[NSString alloc] initWithFormat: @"Error %@ occurred on SAVE, please retry.", [error localizedDescription]];
            }
        }
        else
        {
            errorLabel.text = [[NSString alloc] initWithFormat: @"Error %@ occurred on SAVE, please retry.", [error localizedDescription]];
        }
    }
    else
    {
        errorLabel.text = [[NSString alloc] initWithFormat: @"Error %@ occurred on SAV, please retry.", [error localizedDescription]];
    }
}

/**
 *************************************************************************************
 *  Name: loadButtonClicked
 *************************************************************************************
 *  Description: This method is called whenever the load button is clicked. It calls
 *               the method loadNotes
 *  @param   (id)sender : The object that triggered the loadButtonClicked event.
 *  @return  IBAction
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(IBAction)loadButtonClicked:(id)sender
{
    [self loadNotes];
}

/**
 *************************************************************************************
 *  Name: loadNotes
 *************************************************************************************
 *  Description: This method takes the notes stored in the JSON file and display it on the
 *               the notesTextArea.
 *  @param   (id)sender : The object that triggered the loadButtonClicked event.
 *  @return  IBAction
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(void)loadNotes
{
    NSError *error;
    
    // We are also using the error label to notify the user if they need to save their notes.
    // So clear that, upon loading existing notes
    errorLabel.text = @"";
    
    // Initialie JSON Parser
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    
    // Get the files path to the notes.json file we are saving the JSON structure to
    NSArray *filePathList =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filePath = [filePathList objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:@"notes.json"];
    
    // Populate jsonString with the contents of the notes.json file
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    // Continue the load process only if we haven't encountered in error up to this point.
    // Otherwise, notify the user that there was an error somewhere
    if (error == nil)
    {
        // Create a dictionary object from the contents of the notes.json file
        NSDictionary *jsonObjects = [jsonParser objectWithString:jsonString error:&error];
    
        // Continue the load process only if we haven't encountered in error up to this point.
        // Otherwise, notify the user that there was an error somewhere
        if (error == nil)
        {
            // Only display the notes pointed to by the keys: booksString and chapterString
            NSString *notesToDisplay= [[jsonObjects objectForKey:bookString]
                                       objectForKey:chapterString];
            savedNote = notesToDisplay;
    
            //if (notesTextView.textColor == [UIColor lightGrayColor] || [loadButton isTouchInside])
            //{
                if ([notesToDisplay isEqualToString:@""])
                {
                    notesTextView.text = @"Click here to add your notes...";
                    [notesTextView setTextColor:[UIColor lightGrayColor]];
                }
                else
                {
                    notesTextView.text = notesToDisplay;
                    [notesTextView setTextColor:[UIColor blackColor]];
                }
            
                // Clear the error label just in case, unless it is telling us about an
                // initialization error
                if ([errorLabel.text rangeOfString:@"INIT"].location == NSNotFound)
                {
                    errorLabel.text = @"";
                }
            //}
        }
        else
        {
            errorLabel.text = [[NSString alloc] initWithFormat: @"Error %@ occurred on LOAD, please retry.", [error localizedDescription]];
        }
    }
    else
    {
        errorLabel.text = [[NSString alloc] initWithFormat: @"Error %@ occurred on LOAD, please retry.", [error localizedDescription]];
    }
}

/**
 *************************************************************************************
 *  Name: setupJSONDictionary
 *************************************************************************************
 *  Description: This method will initialize the notes.json file that we are saving
 *               our notes to, and it sets up a 2-level dictionary that will be used
 *               to create the JSON structure.
 *  @param   none
 *  @return  void
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(void)setupJSONDictionary
{
    NSError *error;
    
    NSArray *paths =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    fileName = [NSString stringWithFormat:@"%@/notes.json",
                          documentsDirectory];
    
    // This dicitonary will be used to form the JSON file that we will be reading from
    // and writing to
    bookListing = [NSMutableDictionary dictionary];
    
    // Create the 2nd-level dictionaries
    
    NSMutableDictionary *genesis = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", @"", @"41", @"", @"42", @"", @"43", @"", @"44", @"", @"45", @"", @"46", @"", @"47", @"", @"48", @"", @"49", @"", @"50", nil];
    NSMutableDictionary *exodus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", nil];
    NSMutableDictionary *leviticus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", nil];
    NSMutableDictionary *numbers = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", nil];
    NSMutableDictionary *deuteronomy = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                            @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", nil];
    NSMutableDictionary *joshua = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", nil];
    NSMutableDictionary *judges = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", nil];
    NSMutableDictionary *ruth = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", nil];
    NSMutableDictionary *samuel1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", nil];
    NSMutableDictionary *samuel2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", nil];
    NSMutableDictionary *kings1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", nil];
    NSMutableDictionary *kings2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", nil];
    NSMutableDictionary *chronicles1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                            @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", nil];
    NSMutableDictionary *chronicles2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                            @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", nil];
    NSMutableDictionary *ezra = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", nil];
    NSMutableDictionary *nehemiah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", nil];
    NSMutableDictionary *esther = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", nil];
    NSMutableDictionary *job = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                    @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", @"", @"41", @"", @"42", nil];
    NSMutableDictionary *psalms = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", @"", @"41", @"", @"42", @"", @"43", @"", @"44", @"", @"45", @"", @"46", @"", @"47", @"", @"48", @"", @"49", @"", @"50", @"", @"51", @"", @"52", @"", @"53", @"", @"54", @"", @"55", @"", @"56", @"", @"57", @"", @"58", @"", @"59", @"", @"60", @"", @"61", @"", @"62", @"", @"63", @"", @"64", @"", @"65", @"", @"66", @"", @"67", @"", @"68", @"", @"69", @"", @"70", @"", @"71", @"", @"72", @"", @"73", @"", @"74", @"", @"75", @"", @"76", @"", @"77", @"", @"78", @"", @"79", @"", @"80", @"", @"81", @"", @"82", @"", @"83", @"", @"84", @"", @"85", @"", @"86", @"", @"87", @"", @"88", @"", @"89", @"", @"90", @"", @"91", @"", @"92", @"", @"93", @"", @"94", @"", @"95", @"", @"96", @"", @"97", @"", @"98", @"", @"99", @"", @"100",@"", @"101", @"", @"102", @"", @"103", @"", @"104", @"", @"105", @"", @"106", @"", @"107", @"", @"108", @"", @"109", @"", @"110", @"", @"111", @"", @"112", @"", @"113", @"", @"114", @"", @"115", @"", @"116", @"", @"117", @"", @"118", @"", @"119", @"", @"120", @"", @"121", @"", @"122", @"", @"123", @"", @"124", @"", @"125", @"", @"126", @"", @"127", @"", @"128", @"", @"129", @"", @"130", @"", @"131", @"", @"132", @"", @"133", @"", @"134", @"", @"135", @"", @"136", @"", @"137", @"", @"138", @"", @"139", @"", @"140", @"", @"141", @"", @"142", @"", @"143", @"", @"144", @"", @"145", @"", @"146", @"", @"147", @"", @"148", @"", @"149", @"", @"150",  nil];
    NSMutableDictionary *proverbs = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", nil];
    NSMutableDictionary *ecclesiastes = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                             @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", nil];
    NSMutableDictionary *songofsolomon = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                              @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", nil];
    NSMutableDictionary *isaiah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", @"", @"41", @"", @"42", @"", @"43", @"", @"44", @"", @"45", @"", @"46", @"", @"47", @"", @"48", @"", @"49", @"", @"50", @"", @"51", @"", @"52", @"", @"53", @"", @"54", @"", @"55", @"", @"56", @"", @"57", @"", @"58", @"", @"59", @"", @"60", @"", @"61", @"", @"62", @"", @"63", @"", @"64", @"", @"65", @"", @"66", nil];
    NSMutableDictionary *jeremiah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", @"", @"41", @"", @"42", @"", @"43", @"", @"44", @"", @"45", @"", @"46", @"", @"47", @"", @"48", @"", @"49", @"", @"50", @"", @"51", @"", @"52", nil];
    NSMutableDictionary *lamentations = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                             @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", nil];
    NSMutableDictionary *ezekiel = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", @"", @"29", @"", @"30", @"", @"31", @"", @"32", @"", @"33", @"", @"34", @"", @"35", @"", @"36", @"", @"37", @"", @"38", @"", @"39", @"", @"40", @"", @"41", @"", @"42", @"", @"43", @"", @"44", @"", @"45", @"", @"46", @"", @"47", @"", @"48", nil];
    NSMutableDictionary *daniel = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", nil];
    NSMutableDictionary *hosea = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", nil];
    NSMutableDictionary *joel = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *amos = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", nil];
    NSMutableDictionary *obadiah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", nil];
    NSMutableDictionary *jonah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", @"", @"4", nil];
    NSMutableDictionary *micah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", nil];
    NSMutableDictionary *nahum = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *habakkuk = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *zephaniah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                          @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *haggai = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", nil];
    NSMutableDictionary *zechariah = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                          @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", nil];
    NSMutableDictionary *malachi = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", nil];
    NSMutableDictionary *matthew = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", nil];
    NSMutableDictionary *mark = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", nil];
    NSMutableDictionary *luke = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", nil];
    NSMutableDictionary *john = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", nil];
    NSMutableDictionary *acts = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22", @"", @"23", @"", @"24", @"", @"25", @"", @"26", @"", @"27", @"", @"28", nil];
    NSMutableDictionary *romans = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", nil];
    NSMutableDictionary *corinthians1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                             @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", nil];
    NSMutableDictionary *corinthians2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                             @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", nil];
    NSMutableDictionary *galatians = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                          @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", nil];
    NSMutableDictionary *ephesians = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                          @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", nil];
    NSMutableDictionary *philippians = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                            @"", @"1", @"", @"2", @"", @"3", @"", @"4", nil];
    NSMutableDictionary *colossians = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                           @"", @"1", @"", @"2", @"", @"3", @"", @"4", nil];
    NSMutableDictionary *thessalonians1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                               @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", nil];
    NSMutableDictionary *thessalonians2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                               @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *timothy1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", nil];
    NSMutableDictionary *timothy2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", @"", @"2", @"", @"3", @"", @"4", nil];
    NSMutableDictionary *titus = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *philemon = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                         @"", @"1", nil];
    NSMutableDictionary *hebrews = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", nil];
    NSMutableDictionary *james = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", nil];
    NSMutableDictionary *peter1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", nil];
    NSMutableDictionary *peter2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                       @"", @"1", @"", @"2", @"", @"3", nil];
    NSMutableDictionary *john1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", nil];
    NSMutableDictionary *john2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", nil];
    NSMutableDictionary *john3 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      @"", @"1", nil];
    NSMutableDictionary *jude = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                     @"", @"1", nil];
    NSMutableDictionary *revelation = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        @"", @"1", @"", @"2", @"", @"3", @"", @"4", @"", @"5", @"", @"6", @"", @"7", @"", @"8", @"", @"9", @"", @"10", @"", @"11", @"", @"12", @"", @"13", @"", @"14", @"", @"15", @"", @"16", @"", @"17", @"", @"18", @"", @"19", @"", @"20", @"", @"21", @"", @"22",
                           nil];
    
    // Create the 1st-level dictionar, and place the 2nd-level dictionaries as the values
    // corresponding to each key in the 1st-level dictionary 
    
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
    
    // Now re-create the JSON structure with the updated dictionary and write to notes.json
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:bookListing
                                            options:NSJSONWritingPrettyPrinted error:&error];
    
    // Check for errors on wfsp''''''''''''''''''''''''''''''''''''''''''''''''''''''p
    if (error == nil)
    {
        if ( ! [[NSFileManager defaultManager] fileExistsAtPath:fileName])
        {
            [self writeToTextFile:jsonData];
        }
    }
    else
    {
        errorLabel.text = [[NSString alloc] initWithFormat: @"Error %@ occurred on INIT, close app and rery", [error localizedDescription]];
    }
}

/**
 *************************************************************************************
 *  Name: writeToTextFile
 *************************************************************************************
 *  Description: This function writes the JSON data structure to the notes.json file
 *  @param   (NSData *)data : the data we want to write to the notes.json file
 *  @return  void
 *  @warning none
 *  @bug     none
 *************************************************************************************
 */
-(void)writeToTextFile:(NSData *)data
{
    //save content to the documents directory
    NSString *stringToWrite = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [stringToWrite writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([notesTextView.text isEqualToString:@"Click here to add your notes..."])
    {
        notesTextView.text = @"";
        [notesTextView setTextColor:[UIColor blackColor]];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (![notesTextView.text isEqualToString:savedNote])
    {
        errorLabel.text = @"* SAVE NOTES";
    }
    else
    {
        errorLabel.text = @"";
    }
}

@end
