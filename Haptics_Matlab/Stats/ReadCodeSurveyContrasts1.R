squeezeData <- read.csv("SqueezeSurveyR.dat", sep = ',',header = TRUE, na.strings = 'NaN')
squeezeData$Group <- factor(squeezeData$Group)
squeezeData$Phase <- factor(squeezeData$Phase)

library( ez); library( ggplot2); library( nlme); library( pastecs); library( reshape); library( WRS2)

# standard contrast (Phase1vs2 and Phase1vs3)
Phase1vs2 <- c(0,1,0)
Phase1vs3 <- c(0,0,1)
contrasts(squeezeData$Phase)<-cbind(Phase1vs2,Phase1vs3)

baselineQ1 <- lme(Q1 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit,method = "ML")
phaseQ1 <- update(baselineQ1, .~. + Phase)
groupQ1 <- update(phaseQ1, .~. + Group)
phase_group_Q1 <- update(groupQ1, .~. + Phase:Group)
anova(baselineQ1, phaseQ1, groupQ1, phase_group_Q1)
#summary(phase_group_Q1)
#by(squeezeData$Q1, list(squeezeData$Phase),stat.desc,basic = FALSE)
#by(squeezeData$Q1, list(squeezeData$Group),stat.desc,basic = FALSE)

baselineQ2 <- lme(Q2 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ2 <- update(baselineQ2, .~. + Phase)
groupQ2 <- update(phaseQ2, .~. + Group)
phase_group_Q2 <- update(groupQ2, .~. + Phase:Group)
anova(baselineQ2, phaseQ2, groupQ2, phase_group_Q2)

baselineQ3 <- lme(Q3 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ3 <- update(baselineQ3, .~. + Phase)
groupQ3 <- update(phaseQ3, .~. + Group)
phase_group_Q3 <- update(groupQ3, .~. + Phase:Group)
anova(baselineQ3, phaseQ3, groupQ3, phase_group_Q3)

baselineQ4 <- lme(Q4 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ4 <- update(baselineQ4, .~. + Phase)
groupQ4 <- update(phaseQ4, .~. + Group)
phase_group_Q4 <- update(groupQ4, .~. + Phase:Group)
anova(baselineQ4, phaseQ4, groupQ4, phase_group_Q4)

baselineQ5 <- lme(Q5 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ5 <- update(baselineQ5, .~. + Phase)
groupQ5 <- update(phaseQ5, .~. + Group)
phase_group_Q5 <- update(groupQ5, .~. + Phase:Group)
anova(baselineQ5, phaseQ5, groupQ5, phase_group_Q5)

baselineQ6 <- lme(Q6 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ6 <- update(baselineQ6, .~. + Phase)
groupQ6 <- update(phaseQ6, .~. + Group)
phase_group_Q6 <- update(groupQ6, .~. + Phase:Group)
anova(baselineQ6, phaseQ6, groupQ6, phase_group_Q6)

baselineQ7 <- lme(Q7 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ7 <- update(baselineQ7, .~. + Phase)
groupQ7 <- update(phaseQ7, .~. + Group)
phase_group_Q7 <- update(groupQ7, .~. + Phase:Group)
anova(baselineQ7, phaseQ7, groupQ7, phase_group_Q7)

baselineQ8 <- lme(Q8 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ8 <- update(baselineQ8, .~. + Phase)
groupQ8 <- update(phaseQ8, .~. + Group)
phase_group_Q8 <- update(groupQ8, .~. + Phase:Group)
anova(baselineQ8, phaseQ8, groupQ8, phase_group_Q8)

baselineQ9 <- lme(Q9 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ9 <- update(baselineQ9, .~. + Phase)
groupQ9 <- update(phaseQ9, .~. + Group)
phase_group_Q9 <- update(groupQ9, .~. + Phase:Group)
anova(baselineQ9, phaseQ9, groupQ9, phase_group_Q9)

baselineQ10 <- lme(Q10 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ10 <- update(baselineQ10, .~. + Phase)
groupQ10 <- update(phaseQ10, .~. + Group)
phase_group_Q10 <- update(groupQ10, .~. + Phase:Group)
anova(baselineQ10, phaseQ10, groupQ10, phase_group_Q10)

baselineQ11 <- lme(Q11 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ11 <- update(baselineQ11, .~. + Phase)
groupQ11 <- update(phaseQ11, .~. + Group)
phase_group_Q11 <- update(groupQ11, .~. + Phase:Group)
anova(baselineQ11, phaseQ11, groupQ11, phase_group_Q11)

baselineQ12 <- lme(Q12 ~ 1, random = ~1|Sub/Phase, data = squeezeData, na.action=na.omit, method = "ML")
phaseQ12 <- update(baselineQ12, .~. + Phase)
groupQ12 <- update(phaseQ12, .~. + Group)
phase_group_Q12 <- update(groupQ12, .~. + Phase:Group)
anova(baselineQ12, phaseQ12, groupQ12, phase_group_Q12)

#### Summary of signficant results ####
summary(phase_group_Q3)
by(squeezeData$Q3, list(squeezeData$Phase),stat.desc,basic = FALSE)
by(squeezeData$Q3, list(squeezeData$Group),stat.desc,basic = FALSE)

summary(phase_group_Q4)
by(squeezeData$Q4, list(squeezeData$Group),stat.desc,basic = FALSE)

summary(phase_group_Q6)
by(squeezeData$Q6, list(squeezeData$Group),stat.desc,basic = FALSE)

summary(phase_group_Q7)
by(squeezeData$Q7, list(squeezeData$Phase,squeezeData$Group),stat.desc,basic = FALSE)

summary(phase_group_Q8)
by(squeezeData$Q8, list(squeezeData$Phase),stat.desc,basic = FALSE)

summary(phase_group_Q11)
by(squeezeData$Q11, list(squeezeData$Phase),stat.desc,basic = FALSE)