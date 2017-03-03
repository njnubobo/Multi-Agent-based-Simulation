# -*- encoding: utf-8 -*-
__author__ = 'bbo'
import random

class Agent(object):
    '''
    定义智能体的类
    1表示策略盲从，0表示策略分析
    '''
    def __init__(self, opinionValue):
        self.opinionValue = opinionValue
        self.memory = []
        self.prop = 0.0
        self.profit = 0.0
        self.strategy = 0
        self.opinionHistory = []


def chooseStrategy(agent1, agent2, y, r):
    dValue = abs(agent1.opinionValue - agent2.opinionValue)
    if dValue == 0:
        return False
        #dValue = 0.0001
    deltaG1 = r + (1 - y) / dValue
    print deltaG1
    if deltaG1 < 0:
        agent1.strategy = 1
        agent2.strategy = 1
    elif deltaG1 > 0:
        agent1.strategy = 0
        agent2.strategy = 0
    else:
        agent1.strategy = random.randint(0, 1)
        agent2.strategy = random.randint(0, 1)
    #更新记忆列表
    del agent1.memory[-1]
    del agent2.memory[-1]
    agent1.memory = [agent1.strategy] + agent1.memory
    agent2.memory = [agent2.strategy] + agent2.memory


def game(agent1, agent2, threshold, Mu, y, r):
    if abs(agent1.opinionValue-agent2.opinionValue) < threshold:
        #先进行博弈选择策略
        chooseStrategy(agent1, agent2, y, r)
        #再修改观点值
        agent1.opinionValue += Mu * (agent2.opinionValue - agent1.opinionValue)
        agent2.opinionValue += Mu * (agent1.opinionValue - agent2.opinionValue)
        #根据记忆计算概率
        agent1.prop = sum(agent1.memory) / len(agent1.memory)
        agent2.prop = sum(agent2.memory) / len(agent2.memory)
        return True
    else:
        return False


def simulation(n, t, r, k, Mu, y, m):
    '''
    :param n: 网络节点
    :param t: 迭代次数
    :param r: 交互收益
    :param k: 社会距离的系数
    :param Mu: 调节观点值
    :param y: 分析成本与额外收益的比例
    :param m: 记忆长度
    :return:
    '''
    threshold = k / r
    agents = []
    opinions = []
    for i in range(n):
        #初始化n个节点
        agent = Agent(random.random())
        for j in range(m):
            agent.memory.append(random.randint(0, 1))
        agents.append(agent)
    '''
    for j in range(t):
        #开始迭代,每次迭代t对节点
        num = 0
        index1, index2 = random.sample([i for i in range(n)], 2)
        while num < 5:
            if game(agents[index1], agents[index2], threshold, Mu, y, r):
                num += 1
            index1, index2 = random.sample([i for i in range(n)], 2)
        for agent in agents:
            #记录观点值的坐标
            opinions.append((j + 1, agent.opinionValue))
    '''
    import matplotlib.pyplot as plt
    fig = plt.figure(1)
    ax1 = fig.add_subplot(211)
    ax2 = fig.add_subplot(212)
    PRO = []
    for j in range(t):
        #所有节点两两配对
        X = [x for x in range(n)]
        count = 0
        while len(X) > 1:
            index1, index2 = random.sample(X, 2)
            game(agents[index1], agents[index2], threshold, Mu, y, r)
            X.remove(index2)
            X.remove(index1)
        for agent in agents:
            agent.opinionHistory.append(agent.opinionValue) #记录历史观点值
            if agent.strategy == 1:
                count += 1 #统计盲从比例
        pro = 1. * count / n
        PRO.append(pro)

    plt.sca(ax1)
    for i in range(n):
        ax1.plot([k for k in range(n)], agents[i].opinionHistory, color='k')
    plt.xlabel("Time")
    plt.ylabel("OpinionValue")

    plt.sca(ax2)
    ax2.plot([k for k in range(n)], PRO, color = 'k')
    plt.xlabel("Time")
    plt.ylabel("The prob of M")
    plt.show()




def show(points):
    import matplotlib.pyplot as plt
    import numpy as np
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.scatter([point[0] for point in points], [point[1] for point in points], s = 1)
    plt.xlabel("Time")
    plt.ylabel("OpinionValue")
    plt.show()

if __name__ == '__main__':
    simulation(n = 100, t = 100, r = 1.5, k = 0.3, Mu = 0.5, y = 1.1, m = 5)

