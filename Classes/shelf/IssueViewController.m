//
//  IssueViewController.m
//
//  Created by Bart Termorshuizen on 6/18/11.
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

#import "IssueViewController.h"
#import "BakerAppDelegate.h"
#import "BakerViewController.h"
#import "SSZipArchive.h"

NSString *LibraryViewDidFinishDownloading = @"LibraryViewDidFinishDowloading";
NSString *LibraryViewDidFailDownloading = @"LibraryViewDidFailDowloading";

@implementation IssueViewController

@synthesize publisher, index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect frame = issueView.frame;                    
    [[self view] setFrame:frame];
    
    
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NSString* issueTitle=[publisher titleOfIssueAtIndex:index];
    nkIssue = [nkLib issueWithName:issueTitle];
    
    [labelView setText:[[self publisher] titleOfIssueAtIndex:[self index]]];
    [descriptionView setText:[[self publisher] descriptionOfIssueAtIndex:[self index]]];
    
    coverView.image=nil; // reset image as it will be retrieved asychronously
    [publisher setCoverOfIssueAtIndex:index completionBlock:^(UIImage *img) {
        dispatch_async(dispatch_get_main_queue(), ^{
            coverView.image=img;
        });
    }];
    //
    
    [progressView setHidden:YES];
    
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        [buttonView setTitle:@"Archive" forState:UIControlStateNormal];
    } 
    else if(nkIssue.status==NKIssueContentStatusDownloading) {
        [buttonView setTitle:@"Wait..." forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LibraryViewDidFinishDownloading:) name:LibraryViewDidFinishDownloading object:nkIssue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LibraryViewDidFailDownloading:) name:LibraryViewDidFailDownloading object:nkIssue];
    } 
    else {
        [buttonView setTitle:@"Download" forState:UIControlStateNormal];
        
    }
    return;
}

- (void)LibraryViewDidFinishDownloading:(NSNotification*)not
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LibraryViewDidFinishDownloading object:nkIssue];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LibraryViewDidFailDownloading object:nkIssue];
    [buttonView setTitle:@"Archive" forState:UIControlStateNormal];
}

- (void)LibraryViewDidFailDownloading:(NSNotification*)not
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LibraryViewDidFinishDownloading object:nkIssue];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LibraryViewDidFailDownloading object:nkIssue];
    [buttonView setTitle:@"Download" forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(IBAction) btnClicked:(id) sender {
    
    if  (nkIssue.status==NKIssueContentStatusDownloading){
        // still downloading
        [buttonView setTitle:@"Wait..." forState:UIControlStateNormal];
    }
    else if (nkIssue.status==NKIssueContentStatusNone){
        // start download
        NSURL *downloadURL = [publisher contentURLForIssueWithName:nkIssue.name];
        if(!downloadURL) return;
        NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
        NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:req];
        [assetDownload downloadWithDelegate:self];
        [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:index],@"Index",
                                    nil]];
    }
    else if (nkIssue.status==NKIssueContentStatusAvailable){
        // archive
        UIAlertView *updateAlert = [[UIAlertView alloc] 
                                    initWithTitle: @"Are you sure you want to archive this item?"
                                    message: @"This item will be removed from your device. You may download it at anytime for free."
                                    delegate: self
                                    cancelButtonTitle: @"Cancel"
                                    otherButtonTitles:@"Archive",nil];
        [updateAlert show];
        [updateAlert release];
    }
}

-(IBAction) btnRead:(id) sender{
    if (nkIssue.status == NKIssueContentStatusAvailable) // issue is downloaded
    {       
        NSLog(@"IssueViewController - Opening BakerViewController");  
        BakerAppDelegate *appDelegate = (BakerAppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* navigationController = [appDelegate navigationController];

        BakerViewController * bvc = [BakerViewController alloc];
        
        [bvc initWithMaterial:nkIssue];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 0.50];
        
        //Hook To MainView
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:navigationController.view cache:YES];
        
		[navigationController popViewControllerAnimated:YES];
        [navigationController pushViewController:(UIViewController*)bvc animated:NO];    
        [navigationController setToolbarHidden:YES animated:NO];
        [navigationController setNavigationBarHidden:YES];
        
        [bvc release];
        
        [UIView commitAnimations];            
    }
    else // issue is not downloaded 
    {
        NSLog(@"Cannot read");        
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSLog(@"Archiving %@",nkIssue);
        nkIssue = [publisher removeIssueAtIndex:[self index]];
        [buttonView setTitle:@"Download" forState:UIControlStateNormal];
        [progressView setHidden:YES];
    }
}

#pragma mark - NSURLConnectionDownloadDelegate


-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [progressView setHidden:NO];
    progressView.progress=1.f*totalBytesWritten/expectedTotalBytes;   
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];    
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    [progressView setHidden:YES];
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *dnlIssue = dnl.issue;
    NSLog(@"Issue downloaded: %@", dnlIssue); // should be the same as nkIssue
    NSString *contentPath = [publisher downloadPathForIssue:nkIssue];
    NSLog(@"File is being unzipped to %@",contentPath);

    [SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:contentPath];
    // update the Newsstand icon
    UIImage *img = [publisher coverImageForIssue:nkIssue];
    if(img) {
        [[UIApplication sharedApplication] setNewsstandIconImage:img]; 
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
    [buttonView setTitle:@"Archive" forState:UIControlStateNormal];
}

@end
