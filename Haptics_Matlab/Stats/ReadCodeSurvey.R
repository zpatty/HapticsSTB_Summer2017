squeezeData <- read.csv("SqueezeSurveyR.dat", sep = ',',header = TRUE)
squeezeData$Group <- factor(squeezeData$Group)
squeezeData$Phase <- factor(squeezeData$Phase)