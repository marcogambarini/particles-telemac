# droguemaker
# 14 jan 2021
#
# (1-optional) reads data from previous computation
# (2) prepares drogue positioning randomly around a point

import numpy as np
import matplotlib.pyplot as plt

makePlots = False
writeFile = True

restart = False
restartFile = 'particleFiles/randpart6.csv'
outputFile = 'droguefile.txt'

#simulation setup
nSteps = 6840
timeStep = 10
initialTime = 0

#inflow parameters (piecewise linear function)
tData = [0, 600, 2400, 16400, 54000, 64800]
QData = [0, 0, 0, 350, 350, 0]

particleReleaseStart = 1
#particle release period (number of timesteps)
particleReleaseStep = 18
#particles released at each release step N = k * Q(t)
k = 1/35

xc = 645470.
yc = 5080215.
R = 50.

zSurf = 64.

x = []
y = []
z = []
lab = []
tRelease = []
if (restart):
    with open(restartFile) as f:
        i = 0
        for line in f:
            #ignore first line (header)
            if i>0:
                data = line.split(',')
                x.append(float(data[0]))
                y.append(float(data[1]))
                z.append(float(data[2]))
            #str(int(...)) to avoid \n character
                lab.append('R' + str(int(data[3])))
#restart particles added at step 1 (still can't add particles at step zero...)
                tRelease.append(1)
            i = i+1

t = range(0, timeStep*nSteps, timeStep)
#piecewise linear interpolation
Q = np.interp(t, tData, QData)
nPart = np.zeros(len(t))



for j in range(particleReleaseStart, nSteps, particleReleaseStep):
    nPart[j] = int(np.floor(k*Q[j]))
    for jj in range(1, int(nPart[j])):
        rNew = np.random.uniform(0, 1)
        thetaNew = 2 * np.pi * np.random.uniform(0, 1)

        xNew = xc + R*rNew*np.cos(thetaNew)
        yNew = yc + R*rNew*np.sin(thetaNew)
        labNew = j*100 + jj

        x.append(xNew)
        y.append(yNew)
        z.append(zSurf)
        lab.append(labNew)
        tRelease.append(j)


print('Total number of particles: ', len(x))


if (writeFile):
    with open(outputFile, 'w') as f:
        f.write(str(len(x))+'\n')
        f.write('LABEL, RELEASE TIME STEP, X, Y, Z\n')
        for i in range(0, len(x)-1):
            print('%d, %d, %9.2f, %9.2f, %9.2f'%(lab[i], tRelease[i],
                  x[i], y[i], z[i]), file=f)

if (makePlots):
    for i in range(0, len(nPart)):
        if nPart[i]==0:
            nPart[i]=np.NaN

    ax1 = plt.subplot()
    ax1.plot(t, Q)
    ax2 = ax1.twinx()
    ax2.plot(t, nPart, '*')
    ax2.set_ylim(0, 11)
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Flow rate ($m^3/s$)')
    ax2.set_ylabel('Number of particles released')
    plt.show()
