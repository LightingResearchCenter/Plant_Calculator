import testLSAE
import matlab
import numpy as np
import pprint

import matplotlib.pyplot as plt
import os
import random
# import os
import time
pp = pprint.PrettyPrinter()
## Initialize Matlab
print("Matlab Initializing")
start = time.time()
client = testLSAE.initialize()
end = time.time()
print("Matlab Initialized")
print(end - start)
## Build inputs
testSPD = "\\\\ROOT\\projects\\IPH_PlantPathology\\Testing\\LEA\\SPDs\\A0063110109SPD w SAF .txt"
testIES = "\\\\ROOT\\projects\\IPH_PlantPathology\\Testing\\LEA\\IES Files\\110109_LightLab_scaledLR.ies"
spdData = np.loadtxt(fname=testSPD)
SPD = "C:\\Users\\plummt\\Documents\\MATLAB\\Plant_Calculator - Copy\\CIED65.txt"
IES = "C:\\Users\\plummt\\Documents\\MATLAB\\Plant_Calculator - Copy\\CMH20MR16-830-FL_(85110).ies"
cwd = os.getcwd()
jobNum = random.randint(1000,10000)
outPath = cwd+'\\'+str(jobNum)+'test.png'
print(outPath)
## Define Data Stucture
Data = dict()
Data['Price'] = matlab.double([525])
Data['enCost'] = matlab.double([0.1048])
Data['LampLife'] = matlab.double([10000])
Data['LampCost'] = matlab.double([120])
Data['LampLabor'] = matlab.double([16])
Data['ReflectorLife'] = matlab.double([10000])
Data['ReflectorCost'] = matlab.double([40])
Data['ReflectorLabor'] = matlab.double([69])
Data['BallastLife'] = matlab.double([50000])
Data['BallastCost'] = matlab.double([200])
Data['BallastLabor'] = matlab.double([70])
Data['Source'] = 'HPS'
Data['LLF'] =matlab.double([0.9])
Data['Years'] = matlab.double([20])
Data['oppHrs'] = matlab.double([3000]) #hours per year
Data['installRate'] = matlab.double([69])
Data['Spectrum'] = matlab.double(spdData.tolist())
if Data['Spectrum'].size[1]!= 2:
   raise Exception('Spectrum may be in the wrong orientation')

Data['ISOPlot'] = cwd+'\\'+str(jobNum)+'IsoPlot.png'
Data['IntensityDistplot'] = cwd+'\\'+str(jobNum)+'IntensityDistplot.png'
## Run Client
testDict = client.testLSAE(testIES,300,Data,nargout=1)

## Convert Matlab Arrays to Numpy Arrays
testDict['Eco']['fix']['TotPay'] = np.array(testDict['Eco']['fix']['TotPay']._data).reshape(testDict['Eco']['fix']['TotPay'].size, order='F')
testDict['Spectrum'] = np.array(testDict['Spectrum']._data).reshape(testDict['Spectrum'].size, order='F')

## Print and plot output
pp.pprint(testDict)
plt.figure()

plt.plot(range(0,int(testDict['Years'])+1),testDict['Eco']['fix']['TotPay'])
plt.xlabel('Years') 
plt.xticks
# naming the y axis 
plt.ylabel('$ (Present Worth)') 

plt.figure()
maxVal = max(testDict['Spectrum'][:,1])
plt.plot(testDict['Spectrum'][:,0],(testDict['Spectrum'][:,1]/maxVal))
plt.close('all')