---
title: "README"
author: "R. Holley"
date: "September 17, 2020"
output: html_document
---
## Scraping for a Job
### Intro

One day (today), someone (me) realized they were pretty bored scrolling through job post after job post. You know how it is. *Why does this say 'entry-level' but requires 5 years experience? 5 years experience in a program that is proprietary to this company? Who actually writes these things?*

Anyway... it's a slog. And you know how the old programming saying goes, 'why do something by hand in 3 minutes that I could spend 3 hours writing a program to do for me!' That is a saying, right?

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo=TRUE, cache=TRUE, message=FALSE, warning = 'hide', results=FALSE)
```

Here's the deal: **I want to figure out which skills I should be focusing on to prepare for a data science career.** There are a lot of tools out there, but R is already my bread and butter. What should be the, um, cheese, to add to my bread and butter and make a delicious grilled cheese! I'm going to scrape a bunch of job listings and aggregate the descriptions. Hopefully I'll identify a major tool or skill that I can focus on learning. Here's the libraries I'll use.

```{r libraries}
library(Rcrawler)
library(rvest)
library(stringi)
library(quanteda)
library(stopwords)
library(ggplot2)
library(extrafont)
```

### Scraping

After a cursory glance at source pages for Indeed.com and Linkedin, I've decided to scrape from Indeed. It seems a bit simpler to me, but then again I don't know much about web design.

Indeed lists 15 jobs per page, in a left pane. Each job tile in the list has a 'job key' (attribute *data-jk* of the job tile's *<div>* element) that is used to generate the url for each individual posting. The right pane is an embed (not in the page's source) of the individual post, with the full job description. I want to scrape that job description, but to automate it I'll need to get the job keys from the left pane.
The search term 'data scientist' and filter 'experience level: entry level' are reflected in the url. I'm only scraping the first 150 results, because the relevance to the search term decreases along the results. The first bit of code, generating the urls I want to scrape, could be easily changed to allow for more results or different filters.

Note 1: this is not exactly reproducible, obviously because job listings frequently change. Indeed.com also seemed to prioritze results near my location, despite me not including a specific location search filter.

Note 2: The ContentScraper function I used from the Rcrawler package could take a while to run depending on how many pages you're scraping.

```{r scraping, warning=FALSE}
## the pages I want to scrape
list_pages <- paste0("https://www.indeed.com/jobs?q=data%20scientist&explvl=entry_level&start=", seq.int(0,135,15))
listHTML <- lapply(X=list_pages, FUN=read_html) %>% lapply(FUN=html_nodes, xpath="//@data-jk")

## job keys (data-jk) combine with the frame url to bring up the full job descriptions
jobIDs <- lapply(X=listHTML, FUN=stri_split_fixed, pattern="\"") %>% unlist()
jobIDs <- jobIDs[seq.int(2, length(jobIDs), 3)]
job_frames <- paste0("https://www.indeed.com/viewjob?viewtype=embedded&jk=", jobIDs)

summ_text <- ContentScraper(job_frames, XpathPatterns = "//div[@id='jobDescriptionText']")
```

It took me a bit of time to scan the page source and figure out what exactly I was looking for, but after that it was pretty straightforward. If you're looking for a quick intro to web-scraping with R, I found [this page by Parikshit Joshi on ScrapingBee](https://www.scrapingbee.com/blog/web-scraping-r/) to be pretty helpful, along with (the classic) [w3schools' section on XPaths](https://www.w3schools.com/xml/xpath_intro.asp) for a refresh on the correct syntax. For the record, I'm not familiar with the tool that ScrapingBee sells, and did not use it in this little afternoon project.

### Text Analysis
Alright, let's see what super cool and interesting data I collected! A quick **document-feature matrix** and plotting the frequencies...

```{r text}
corp <- corpus(c(unlist(summ_text)))

## if just use a smple dfm and frequency plot...
dfm(corp) %>% textstat_frequency() %>% .[1:10,] %>% plot(x=as.factor(.$feature), y=.$docfreq)
```

...and the most frequent features are 'and' and a comma. Not exactly the career-saving information I was looking for, so I'll use functions from the packages quanteda and stopwords to clean the text into something more useful. It's also worth pointing out that I'm plotting the variable *docfreq* instead of *frequency*, so wordy job posts that repeat themselves a lot don't slant the results.

The result is a pretty bare-bones word frequency chart. Not exactly a work of art, but at least particles and punctuation are out of the way.

```{r cleaning}
## whenever verbose is an option, I generally set it to TRUE
## because that's just who I am as a person
## I'll suppress it from the README
clean_tokens <- tokens(corp, what="word", remove_punct = TRUE, split_hyphens = TRUE, remove_symbols = TRUE, padding=FALSE, verbose=TRUE)
clean_tokens <- tokens_remove(clean_tokens, pattern=stopwords("en"), case_insensitive=TRUE, padding=FALSE, verbose=TRUE)

dfm(clean_tokens) %>% textstat_frequency() %>% .[1:10,] %>% plot(x=as.factor(.$feature), y=.$docfreq)
```

### Cleaned Up

Okay, okay, I know my charts have been ugly so far. Here's some prettier ones, but really guys, don't hire me for graphic design. I like coding and problem-solving, but spending an hour figuring out which colors go together only to realize that my monitor's 'night light' function was on is a headache that I don't want to repeat regularly!

```{r table1}
freq_table <- dfm(clean_tokens) %>% textstat_frequency()

custom_theme1 <- theme(plot.title=element_text(family="Castellar", size=22, face="bold"), text = element_text(family="Gadugi"), plot.caption = element_text(face="italic", size=6), axis.text.x=element_text(angle=45, vjust = 0.5),
                        plot.background = element_rect(color="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

g <- ggplot(data=freq_table[1:15,], aes(x=feature, y=frequency))               
g + geom_bar(stat='identity',fill="darkgoldenrod2") + custom_theme1 + labs(title="Data Science Jobs", subtitle="What are they looking for anyway?", caption="R didn't even make the top 20. It was 26 :(", x=NULL)
```

This still isn't terribly helpful. It's no surprise that 'data scientist' job descriptions include the word 'data!' To further refine, I'm going to search for names of common data analysis/management/visualization tools. This introduces a lot of human error and bias, as there are many tools I could have forgotten to include. 

```{r table2}
stuff <- c("python", "^sql", "nosql", "hadoop", "^r$", "tableau", "postgresql", "pyro", "pymc3", "stata", "spss", "oracle", "alteryx", "vba", "excel$", "matlab", "java", "weka", "gephi", "numpy", "pandas", "mysql", "aws", "qlik", "power bi", "pyspark", "scala$", "rstudio")

i <- 1
inds <- NULL
for(i in 1:length(stuff)){
  inds <- c(inds,grep(stuff[i], freq_table$feature)[1])
  i <- i+1
}
## make sure any tools that had zero matches are listed as 0 and not NA
inds[which(is.na(inds))] <- 0

custom_theme2 <- theme(plot.title=element_text(family="Centaur", size=20), text=element_text(family="Gadugi"), axis.text.x = element_text(angle=45, vjust=0.5),
                       plot.subtitle = element_text(face="italic"), plot.background = element_rect(fill="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

h <- ggplot(data=freq_table[inds,], aes(x=feature, y=docfreq))

h + custom_theme2 + geom_bar(stat='identity',fill="darkgoldenrod2") + labs(title="Popular Data Science Tools", subtitle="As Per Indeed.com Job Posts", x=NULL)
```

And there I have it! Python seems to reign, with my preferred tool R coming in second. SQL and Tableau are strong contenders, but it's pretty obvious that python is far and ahead the most favored - or at least, most talked about - tool for recruiters-of-data-scientists. Now I'm wondering if recreating this little script in python would be good practice?






