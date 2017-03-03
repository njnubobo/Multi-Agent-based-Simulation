# -*- encoding: utf-8 -*-
__author__ = 'bbo'
import math
import random


class Agent(object):
    def __init__(self, label):
        self.location = (0., 0.)
        self.label = label
        self.relationships = {}
        # R {friendID: {'strength':, 'age':}}
        self.friendliness = 0.
        # 0 to 100 percentage
        #self.interestAreas = []
        self.interests = []
        # interests in every areas
        self.remainings = []

    def remaining_Meetings(self, V_mm, V_c, V_d, V_nr, V_ps, V_pn):
        # calculate the remaining number of meetings the agent can have
        strangers_ToMeet = V_c * V_ps
        neighbors_ToMeet = V_d * V_pn * math.pi * math.pow(V_nr, 2)
        self.remainings = V_mm * self.friendliness - strangers_ToMeet -neighbors_ToMeet



def init(num):
    # init agents of number num
    agents = [Agent(i) for i in range(num) ]
    return agents

def build_priority(agent, agents):
    # build a priority list of other agents it has relations with
    friendsList = agent.relationships.keys()
    priority = [(i, cal_likehood(agent, i, agents)) for i in friendsList]
    return sorted(priority, key=lambda likehood: likehood[1])
    # return tuples (agentID, likehood) sorted by likehood


def build_relationship(agentI, agentJ, agents, V_s, V_ra, V_rw):
    strength_new = V_s
    if agentJ.label not in agentI.relationships.keys():
        pro = (agentI.friendliness + agentJ.friendliness) / 2
        # the probability of initiating a relationship between two agents
        if random() < pro:
            agentI.relationships[agentJ.label] = {'strength': V_s, 'age': 1}
            agentJ.relationships[agentI.label] = {'strength': V_s, 'age': 1}
    else:
        # a relationship can has its strength s increased or decreased
        strength_new = (100 - agentI.relationships[agentJ.label]['strength']
                        ) * cal_likehood(agentI, agentJ.label, agents
                                         ) / (V_ra * agentI.relationships[agentJ.label]['age'])
        agentI.relationships[agentJ.label]['strength'] = strength_new
        agentJ.relationships[agentI.label]['strength'] = strength_new

    # all relationships decay over time
    strength_new2 = strength_new * (1 - V_rw)
    agentI.relationships[agentJ.label]['strength'] = strength_new2
    agentJ.relationships[agentI.label]['strength'] = strength_new2

    # once a relationship's strength lower than a predefined value, then remove from the list
    if agentI.relationships[agentJ.label]['strength'] <= 0.05:
        agentI.relationships.pop(agentJ.label)
        agentJ.relationships.pop(agentI.label)




def cal_likehood(agent, i, agents):
    temp = [min(agent.interests[j].size(), agents[i].intersts[j].size()) for j in range(areas)]
    return sum(temp) / max(agent.interests[j].size() for j in range(areas))

def simulation(num):
    Agents = init(num)
