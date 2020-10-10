## Scraping Project

library(rvest)
library(stringi)
library(quanteda)
library(plyr)
library(ggplot2)
library(extrafont)

## there are 15 jobs listed on each page of Indeed.com results
list_pages <- paste0("https://www.indeed.com/jobs?q=data%20scientist&explvl=entry_level&start=", seq.int(0,90,15))
listHTML <- lapply(X=list_pages, FUN=read_html) %>% lapply(FUN=html_nodes, xpath="//@data-jk")

## job keys (data-jk) combine with the frame url to bring up the full job descriptions
jobIDs <- lapply(X=listHTML, FUN=stri_split_fixed, pattern="\"") %>% unlist()
jobIDs <- jobIDs[seq.int(2, length(jobIDs), 3)]
job_frames <- paste0("https://www.indeed.com/viewjob?viewtype=embedded&jk=", jobIDs)

summ_text <- lapply(X=job_frames, FUN=read_html) %>% lapply(FUN=html_nodes, xpath = "//div[@id='jobDescriptionText']") %>% lapply(FUN=html_text)

## scraping is done, now for language processing
corp <- corpus(as.character(summ_text))
clean_tokens <- tokens(corp, what="word", remove_punct = TRUE, split_hyphens = TRUE, remove_symbols = TRUE, padding=FALSE, verbose=TRUE)
clean_tokens <- tokens_remove(clean_tokens, pattern=stopwords("en"), case_insensitive=TRUE, padding=FALSE, verbose=TRUE)
freq_table <- dfm(clean_tokens) %>% textstat_frequency() %>% mutate(perc = 100*docfreq/length(summ_text))
## filter for keywords that I select (introducing my own bias)
stuff <- c("python", "sql", "nosql", "hadoop", "r", "tableau", "postgresql", "pyro", "pymc3", "stata", "spss", "oracle", "alteryx", "vba", "excel", "matlab", "java", "weka", "gephi", "numpy", "pandas", "mysql", "aws", "qlik", "power bi", "pyspark", "scala", "rstudio", "access")

i <- 1
inds <- NULL
for(i in 1:length(stuff)){
  inds <- c(inds,grep(paste0("^",stuff[i],"$"), freq_table$feature)[1])
  i <- i+1
}
## make sure any tools that had zero matches are listed as 0 and not NA
inds[which(is.na(inds))] <- 0

## create pretty plot
custom_theme2 <- theme(plot.title=element_text(family="Centaur", size=20), text=element_text(family="Gadugi"), axis.text.x = element_text(angle=45, vjust=0.5),
                       plot.subtitle = element_text(face="italic"), plot.background = element_rect(fill="#F5F5F5"), panel.background=element_rect(fill="#B0E0E6"))

h <- ggplot(data=freq_table[inds,], aes(x=feature, y=perc))
h + custom_theme2 + geom_bar(stat='identity', fill="darkgoldenrod2") + labs(title="Popular Data Science Tools", subtitle="As Per Indeed.com Job Posts", x=NULL, y="% of Posts Containing Word")
