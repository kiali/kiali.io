## Kiali.io 
This repository contains the source code for https://kiali.io website.

The website is written in [markdown](https://guides.github.com/features/mastering-markdown/), generated using [Hugo](https://gohugo.io/), and hosted on GitHub.


## Install Hugo

On Fedora: `sudo dnf install hugo`

On Mac: `brew install hugo`

Or see the Hugo installation instructions here: https://gohugo.io/getting-started/installing/

## Start local server

Hugo has a live `serve` command that runs a small, lightweight web server on your computer so you can test your site locally without needing to upload it anywhere.  As you make changes to files in your project, it will rebuild your project and reload the browser for you.

```
$ hugo serve  

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
Press Ctrl+C to stop
```

It should live reload. If not, you may have to restart the server.

## Project directory structure

├── [archetypes]- Directory where you define the content, tags, categories, etc.
├── [content] - Directory that contains the content of the site.
│   ├── [api]
│   ├── [contribute]
│   ├── [features]
│   ├── [gettingstarted]
├── [data] - Directory that contains site data such as localization configuration.
├── [layouts] - Directory that contains Go HTML/template library used to template and format the site.
├── [public] - (Doesn't exist until generated) Directory that contains the generated content for the site.  Should be part of your git.ignore file.
├── [scripts]
├── [static] - Directory for any static files to be compiled into the web site (style sheets, JavaScript, images, robots.txt, fav icons, etc.).
├── [themes] - Directory that contains the site theme.  Themes override layouts.
├── Makefile
├── config.toml - Main configuration file, where you define the web site title, URL, language, etc.
├── README.md (This file)

## Add a new feature to be listed
`hugo new features/my-feature.md`

In the header, fill-in either the `youTubeID` or `image`, the template will use the YouTube ID if any and ignore `image`. The `youTubeId` looks like `NcxOapR7D0I`.
If you have an image rather than an YouTube video, add the image in: static/images/features (use the same name as the Markdown file) and use: `features/my-feature.png` as the value for the `image` header

## To generate the Swagger documentation
Run the following:
`sh scripts/build-swagger.sh`
