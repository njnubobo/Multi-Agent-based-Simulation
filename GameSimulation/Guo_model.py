# -*- encoding: utf-8 -*-
__author__ = 'bbo'

'''
策略：{传播，不传播}用{1,0}表示
个体状态：舆情未传播状态（S）、舆情传播状态（I）、舆情疲劳状态（C）、舆情遗忘状态（R）

'''
import pickle
import matplotlib.pyplot as plt
import math
import random
import codecs

def Get_BA_model(file_Name):
    '''
    从本地读入网络模型
    '''
    file = open(file_Name, 'rb')
    model = pickle.load(file)
    return model

class Agent(object):
    def __init__(self, label):
        self.state = 'R'
        self.strategy = -1
        self.label = label

def init(model):
    Agents = []
    labels = model.nodes()
    for label in labels:
        agent = Agent(label)
        agent.state = ''
        Agents.append(agent)
    return Agents

def simulation(T, BA_model, bp, ep, Vg, u, deltag, alpha, beta, omiga, theta, phi, rho):
    Agents = init(BA_model)
    num_of_I = []
    outfile = codecs.open('ep=' + str(ep) + 'Vg=' + str(Vg) + '.txt', 'w')
    for iter in range(T):                                     #迭代博弈过程
        S_list = []
        I_list = []
        C_list = []
        R_list = []
        for agent in Agents:                                  #统计各状态的节点
            index = Agents.index(agent)
            if agent.state == 'S':
                S_list.append(index)
            elif agent.state == 'I':
                I_list.append(index)
            elif agent.state == 'C':
                C_list.append(index)
            else:
                R_list.append(index)

        num_of_I.append(len(I_list))
        outfile.write(str(len(I_list)) + ' ')
        print(iter)

        new_Strategys = []                                    #记录所有处于未传播状态的节点一次博弈所采用的策略
        for index in S_list:                                  #遍历所有处于S状态的节点
            neighbs = BA_model.neighbors(Agents[index].label)
            neighb_list = []                                  #所有邻居节点
            for agent in Agents:
                if agent.label in neighbs:
                    neighb_list.append(Agents.index(agent))

            m = len([index for index in neighb_list if Agents[index].state == 'I']) - 1     #处于I状态的节点数
            n = len(neighb_list) - m - 1                      #其他状态的节点
            p = math.ceil(bp * n)
            q = math.floor(ep * n)

            if m == 0:
                if p == 0 & Vg <= (q + 1) * u:
                    next_Strategy = random.randint(0, 1)
                elif p not in [0] & Vg <= (q + 1) * u:
                    next_Strategy = 1
                else:
                    next_Strategy = 0
            else:
                if Vg <= (q + m + 1) * u:
                    next_Strategy = 1
                else:
                    next_Strategy = 0
            new_Strategys.append(next_Strategy)

        for i in S_list:                                      #更新S节点的状态
            if new_Strategys[S_list.index(i)] == 1:
                Agents[i].state = 'I'
        for i in I_list:                                      #I状态的节点转移到C状态
            prop = random.random()
            if prop <= omiga:
                Agents[i].state = 'C'
        for i in C_list:                                      #C状态的转移到R状态
            prop = random.random()
            if prop <= rho:
                Agents[i].state = 'R'
        for i in R_list:                                      #R状态的转移到S状态
            prop = random.random()
            if prop <= phi:
                Agents[i].state = 'S'

    output = open('ep=' + str(ep) + 'Vg=' + str(Vg) + '.pkl', 'wb')
    pickle.dump(num_of_I, output)
    del Agents
    '''
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(range(T), num_of_I)
    plt.show()
    '''



if __name__ == '__main__':
    BA = Get_BA_model('BA_model.pkl')
    eps = [0.1, 0.2, 0.4, 0.7, 1]
    for ep in eps:
        simulation(T = 4000, BA_model = BA, bp = 0, ep = ep, Vg = 350, u = 100, deltag = 10,
               alpha = 1., beta = 1., omiga = 0.1, theta = 0.3, phi = 0.1, rho = 0.1)
    vgs = [200, 300, 350, 400, 500, 1000, 2000]
    for vg in vgs:
        simulation(T = 4000, BA_model = BA, bp = 0, ep = 0.1, Vg = vg, u = 100, deltag = 10,
               alpha = 1., beta = 1., omiga = 0.1, theta = 0.3, phi = 0.1, rho = 0.1)