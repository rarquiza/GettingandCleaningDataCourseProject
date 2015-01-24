# Install or load the dplyr package
require(dplyr)
 
# Read the activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE)
names(activity_labels) <- c("activity_id", "activity_name")

# Read the features which are the columns for the measurements dataset
features <- read.table("./UCI HAR Dataset/features.txt",header=FALSE)
names(features) <- c("feature_id", "feature_name")

# Read the subject table for the test dataset
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
subject_test <- cbind(paste("test",row.names(subject_test),sep=""),subject_test,c("test"))
names(subject_test) <- c("idx","subject","set_type")

# Read the activity table for the test dataset
activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
activity_test <- cbind(paste("test",row.names(activity_test),sep=""),activity_test,c("test"))
names(activity_test) <- c("idx","activity_id","set_type")

# Read the measurements for the test dataset
measure_raw_test <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
names(measure_raw_test) <- make.names(features$feature_name, unique=TRUE)
measure_raw_test <- cbind(idx=paste("test",row.names(measure_raw_test),sep=""),measure_raw_test,set_type=c("test"))

# Joined activity with the labels for test dataset
activity_labels_test <- join(activity_test,activity_labels)

# Joined subject and activity
sub_act_test <- join(subject_test,activity_labels_test,by=c("idx","set_type"))

# Measurements with subject and activity for test dataset
measure_test <- join(sub_act_test,measure_raw_test,by=c("idx","set_type"))

# Read the subject table for the train dataset
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)
subject_train <- cbind(paste("train",row.names(subject_train),sep=""),subject_train,c("train"))
names(subject_train) <- c("idx","subject","set_type")

# Read the activity table for the train dataset
activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
activity_train <- cbind(paste("train",row.names(activity_train),sep=""),activity_train,c("train"))
names(activity_train) <- c("idx","activity_id","set_type")

# Read the measurements for the train dataset
measure_raw_train <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
names(measure_raw_train) <- make.names(features$feature_name, unique=TRUE)
measure_raw_train <- cbind(idx=paste("train",row.names(measure_raw_train),sep=""),measure_raw_train,set_type=c("train"))

# Joined activity with the labels for train dataset
activity_labels_train <- join(activity_train,activity_labels)

# Joined subject and activity
sub_act_train <- join(subject_train,activity_labels_train,by=c("idx","set_type"))

# Measurements with subject and activity for train dataset
measure_train <- join(sub_act_train,measure_raw_train,by=c("idx","set_type"))

#
# 1. Combined the test and train measure datasetss
#
measure_combined <- rbind(measure_test,measure_train)

#
# 2. Extract the field with only the mean and standar deviation
#
measure_mean_std <- select(measure_combined,idx,subject,set_type,activity_id,activity_name,matches("mean|std",ignore.case=TRUE))

#
# 3. Example to show descriptive activity names for activities
#
table(measure_mean_std$activity_name)
##  LAYING            SITTING           STANDING 
##  1944               1777               1906 
##  WALKING WALKING_DOWNSTAIRS   WALKING_UPSTAIRS 
##  1722               1406               1544 

#
# 4. Display descriptive variable names such as idx, subject, etc.
#
names(measure_mean_std)[1:10]
##  [1] "idx"               "subject"           "set_type"         
##  [4] "activity_id"       "activity_name"     "tBodyAcc.mean...X"
##  [7] "tBodyAcc.mean...Y" "tBodyAcc.mean...Z" "tBodyAcc.std...X" 
##  [10] "tBodyAcc.std...Y"

#
# 5. Create an independent tidy dataset average of variables
#    by activity and subject. SQL interface is the natural tool
#    to use based on the requirement.
#
require(sqldf)
measure_mean_std_avg <- sqldf("select activity_id, subject,   
      activity_name, 
      avg(\"tBodyAcc.mean...X\"),                   
      avg(\"tBodyAcc.mean...Y\"),                   
      avg(\"tBodyAcc.mean...Z\"),                   
      avg(\"tBodyAcc.std...X\"),                    
      avg(\"tBodyAcc.std...Y\"),                    
      avg(\"tBodyAcc.std...Z\"),                    
      avg(\"tGravityAcc.mean...X\"),                
      avg(\"tGravityAcc.mean...Y\"),                
      avg(\"tGravityAcc.mean...Z\"),                
      avg(\"tGravityAcc.std...X\"),                 
      avg(\"tGravityAcc.std...Y\"),                 
      avg(\"tGravityAcc.std...Z\"),                 
      avg(\"tBodyAccJerk.mean...X\"),               
      avg(\"tBodyAccJerk.mean...Y\"),               
      avg(\"tBodyAccJerk.mean...Z\"),               
      avg(\"tBodyAccJerk.std...X\"),                
      avg(\"tBodyAccJerk.std...Y\"),                
      avg(\"tBodyAccJerk.std...Z\"),                
      avg(\"tBodyGyro.mean...X\"),                  
      avg(\"tBodyGyro.mean...Y\"),                  
      avg(\"tBodyGyro.mean...Z\"),                  
      avg(\"tBodyGyro.std...X\"),                   
      avg(\"tBodyGyro.std...Y\"),                   
      avg(\"tBodyGyro.std...Z\"),                   
      avg(\"tBodyGyroJerk.mean...X\"),              
      avg(\"tBodyGyroJerk.mean...Y\"),              
      avg(\"tBodyGyroJerk.mean...Z\"),              
      avg(\"tBodyGyroJerk.std...X\"),               
      avg(\"tBodyGyroJerk.std...Y\"),               
      avg(\"tBodyGyroJerk.std...Z\"),               
      avg(\"tBodyAccMag.mean..\"),                  
      avg(\"tBodyAccMag.std..\"),                   
      avg(\"tGravityAccMag.mean..\"),               
      avg(\"tGravityAccMag.std..\"),                
      avg(\"tBodyAccJerkMag.mean..\"),              
      avg(\"tBodyAccJerkMag.std..\"),               
      avg(\"tBodyGyroMag.mean..\"),                 
      avg(\"tBodyGyroMag.std..\"),                  
      avg(\"tBodyGyroJerkMag.mean..\"),             
      avg(\"tBodyGyroJerkMag.std..\"),              
      avg(\"fBodyAcc.mean...X\"),                   
      avg(\"fBodyAcc.mean...Y\"),                   
      avg(\"fBodyAcc.mean...Z\"),                   
      avg(\"fBodyAcc.std...X\"),                    
      avg(\"fBodyAcc.std...Y\"),                    
      avg(\"fBodyAcc.std...Z\"),                    
      avg(\"fBodyAcc.meanFreq...X\"),               
      avg(\"fBodyAcc.meanFreq...Y\"),               
      avg(\"fBodyAcc.meanFreq...Z\"),               
      avg(\"fBodyAccJerk.mean...X\"),               
      avg(\"fBodyAccJerk.mean...Y\"),               
      avg(\"fBodyAccJerk.mean...Z\"),               
      avg(\"fBodyAccJerk.std...X\"),                
      avg(\"fBodyAccJerk.std...Y\"),                
      avg(\"fBodyAccJerk.std...Z\"),                
      avg(\"fBodyAccJerk.meanFreq...X\"),           
      avg(\"fBodyAccJerk.meanFreq...Y\"),           
      avg(\"fBodyAccJerk.meanFreq...Z\"),           
      avg(\"fBodyGyro.mean...X\"),                  
      avg(\"fBodyGyro.mean...Y\"),                  
      avg(\"fBodyGyro.mean...Z\"),                 
      avg(\"fBodyGyro.std...X\"),                   
      avg(\"fBodyGyro.std...Y\"),                   
      avg(\"fBodyGyro.std...Z\"),                   
      avg(\"fBodyGyro.meanFreq...X\"),              
      avg(\"fBodyGyro.meanFreq...Y\"),              
      avg(\"fBodyGyro.meanFreq...Z\"),              
      avg(\"fBodyAccMag.mean..\"),                  
      avg(\"fBodyAccMag.std..\"),                   
      avg(\"fBodyAccMag.meanFreq..\"),              
      avg(\"fBodyBodyAccJerkMag.mean..\"),          
      avg(\"fBodyBodyAccJerkMag.std..\"),           
      avg(\"fBodyBodyAccJerkMag.meanFreq..\"),      
      avg(\"fBodyBodyGyroMag.mean..\"),             
      avg(\"fBodyBodyGyroMag.std..\"),              
      avg(\"fBodyBodyGyroMag.meanFreq..\"),         
      avg(\"fBodyBodyGyroJerkMag.mean..\"),         
      avg(\"fBodyBodyGyroJerkMag.std..\"),          
      avg(\"fBodyBodyGyroJerkMag.meanFreq..\"),     
      avg(\"angle.tBodyAccMean.gravity.\"),         
      avg(\"angle.tBodyAccJerkMean..gravityMean.\"),
      avg(\"angle.tBodyGyroMean.gravityMean.\"),    
      avg(\"angle.tBodyGyroJerkMean.gravityMean.\"),
      avg(\"angle.X.gravityMean.\"),                
      avg(\"angle.Y.gravityMean.\"),                
      avg(\"angle.Z.gravityMean.\")
from measure_mean_std group by activity_id, subject, activity_name;")

names(measure_mean_std_avg) <- c("activity_id","subject","activity_name",
      "tBodyAcc.mean...Xavg",                   
      "tBodyAcc.mean...Yavg",                   
      "tBodyAcc.mean...Zavg",                   
      "tBodyAcc.std...Xavg",                    
      "tBodyAcc.std...Yavg",                    
      "tBodyAcc.std...Zavg",                    
      "tGravityAcc.mean...Xavg",                
      "tGravityAcc.mean...Yavg",                
      "tGravityAcc.mean...Zavg",                
      "tGravityAcc.std...Xavg",                 
      "tGravityAcc.std...Yavg",                 
      "tGravityAcc.std...Zavg",                 
      "tBodyAccJerk.mean...Xavg",               
      "tBodyAccJerk.mean...Yavg",               
      "tBodyAccJerk.mean...Zavg",               
      "tBodyAccJerk.std...Xavg",                
      "tBodyAccJerk.std...Yavg",                
      "tBodyAccJerk.std...Zavg",                
      "tBodyGyro.mean...Xavg",                  
      "tBodyGyro.mean...Yavg",                  
      "tBodyGyro.mean...Zavg",                  
      "tBodyGyro.std...Xavg",                   
      "tBodyGyro.std...Yavg",                   
      "tBodyGyro.std...Zavg",                   
      "tBodyGyroJerk.mean...Xavg",              
      "tBodyGyroJerk.mean...Yavg",              
      "tBodyGyroJerk.mean...Zavg",              
      "tBodyGyroJerk.std...Xavg",               
      "tBodyGyroJerk.std...Yavg",               
      "tBodyGyroJerk.std...Zavg",               
      "tBodyAccMag.mean..avg",                  
      "tBodyAccMag.std..avg",                   
      "tGravityAccMag.mean..avg",               
      "tGravityAccMag.std..avg",                
      "tBodyAccJerkMag.mean..avg",              
      "tBodyAccJerkMag.std..avg",               
      "tBodyGyroMag.mean..avg",                 
      "tBodyGyroMag.std..avg",                  
      "tBodyGyroJerkMag.mean..avg",             
      "tBodyGyroJerkMag.std..avg",              
      "fBodyAcc.mean...Xavg",                   
      "fBodyAcc.mean...Yavg",                   
      "fBodyAcc.mean...Zavg",                   
      "fBodyAcc.std...Xavg",                    
      "fBodyAcc.std...Yavg",                    
      "fBodyAcc.std...Zavg",                    
      "fBodyAcc.meanFreq...Xavg",               
      "fBodyAcc.meanFreq...Yavg",               
      "fBodyAcc.meanFreq...Zavg",               
      "fBodyAccJerk.mean...Xavg",               
      "fBodyAccJerk.mean...Yavg",               
      "fBodyAccJerk.mean...Zavg",               
      "fBodyAccJerk.std...Xavg",                
      "fBodyAccJerk.std...Yavg",                
      "fBodyAccJerk.std...Zavg",                
      "fBodyAccJerk.meanFreq...Xavg",           
      "fBodyAccJerk.meanFreq...Yavg",           
      "fBodyAccJerk.meanFreq...Zavg",           
      "fBodyGyro.mean...Xavg",                  
      "fBodyGyro.mean...Yavg",                  
      "fBodyGyro.mean...Zavg",                 
      "fBodyGyro.std...Xavg",                   
      "fBodyGyro.std...Yavg",                   
      "fBodyGyro.std...Zavg",                   
      "fBodyGyro.meanFreq...Xavg",              
      "fBodyGyro.meanFreq...Yavg",              
      "fBodyGyro.meanFreq...Zavg",              
      "fBodyAccMag.mean..avg",                  
      "fBodyAccMag.std..avg",                   
      "fBodyAccMag.meanFreq..avg",              
      "fBodyBodyAccJerkMag.mean..avg",          
      "fBodyBodyAccJerkMag.std..avg",           
      "fBodyBodyAccJerkMag.meanFreq..avg",      
      "fBodyBodyGyroMag.mean..avg",             
      "fBodyBodyGyroMag.std..avg",              
      "fBodyBodyGyroMag.meanFreq..avg",         
      "fBodyBodyGyroJerkMag.mean..avg",         
      "fBodyBodyGyroJerkMag.std..avg",          
      "fBodyBodyGyroJerkMag.meanFreq..avg",     
      "angle.tBodyAccMean.gravity.avg",         
      "angle.tBodyAccJerkMean..gravityMean.avg",
      "angle.tBodyGyroMean.gravityMean.avg",    
      "angle.tBodyGyroJerkMean.gravityMean.avg",
      "angle.X.gravityMean.avg",                
      "angle.Y.gravityMean.avg",                
      "angle.Z.gravityMean.avg")

#
# Write the table on the UCI HAR Dataset folder
#
write.table(measure_mean_std_avg,"./UCI HAR Dataset/X_combined_mean_std_avg",row.name=FALSE)
