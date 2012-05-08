//
//  LibraryViewController.m
//
//  Created by Bart Termorshuizen on 6/17/11.
//  Modified/Adapted for BakerShelf by Andrew Krowczyk @nin9creative on 2/18/2012
//
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//  
//  Redistributions of source code must retain the above copyright notice, this list of 
//  conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of 
//  conditions and the following disclaimer in the documentation and/or other materials 
//  provided with the distribution.
//  Neither the name of the Baker Framework nor the names of its contributors may be used to 
//  endorse or promote products derived from this software without specific prior written 
//  permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import  "LibraryViewController.h"
#include "IssueViewController.h"
#include "BakerAppDelegate.h"

#import "JSON.h"


NSString *DidFinishDownloading = @"LibraryViewDidFinishDowloading";
NSString *DidFailDownloading = @"LibraryViewDidFailDowloading";

@implementation LibraryViewController


@synthesize numberOfIssuesShown;
@synthesize numberOfPagesShown;


//Sync button
-(IBAction) sync:(id) sender
{
    [self loadIssues];
}

//Subscribe button
-(IBAction) subscribe:(id) sender
{
    NSLog(@"Subscribe button pushed");
	UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Subscribe to Magazine" message: @"Subscription action!" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[someError show];
	[someError release];
}


-(void) layout:(IssueViewController *)ivc setOrientation:(UIInterfaceOrientation) interfaceOrientation 
{
    
    if (interfaceOrientation != UIInterfaceOrientationLandscapeLeft &&
        interfaceOrientation != UIInterfaceOrientationLandscapeRight)
    {
        // determine position to place the ivc based on 4 views per page 
        numberOfIssuesShown ++; // note that this may be confusing - just avoiding '+1' everywhere in this method
        
        // position indicates position on a page
        NSInteger position = (numberOfIssuesShown)%4;
        if (position == 0) position = 4;
        
        NSInteger pageWidth = scrollView.frame.size.width;
        NSInteger pageHeight = scrollView.frame.size.height;
        NSLog(@"pageWidth=%d, pageHeight=%d", pageWidth, pageHeight);
        
        // Scrollview background repeat
        //[scrollView setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"bg.png"]]];
        
        if (position == 1) // new page situation
        {
            // extend the scrollview's contentsize height with 1 page
            [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, pageHeight*(numberOfPagesShown+1))];
            numberOfPagesShown++;
        }
        
        // 4 ivc's on a page as follows - numbers below indicate the value of the position variable
        // 1    2
        // 3    4
        
        NSInteger row = 0;
        NSInteger col = 0;
        if (position > 2) row = 1;
        if (position == 2 || position == 4) col = 1;
        
        UIView * ivcView = [ivc view];
        
        CGRect frame = CGRectMake(col*pageWidth/2 + 20,
                                  row*pageHeight/2 + (numberOfPagesShown-1)*pageHeight + 20,
                                  ivcView.frame.size.width, 
                                  ivcView.frame.size.height
                                  );
        [ivcView setFrame:frame];   
        
    } else {
        
        // Show horizontally
        NSLog(@"HORIZONTAL!!!!!!!!");
        
        // determine position to place the ivc based on 6 views per page 
        numberOfIssuesShown ++; // note that this may be confusing - just avoiding '+1' everywhere in this method
        
        
        NSLog(@"numberOfIssuesShown=%d", numberOfIssuesShown);
        
        // position indicates position on a page
        NSInteger position = (numberOfIssuesShown)%6;
        if (position == 0) position = 6;
        
        
        NSLog(@"position=%d", position);
        
        
        NSInteger pageWidth = scrollView.frame.size.width;
        NSInteger pageHeight = scrollView.frame.size.height;
        
        
        if (position == 1) // new page situation
        {
            // extend the scrollview's contentsize height with 1 page
            [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, pageHeight*(numberOfPagesShown+1))];
            numberOfPagesShown++;
        }
        
        // 6 ivc's on a page as follows - numbers below indicate the value of the position variable
        // 1    2   3
        // 4    5   6
        
        NSInteger row = 0;
        NSInteger col = 0;
        //const NSInteger w = 320;
        const NSInteger h = 304;
        
        
        if (position > 3) row = 1;
        if (position == 2 || position == 5) col = 1;
        if (position == 3 || position == 6) col = 2;
        
        
        UIView * ivcView = [ivc view];
        
        
        NSLog(@"col0=%d, row0=%d", col, row);
        NSLog(@"pageWidth=%d, pageHeight=%d", pageWidth, pageHeight);
        
        
        // set col position
        switch (col) {
            case  1:
                //col = pageWidth/2 - 140;
                col = pageWidth/2 - 165;
                break;
            case  2:
                //col = pageWidth - 300;
                col = pageWidth - 330;
                break;
        }
        
        // set row position
        switch (row) {
            case  1:
                row = pageHeight/2 - h/2 + 10;
                break;
        }
        
        
        CGRect frame = CGRectMake(col,
                                  row + ((numberOfPagesShown-1) * pageHeight),
                                  ivcView.frame.size.width, 
                                  ivcView.frame.size.height
                                  );
        
        NSLog(@"col=%d, row=%d", col, row + (numberOfPagesShown-1)*pageHeight + 20);
        
        [ivcView setFrame:frame];        
    }
    
    
    return;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        publisher = [[Publisher alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)updateShelf:(UIInterfaceOrientation)interfaceOrientation
{
    numberOfIssuesShown = 0;
    numberOfPagesShown = 0; 
    
    
    // iterate over the issues and create the issueview controllers and issues
    issueViewControllers = [[NSMutableArray alloc] initWithCapacity:[publisher numberOfIssues]];
    int i = 0;
    while (i < [publisher numberOfIssues]){
        // instantiate a issueviewcontroller object
        IssueViewController *ivc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:[NSBundle mainBundle]];
        // register the publisher and index of issue
        [ivc setPublisher: publisher];
        [ivc setIndex: i];
        
        [issueViewControllers addObject:ivc];
        
        // layout the ivc and adapt the scroll view if necessary
        [self layout:ivc setOrientation:interfaceOrientation];
        
        [scrollView addSubview:[ivc view]];
        
        [ivc release];
        i++;
    }
}


#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
     [super viewDidLoad];
    
    if([publisher isReady]) {
        [self updateShelf:1];
    } 
    else {
        [self loadIssues];
    }
   
    //Library background
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    
}

-(void)loadIssues {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherReady:) name:PublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherFailed:) name:PublisherFailedUpdateNotification object:publisher];
    [publisher getIssuesList];    
}

-(void)publisherReady:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherFailedUpdateNotification object:publisher];
    [self updateShelf:1];
}

-(void)publisherFailed:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherFailedUpdateNotification object:publisher];
    NSLog(@"%@",not);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Cannot get issues from publisher server."
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    for (IssueViewController *ivc in issueViewControllers) [ivc release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    [shelfToolBar sizeToFit];
    //shelfToolBar.frame = CGRectMake(0, 0, shelfToolBar.frame.size.width, shelfToolBar.frame.size.height);
    
    // Update the size/position of some objects
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        scrollView.frame = CGRectMake(0, 239, 1024, 785);
		shelfImage.frame = CGRectMake(0, 44, 1024, 195);
        shelfTitle.frame = CGRectMake(228, 0, shelfTitle.frame.size.width, shelfTitle.frame.size.height);
    }
    else
    {
        scrollView.frame = CGRectMake(0, 239, 768, 785);
		shelfImage.frame = CGRectMake(0, 44, 768, 195);
        shelfTitle.frame = CGRectMake(100, 0, shelfTitle.frame.size.width, shelfTitle.frame.size.height);
    }
    
    
    // Clear existing views from the content
    for (UIView *view in scrollView.subviews)
    {
        if (![view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
    }
    
    // Update issues view
    [self updateShelf:toInterfaceOrientation];
}

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *dnlIssue = dnl.issue;
    NSLog(@"Issue downloaded: %@", dnlIssue); // should be the same as nkIssue
    NSString *contentPath = [publisher downloadPathForIssue:dnlIssue];
    NSLog(@"File is being unzipped to %@",contentPath);
    
    [SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:contentPath];
    if (publisher){

        // update the Newsstand icon
        UIImage *img = [publisher coverImageForIssue:dnlIssue];
        if(img) {
            [[UIApplication sharedApplication] setNewsstandIconImage:img]; 
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishDownloading object:dnlIssue];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *dnlIssue = dnl.issue;
    [[NSNotificationCenter defaultCenter] postNotificationName:DidFailDownloading object:dnlIssue];
}
@end
