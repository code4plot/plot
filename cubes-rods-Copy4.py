#!/usr/bin/env python
# coding: utf-8

# In[1]:


from collections import defaultdict
class Cubes:
    def __init__(self):
        #initiate dictionary for adjacency list
        self.adjacent = defaultdict(list)
        #initiate list to store list of islands
        self.cube_island = []
        
    #store adjacent cubes in dictionary
    def addRods(self, u, v):
        self.adjacent[u].append(v)
        self.adjacent[v].append(u)
    
    #function to identify connected cubes
    #using Depth-First Search (DFS)
    #and store into cube_island list
    def connectedCubes(self):     
        #initiate visited dictionary
        visited = defaultdict(bool)    
        cubeList = self.adjacent.keys()
        for i in cubeList:
            visited[i] = False
        
        for i in cubeList:
            if visited[i] == False:
                #start traversing
                store_cubes = [] #to store cubes
                self.cube_island.append(self.DFSutils(i, visited, store_cubes))

    #recursive function to identify all cubes connected to v
    def DFSutils(self, v, visited, store_cubes):
        #print cube v and mark it visited
        visited[v] = True
        store_cubes.append(v)
                
        #iterate through all cubes adjacent to v
        for i in self.adjacent[v]:
            if visited[i] == False:
                store_cubes = self.DFSutils(i, visited, store_cubes)
                
        return store_cubes


# In[2]:


def compute(rods):
    #initiate Cubes class
    c = Cubes()
    
    #construct a dictionary of adjacent cubes
    for i,j in rods:
        c.addRods(i,j)
    
    #identify islands
    #initiates DFS and stores list of islands in c.cube_island
    c.connectedCubes() 
    
    #minimum number of rods needed for each island
    minRods = 0
    for island in c.cube_island:
        minRods += len(island) - 1 #(n-1), where n is the number of cubes
    
    #maximum rods can be removed
    #subtract the minRods from len(rods)
    removeRod = len(rods) - minRods
    return removeRod


# In[3]:


#test cases
#1 island
a = [(1,2),(1,3)] #output 0
compute(a)


# In[4]:


#1 island
a = [(1,2), (2,3),(1,3)] #output 1
compute(a)


# In[5]:


#2 islands
a = [(1,2),(2,3),(4,5)] #output 0
compute(a)


# In[6]:


#more islands
a = [(1,2),(2,3),(4,5),(1,2),(2,3),(1,3),(10,11),(11,12),(42,35),(20,35),(20,35),(42,10)] #output 4
compute(a)


# In[7]:


#more islands with self connections
a = [(1,2),(2,3),(4,5),(42,35),(20,35),(20,35),(42,10),(1,2),(2,3),(1,3),(10,11),(11,12),(1,1),(50,50),(30,30)] #output 7
compute(a)


# In[8]:


#cubes with negative integers
a = [(1,2),(42,35),(2,3),(20,35),(10,11),(11,12),(3,4),(20,35),(-1,2),(1,-2),(2,-3),(1,3)] #output 2
compute(a)


# In[10]:


import random
a = []
for k in range(20):
    a.append((random.randint(-10,10),random.randint(-5,5)))
print(a, compute(a))


# In[ ]:




