#This scrip dowloads the file from the provided url and uzips it in whatever work directory
#you have setup when you run the code.

#I assume you let the program unzip the files and that you don't move them around.  If you do you 
#will need to remap all of the work directory appropriately.

#In order to save space this program deletes items as soon as they are not needed and takes
#out the trash.  If you want to debug the program or look at intermediated data frames
#you will need to comment out the appropriate rm()

#If you have issues with the dataset being too big for memory a quick fix may be to uncomment
#and run the next two lines of code.
#rm(list=ls(all=TRUE))
#gc

#If you want to specify the directory where all of this takes place please 
#uncomment the next line and replace "MY DIRECTORY" where you'd like it to go
#setwd("MY DIRECTORY")

#pull the file from the internet
download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "project.zip")

#unzip the file
unzip("project.zip")

#You need the reshape2 package for this to run.  If you don't have it installed please install it
#or uncommnent the line below
#install.packages("reshape2")

#Need for melt and recast.  If you have questions you will have to use the googlez
library(reshape2)

#You should create one R script called run_analysis.R that does the following.


#get the current working directory
wd = getwd()

#Get labels and activity types
#Build out path to where labels are
lab_wd= paste(wd, "UCI HAR Dataset/", sep="/")

#Change working directory to where labels are
setwd(lab_wd)

#Read in features labels
feat_labs = read.table("features.txt")

#Read in activity types
act_types = read.table("activity_labels.txt")

#Change column names
colnames(act_types) = c("Activity_Number", "Activity_Performed")


#Setup Train and Test Dirs
#Build out train directory
train_wd = paste(wd, "UCI HAR Dataset/train", sep="/")

#Build out train directory
test_wd = paste(wd, "UCI HAR Dataset/test", sep="/")

#Read in and process the train data*************************************************

#set train wd
setwd(train_wd)

#Read in the subjects file
sub_train = read.table("subject_train.txt")

#Update column names to 'subject number'
colnames(sub_train)= "Subject_Number"

#Read in X train
x_train = read.table("X_train.txt")

#Assign proper cloumn names
colnames(x_train) = feat_labs$V2

#Parse only columns with std or mean in name to save space and speed it up.
#Get all of the column names to check for 'mean' and 'std'
cols = colnames(x_train)

#Grep out the mean and std
std_cols = grep("std", cols)
mean_cols = grep("mean", cols)

#limit X to only relevant columns
x_train = x_train[,c(mean_cols, std_cols)]


#Read in Y Train
y_train = read.table("y_train.txt")

#Update the row values to actual activity names
y_clean = merge(x=y_train, y=act_types, all.x=TRUE)
Activity_Performed = y_clean$Activity_Performed

#Merge into one dataset
Merged_Train = cbind(sub_train, Activity_Performed, x_train)

#Remove underlying inputs no longer needed and take to trash
rm(y_clean)
rm(y_train)
rm(x_train)
rm(sub_train)
gc()
gc()

#End Reading in Train Data*********************************************************

#Read in and process the Test data*************************************************
setwd(test_wd)

#Read in the subjects file
sub_test = read.table("subject_test.txt")

#Update column names to 'subject number'
colnames(sub_test)= "Subject_Number"

#Read in X test
x_test = read.table("X_test.txt")

#Assign proper cloumn names
colnames(x_test) = feat_labs$V2

#Parse only columns with std or mean in name to save space and speed it up.
#Get all of the column names to check for 'mean' and 'std'
cols = colnames(x_test)

#Grep out the mean and std
std_cols = grep("std", cols)
mean_cols = grep("mean", cols)

#limit X to only relevant columns
x_test = x_test[,c(mean_cols, std_cols)]

#Read in Y Test
y_test = read.table("y_test.txt")

#Update the row values to actual activity names
y_clean = merge(x=y_test, y=act_types, all.x=TRUE)
Activity_Performed = y_clean$Activity_Performed

#Merge into one dataset
Merged_Test = cbind(sub_test, Activity_Performed, x_test)

#Remove underlying inputs no longer needed and take to trash
rm(y_clean)
rm(y_test)
rm(x_test)
rm(sub_test)
gc()
gc()

#End Reading in Test Data**********************************************************



#Append the train to the test
Full_Set = rbind(Merged_Train, Merged_Test)

#Clean House
rm(Merged_Test)
rm(Merged_Train)
rm(act_types)
rm(feat_labs)
rm(Activity_Performed)
rm(lab_wd)
rm(test_wd)
rm(train_wd)
rm(cols)
rm(mean_cols)
rm(std_cols)
gc()
gc()



#Melt the data set so we can find the mean of columns with groupings in c()
Final_Melted = melt(Full_Set, id = c("Activity_Performed", "Subject_Number"))

#Clean up the variable names.  I did it here because they are in a nice row $variable
#Make names entirely lower case
Final_Melted$variable=tolower(Final_Melted$variable)

#Get rid of the ()
Final_Melted$variable = gsub("()","",Final_Melted$variable, fixed=TRUE)

#Replace all of the - with _
Final_Melted$variable = gsub("-","_",Final_Melted$variable, fixed=TRUE)

#Add mean of to the column names
Final_Melted$variable = paste("mean_of_",Final_Melted$variable,  sep="")


#Recast into final tidy data set.
Final_Recast = dcast(Final_Melted, Activity_Performed + Subject_Number ~ variable, mean)

#I output the file in the base work directory.  If you'd like it to go someplace else please
#edit the work directory change in the next line of code.

#Point working directory back to default
setwd(wd)

printout = paste("file has been created here: ", wd, sep="")

rm(wd)
gc()


#Write out the final file
write.table(Final_Recast, "tidy_data.txt", sep = ",",row.names = FALSE, col.names=TRUE)

#Delete source combined table and garbage clean
rm(Full_Set)
rm(Final_Melted)
rm(Final_Recast)
gc()

print(printout)
rm(printout)


