# -*- encoding: utf-8 -*-
__author__ = 'bbo'

import matplotlib.pyplot as plt
import os
import pickle


ax = plt.subplot(111)
Vg = ['Vg=200', 'Vg=300', 'Vg=350', 'Vg=400', 'Vg=500', 'Vg=1000', 'Vg=2000']
Ep = ['ep=0.1', 'ep=0.2', 'ep=0.4', 'ep=0.7', 'ep=1']

i = 0
lis = [os.listdir('Guo')[2]] + os.listdir('Guo')[7:11]
for filename in lis:
    print filename
    file = open('Guo/' + filename, 'rb')
    All = pickle.load(file)
    all = [All[j] for j in range(0, 4000, 10)]
    pl = ax.plot(range(0, 4000, 10), all, label = Ep[i])
    i += 1

handles, labels = ax.get_legend_handles_labels()
ax.legend(handles[::], labels[::])
plt.xlabel('time')
plt.ylabel('spread number')
plt.show()