# -*- encoding: utf-8 -*-
__author__ = 'bbo'
import pickle
import random
import math

def Get_BA_model(filename):
    file = open(filename, 'rb')
    BA = pickle.load(file)
    return BA

class Agent(object):
    '''
    智能体
    策略：{相信，不相信}={1，0}
    '''
    def __init__(self, label):
        self.strategy = -1
        self.memory = []
        self.label = label

def Init(model):
    nodes = model.nodes()
    Agents = []
    for i in nodes:
        Agents.append(Agent(i))
    return Agents

def Simulation(BA, T, p, q, a, b, c, d, r):
    Agents = Init(BA)
    Notbelieve = []
    InitBelieve = random.sample(range(len(Agents)), int(p * len(Agents)))#设置初始偏好
    for i in range(len(Agents)):
        if i in InitBelieve:
            Agents[i].memory.append(1)
        else:
            Agents[i].memory.append(0)

    for iter in range(T):
        if iter == 0:
            selected = random.sample(InitBelieve, int(p * 100)) + random.sample(
                [i for i in range(len(Agents)) if i not in InitBelieve], 100 - int(p * 100))
        else:
            selected = random.sample(range(len(Agents)), 100)

        for index in selected:
            pos, neg, strategyH, neighbs = PredictH(BA, Agents, index)
            B1 = pos * a + neg * b
            U2 = pos * c + neg * d
            U1 = r * U2
            B2 = r * B1
            if a -c > d - b:
                if B1 >= U1:
                    strategyI = 1
                else:
                    strategyI = 0
            else:
                if B2 >= U2:
                    strategyI = 1
                else:
                    strategyI = 0

            prop = random.random()
            if prop < q:
                final_strategy = strategyI
            else:
                final_strategy = strategyH
            Agents[index].strategy = final_strategy

            for i in neighbs:
                if len(Agents[i].memory) < 10:
                    Agents[i].memory.append(final_strategy)
                else:
                    del Agents[i].memory[0]
                    Agents[i].memory.append(final_strategy)

        for i in range(len(Agents)):
            forget = random.randint(0, len(Agents[i].memory) - 1)
            del Agents[i].memory[0:forget]
            '''
            if len(Agents[i].memory) >= 3:
                forget = random.randint(0, 2)
                if forget == 1:
                    del Agents[i].memory[0]
                elif forget == 2:
                    del Agents[i].memory[0:2]
            '''
        num = 0
        for agent in Agents:
            if agent.strategy == 0:
                num += 1
        Notbelieve.append(num)

        num2 = 0
        for i in selected:
            if Agents[i].strategy == 0:
                num2 += 1
        #print num2
    print Notbelieve
    return Notbelieve



def PredictH(BA, Agents, index):
    nei_Labels = BA.neighbors(Agents[index].label)
    count = 0
    for j in nei_Labels:
        count_ = 0
        neiofnei_Labels = BA.neighbors(j)
        for i in neiofnei_Labels:
            pos_Num = Agents[i].memory.count(1)
            neg_Num = len(Agents[i].memory) - pos_Num
            if pos_Num > neg_Num:
                count_ += 1

            elif pos_Num == neg_Num:
                temp = random.randint(0, 1)
                count_ += temp

        if count_ > len(neiofnei_Labels) - count_:
            count += 1
        '''
        elif count_ == len(neiofnei_Labels) - count_:
            temp = random.randint(0, 1)
            count += temp
        '''
    if count > len(nei_Labels) - count:
        myStrategy = 1
    elif count < len(nei_Labels) - count:
        myStrategy = 0
    else:
        myStrategy = random.randint(0, 1)
    return count, len(nei_Labels) - count, myStrategy, nei_Labels

if __name__ == '__main__':
    BA = Get_BA_model('BA_model.pkl')
    import matplotlib.pyplot as plt
    fig = plt.figure()
    ax = fig.add_subplot(111)

    for r in [1.2, 1.3, 1.5, 2]:
        Notbelieve = Simulation(BA = BA, T = 600, p = 0.5, q = 0, a = 4, b = 0, c = 3, d = 2, r = r)
        print len(Notbelieve)
        ax.plot(range(len(Notbelieve)), [1 - 1. * i / len(BA.nodes()) for i in Notbelieve], label = 'r='+str(r))
    '''
    Notbelieve = Simulation(BA = BA, T = 600, p = 0.5, q = 0, a = 4, b = 0, c = 3, d = 2, r = 1)
    ax.plot(range(len(Notbelieve)), [1 - 1. * i / len(BA.nodes()) for i in Notbelieve], label = 'believe')
    '''
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles[::], labels[::])
    plt.xlabel('time')
    plt.ylabel('propotion')
    plt.show()