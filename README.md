## README: Scraping for a Job
### R. Holley, September 17, 2020

One afternoon, I decided to ignore my pressing need to apply for jobs, and threw together this script instead. There's a full report (html page on gh-pages). If you're interested in it, here's the basics.

### INPUT
Unless Indeed.com changes their url schema, no dataset is necessary to run this code; it is a scraper for job posts on Indeed.com using the search term 'data scientist' with the filter experience: entry level. Depending on how much you want to scrape, it could take a while.

### THE SCRIPT
scraping.R takes the aforementioned job posts and aggregates the job descriptions into a corpora for text analysis. It is stream-of-consciousness programming, and so not terribly efficient. It was, however, kind of fun, because I made this entirely for myself.

### INFO 
R version 3.6.2 (2019-12-12) -- "Dark and Stormy Night"
Copyright (C) 2019 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64 (64-bit)

RStudio Version 1.1.463

R packages:
* Rcrawler
* rvest
* stringi
* quanteda
* stopwords
* ggplot2
* extrafont

### FILES
* scraping.R
* README.md
* index.html

