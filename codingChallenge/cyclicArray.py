# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 22:14:23 2020

@author: mbijlkh
"""


def solution(A, K):
    # write your code in Python 3.6
    length = len(A)
    if K%length == 0:
        return A
    else:
        move = K%length
        B = A[:]
        for i in range(length):
            if i+move < length:
                B[i+move] = A[i]
            else:
                B[abs(i+move-length)] = A[i]
        return B