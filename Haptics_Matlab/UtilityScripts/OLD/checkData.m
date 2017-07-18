close all

x = STBToolbox.StbSubject('/Volumes/STB1/STB_Test_Data');

nSubjects = length(x);

for sub = 1:nSubjects
    ntasks = length(x(sub).task);
    for tsk = 1:ntasks
        nTrials = length(x(sub).task(tsk).trial);
        for tri = 1:nTrials
            x(sub).task(tsk).trial(tri).plotAcc;
            set(gcf, 'units', 'normalized', 'OuterPosition', [0 0 1 1/3])
            x(sub).task(tsk).trial(tri).plotForces;
            set(gcf, 'units', 'normalized', 'OuterPosition', [0 1/3 1 1/3])
            x(sub).task(tsk).trial(tri).plotMom;
            set(gcf, 'units', 'normalized', 'OuterPosition', [0 2/3 1 1/3])
            pause
            close all
        end
    end
end

            