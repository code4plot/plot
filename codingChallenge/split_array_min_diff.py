# -*- coding: utf-8 -*-
"""
Created on Sat Nov 14 22:54:28 2020

@author: mbijlkh
"""


import sys

def solution(A):
    # write your code in Python 3.6
    preSum = [0] * len(A)
    sufSum = [0] * len(A)
    preSum[0] = A[0]
    for i in range(1, len(A)):
        preSum[i] = preSum[i-1] + A[i]
    sufSum[-1] = A[-1]
    for i in range(len(A)-2, -1, -1):
        sufSum[i] = sufSum[i+1] + A[i]
    min_diff = sys.maxsize
    for i in range(len(A)-1):
        d = abs(preSum[i] - sufSum[i+1])
        if d < min_diff:
            min_diff = d
    return min_diff