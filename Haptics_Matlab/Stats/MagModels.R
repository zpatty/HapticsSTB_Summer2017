library( ez); library( ggplot2); library( nlme); library( pastecs); library( reshape); library( WRS2)

baseline <- lme(Mag ~ 1, random = ~1|Sub/Phase, data = data, method = "ML")

phaseM <- update(baseline, .~. + Phase)

groupM <- update(phaseM, .~. + Group)

phase_group <- update(groupM, .~. + Phase:Group)

anova(baseline, phaseM, groupM, phase_group)