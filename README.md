## README: Scraping for a Job

### UPDATE: July 22, 2021
Some updates to the packages rvest and quanteda broke this script. A few minor changes and a new package import later, and everything is working again. R and RStudio versions have been updated as well.

### R. Holley, September 17, 2020

One afternoon, I decided to ignore my coursework projects and job searching, and threw together this script instead. There's a [full report here(html page on gh-pages)](https://mementomakomori.github.io/ScrapingPractice/). If you're interested in it, here's the basics.

### INPUT
No dataset is necessary to run this code; it is a scraper for job posts on Indeed.com using the search term 'data scientist' with the filter experience: entry level. Depending on how much you want to scrape, it could take a while. I will have to update it if Indeed changes their URL naming schema.

### THE SCRIPT
scraping.R takes the aforementioned job posts and aggregates the job descriptions into a corpora for text analysis. It is stream-of-consciousness programming, and so not terribly efficient. It was, however, kind of fun, because I made this entirely for myself.

### INFO 
R version 3.4.1 (2021-05-18) -- "Camp Pontanezen"
Copyright (C) 2021 The R Foundation for Statistical Computing

RStudio Version 1.4.1717

R packages:
* rvest
* stringi
* quanteda
* **quanteda.textstats**
* stopwords
* plyr
* ggplot2
* extrafont

### FILES
* scraping.R
* README.md
* index.html
* index_cache folder
* index_files folder
* LICENSE 

### THANK YOU
[This page from Scraping Bee](https://www.scrapingbee.com/blog/web-scraping-r/) got me straight to the basics of webscraping with R, and I reviewed Xpath syntax on [w3schools.com](https://www.w3schools.com/xml/xpath_intro.asp).