import os
import pprint
import random
import time

import matplotlib.pyplot as plt
from matplotlib.ticker import (FormatStrFormatter,MaxNLocator)
import numpy as np
import testLSAE

import matlab

pp = pprint.PrettyPrinter()
#%% Initialize Matlab
print("Matlab Initializing")
start = time.time()
client = testLSAE.initialize()
end = time.time()
print("Matlab Initialized")
print(end - start)
#%% Build inputs
folder = "\\\\ROOT\\projects\\IPH_PlantPathology\\Testing\\LEA\\"
testSPD = folder + "SPDs\\A0063110109SPD w SAF .txt"
testIES = folder + "IES Files\\110109_LightLab_scaledLR.ies"
spdData = np.loadtxt(fname=testSPD)
cwd = os.getcwd()
jobNum = random.randint(1000, 10000)
outPath = cwd+'\\'+str(jobNum)+'test.png'
print(outPath)
#%% Define test Data Stucture
testData = dict()
testData['Price'] = matlab.double([569])
testData['enCost'] = matlab.double([0.1048])
testData['LampLife'] = matlab.double([10000])
testData['LampCost'] = matlab.double([120])
testData['LampLabor'] = matlab.double([16])
testData['ReflectorLife'] = matlab.double([10000])
testData['ReflectorCost'] = matlab.double([40])
testData['ReflectorLabor'] = matlab.double([69])
testData['BallastLife'] = matlab.double([50000])
testData['BallastCost'] = matlab.double([200])
testData['BallastLabor'] = matlab.double([70])
testData['Source'] = 'HPS'
testData['LLF'] = matlab.double([0.9])
testData['Years'] = matlab.double([20])
testData['oppHrs'] = matlab.double([3000])  # hours per year
testData['installRate'] = matlab.double([69])
testData['Spectrum'] = matlab.double(spdData.tolist())
if testData['Spectrum'].size[1] != 2:
    raise Exception('Spectrum may be in the wrong orientation')
testData['ISOPlot'] = cwd+'\\'+str(jobNum)+'IsoPlot.png'
testData['IntensityDistplot'] = cwd+'\\'+str(jobNum)+'IntensityDistplot.png'

compSPD = folder + "SPDs\\A0063110104 knob 1000SPD w SAF .txt"
compIES = folder + "IES Files\\110104_LightLab_scaledLR.ies"
spdData = np.loadtxt(fname=compSPD)

#%% Define comparison Data Stucture
compData = dict()
compData['Price'] = matlab.double([2000])
compData['enCost'] = matlab.double([0.1048])
compData['LampLife'] = matlab.double([5000])
compData['LampCost'] = matlab.double([135])
compData['LampLabor'] = matlab.double([16])
compData['ReflectorLife'] = matlab.double([10000])
compData['ReflectorCost'] = matlab.double([53])
compData['ReflectorLabor'] = matlab.double([69])
compData['BallastLife'] = matlab.double([50000])
compData['BallastCost'] = matlab.double([200])
compData['BallastLabor'] = matlab.double([70])
compData['Source'] = 'HPS'
compData['LLF'] = matlab.double([0.9])
compData['Years'] = matlab.double([20])
compData['oppHrs'] = matlab.double([3000])  # hours per year
compData['installRate'] = matlab.double([69])
compData['Spectrum'] = matlab.double(spdData.tolist())
if compData['Spectrum'].size[1] != 2:
    raise Exception('Spectrum may be in the wrong orientation')
compData['ISOPlot'] = cwd+'\\'+str(jobNum)+'IsoPlot.png'
compData['IntensityDistplot'] = cwd+'\\'+str(jobNum)+'IntensityDistplot.png'
#%% Run Client
testDict = client.testLSAE(testIES, 300, testData, nargout=1)
compDict = client.compLSAE(compIES, 300, compData, nargout=1)
#%% Convert Matlab Arrays to Numpy Arrays
testDict['Eco']['fix']['TotPay'] = np.array(testDict['Eco']['fix']['TotPay']._data).reshape(
    testDict['Eco']['fix']['TotPay'].size, order='F')
testDict['Spectrum'] = np.array(testDict['Spectrum']._data).reshape(
    testDict['Spectrum'].size, order='F')

testDict['LSAETable']['Avg'] = np.array(testDict['LSAETable']['Avg']._data).reshape(
    testDict['LSAETable']['Avg'].size, order='F')
testDict['LSAETable']['CUavg'] = np.array(testDict['LSAETable']['CUavg']._data).reshape(
    testDict['LSAETable']['CUavg'].size, order='F')
testDict['LSAETable']['LSAE'] = np.array(testDict['LSAETable']['LSAE']._data).reshape(
    testDict['LSAETable']['LSAE'].size, order='F')
testDict['LSAETable']['Max'] = np.array(testDict['LSAETable']['Max']._data).reshape(
    testDict['LSAETable']['Max'].size, order='F')
testDict['LSAETable']['Min'] = np.array(testDict['LSAETable']['Min']._data).reshape(
    testDict['LSAETable']['Min'].size, order='F')
testDict['LSAETable']['MinToAvg'] = np.array(testDict['LSAETable']['MinToAvg']._data).reshape(
    testDict['LSAETable']['MinToAvg'].size, order='F')
testDict['LSAETable']['maxCount'] = np.array(testDict['LSAETable']['maxCount']._data).reshape(
    testDict['LSAETable']['maxCount'].size, order='F')
testDict['LSAETable']['maxToMin'] = np.array(testDict['LSAETable']['maxToMin']._data).reshape(
    testDict['LSAETable']['maxToMin'].size, order='F')
testDict['LSAETable']['mountHeight'] = np.array(testDict['LSAETable']['mountHeight']._data).reshape(
    testDict['LSAETable']['mountHeight'].size, order='F')
testDict['LSAETable']['numLuminaire'] = np.array(testDict['LSAETable']['numLuminaire']._data).reshape(
    testDict['LSAETable']['numLuminaire'].size, order='F')
testDict['LSAETable']['perDif'] = np.array(testDict['LSAETable']['perDif']._data).reshape(
    testDict['LSAETable']['perDif'].size, order='F')
testDict['LSAETable']['targetPPFD'] = np.array(testDict['LSAETable']['targetPPFD']._data).reshape(
    testDict['LSAETable']['targetPPFD'].size, order='F')
testDict['LSAETable']['targetUniform'] = np.array(testDict['LSAETable']['targetUniform']._data).reshape(
    testDict['LSAETable']['targetUniform'].size, order='F')
testDict['LSAETable'].pop('count', None) #Data not needed, and converting to nparray is hard

compDict['Eco']['fix']['TotPay'] = np.array(compDict['Eco']['fix']['TotPay']._data).reshape(
    compDict['Eco']['fix']['TotPay'].size, order='F')
compDict['Spectrum'] = np.array(compDict['Spectrum']._data).reshape(
    compDict['Spectrum'].size, order='F')

compDict['LSAETable']['Avg'] = np.array(compDict['LSAETable']['Avg']._data).reshape(
    compDict['LSAETable']['Avg'].size, order='F')
compDict['LSAETable']['CUavg'] = np.array(compDict['LSAETable']['CUavg']._data).reshape(
    compDict['LSAETable']['CUavg'].size, order='F')
compDict['LSAETable']['LSAE'] = np.array(compDict['LSAETable']['LSAE']._data).reshape(
    compDict['LSAETable']['LSAE'].size, order='F')
compDict['LSAETable']['Max'] = np.array(compDict['LSAETable']['Max']._data).reshape(
    compDict['LSAETable']['Max'].size, order='F')
compDict['LSAETable']['Min'] = np.array(compDict['LSAETable']['Min']._data).reshape(
    compDict['LSAETable']['Min'].size, order='F')
compDict['LSAETable']['MinToAvg'] = np.array(compDict['LSAETable']['MinToAvg']._data).reshape(
    compDict['LSAETable']['MinToAvg'].size, order='F')
compDict['LSAETable']['maxCount'] = np.array(compDict['LSAETable']['maxCount']._data).reshape(
    compDict['LSAETable']['maxCount'].size, order='F')
compDict['LSAETable']['maxToMin'] = np.array(compDict['LSAETable']['maxToMin']._data).reshape(
    compDict['LSAETable']['maxToMin'].size, order='F')
compDict['LSAETable']['mountHeight'] = np.array(compDict['LSAETable']['mountHeight']._data).reshape(
    compDict['LSAETable']['mountHeight'].size, order='F')
compDict['LSAETable']['numLuminaire'] = np.array(compDict['LSAETable']['numLuminaire']._data).reshape(
    compDict['LSAETable']['numLuminaire'].size, order='F')
compDict['LSAETable']['perDif'] = np.array(compDict['LSAETable']['perDif']._data).reshape(
    compDict['LSAETable']['perDif'].size, order='F')
compDict['LSAETable']['targetPPFD'] = np.array(compDict['LSAETable']['targetPPFD']._data).reshape(
    compDict['LSAETable']['targetPPFD'].size, order='F')
compDict['LSAETable']['targetUniform'] = np.array(compDict['LSAETable']['targetUniform']._data).reshape(
    compDict['LSAETable']['targetUniform'].size, order='F')
compDict['LSAETable'].pop('count', None)


#try:
#    os.remove(testDict['ISOPlot'])
#    os.remove(testDict['IntensityDistplot'])
#except:
#    print("Could not delete files")
#%% Print and plot output
pp.pprint(testDict)
fig, ax = plt.subplots()
ax.plot(range(0, int(testDict['Years'])+1), testDict['Eco']['fix']['TotPay']/1000)
ax.plot(range(0, int(compDict['Years'])+1), compDict['Eco']['fix']['TotPay']/1000)
ax.set_xlabel('Years')
ax.xaxis.set_major_locator(MaxNLocator(6,integer=True))
ax.xaxis.set_minor_locator(MaxNLocator(integer=True))
plt.minorticks_on()
ax.set_ylabel('$ (Present Worth)')
ax.yaxis.set_major_formatter(FormatStrFormatter('%d K'))
plt.grid(which='major')
plt.grid(which='minor', linestyle=':')
plt.show(block=False)
plt.savefig(outPath)
fig, ax = plt.subplots()
maxVal = testDict['Spectrum'][:, 1].max()
ax.plot(testDict['Spectrum'][:, 0], (testDict['Spectrum'][:, 1]/maxVal))
plt.show(block=False)
plt.close('all')
