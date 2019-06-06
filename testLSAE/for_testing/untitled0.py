# -*- coding: utf-8 -*-
"""
Created on Mon Apr 15 09:50:36 2019

@author: plummt
"""

import cdflib
import pprint
import numpy as np
cdf_file = cdflib.CDF("C:\\Users\\plummt\\Desktop\\DaysimetersDataLogs\\testing\\0070-2019-04-08-11-06-59.cdf")
pp = pprint.PrettyPrinter()

calFact = cdf_file.attget(attribute='creationDate',entry = 0)
time2 = cdflib.cdfepoch.breakdown(calFact['Data'][0],to_np=1)
pp.pprint(calFact)
#pp.pprint(calFact['Data'][0])
time = cdf_file.varget(variable='red')
pp.pprint(time)