iOSVimeoURLFetcher
==================

iOS SDK / Objective C

Convert a Vimeo website URL into a URL that's playable in MPMoviePlayerViewController.

When you watch a Vimeo video on the website, it generates a temporary URL to its CDN for playback. This URL quickly exires.

This class will:

* Scrape the provided Vimeo HTML page for the URL to the JSON metadata
* Parse the JSON and get the HLS stream

Notes:

* It doesn't instantiate a temporary UIWebView, so it should be faster than other solutions
* It runs asynchronously
* It's currently non-ARC
* Don't store and reuse the fetched URL anywhere, as it will quickly become invalid
* The scraping method used is currently pretty brittle and dumb, so it's liable to break if the source format changes

HOW TO USE
----

* Add VimeoURLFetcher.h and VimeoURLFetcher.c to your project.

* Import the header file:

```objective-c
	#import "VimeoURLFetcher.h"
```

* Declare that your UIViewController, or whatever, adopts the VimeoURLFetcherDelegate protocol:

```objective-c
	YourViewController<VimeoURLFetcherDelegate>
```

* Implement vimeoURLFetcherFinished in your implementation file. If the lookup failed then .fetchedURL will be nil and there will likely be error information in .error. The original URL will be in .orignalURL. For example, to play a Vimeo video back in iOS's MPMoviePlayerViewController:

```objective-c
	- (void)vimeoURLFetcherFinished:(VimeoURLFetcher *)convertor
	{
	    if (convertor.error == nil && convertor.fetchedURL != nil)
	    {
	    	NSLog(@"Original URL: %@", convertor.originalURL);

	        MPMoviePlayerViewController *newMoviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:convertor.fetchedURL]];
	        [self presentMoviePlayerViewControllerAnimated:newMoviePlayer];
	        [newMoviePlayer release];
	    }
	}
```

* Then whenever you want to play a video:

```objective-c
 	VimeoURLFetcher *vimeoURLFetcher = [[VimeoURLFetcher alloc] init];
    vimeoURLFetcher.delegate = self;
    [vimeoURLFetcher getRawVimeoURLFromURL:@"http://vimeo.com/60850548"];
```

