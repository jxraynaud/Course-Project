Read Me !
========================================================

This is a R markdown file using knitr and plyr to produce a tidy data set with the average of the variable which are a mean or a standard deviation from a data set provided as the following url : [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip )

U can easily read the produced tidy dataset by using :


```r
DF<-read.table("tidydataset.txt",sep=",",header=TRUE)
```

## Loading the raw data into memory.

In order to create the tidy set we first need to load the data. This is a two step process :
- First we check if we have the needed files, if not we use the dataloader function to load the zip and uncompress it.


```r
library(plyr)
```

```
## Warning: package 'plyr' was built under R version 3.1.1
```

```r
if(!file.exists("data")){
        source("dataLoader.R")
        dataLoader()
}
```
- Then we simply load the needed files into memory using read.table :

```r
features<-read.table("data/UCI HAR Dataset/features.txt", sep="",colClasses="character",col.names=c("v1","name"))
activity<-read.table("data/UCI HAR Dataset/activity_labels.txt", sep="", colClasses="character",col.names=c("v1","name"))

x.test <- read.table("data/UCI HAR Dataset/test/X_test.txt",sep="",colClasses=c(rep("numeric",561)),col.names=features$name)
y.test <- read.table("data/UCI HAR Dataset/test/y_test.txt",sep="",col.names="y")
subject.test <- read.table("data/UCI HAR Dataset/test/subject_test.txt",sep="",col.names="subject")

x.train <- read.table("data/UCI HAR Dataset/train/X_train.txt",sep="",colClasses=c(rep("numeric",561)),col.names=features$name)
y.train <- read.table("data/UCI HAR Dataset/train/y_train.txt",sep="",col.names="y")
subject.train <- read.table("data/UCI HAR Dataset/train/subject_train.txt",sep="",col.names="subject")
```

## Unifying the tables

Before merging the train and the test sets we need to unify each of them in a single table. In order to not overload the memory we will simply add two collums to x.test, one with y.test (as factor) and the other one with subject.test.
As y is representing the activity it should be stored as a factor and not a numeric value but as we are going to add some labels to it we will keep it a numeric value for the moment
As subject is representing a person it's also a factor.


```r
x.test$activity = y.test$y
x.test$subject = as.factor(subject.test$subject)
x.train$activity = y.train$y
x.train$subject = as.factor(subject.train$subject)
```

## Merging the two datasets.

It's a simple rbind. I have honestly no idea of how to explain that further.
We put this new dataset into a dataframe named rawdata.
In order to save some memory we delete the unnecessary data.


```r
rawdata <- rbind(x.test,x.train)
rm(x.test,y.test,subject.test,x.train,y.train,subject.train)
```

## Extracting the mean and sd measurements

In order to get the mean and sd measurements we will create a logical vector using grepl over the name column of the features dataframe.
As we want to keep the y and subject column we will simply add two TRUE at the end of this logical vector.
Then we will subset rawdata to extract the required measurements.


```r
neededfeatures <- c(grepl("mean",tolower(features$name)) | grepl("std",tolower(features$name)), TRUE, TRUE)
rawdata <- rawdata[,neededfeatures]
```

## Label the activity

To label the activity we are simply going to use the factor() function and give it the names in activity to be used as level.
We don't need the activity dataframe anymore so let's just remove it from memory.


```r
rawdata$activity <- factor(rawdata$activity,labels=activity$name)
rm(activity)
```

## Properly name the variables.

I'm going to keep the convension used in the original data :
- t means time domain
- f means frequency domain

What I'm going to do is :
* Create a vector of characters based on features and the logical vector neededfeatures
* Change the name of the two last features from "NA" to "Activity" and "Subject"
* Remove the unwanted character that are going to cause trouble in R.
* Replace mean and std by Mean and Std

Finally I'm going to use this vector to rename the Column.


```r
newNames <- features[neededfeatures,"name"]
newNames[c(87,88)]=c("Activity","Subject")
newNames <- gsub("[[:punct:]]","",newNames)
newNames <- gsub("mean", "Mean", newNames)
newNames <- gsub("std", "Std", newNames)
names(rawdata) <- newNames
rm(neededfeatures,features,newNames)
```

## Tidy dataset

First we need to create a new dataset.
We are going to use the aggregate function from the plyr package in order to get the mean by Subject and activity.
Last but not least we are going to save this data set to a .txt named "tidydataset.txt"


```r
tidydata <- aggregate(.~ Subject + Activity, data=rawdata, mean)
write.table(tidydata,"tidydataset.txt",sep=",",quote=TRUE,eol="\r\n",na="NA")
```

