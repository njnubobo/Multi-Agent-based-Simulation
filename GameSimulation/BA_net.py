# -*- encoding: utf-8 -*-
__author__ = 'bbo'

import networkx as nx
import matplotlib.pyplot as plt
import pickle

BA= nx.random_graphs.barabasi_albert_graph(10000, 10)  #生成n=10000、m=10的BA无标度网络
pos = nx.spring_layout(BA)          #定义一个布局，此处采用了spring布局方式
#nx.draw(BA,pos,with_labels=False, node_size = 60)  #绘制图形
#plt.show()

output = open('BA_model.pkl', 'wb')
pickle.dump(BA, output)
output.close()








'''
import random
import numpy as np

def BA(m, n, add):
    Nodes = np.zeros((n, 2))
    degrees = np.zeros((1, n))
    #degrees = []
    links = np.zeros((n, n))

    for i in range(m):
        #初始化m个节点
        x = 10 * random.random()
        y = 10 * random.random()
        Nodes[i] = (x, y)
        for j in range(m):
            links[i][j] = 1
        degrees[0][i] = m - 1
        #degrees.append(m - 1)

    for N in range(m, n):
        #添加节点
        x = 10 * random.random()
        y = 10 * random.random()
        Nodes[N] = (x, y)
        p = [1.0 * degree/sum(degrees[0][:N]) for degree in degrees[0][:N]]
        index = np.argsort(-np.array(p))[:add].tolist()
        for j in index:
            links[N][j] = 1
            degrees[0][j] += 1
        degrees[0][N] = add
    return Nodes, degrees, links

def show(nodes, links):
    import matplotlib.pyplot as plt
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.scatter([nodes[i][0] for i in range(nodes.shape[0])], [nodes[i][1] for i in range(nodes.shape[0])])
    x, y = links.shape
    for i in range(1, x):
        for j in range(i):
            if links[i][j] == 1:
                ax.plot([nodes[i][0], nodes[j][0]], [nodes[i][1], nodes[j][1]], color = 'k')

    plt.show()


if __name__ == '__main__':
    nodes, degrees, links = BA(8, 100, 5)
    show(nodes, links)


'''







