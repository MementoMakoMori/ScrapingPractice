### Scraping for a Job
## R. Holley, September 17 2020

## I'm a little bored of scrolling through pages of job postings, many listing programs I'm only a little familiar with
## What should I focus on mastering for my career? SQL, Hadoop, Tableau?
## Pff, why would I decide when I could write a program to decide for me!

## TO DO:
## automate for daily/weekly reports
## find 3rd party list instead of trying to think up my own
## add locations variable

library(rvest)
library(stringi)
library(quanteda)
library(quanteda.textstats)
library(plyr)
library(ggplot2)
library(extrafont)
loadfonts(quiet=TRUE)

## a cursory glance at source pages for Indeed.com and Linkedin, Indeed seemed somewhat simpler
## there are 15 jobs listed on each page of results
list_pages <- paste0("https://www.indeed.com/jobs?q=data%20scientist&explvl=entry_level") %>% lapply(FUN=paste0, "&start=", seq.int(0,30,15)) %>% unlist()
listHTML <- lapply(X=list_pages, FUN=read_html) %>% lapply(FUN=html_nodes, xpath="//@data-jk")

## job keys (data-jk) combine with the frame url to bring up the full job descriptions
jobIDs <- lapply(X=listHTML, FUN=stri_split_fixed, pattern="\"") %>% unlist()
jobIDs <- jobIDs[seq.int(2, length(jobIDs), 3)]
job_frames <- paste0("https://www.indeed.com/viewjob?viewtype=embedded&jk=", jobIDs) %>% lapply(FUN=read_html)

summ_text <- lapply(X=job_frames, FUN=html_element, xpath = "//div[@id='jobDescriptionText']") %>% lapply(FUN=html_text) %>% unlist()

## scraping is done, now for language processing
corp <- corpus(summ_text)
clean_tokens <- tokens(corp, what="word", remove_punct = TRUE, split_hyphens = TRUE, remove_symbols = TRUE, padding=FALSE, verbose=TRUE)
clean_tokens <- tokens_remove(clean_tokens, pattern=stopwords("en"), case_insensitive=TRUE, padding=FALSE, verbose=TRUE)
#freq_table <- dfm(clean_tokens) %>% textstat_frequency() %>% mutate(perc = 100*docfreq/length(summ_text))
dfm_table <- dfm(clean_tokens)
freq_table <- textstat_frequency(dfm_table)
freq_table = mutate(freq_table, perc=100*docfreq/length(summ_text))

custom_theme1 <- theme(plot.title=element_text(family="Castellar", size=24, face="bold"), text = element_text(family="Gadugi"), plot.caption = element_text(face="italic", size=6), axis.text.x=element_text(angle=45, vjust = 0.5),
                        plot.background = element_rect(color="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

g <- ggplot(data=freq_table[1:20,], aes(x=feature, y=perc))               
g + geom_bar(stat='identity',fill="darkgoldenrod2") + custom_theme1 + labs(title="Data Science Jobs", subtitle="What are they looking for anyway?", caption="R didn't even make the top 20 :(", x=NULL, y="% of Posts Containing Word")

## ...okay, maybe this isn't super helpful. I need to filter down to just what I'm looking for
## which may introduce a lot of human error
## aka I forget things
stuff <- c("python", "sql", "nosql", "hadoop", "r", "tableau", "postgresql", "pyro", "pymc3", "stata", "spss", "oracle", "alteryx", "vba", "excel", "matlab", "java", "weka", "gephi", "numpy", "pandas", "mysql", "aws", "qlik", "power bi", "pyspark", "scala", "rstudio", "access")

i <- 1
inds <- NULL
for(i in 1:length(stuff)){
  inds <- c(inds,grep(paste0("^",stuff[i],"$"), freq_table$feature)[1])
  i <- i+1
}
## make sure any tools that had zero matches are listed as 0 and not NA
inds[which(is.na(inds))] <- 0

custom_theme2 <- theme(plot.title=element_text(family="Centaur", size=20), text=element_text(family="Gadugi"), axis.text.x = element_text(angle=45, vjust=0.5),
                       plot.subtitle = element_text(face="italic"), plot.background = element_rect(fill="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

h <- ggplot(data=freq_table[inds,], aes(x=feature, y=perc))
h + custom_theme2 + geom_bar(stat='identity', fill="darkgoldenrod2") + labs(title="Popular Data Science Tools", subtitle="As Per Indeed.com Job Posts", x=NULL, y="% of Posts Containing Word")

## speed tests
# start <- Sys.time()
# summ_text <- ContentScraper(job_frames, XpathPatterns = "//div[@id='jobDescriptionText']")
# Sys.time() - start
# Time difference of 2.432893 mins
# 
# st2 <- Sys.time()
# rvest_text <- lapply(X=job_frames, FUN=read_html) %>% lapply(FUN=html_nodes, xpath = "//div[@id='jobDescriptionText']")
# Sys.time() - st2
# Time difference of 25.78247 secs
