## Install Hugo

On Ferdora
```sudo dnf install hugo```

On Mac:
```brew install hugo```

Or see instructions here: https://gohugo.io/getting-started/installing/

## Start local server

```$ hugo serve

                   | EN
+------------------+-----+
  Pages            |  12
  Paginator pages  |   0
  Non-page files   |   0
  Static files     | 804
  Processed images |   0
  Aliases          |   0
  Sitemaps         |   1
  Cleaned          |   0

Total in 4798 ms
Watching for changes in /home/theute/Projects/Kiali/kiali.io/{content,data,layouts,static,themes}
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop```

It should live reload. I sometimes had to restart the server though...

## Add a new feature to be listed
```hugo new features/my-feature.md```

In the header, fill-in either the `youTubeID` or `image`, the template will use the YouTube id if any and ignore `image`. The `youTubeId` looks like `NcxOapR7D0I`.
If you have an image rather than an YouTube video, add the image in: static/images/features (use the same name as the Markdown file) and use: `features/my-feature.png` as the value for the `image` header
