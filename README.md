iOSVimeoURLFetcher
==================

iOS SDK / Objective C

Convert a Vimeo website URL into a URL that's playable in MPMoviePlayerViewController.

When you watch a Vimeo video on the website, it generates a temporary URL to its CDN for playback. This URL quickly exires.

This class will:

* Scrape the provided Vimeo HTML page for the URL to the JSON metadata
* Parse the JSON and get the HD H.264 stream

Notes:

* It doesn't instantiate a temporary UIWebView, so it should be faster than other solutions. 
* It runs asynchronously.
* It's currently non-ARC.
* Don't store and reuse the fetched URL anywhere, as it will quickly become invalid
* The scraping method used is currently pretty brittle and dumb, so it's liable to break if the source format changes.

HOW TO USE
----

1. Add VimeoURLFetcher.h and VimeoURLFetcher.c to your project.

2. #import "VimeoURLFetcher.h"

3. Declare that your UIViewController, or whatever, adopts the VimeoURLFetcherDelegate protocl

<pre>
<code>
	YourViewController<VimeoURLFetcherDelegate>
</code>
</pre>

4. Implement vimeoURLFetcherFinished in your implementation file. If the lookup failed then .fetchedURL will be nil and there will likely be error information in .error. The original URL will be in .orignalURL.

For example, to play a Vimeo video back in iOS's MPMoviePlayerViewController:

<pre>
<code>
	- (void)vimeoURLFetcherFinished:(VimeoURLFetcher *)convertor
	{
	    if (convertor.error == nil && convertor.fetchedURL != nil)
	    {
	    	NSLog(@"Original URL: %@", convertor.originaURL);

	        MPMoviePlayerViewController *newMoviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:convertor.fetchedURL]];
	        [newMoviePlayer.moviePlayer prepareToPlay];
	        [self presentMoviePlayerViewControllerAnimated:newMoviePlayer];
	        [newMoviePlayer release];
	    }
	}
</code>
</pre>

5. Then whenever you want to play a video:

<pre>
<code>
 	VimeoURLFetcher *vimeoURLFetcher = [[VimeoURLFetcher alloc] init];
    vimeoURLFetcher.delegate = self;
    [vimeoURLFetcher getRawVimeoURLFromURL:@"http://vimeo.com/60850548"];
</code>
</pre>

