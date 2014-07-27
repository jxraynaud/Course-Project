## SEE THE README.md for a complet walkthrough the code.

library(plyr) ## We will need it later...

## test if a rep called data exist, if not call the dataLoader function in dataLoader.R
if(!file.exists("data")){ 
        source("./dataLoader.R") 
        dataLoader()
}


## Loading Data from the files

features<-read.table("data/UCI HAR Dataset/features.txt", sep="",colClasses="character",col.names=c("v1","name")) 
## give us the name of the column in the x.test and x.train files
activity<-read.table("data/UCI HAR Dataset/activity_labels.txt", sep="", colClasses="character",col.names=c("v1","name"))
## give us the activity labels in the y.test and y.train files.

## the test dataset
x.test <- read.table("data/UCI HAR Dataset/test/X_test.txt",sep="",colClasses=c(rep("numeric",561)))
y.test <- read.table("data/UCI HAR Dataset/test/y_test.txt",sep="",col.names="y")
subject.test <- read.table("data/UCI HAR Dataset/test/subject_test.txt",sep="",col.names="subject")

## the train dataset
x.train <- read.table("data/UCI HAR Dataset/train/X_train.txt",sep="",colClasses=c(rep("numeric",561)))
y.train <- read.table("data/UCI HAR Dataset/train/y_train.txt",sep="",col.names="y")
subject.train <- read.table("data/UCI HAR Dataset/train/subject_train.txt",sep="",col.names="subject")

## Unifying the tables

x.test$activity = y.test$y 
x.test$subject = as.factor(subject.test$subject)
x.train$activity = y.train$y
x.train$subject = as.factor(subject.train$subject)

## Merging the two datasets.

rawdata <- rbind(x.test,x.train)
rm(x.test,y.test,subject.test,x.train,y.train,subject.train)

## Extracting the mean and sd measurements

neededfeatures <- c(grepl("mean",tolower(features$name)) | grepl("std",tolower(features$name)), TRUE, TRUE)
rawdata <- rawdata[,neededfeatures]

## Label the activity

rawdata$activity <- factor(rawdata$activity,labels=activity$name)
rm(activity)

## Properly name the variables.

newNames <- features[neededfeatures,"name"]
newNames[c(87,88)]=c("Activity","Subject")
newNames <- gsub("[[:punct:]]","",newNames)
newNames <- gsub("mean", "Mean", newNames)
newNames <- gsub("std", "Std", newNames)
names(rawdata) <- newNames
rm(neededfeatures,features,newNames)

## Tidy dataset

tidydata <- aggregate(.~ Subject + Activity, data=rawdata, mean)
write.table(tidydata,"tidydataset.txt",sep=",",quote=TRUE,eol="\r\n",na="NA")