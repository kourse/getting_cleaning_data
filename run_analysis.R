library(reshape2)
library(data.table)
library(plyr)

# get the descriptive activities and features
activity_labels = read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
feature_names = read.table("./UCI HAR Dataset/features.txt")[,2]

# grab only the interesting features
interesting_features = grepl("mean|std", feature_names)

# Loading the test data
X_test = read.table("./UCI HAR Dataset/test/X_test.txt")
y_test = read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test = read.table("./UCI HAR Dataset/test/subject_test.txt")

# naming the columns in test data
names(X_test) = feature_names

# Extracting interesting features from the test data
X_test = X_test[,interesting_features]

y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("activity", "activity_label")
names(subject_test) = "subject"

# Put the test data info together
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Do the above steps for training data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = feature_names
X_train = X_train[, interesting_features]
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("activity", "activity_label")
names(subject_train) = "subject"
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Put the test and training data together
data = rbind(test_data, train_data)

# Form the id and measure variables for using melt
id_vars = c("subject", "activity", "activity_label")
measure_vars = setdiff(colnames(data), id_vars)
# melt the data
molten_data = melt(data, id=id_vars, measure.vars=measure_vars)

# cast the molten data
tidy_data = dcast(molten_data, subject + activity_label ~ variable, mean)
# write it to a .txt file
write.table(tidy_data, file= "./tidy_data.txt")

