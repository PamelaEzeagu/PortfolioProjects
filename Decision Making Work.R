#Attach the data
attach(X21070930_DecisionMaking)

#Sample Size of English and Spanish speakers
lang_counts<- table(X21070930_DecisionMaking$`language (1=english, 2=spanish)`)
lang_counts

#Varience of amount spent on english and spanish speakers
english_speakers<- subset(X21070930_DecisionMaking,`language (1=english, 2=spanish)`==1)
english_speakers
var_english_speakers<- var(english_speakers$`amount spent (£)`)
var_english_speakers

spanish_speakers<-subset(X21070930_DecisionMaking,`language (1=english, 2=spanish)`==2)
spanish_speakers
var_spanish_speakers<-var(spanish_speakers$`amount spent (£)`)
var_spanish_speakers

#Skewness of amount spent for english and spanish speakers
library(e1071)
skew_engspeakers<- skewness(english_speakers$`amount spent (£)`)
skew_engspeakers

skew_spaspeakers<-skewness(spanish_speakers$`amount spent (£)`)
skew_spaspeakers

#Test statistic 
t.test(X21070930_DecisionMaking$`time on website`~X21070930_DecisionMaking$`experience (0=beginner, 1=expert)`)

#Regression Analyis