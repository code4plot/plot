# -*- coding: utf-8 -*-
"""
Created on Tue Nov 17 12:25:10 2020

@author: mbijlkh
"""
"""
Write a function

def solution(A)

that, given an array A consisting of N integers, returns the number of distinct values in array A.

For example, given array A consisting of six elements such that:

 A[0] = 2    A[1] = 1    A[2] = 1
 A[3] = 2    A[4] = 3    A[5] = 1
the function should return 3, because there are 3 distinct values appearing in array A, namely 1, 2 and 3.

Write an efficient algorithm for the following assumptions:

N is an integer within the range [0..100,000];
each element of array A is an integer within the range [−1,000,000..1,000,000].
"""

def solution(A):
    # write your code in Python 3.6
    if len(A) == 0:
        return 0
    elif len(A) == 1:
        return 1
    A.sort()
    distinct = 1
    for i in range(1,len(A)):
        if A[i] != A[i-1]:
            distinct += 1
    return distinct