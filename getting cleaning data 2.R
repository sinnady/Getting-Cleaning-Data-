if (!"reshape2" %in% installed.packages()) {
  install.packages("reshape2")
}
library("reshape2")

#Getting Data
fileName <- "UCIdata.zip"
source <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
path <- "UCI HAR Dataset"

if(!file.exists(fileName)){
  download.file(source,fileName, mode = "wb") 
}

if(!file.exists(path)){
  unzip(fileName, files = NULL, exdir=".")
}


## Read Data
sub_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
sub_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

activity <- read.table("UCI HAR Dataset/activity_labels.txt")
feature <- read.table("UCI HAR Dataset/features.txt")  

# 1). Merges the training and the test sets to create one data set.
data_set <- rbind(x_train,x_test)

# 2). Extracts only the measurements on the mean and standard deviation for each measurement.
mean_std_filter <- grep("mean()|std()", feature[, 2]) 
data_set <- data_set[, mean_std_filter]

# 3). Uses descriptive activity names to name the activities in the data set.

sub <- rbind(sub_train, sub_test)
names(sub) <- 'subject'
activity <- rbind(y_train, y_test)
names(activity) <- 'activity'
data_set <- cbind(sub,activity, data_set)
activity_group <- factor(data_set$activity)
levels(activity_group) <- activity_labels[,2]
data_set$activity <- actitivity_group


# 4). Appropriately labels the data set with descriptive variable names.
descriptive_name <- sapply(feature[, 2], function(x) {gsub("[()]", "",x)})
names(data_set) <- descriptive_name[mean_std_filter]


# 5). From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
base_data <- melt(data_set,(id.vars=c("sub","activity")))
new_data_set <- dcast(base_data, sub + activity ~ variable, mean)
names(new_data_set)[-c(1:2)] <- paste("[mean of]" , names(new_data_set)[-c(1:2)] )
write.table(new_data_set, "tidy_data.txt", sep = ",")
