# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 21:49:03 2020

@author: mbijlkh
"""

#given a list of unsorted integers,
#find the smallest integer (>0) missing from the list

def negativeleft(A):
    neg = 0
    for i in range(len(A)):
        if A[i] <= 0:
#            print('test')
            A[i], A[neg] = A[neg], A[i]
            neg += 1
    #print(A)
    return neg

def find_smallest_int(A):
    tot = len(A)
    for i in range(tot):
        if (abs(A[i]) - 1 < tot and A[abs(A[i]) - 1] > 0):
            A[abs(A[i]) - 1] = -A[abs(A[i]) - 1]
    for i in range(tot):
        if A[i] > 0:
            return i + 1
    return tot + 1

def solution(A):
    # write your code in Python 3.6
    neg = negativeleft(A)
    #print(A)
    result = find_smallest_int(A[neg:])
    return result
