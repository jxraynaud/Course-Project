## Contain a single function used to load the archive from the net then uncompress it in a folder named "data"

dataLoader <- function(){
        temp <- tempfile()
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
        unzip(temp,exdir="data", list=FALSE, overwrite=TRUE)
        unlink(temp)
}