# Load packages
library(Matrix)
library(NLP)
library(tm)
library(SnowballC)
library(RColorBrewer) 
library(wordcloud)
library(sentimentr) 
library(topicmodels)
library(textdata)
library(dplyr)
library(slam) 
library(tidyverse) 
library(lubridate) 
library(textclean) 

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 1: Read in the data ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Define file path
filepath <- file.path("./dataset/reddit_scrape.csv")

# Load data into dataframe
reddit <-read.csv(filepath, header=TRUE, stringsAsFactors=FALSE)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 2: Data Understanding ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Check dimensions
# 12,852 rows and 4 columns
dim(reddit)

#Checking feature names
names(reddit)

# Determine data types of dataframe's columns
sapply(reddit, class)

# Checking for missing values
# No missing values
colSums(is.na(reddit))

# Count the number of unique comments in Reddit
n_distinct(reddit$comment)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 3: Data Pre-processing (1) ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Removes 137 rows of posts unrelated to the endemic 
wronglyclassified <- reddit %>% 
  filter(str_detect(title, 'Former LTA director admits taking S\\$1.24m in bribes, cheating colleagues of S\\$726,000'))
reddit<- reddit %>% 
  filter(!str_detect(title, 'Former LTA director admits taking S\\$1.24m in bribes, cheating colleagues of S\\$726,000'))

# Drop unnecessary columns
reddit <- select(reddit, -c(title,body))

# Convert comment_date to date class
reddit$comment_date <- as_date(reddit$comment_date)

# Removes 323 rows with the word [deleted] and 58 rows with the word [removed]
deleted_comment <- reddit %>% 
  filter(str_detect(comment, '^\\[deleted].*$'))
removed_comment <- reddit %>% 
  filter(str_detect(comment, '^\\[removed].*$'))

reddit<- reddit %>% 
  filter(!str_detect(comment, '^\\[deleted].*$'))%>%
  filter(!str_detect(comment, '^\\[removed].*$'))

# Removes 212 row of one word texts
odf_sentimentord_comment <- reddit %>% 
  filter(!str_detect(comment, '[:blank:]'))
reddit<- reddit %>% 
  filter(str_detect(comment, '[:blank:]'))

# Removes 15 entries of bot generated comments
bot_comment <- reddit %>% 
  filter(str_detect(comment, 'I am a bot, and this action was performed automatically.'))
reddit<- reddit %>% 
  filter(!str_detect(comment, 'I am a bot, and this action was performed automatically.'))

# A total of 745 rows are removed, resulting in 12,107 rows and 2 columns.


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 4: Data Pre-processing (2) ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Printing posts before pre-processing
reddit$comment[46]
reddit$comment[2491]
reddit$comment[670] 
reddit$comment[2627] 
reddit$comment[2478]
reddit$comment[67]
reddit$comment[23]
reddit$comment[84]
reddit$comment[25]
reddit$comment[1472]


# Printing posts before spelling normalisation
reddit$comment[331]
reddit$comment[1019]
reddit$comment[101]
reddit$comment[163]
reddit$comment[1664]
reddit$comment[1568]
reddit$comment[209]
reddit$comment[479]
reddit$comment[649]
reddit$comment[139]
reddit$comment[108]
reddit$comment[4496]
reddit$comment[4458]
reddit$comment[132]
reddit$comment[2398]

# Removing hyperlinks
reddit$comment <-str_replace_all(reddit$comment," ?(f|ht)tp\\S+\\s*", "")
reddit$comment <-str_replace_all(reddit$comment,"\\S*\\.com\\b|\\S*\\.co.in\\b","")
reddit$comment <-str_replace_all(reddit$comment,'(www)\\S+\\s*',"")

# Removing subreddits (r/)
reddit$comment <-str_replace_all(reddit$comment,"(?:^| )(/?r/[a-zA-Z]+)", "")

# Removing mentions and usernames (u/)
reddit$comment <-str_replace_all(reddit$comment,"(?:^| )(/?u/[a-zA-Z]+)", "")

# Removing hex character code &#x200B
reddit$comment <-str_replace_all(reddit$comment,"&#x200B;", "")

# Removing hashtags
reddit$comment <-str_replace_all(reddit$comment,"#\\S+", "")

# Removing control characters (\n)
reddit$comment <-str_replace_all(reddit$comment,"[[:cntrl:]]", " ")

# Replacing invalid characters to apostrophe
reddit$comment <-str_replace_all(reddit$comment,"â€™", "'")
reddit$comment <-str_replace_all(reddit$comment,"â€œ", "'")

# Replacing contractions
reddit$comment <- replace_contraction(reddit$comment)

# Removing all non-ASCII characters (emojis)
reddit$comment <- str_replace_all(reddit$comment,"[^\x01-\x7F]", "")

# Removing non-alphanumeric characters
reddit$comment <- str_replace_all(reddit$comment,"[^a-zA-Z0-9.,]", " ")

# Trimming whitespace
reddit$comment <- str_squish(reddit$comment)

# Case normalisation, convert to lower case
reddit$comment <- tolower(reddit$comment)

# Spelling normalisation
reddit$comment <- gsub("\\b(bcos|cos|coz|bc)\\b", 
                      "because", reddit$comment)
reddit$comment <- gsub("\\b(dats|dat)\\b", 
                      "that", reddit$comment)
reddit$comment <- gsub("\\b(vaxxed|vaxxers|vaxxer|vaxx|vax)\\b", 
                      "vaccine", reddit$comment)
reddit$comment <- gsub("\\b(unvaxxed|unvaxx|unvaxed|unvax)\\b", 
                      "unvaccinated", reddit$comment)
reddit$comment <- gsub("\\b(gahmen|govt|gov)\\b", 
                      "government", reddit$comment)
reddit$comment <- gsub("\\b(multi ministerial task force|multi ministry task force|task force)\\b", 
                      "mmtf", reddit$comment)
reddit$comment <- gsub("\\b(lawrence wong|wong)\\b", 
                      "lw", reddit$comment)
reddit$comment <- gsub("ong ye kung", 
                      "oky", reddit$comment)
reddit$comment <- gsub("\\b(dying|die|dead)\\b", 
                      "death", reddit$comment)
reddit$comment <- gsub("biz", 
                      "business", reddit$comment)
reddit$comment <- gsub("\\b(healthcare workers|healthcare worker|health care workers|health care worker)\\b", 
                      "hcw", reddit$comment)
reddit$comment <- gsub("ministry of health", 
                      "moh", reddit$comment)
reddit$comment <- gsub("\\b(yup|yea|dead)\\b", 
                       "moh", reddit$comment)

# Removes 49 rows of duplicates
duplicated_comment <- reddit[duplicated(reddit$comment),]
reddit <- reddit[!duplicated(reddit$comment),]

# Removes 10 rows that turned into one word text or blanks after cleaning
odf_sentimentord_comment <- reddit %>% 
  filter(!str_detect(comment, '[:blank:]'))
reddit<- reddit %>% 
  filter(str_detect(comment, '[:blank:]'))

# A total of 59 rows are removed, resulting in 12,048 rows and 2 columns.

# Printing posts after pre-processing
reddit$comment[46]
reddit$comment[2477]
reddit$comment[670]
reddit$comment[2611]
reddit$comment[2465]
reddit$comment[67]
reddit$comment[23]
reddit$comment[84]
reddit$comment[25]
reddit$comment[1468]


# Printing posts after spelling normalisation
reddit$comment[331]
reddit$comment[1019]
reddit$comment[101]
reddit$comment[163]
reddit$comment[1657] 
reddit$comment[1562]
reddit$comment[209]
reddit$comment[479]
reddit$comment[649]
reddit$comment[139]
reddit$comment[108]
reddit$comment[4477]
reddit$comment[4439]
reddit$comment[132]
reddit$comment[2386]


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 5: Preliminary Data Exploration (1) ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Bar plot - Distribution of posts by date
ggplot(reddit, aes(x = comment_date)) +
  geom_bar(colour = "#00abff", fill = "NA") +
  scale_x_date(date_breaks = "2 week", date_labels = "%d-%m-%y")+ 
  labs(title = "Distribution of Posts by Date (May 28, 2021 to October 24, 2021)",
       x= "Month",
       y= "Number of Posts")+
  theme(plot.title = element_text(face="bold"),
        axis.text.x = element_text(angle=45,  hjust = 1),
        axis.title.x = element_text(face="bold"),
        axis.title.y = element_text(face="bold"))

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 6: Sentiment Analysis ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Splitting text data into sentences
mytext <- get_sentences(reddit)

# Generate sentiment scores by comment
sentiment_by_comment <- sentiment_by(mytext)

# Combine the sentiment score and the original sample data
df_sentiment <- cbind(reddit, sentiment_by_comment)

# Convert the predicted sentiment score to a categorical variable
df_sentiment$pre_sentiment[df_sentiment$ave_sentiment > 0] <- 1
df_sentiment$pre_sentiment[df_sentiment$ave_sentiment == 0] <- 0
df_sentiment$pre_sentiment[df_sentiment$ave_sentiment < 0] <- -1

# Filter out neutral sentiment
df_noneutral <- filter(df_sentiment, !str_detect(pre_sentiment, '0'))

# Subset data by sentiment
# Dataframe for positive sentiment
df_positive <- filter(df_noneutral, pre_sentiment =='1')

# Dataframe for negative sentiment
df_negative <- filter(df_noneutral, pre_sentiment == '-1')


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 7: Preliminary Data Exploration (2) ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Plot time series - Frequency of positive and negative comments over time
ggplot(df_noneutral, aes(x = comment_date))+
  geom_line(size = 0.7, stat = 'count', 
            aes(group = pre_sentiment, colour = factor(pre_sentiment))) +
  scale_color_manual(values=c('#D2222D','#238823'))+
  ggtitle("Distribution of Posts by Date (May 28, 2021 to October 24, 2021)")+
  xlab("Month") + ylab("Number of Posts") +
  scale_x_date(date_breaks = "2 week", date_labels = "%d-%m-%y")+
  theme(plot.title = element_text(face="bold"),
        axis.text.x = element_text(angle=45,  hjust = 1),
        axis.title.x = element_text(face="bold"),
        axis.title.y = element_text(face="bold"))+
  labs(color="Pre-Sentiment")


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 8: Visualisations for Sentiment Analysis ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Plot Histogram - Distribution of Sentiments (Continuous)
hist(df_sentiment$ave_sentiment, col=rainbow(10), 
     main = "Distribution of Sentiment - Continuous", xlab = "Sentiments")

# Frequency based on sentiment
pos_neg_counts <- table(df_sentiment$pre_sentiment)

# Plot Bar chart - Distribution of Sentiments (Categorical)
sentiment_freq <- par(mar=c(5,4,4,2))
bp <- barplot(pos_neg_counts, main = "Distribution of Sentiment - Categorical",
        xlab = "Positive, Neutral, or Negative", 
        col = c("#F35E5A", "#E6E6E6", "#009E73"))
text(bp, pos_neg_counts -300, pos_neg_counts, font=2, col='black')
rm(sentiment_freq) 


# Load packages
library(syuzhet)

# Binding positive and negative dataframe
combined_sentiments <- rbind(df_positive,df_negative)

# Changing from dataframe to character vector
combined_sentiments <- as.character(combined_sentiments)

# Calculating emotions and valence
sentiment <- get_nrc_sentiment(combined_sentiments)

# Setting up Bar plot
sentimentscore <- data.frame(colSums(sentiment[,]))
names (sentimentscore) <- "Score"
sentimentscore <-cbind("sentiment"=rownames(sentimentscore), sentimentscore)

# Plot Bar plot - Emotions from NRC Sentiments
ggplot(data=sentimentscore, 
       aes(x=sentimentscore$sentiment, y=sentimentscore$Score))+
  geom_bar(aes(fill=sentiment),stat='identity')+
  xlab("Sentiment")+ ylab("score")+
  ggtitle("Distribution of Emotion Categories")+
  theme(plot.title = element_text(face="bold"))

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 9: Text Pre-Processing ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Transform dataframe of comments into a corpus object
positive_corpus<- VCorpus(VectorSource(df_positive$comment)) 
negative_corpus<- VCorpus(VectorSource(df_negative$comment)) 

# View content of corpus
positive_corpus$content
negative_corpus$content

# Create a copy of the Corpus
positive <- positive_corpus
negative <- negative_corpus

# Case normalisation is not conducted in this step

# Removing punctuation
positive <- tm_map(positive,removePunctuation)
negative <- tm_map(negative,removePunctuation)

# Removing numbers 
positive <- tm_map(positive, removeNumbers)
negative <- tm_map(negative, removeNumbers)

# Removing non-English words
toSpace <- content_transformer(function(x, pattern)gsub(pattern," ",x))
positive <- tm_map(positive, toSpace,"[^A-Za-z]")
negative <- tm_map(negative, toSpace,"[^A-Za-z]")

# Removing stop words (First cut)
# Create a list of stop words and store in a .data file
mystopwords <- scan(file="./files/mystopwords.data", 
                    what=character(),sep="\n")

# Import stop words file to remove customised stop words
positive <- tm_map(positive,removeWords, mystopwords[2:672])
negative <- tm_map(negative,removeWords, mystopwords[2:672])

# Removing all custom stopwords (Second cut)
customstopwords <- c("bro", "cases", "coronavirus", "virus", "damn" ,"decide",
                     "delta", "despite", "disease", "dumbass", "fuck",
                     "fucking", "infect", "la", "lah", "lmao", "loled",
                     "macam", "need", "people", "ppl", "reddit", "redditors",
                     "singapore", "sg", "singaporean", "tbh", "thing",
                     "think", "vibes", "wow", "wtf", "zoop", "covid", "sure",
                     "cos", "pandemic", "shit", "example", "guy", "pi jiu meis",
                     "wee hours", "isbot", "whynotcollegeboard", "eskipony",
                     "copypasta", "bukitbukit", "omg", "ikr", "tldr", "lol",
                     "um", "haven", "ph ph pha pha lula", "ayo",
                     "zzz", "zoe" ,"zinger" ,"zaobao" ,"zao", "yuck", "ytd",
                     "youv", "yoyo", "yiu" ,"yos", "youll", "yin", 
                     "yesteryear", "yesterdaywhat", "yesss", "abcdefg", "abc",
                     "abdallah", "aberr", "abbott", "abdomin", "abd",
                     "abhorr", "abid", "angmoh", "anywayregard", "boomz", "btw",
                     "bullcrap", "bullshit", "bukakk", "buuuuyaaaaooooooo",
                     "bwahahahahaha", "bruhh", "broooo", "cant")

positive <- tm_map(positive, removeWords, customstopwords)
negative <- tm_map(negative, removeWords, customstopwords)

# Check comment every now and then for good practice
writeLines(as.character(positive[[28]]))
writeLines(as.character(negative[[36]]))

# Stemming
positive<-tm_map(positive, stemDocument)
negative<-tm_map(negative, stemDocument)

# Removing extra white space
positive<-tm_map(positive, stripWhitespace)
negative<-tm_map(negative, stripWhitespace)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 10: Topic Modelling (1) ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Generates Document-Term Matrix, 5,147 documents and 7,431 terms
dtm_positive <-DocumentTermMatrix(positive)
# Generates Document-Term Matrix, 5.214 documents and 7,535 terms
dtm_negative <-DocumentTermMatrix(negative)

# Looking at the number of features
dtm_positive
dtm_negative

# Check the terms in the Document-Term Matrix
# Stop words further are removed after reviewing
dtm_positive$dimnames$Terms
dtm_negative$dimnames$Terms

# Check the dimensions of the Document-Term Matrix
dim(dtm_positive)
dim(dtm_negative)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 11: Term Frequency Visualisations ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Sorting by frequency and Converting DTM to Matrix class
tf_positive <-sort(colSums(as.matrix(dtm_positive)), decreasing=TRUE)
tf_negative <-sort(colSums(as.matrix(dtm_negative)), decreasing=TRUE)

# Check top 10 frequent words
head(tf_positive, 10)
head(tf_negative, 10)

# Plot Bar plot - Frequency of Positive words
tibble(word=names(tf_positive), frequency=tf_positive) %>%
  top_n(25,frequency)  %>%
  mutate(word=reorder(word, frequency)) %>%
  ggplot(aes(word,frequency)) +
  geom_col() + 
  labs(title="Top 25: Positive words",
       x = 'Word',
       y = "Frequency") +
  coord_flip()


# Plot Bar plot - Frequency of Negative words
tibble(word=names(tf_negative), frequency=tf_negative) %>%
  top_n(25,frequency)  %>%
  mutate(word=reorder(word, frequency)) %>%
  ggplot(aes(word,frequency)) +
  geom_col() + 
  labs(title="Top 25: Negative words",
       x = 'Word',
       y = "Frequency") +
  coord_flip()


# Plot Word cloud - Top 50 keywords in positive
tf_positive <-sort(colSums(as.matrix(dtm_positive)), decreasing=TRUE)
wordcloud(names(tf_positive), tf_positive, random.order=F,max.words=50, 
          col=brewer.pal(5, "Set2"),scale=c(3.5,0.25))

# Plot Word cloud - Top 50 keywords in negative
tf_negative <-sort(colSums(as.matrix(dtm_negative)), decreasing=TRUE)
wordcloud(names(tf_negative), tf_negative, random.order=F,max.words=50, 
          col=brewer.pal(5, "Set2"),scale=c(3.5,0.25))


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 12: Topic Modelling (2) ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Removing empty documents from DTM
rowtotals_pos <- apply(dtm_positive,1,sum) 
dtm_positive <- dtm_positive[rowtotals_pos> 0,]

rowtotals_neg <- apply(dtm_negative,1,sum) 
dtm_negative <- dtm_negative[rowtotals_neg> 0,]

# Inspect the dtm
inspect(dtm_positive)
inspect(dtm_negative)

# Create Document-Term Martix with TF-IDF values
dtm_tfidf_positive<-weightTfIdf(dtm_positive, normalize=TRUE)
dtm_tfidf_negative<-weightTfIdf(dtm_negative, normalize=TRUE)

# Get statistical summary of TF-IDF values
summary(dtm_tfidf_positive$v) # Median = 0.263711 (Round up to 0.27)
summary(dtm_tfidf_negative$v) # Median = 0.250559 (Round up to 0.26)

# Filter terms in Document-Term Matrix according to TFIDF-value
# Keep all the terms with a tfidf value >= 0.27
dtm_reduced_positive<-dtm_positive[,dtm_tfidf_positive$v>=0.27]
# Keep documents with at least one term
dtm_reduced_positive<-dtm_reduced_positive[row_sums(dtm_reduced_positive)>0,] 

# Keep all the terms with a tfidf value >= 0.26
dtm_reduced_negative<-dtm_negative[,dtm_tfidf_negative$v>=0.26] 
# Keep documents with at least one term
dtm_reduced_negative<-dtm_reduced_negative[row_sums(dtm_reduced_negative)>0,] 

# Inspect the reduced dtm
inspect(dtm_reduced_positive)
inspect(dtm_reduced_negative)



# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 13: Topic Modelling (3) - Building LDA Model  ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Run final topic model at k = 8 for Positive sentiments
# k = 5, 7, 10 and 15 are also tested
k <- 8
seed <- 2020
model_lda_pos <-list(VEM=LDA(dtm_reduced_positive,k=k,method="VEM",
                        control=list(seed=seed)),
                Gibbs=LDA(dtm_reduced_positive,k=k,method="Gibbs",
                          control=list(seed=seed,
                                       burnin=1000,thin=100,iter=1000)))

# Run final topic model at k = 7 for Negative sentiments
# k = 5, 8, 10 and 5 are also tested
k <- 7
seed <- 2020
model_lda_neg <- list(VEM=LDA(dtm_reduced_negative,k=k,method="VEM",
                        control=list(seed=seed)),
                Gibbs=LDA(dtm_reduced_negative,k=k,method="Gibbs",
                          control=list(seed=seed,
                                       burnin=1000,thin=100,iter=1000)))


# Results
# Check top 15 keywords representing each topic for VEM and Gibbs
terms_vem_pos <- terms(model_lda_pos$VEM,15)
terms_gibbs_pos <- terms(model_lda_pos$Gibbs,15)

terms_vem_neg <- terms(model_lda_neg$VEM,15)
terms_gibbs_neg <- terms(model_lda_neg$Gibbs,15)

# View results
terms_vem_pos
terms_gibbs_pos

terms_vem_neg
terms_gibbs_neg


# Finalise k = 8 (Gibbs) for Positive sentiments and k = 7 (Gibbs) for Negative sentiments

# Topic-document relationship
# Get top 8 topic for each of the document - Positive Sentiment
topic_gibbs_pos <- topics(model_lda_pos$Gibbs,8)
topic_gibbs_pos[,1:5]


# Get top 7 topic for each of the document - Negative Sentiment
topic_gibbs_neg <- topics(model_lda_neg$Gibbs,7)
topic_gibbs_neg[,1:5]


# Generate posterior topic distribution - Positive Sentiment
gammaDF_gibbs_pos <- as.data.frame(model_lda_pos$Gibbs@gamma,
                             row.names=model_lda_pos$Gibbs@documents)
names(gammaDF_gibbs_pos) <- c(1:k)
view(gammaDF_gibbs_pos)

# Generate posterior topic distribution - Negative Sentiment
gammaDF_gibbs_neg <- as.data.frame(model_lda_neg$Gibbs@gamma,
                             row.names=model_lda_neg$Gibbs@documents)
names(gammaDF_gibbs_neg) <- c(1:k)
view(gammaDF_gibbs_neg)

# Exporting as csv
write.csv(gammaDF_gibbs_pos,
          "./files/gammaDF_gibbs_pos.csv", 
          row.names = TRUE)
write.csv(gammaDF_gibbs_neg,
          ".files/gammaDF_gibbs_neg.csv", 
          row.names = TRUE)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Part 14: Visualisations for Topic Modelling ----
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

# Import packages
library(tidytext)

# Setting up visualisation for final model
topics_pos <- tidy(model_lda_pos$Gibbs, matrix="beta")
topics_neg <- tidy(model_lda_neg$Gibbs, matrix="beta")

# Displaying top 15 terms and grouping them by topics created
top_terms_pos <- topics_pos %>%
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms_neg <- topics_neg %>%
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

# Converting topic into a factor class for visualisation 
top_terms_pos$topic <- as.factor(top_terms_pos$topic)
top_terms_neg$topic <- as.factor(top_terms_neg$topic)

# Visualisation of the top terms - Positive Sentiments
png(file="./files/positive.png",width=1500, height=1500, res = 200)
par(mar=c(5,3,2,2)+0.1)
par(cex.axis=10)
top_terms_pos %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = topic)) +
  theme_bw()+
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 4, scales = "free") +
  coord_flip()+
  labs(title = "Most common terms within each topic - Positive Sentiments")
dev.off()


# Visualisation of the top terms - Positive Sentiments
png(file="./files/negative.png",width=1500, height=1500, res = 200)
par(mar=c(5,3,2,2)+0.1)
par(cex.axis=10)
top_terms_neg %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = topic)) +
  theme_bw()+
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 4, scales = "free") +
  coord_flip()+
  labs(title = "Most common terms within each topic - Negative Sentiments")
dev.off()


