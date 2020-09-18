### Scraping for a Job
## R. Holley, September 17 2020

## I'm a little bored of scrolling through pages of job postings, many listing programs I'm only a little familiar with
## What should I focus on mastering for my career? SQL, Hadoop, Tableau?
## Pff, why would I decide when I could write a program to decide for me!

library(Rcrawler)
library(rvest)
library(stringi)
library(quanteda)
library(stopwords)
library(ggplot2)
library(extrafont)

## a cursory glance at source pages for Indeed.com and Linkedin, Indeed seemed somewhat simpler
## there are 15 jobs listed on each page of results
list_pages <- paste0("https://www.indeed.com/jobs?q=data%20scientist&explvl=entry_level&start=", seq.int(0,90,15))
listHTML <- lapply(X=list_pages, FUN=read_html) %>% lapply(FUN=html_nodes, xpath="//@data-jk")

## job keys (data-jk) combine with the frame url to bring up the full job descriptions
jobIDs <- lapply(X=listHTML, FUN=stri_split_fixed, pattern="\"") %>% unlist()
jobIDs <- jobIDs[seq.int(2, length(jobIDs), 3)]
job_frames <- paste0("https://www.indeed.com/viewjob?viewtype=embedded&jk=", jobIDs)

summ_text <- ContentScraper(job_frames, XpathPatterns = "//div[@id='jobDescriptionText']")

## scraping is done, now for language processing
corp <- corpus(c(unlist(summ_text)))

## if just use a smple dfm and frequency plot...
dfm(corp) %>% textstat_frequency() %>% .[1:10,] %>% plot(x=as.factor(.$feature), y=.$frequency)
## the biggest results are 'and' and a comma. That's boring! I'll filter the text

clean_tokens <- tokens(corp, what="word", remove_punct = TRUE, padding=FALSE, verbose=TRUE)
clean_tokens <- tokens_remove(clean_tokens, pattern=stopwords("en"), case_insensitive=TRUE, padding=FALSE, verbose=TRUE)

dfm(clean_tokens) %>% textstat_frequency() %>% .[1:10,] %>% plot(x=as.factor(.$feature), y=.$frequency)

## I know you're probably judging my ugly charts right now
## so here's a pretty one
freq_table <- dfm(clean_tokens) %>% textstat_frequency()

custom_theme1 <- theme(plot.title=element_text(family="Castellar", size=24, face="bold"), text = element_text(family="Gadugi"), plot.caption = element_text(face="italic", size=6), axis.text.x=element_text(angle=45, vjust = 0.5),
                        plot.background = element_rect(color="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

g <- ggplot(data=freq_table[1:15,], aes(x=feature, y=frequency))               
g + geom_col(fill="darkgoldenrod2") + custom_theme1 + labs(title="Data Science Jobs", subtitle="What are they looking for anyway?", caption="R didn't even make the top 20 :(", x=NULL)

## ...okay, maybe this isn't super helpful. I need to filter down to just what I'm looking for
## which may introduce a lot of human error
## aka I forget things
stuff <- c("python", "SQL", "noSQL", "Hadoop", "R", "Tableau", "postgreSQL", "pyro", "pymc3", "stata", "spss", "Oracle", "Alteryx", "VBA", "excel", "matlab", "java", "weka", "gephi", "numpy", "pandas", "mysql", "aws", "qlik", "power bi", "pyspark", "scala")
i <- 1
inds <- NULL
for(i in 2:length(stuff)){
  inds <- c(inds,grep(stuff[i], freq_table$feature, ignore.case=TRUE)[1])
}

custom_theme2 <- theme(plot.title=element_text(family="Centaur", size=20), text=element_text(family="Gadugi"), axis.text.x = element_text(angle=45, vjust=0.5),
                       plot.subtitle = element_text(face="italic"), plot.background = element_rect(fill="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

h <- ggplot(data=freq_table[inds,], aes(x=feature, y=frequency))
h + custom_theme2 + geom_col(fill="darkgoldenrod2") + labs(title="Popular Data Science Tools", subtitle="As Per Indeed.com Job Posts", x=NULL)
qplot(x=feature, y=frequency, data=freq_table[inds,])
