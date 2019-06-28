# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 16:47:32 2019

@author: plummt
"""
import numpy as np
def calcEconomics(qty, data=None):
    if data is None:
        data= dict()
        data['opHrs'] = 3000
        data['installRate'] = 69 #$ per fixture from:RSMeans data 2017
        data['enCost'] = 0.1048#$ per kW
        data['fixCost'] = 525 #$
        data['lampCost'] = 120 #$
        data['ballastCost'] = 40 #$
        data['lampLife'] = 10000 #hrs
        data['ballastLife'] = 10000 #hrs
        data['LaborRate'] = 16 #$perHr
        data['installTime'] = 1 #hrs
        data['replaceLampTime'] = 1 #hrs
        data['replaceBallastTime'] = .5 #hrs
        data['cleanTime'] = .5 #hrs
        data['Watt'] = 1057.3 #Watts
        data['isLED'] = False
    # room Diminsions
    roomLength = 30
    roomWidth = 36
    ftArea = roomWidth*roomLength
    mArea = (roomWidth*0.3048)*(roomLength*0.3048)
    pv = np.ma.round(np.pv(0.03,range(21),0,1),3)*-1
    
    eco = dict()
    #Initial Costs
    eco['Init'] = qty*(data['fixCost']+data['installRate'])
    eco['InitFt'] = eco['Init']/ftArea
    eco['InitM'] = eco['Init']/mArea
    #Wattage per area
    eco['WFt'] = (data['Watt']*qty)/ftArea
    eco['WM'] = (data['Watt']*qty)/mArea
    #Wattage per year
    eco['kWYr'] = (data['Watt']/1000)*data['opHrs']*qty
    eco['kWYrFt'] = eco['kWYr']/ftArea
    eco['kWYrM'] = eco['kWYr']/mArea
    #Energy cost per year
    eco['enCostYr'] = eco['kWYr']*data['enCost']
    eco['enCostYrFt'] = eco['enCostYr']/ftArea
    eco['enCostYrM'] = eco['enCostYr']/mArea
    
    # 20Year Cost Calculation
    years = np.array(range(21))
    oppHours = years*data['opHrs']
    relampInt = (np.array([np.mod(oppHours[range(1,21)],data['lampLife'])])-np.array([np.mod(oppHours[range(0,20)],data['lampLife'])]))<0
    relampInt = np.insert(relampInt[0],0,0)
    np.size(relampInt.T)
    print(relampInt.T)
    print(eco)
    return eco, relampInt


