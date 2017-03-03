# -*- encoding: utf-8 -*-
__author__ = 'bbo'



def Jaccard(new_text, hot_topics):
    '''
    计算微博内容的词语集合与历史高频词集合的Jaccard相似度
    '''
    count1 = 0
    for i in new_text:
        if i in hot_topics:
            count1 += 1
    count2 = len(new_text) + len(hot_topics) - count1
    return count1 / count2 * 1.0

