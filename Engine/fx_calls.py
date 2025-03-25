# -*- coding: utf-8 -*-
"""
Created on Thu Sep 12 02:43:13 2024

@author: Enea
"""

from Call import vbo_circle
import numpy as np


np.set_printoptions(precision=2)

# def vbo_mesh(array):
#     return fmesh_to_vbo(array) hehe



def circle(p_layers, p_pplayer, p_xcenter, p_ycenter, p_radius, p_solve, p_bcmultiplier, p_icmultiplier):
    result = vbo_circle(p_layers, p_pplayer, p_xcenter, p_ycenter, p_radius, p_solve, p_bcmultiplier, p_icmultiplier)
    
    # Swap the 1st (Y) and 2nd (Z) columns
    #result[:, [1, 2]] = result[:, [2, 1]]
    
    return result


def circle_test():
    result = circle(32, 50, 0, 0, 1, 1, 0.12, 6)
    shift = -min(result[:,2])
    d = 1/abs(max(result[:,2])-min(result[:,2]))
    result = np.c_[ result, np.zeros(result.shape[0]), np.zeros(result.shape[0]), np.zeros(result.shape[0])]
    result[:,3] = result[:,2]
    result[:,3] += shift
    result[:,3] *= d
    result[:, [1, 2]] = result[:, [2, 1]]
    result = np.asarray(result, dtype='f4')
    
    return result

# a = circle_test()
# a[:,2] = 0
# a = np.asarray(circle_test(), dtype='f4')
# print(a)
# print(a.shape)