### Research Title: Public Sentiment Analysis and Topic Modelling on Reddit: Government’s approach in transiting to endemic COVID-19 in Singapore
#
### Project Structure

1.	[Introduction](#1-introduction)
2.	[Data Collection](#2-data-collection)
3.	[Exploratory Data Analysis](#3-exploratory-data-analysis)
4.	[Data Preparation](#4-data-preparation)
5.	[Sentiment Analysis](#5-sentiment-analysis)
6.	[Topic Modelling](#6-topic-modelling)
7.	[Conclusion](#7-conclusion)

#
### 1. Introduction
In December 2019, an atypical pneumonia disease was first detected in Wuhan, China. Termed as the coronavirus disease (COVID-19), its accelerated spread had eventually ignited a global health emergency, fuelling worldwide economic and social disruption. For nearly two years, countries have been battling the reoccurring waves of infection till today.
\
\
Likewise, Singapore had experienced massive changes brought by the pandemic. The Singapore government had imposed stringent public health measures such as travel bans, mandated mask-wearing, social distancing, localised lockdowns (i.e., ‘Circuit Breaker’) to reduce transmission. Attributable to high vaccination rates (85%), majority of the cases (98%) in Singapore, to date (i.e., October 2021), report mild infections or are asymptotic. Against this background, Singapore’s Prime Minister (PM) Lee Hsien Loong thus announced on October 9, 2021 on the nation’s progressive strategy to live with COVID-19 as an endemic disease. Living with endemic COVID-19 means to have a strategy to monitor the disease and protect the vulnerable, while ensuring people can carry on with their lives without much damage to health and to the well-being of the society.
\
\
The research aims to understand the public's perception in the government’s decision to transition towards endemic living in Singapore. It seeks to employ text mining, by performing sentiment analysis and topic modelling to analyse public's sentiments and uncover meaningful themes of concern on Reddit forums. This project therefore aims to answer two research questions: **(1) What are the public’s sentiments on the Government’s approach towards endemic living in Singapore, and (2) What are the themes of discussions on the Government’s decision to live with COVID-19?**
\
\
With the COVID-19 situation in Singapore constantly evolving, the ability to understand public’s attitudes and react accordingly is imperative. Policymakers can thereby align interests with Singaporeans on future response actions regarding the new normal. 

&nbsp;

### 2. Data Collection
- Posts were crawled from Reddit under the subreddit, r/Singapore based on the search term “endemic”. 
- Scrapped on October 27, 2021
- Collected a total of 12,852 comments from May 28, 2021 to October 23, 2021 using Python, through the Reddit API.

#### Description of Dataset

The dataset has a total of **12,852 rows and 4 columns**. The four columns represent: 

- ***title***:  Headline of the topic that a user post
- ***body***: Elaboration on the headline
- ***comment***: Replies from other redditors
- ***comment_date***: Date that the post was made

&nbsp;

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192767505-969c0705-0c64-4bfa-88b5-3ba3582d2031.png" width="400" height="250"/>
</p>


- **No missing values** are detected.
- Number of unique comments (12,408) is less than the number of rows in the dataset (12,852), **suggesting potential duplicates**. Duplicated comments will be taken into consideration during the data cleaning process.

&nbsp;

### 3. Exploratory Data Analysis
Exploratory data analysis was conducted after an initial data cleaning was made. 

&nbsp;

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192767576-7776e9c4-483c-4a18-861d-5adf2e1c920a.png" width="520" height="300"/>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192767602-c605096f-a47b-425b-9ebb-ae6afc2d165b.png" width="520" height="300"/>
</p>


The figures above illustrate the distribution of posts over time from May 28, 2021 to October 24, 2021. Over time, there is **increasing posts** regarding the endemic living on Reddit. There are peaks appearing at several specific date periods, indicating **high public discussion**.

&nbsp;

**Findings from time series:**

The term “endemic” was raised for discussion starting from May 28, 2021. 

- **[1] May 31**: PM Lee announced Singapore’s direction in preparing to live with COVID-19 in a live broadcast, through greater and faster vaccinations. (Positive > Negative Sentiments)
-	Towards the end of July 2021, the term “COVID-resilient” has started to show up in ministers’ speeches, illustrating the intend towards endemic living. 
-	**[2] July 19-22**: Amid the upcoming National Day Parade, Singapore public were concerned on the celebrations which were announced to resume ahead despite higher number of locally transmitted cases. (Negative > Positive Sentiments)
-	**[3] August 26-27**: Singapore reached new all-time high of 100 COVID-19 cases per day. (Negative > Positive Sentiments) 
-	**[4] September 6-8**: Though the Government has loosened restrictions in August, stricter restrictions was imposed a few weeks after. (Positive > Negative Sentiments)
-	**[5] September 16-19**: Community cases had reached all time high since May 1, 2020, of around 1,000 daily cases. (Negative and Positive sentiments relatively similar) 
-	**[6] September 25-27**: On September 24, measures were re-tightened amid surge in COVID-19 cases. (Negative > Positive Sentiments)

&nbsp;

### 4. Data Preparation
In this step, these rows were removed: 
-	137 rows of posts unrelated to the endemic 
-	323 rows with the word [deleted] and 58 rows with the word [removed]
-	212 rows of one-word texts
-	15 entries of bot generated comments

A total of 745 rows are removed, resulting in 12,107 rows and 2 columns.

Text issues in the remaining rows are cleaned. We removed:
-	Website links (e.g., *https//*)
-	Subreddits (e.g., *‘r/singapore’*)
-	Usernames (e.g., *‘u/nosajpersonlah’*)
-	Zero-width space (e.g., *‘&#x200B’*)
-	Hashtags (e.g., *#populationpolicy*)
-	Control characters (e.g., *next line spacing, ‘\n’*)
-	Non-ASCII characters
    -	Emojis (e.g., *‘ðŸ˜‰’*)
    -	Invalid characters (e.g., *‘â€™’, ‘â€œ’*)
-	Non-alphanumeric characters (e.g.,* ^ () - ;)

Additionally, contractions converted back to their base words (e.g., *“don’t”* becomes *“do not”*). Spelling normalisation is also conducted (e.g., convert *‘vaxx’* to *‘vaccine’*). Whitespaces are trimmed and texts are converted to lower case. After case normalisation, 49 rows of duplicates were then removed. The initial data clean resulted in 10 rows of comments remaining as one word text or blanks, which were also eliminated. 

The figures below provide various instances of text issues found and corrected:

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770486-15b4d016-0bdd-4332-92c2-bf6b1785b7bd.png" width="520" height="350"/>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770520-4973db34-d918-4fee-a111-c8d9cb32120f.png" width="520" height="320"/>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770505-374f76f9-c152-4769-b7c7-1baf56457848.png" width="520" height="400"/>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770529-57e5048a-896f-4d9b-9f38-2926f94aa537.png" width="520" height="400"/>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770532-ee498f91-0381-4465-b34e-4d65b9c7a1be.png" width="520" height="320"/>
</p>

&nbsp;

### 5. Sentiment Analysis

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770574-44776fdf-e818-4def-a77b-4251908293ce.png" width="520" height="320"/>
</p>

- Results of the sentiment analysis showed that people have a **greater negative outlook than positive regarding the endemic phase**. However, these negative sentiments are not far off from the positive sentiments, suggesting that sentiments are relatively divided. 

\
&nbsp;

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770602-1bacf65d-8182-4cbe-8cc0-646f2a0a0167.png" width="520" height="320"/>
</p> 

- Opinions were classified into three categories, positive (1), neutral (0) and negative (-1). Results showed that 43% comprises of positive opinions, 14% neutral opinions, and 43% negative opinions. **Sentiments are almost equally distributed between positive and negative**, with negative slightly more than positive.

\
&nbsp;

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192770616-4f076e17-8f6a-448a-bf67-0504b964f808.png" width="520" height="320"/>
</p>

Keywords of COVID-19 are categorised into emotional quotients using NRC sentiment lexicon to examine the expressions of ten sentiments. 

- The **overall sentiment is dominantly negative regarding the endemic phase** but contrastingly, is followed closely by positive sentiments. This implies that Singaporeans have relatively split opinions on the endemic progression. Though the public are **fearful of the COVID-19 disease**, but they **trust the Singapore Government** in bringing the nation through the endemic stage. 

&nbsp;

Positive and Negative word frequency are depicted in the following figures:

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192773491-4b843f8d-c57c-4616-a5b8-9cb88142b555.png" width="520" height="320"/>
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192773470-b8e3c52b-7002-480c-b30c-8c5e81f7f09f.png" width="520" height="320"/>
</p>
Differences in top terms between positive and negative sentiments are highlighted in red boxes. Words associated with positive sentiments are almost similar as those in negative.

- Words which are more positively associated are *“well”, “good, “better”, “posit”* (means, *“positive”*), and *“moh”*. MOH is a synonym representing the Ministry of Health (MOH) in Singapore. This could imply that the **public feels that the MOH has done relatively well working towards the endemic phase**.

- Words that are more negatively associated are *“infect”, “flu”, “risk”, “lockdown”, “plan” and “icu”*. ICU refers to intensive care unit, where COVID-19 cases requiring intensive care are being transferred to. This implies that **the symptoms and risks upon contracting COVID-19 are negatively perceived**.

&nbsp;

The following illustrates the word cloud for positive and negative sentiments:

| Positive Sentiments      | Negative Sentiments
:-------------------------:|:-------------------------:
<img src="https://user-images.githubusercontent.com/79804641/192796635-e8861c62-8a96-4f28-8ead-c09217cb92be.png" width="270" height="200"/> | <img src="https://user-images.githubusercontent.com/79804641/192796653-afc044ad-e2de-4edc-ab65-25488015c060.png" width="270" height="200"/>


*‘Vaccine’ and ‘Government’* seems to be mentioned frequently for both sentiments. This could mean that they are important aspects that are necessary in driving endemic living in Singapore. 

&nbsp;

### 6. Topic Modelling
Topic-keyword relationship is illustrated as follows:

**(A) Positive Sentiments** :smile:

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192789174-eb18a822-b586-402e-af4b-8091c620033b.png" width="700" height="550"/>
</p>

**Aspects related to positive sentiments are (in order of topics):**
- (1) Well-thought-out roadmap to reach COVID resilience (*‘well’* planned, *‘success’*)
- (2) Confusing strategies (stop *‘changing plans’*, *‘make’* up your *‘mind’*)
- (3) Hopeful to return to social activities, travel and dine
- (4) Narrating bad experiences contracting COVID-19 (receive *‘calls’* from MOH *‘personnel’* after *‘long time’*, *‘sick family’* members *‘stay’* at home) 
- (5) Advantages of vaccines and booster shots (strengthen *‘immunity’*, *‘protect seniors’*) 
- (6) Justifying why ministers could be imposing restrictions (buy additional *‘time’*, to support healthcare *‘system’* and focus *‘resources’* on the vulnerable e.g., *‘elderly’*)
    -	Called out specific party and health minister - *‘pap’* (People's Action Party), *‘oyk’* (Ong Ye Kung)
- (7) Moving towards radical acceptance (*‘require staff, worker’* to test and *‘update status’* every *‘week’*, experiencing *‘mild symptoms, recovering’*).
- (8) Highlighting what ministers could have done better at (*‘spread’* of *‘unlinked clusters’*, *‘ktv’*, *‘provide’* more *‘details’* on roadmap)
    - *‘reason’* and *‘wonder’* suggests that the public is questioning the ministry why. This indicates that public is uninformed and wish to know more.

:exclamation: **The three themes surrounding positive sentiments are: (1) Government’s endemic plan (2) Easing restrictions (3) Vaccines and boosters**.

\
&nbsp;

**(B) Negative Sentiments** :rage:

<p align="center">
  <img src="https://user-images.githubusercontent.com/79804641/192789210-04698eb3-8f0a-4be8-b0a5-bfb5a0634e62.png" width="700" height="550"/>
</p>

**Aspects related to negative sentiments are (in order of topics):**
- (1) Dissatisfaction on government measures (*‘testing’,’ quarantine’, ‘isolation’, ‘safe’ distancing*)
- (2) Disagree to reopening measures (expressing COVID-19 as a *‘serious issue’*, long *‘term’* implications if adopt *‘full reopening’*)
- (3) Highlighting implications of long-term restrictions (not *‘good reasons’* to impose *‘lockdown’* (more than a *‘year’*), affecting *'livelihood’* and *‘mental’* health of people around them.)
- (4) Comparing differences between vaccinated and unvaccinated. (*‘unvaccinated’* cases more likely to be *‘hospitalised’*, more *‘severe’*)
- (5) Highlighting data reports such as daily and weekly COVID-19 cases.
- (6) Frustrated about mandated government restrictions. (do not *‘agree’*, to propose *‘better’* solution, *‘thought’* restrictions will ease, name calling (*‘Wrong’* Ye Kung, Lawrence *‘Wrong’*))
- (7) Highlighting that there is no point changing restriction plans when we are going to live normally. 

:exclamation: **The three themes surrounding negative sentiments are: (1) Long-term COVID-19 restrictions (i.e., inconvenient, changing and confusing measures, deteriorating mental health) (2) Risk of reopening (3) COVID-19 recovery support.**



&nbsp;

### 7. Conclusion

From sentiment analysis, insights revealed that a **significant majority still fear catching the virus**. **Sentiments seems to be fairly divided** on the endemic progression but public sentiments are **slightly more negative than positive**. People are still **scared and frustrated**. Promisingly, our findings document **public trust in Government officials** which is reassuring in a pandemic.


From topic modelling, three themes for positive sentiments and three themes for negative sentiments are labelled. Overall, findings revealed that the **public is favour of government’s endemic plan, easing of restrictions, vaccines and boosters**. However, there is **blame tendency on the national government, especially on long-term restrictions and changing plans**.

&nbsp;

[(Go to the top)](#research-title-public-sentiment-analysis-and-topic-modelling-on-reddit-governments-approach-in-transiting-to-endemic-covid-19-in-singapore) 
