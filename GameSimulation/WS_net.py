# -*- encoding: utf-8 -*-
__author__ = 'bbo'
import networkx as nx
import matplotlib.pyplot as plt
import pickle

WS = nx.random_graphs.watts_strogatz_graph(30, 3, 0.2)
pos = nx.circular_layout(WS)
output = open('WS_model.pkl', 'wb')
pickle.dump(WS, output)
nx.draw(WS, pos, with_labels= False, node_size = 30)
plt.show()