EnsurePackage<-function(x)
{
  x<-as.character(x)
  if (!require(x,character.only=TRUE))
  {
    install.packages(pkgs=x,dependencies = TRUE)
    require(x,character.only=TRUE)
  }
}
EnsurePackage("h2o")


data_modelling <- readRDS("C:/Users/user/Documents/PSU/DataFest/data_modelling.RDS")
data_modelling$date <- NULL
data_modelling$companyId <- NULL
data_modelling$jobId <- NULL
data_modelling[is.na(data_modelling$NAICS_Category),c("NAICS_Category")] <- "Unknown"
data_modelling$normTitleCategory <- NULL
data_modelling$clicks <- NULL
data_modelling$localClicks <- NULL
data_modelling$Cumulative_clicks <- NULL
data_modelling$Cumulative_localclicks <- NULL
data_modelling$descriptionWordCount <- NULL
data_modelling$jobAgeDays <- NULL
data_modelling$jobDemand_Clicks <- NULL
data_modelling$jobDemand_localClicks <- NULL


#Fixing the demand index of VA and PR
data_modelling[data_modelling$stateProvince=="VA", c("state_population")] <- 8470000
data_modelling[data_modelling$stateProvince=="VA", c("demandIndex")] <- data_modelling[data_modelling$stateProvince=="VA",
                                                                                       c("jobDemand_Clicks")]/8470000
data_modelling[data_modelling$stateProvince=="PR", c("state_population")] <- 3337000
data_modelling[data_modelling$stateProvince=="PR", c("demandIndex")] <- data_modelling[data_modelling$stateProvince=="PR",
                                                                                       c("jobDemand_Clicks")]/3337000
data_modelling <- data_modelling[!(is.na(data_modelling$state_population)),]

#Checking and fixing attrs with high skewness
data_modelling$estimatedSalary <- as.numeric(data_modelling$estimatedSalary)
get.skewness <- data.frame(apply(data_modelling[,c("numReviews","avgOverallRating","descriptionCharacterLength",
                                                   "experienceRequired","estimatedSalary","state_population")],2,moments::skewness))
colnames(get.skewness) <- c("skewness")
get.skewness$Attrs <- rownames(get.skewness)
skewed.attrs <- get.skewness[get.skewness$skewness>2|get.skewness$skewness < -2,]

data_modelling$numReviews <- data_modelling$numReviews+1
data_modelling$experienceRequired <- data_modelling$experienceRequired+1

lambda <- BoxCoxTrans(data_modelling$numReviews)
data_modelling$numReviews <- predict(lambda,data_modelling$numReviews)

lambda <- BoxCoxTrans(data_modelling$experienceRequired)
data_modelling$experienceRequired <- predict(lambda,data_modelling$experienceRequired)

data_modelling$demandIndex <- data_modelling$demandIndex * 100000
data_modelling2 <- data_modelling
data_modelling$state_population <- NULL

data_modelling$stateProvince <- NULL
data_modelling$city <- NULL

#Train/Test Partition
set.seed(20)
index <- createDataPartition(data_modelling$demandIndex,p=0.8,list = FALSE, times = 1)
train <- data_modelling[index,]
test <- data_modelling[-index,]

#Using h2o package to run gbm, random forest and neural network
h2o.init(nthreads = -1,max_mem_size = "16G")
train.h2o <- as.h2o(train)
test.h2o <- as.h2o(test)
y <- "demandIndex"
x <- setdiff(names(train), c(y))

gbm <- h2o.gbm(x=x, y=y, training_frame = train.h2o, nfold=10)
h2o.rmse(h2o.performance(gbm,newdata = test.h2o))
h2o.varimp_plot(gbm)

rf <- h2o.randomForest(x=x, y=y, training_frame = train.h2o)
h2o.rmse(h2o.performance(rf,newdata = test.h2o))

nn <- h2o.deeplearning(model_id="m2",training_frame = train.h2o, validation_frame = test.h2o, x=x, y=y, 
                       epochs = 5, stopping_rounds=2,stopping_metric="MSE",
                       variable_importances = T)
h2o.varimp_plot(nn)
