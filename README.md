### Introduction

This is the course project for the Coursera class Getting and Cleaning Data
of the Data Science signature track offered by John Hopkins Bloomberg School 
of Public Health. The purpose is to get datasets and transform them to a tidy 
dataset suitable for the intended analysis. The main R script is run_analysis.R
and the detailed descriptions are provided below. 

### Steps in the Creation of the Tidy Set

1. Merges the training and test datasets into one dataset.
2. Extracts the mean and standard deviation for each measurement.
3. Uses descriptive names to name activities in the datasets.
4. Labels the datasets with descriptive variable names.
5. Create an independent tidy data set with average of each variable
   for each activity and each subject.


### 1. Merge Training and Test Datasets

The training and test datasets are in their appropriate folders called test and
train data folders. There is a file activity_labels which is a table for a
numeric activty and the descriptive activty. There are three main parallel
vectors consisting of the subject, the activity and the actual measurements
for train and test datasets. The subject_test.txt and subject_train.txt have
subjects (numbered 1-30), y_test.txt and y_train.txt have the activities
(numbered 1-6), and the X_test.txt and X_train.txt have the actual measurements.

The columns for subject, activity and measurements are merged using `cbind` R
function and the test and train datasets are merged using the `rbind` R function.

### 2. Extract the Mean and Standard Deviation for each Measurement

The *dplyr* package `select` function has an argument `matches` that will
match rows given regular expresion mean|std for the mean and standard deviation
variables::
  
```
measure_mean_std <- select(measure_combined,idx,subject,set_type,activity_id,activity_name,matches("mean|std",ignore.case=TRUE))
```

### 3. Use Descriptive Names for Activities

The activities are numbered 1-6 with their descriptive names in the 
activity_labels file. They are joined as a data frame and cbind the 
measurements:

```
# Joined activity with the labels for test dataset
activity_labels_test <- join(activity_test,activity_labels)

# Joined subject and activity
sub_act_test <- join(subject_test,activity_labels_test,by=c("idx","set_type"))

# Measurements with subject and activity for test dataset
measure_test <- join(sub_act_test,measure_raw_test,by=c("idx","set_type"))
```

### 4. Label the Datasets with Descriptive Variable Names

The features.txt file provided meaningful names for the measurements columns.
The `make.names` function enforced the uniqueness as suggested by one of
fellow students. The activity variables are named activity_id and activity_name,
the subject is retained, the test or train dataset goes under set_type and
idx was introduced if needed in the train and test tables. The SQL interface
using the *sqldf* package left some artifacts in the columns names such as
quotes and parentheses and have tobe cleaned out using the `names` function.

### 5. Create an Independent Dataset with Average of each Variable

The SQL interface can be arguably the easiest approach to the problem of
grouping by two levels (activity,subject) and using `avg()` to average values.
