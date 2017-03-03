# -*- encoding: utf-8 -*-
__author__ = 'bbo'
import pickle
import networkx
import math
import random

def Get_WS_model(filename):
    file = open(filename, 'rb')
    WS = pickle.load(file)
    return WS

class Agent(object):
    '''
    智能体
    '''
    def __init__(self, label):
        self.strategy = -1
        self.knowledge = 0
        self.label = label

def Init(model):
    nodes = model.nodes()
    Agents = []
    for node in nodes:
        Agents.append(Agent(node))
    return Agents

def Simulation(WS, p, T, a, b, c):
    Agents = Init(WS)
    selected = random.sample(range(len(Agents)), int(p * len(Agents)))
    for i in range(len(Agents)):
        if i in selected:
            Agents[i].knowledge = 1
            Agents[i].strategy = 1
        else:
            Agents[i].knowledge = 0
            Agents[i].strategy = 0
    '''
    selected = random.sample(range(len(Agents)), int(p * len(Agents)))
    for i in range(len(Agents)):
        if i in selected:
            Agents[i].strategy = 1
        else:
            Agents[i].strategy = 0
    '''
    iter = 0
    PRO = []
    KNO = []
    while iter < T:
        rand_A = random.sample(range(len(Agents)), 1)[0]
        f, neighbs = F(Agents, rand_A, WS)               #返回存在信息差异的邻居节点

        if f != 0:
            iter += 1
            neg_indexs, pos_indexs, I_ZZ, I_NN, I_Aver, prop = Cacul_Profit(f, neighbs, Agents, a, b, c)
            '''
            if I_Aver == 0:
                P_ZN = len(pos_indexs)
                P_NZ = len(neg_indexs)
            else:
                P_ZN = prop * abs(I_Aver - I_ZZ) / I_Aver * len(pos_indexs)
                P_NZ = (1 - prop) * abs(I_Aver - I_NN) / I_Aver * len(neg_indexs)
            print prop, I_Aver,I_ZZ, P_ZN, P_NZ
            '''
            if I_ZZ < I_NN:
                P_ZN = len(pos_indexs)
                P_NZ = 0
            else:
                P_ZN = 0
                P_NZ = len(neg_indexs)

            for i in random.sample(pos_indexs, int(P_ZN)):
                Agents[i].strategy = 0
            for i in random.sample(neg_indexs, int(P_NZ)):
                Agents[i].strategy = 1


            kl = Agents[rand_A].knowledge
            for index in neighbs:
                kl_J = Agents[index].knowledge
                strategy_J = Agents[index].strategy
                if Agents[rand_A].strategy == 1:
                    if strategy_J == 1:
                        kl_delta = a * abs(kl - kl_J)
                        #Agents[index].knowledge += kl_delta
                    else:
                        kl_delta = c * abs(kl - kl_J)
                        #Agents[index].knowledge -= b * abs(kl - kl_J)
                else:
                    if strategy_J == 1:
                        kl_delta = - b * abs(kl - kl_J)
                        #Agents[index].knowledge += c * abs(kl - kl_J)
                    else:
                        kl_delta = 0

                Agents[rand_A].knowledge += kl_delta

            '''
            计算平均心理收益
            '''
            Allprofit = 0
            Allknowledge = 0
            for index in range(len(Agents)):
                f, neighbs = F(Agents, index, WS)
                I_ZZ, I_NN, I_Aver =Cacul_Profit(f, neighbs, Agents, a, b, c)[2:5]
                Allprofit += I_Aver
                Allknowledge += Agents[index].knowledge
            PRO.append(Allprofit / len(Agents))
            KNO.append(1. * Allknowledge/ len(Agents))
    return PRO, KNO

def Cacul_Profit(f, neighbs, Agents, a, b, c):  #计算预期收益
    neg_indexs = []
    pos_indexs = []
    for i in neighbs:                              #邻居中计算P
    #for i in range(len(Agents)):                  #全局计算P
        if Agents[i].strategy == 1:
            pos_indexs.append(i)
        else:
            neg_indexs.append(i)
    #prop = 1. * len(pos_indexs) / len(Agents)
    prop = 1. * len(pos_indexs) / len(neighbs)
    '''
    I_ZZ = f * (prop * a - (1 - prop) * b)
    I_NN = f * prop * c
    '''
    I_ZZ = f * (prop * a + (1 - prop) * c)
    I_NN = - f * b * (1-prop)

    I_Aver = prop * I_ZZ + (1 - prop) * I_NN
    return neg_indexs, pos_indexs, I_ZZ, I_NN, I_Aver, prop



def F(Agents, index, WS):    #f函数
    neighb_Labels = WS.neighbors(Agents[index].label)
    neighb_indexs = []
    count_N = 0
    for i in range(len(Agents)):
        if Agents[i].label in neighb_Labels:
            if Agents[i].knowledge != Agents[index].knowledge:
                count_N += 1
            neighb_indexs.append(i)
    return 1. * count_N / len(Agents), neighb_indexs

if __name__ == '__main__':
    WS = Get_WS_model('WS_model.pkl')
    import matplotlib.pyplot as plt
    fig = plt.figure()
    ax = fig.add_subplot(111)
    P = [0.1, 0.6]

    for p in P:
        PRO, KNO = Simulation(WS = WS, p = p, T = 100, a = 0.8, b = 0.5, c = 0.3)
        ax.plot(range(100), KNO, label='p='+str(p))
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles[::], labels[::])
    plt.xlabel('time')
    plt.ylabel('average knowledge')
    plt.show()
