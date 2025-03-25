# -*- coding: utf-8 -*-
"""
Created on Thu Sep 12 03:24:03 2024

@author: Enea
"""
import numpy as np
cimport numpy as np
from Math cimport fmesh, get_fmesh, dirichlet, InputFunc


cdef char is_cc(double x1, double y1, double x2, double y2, double x3, double y3)

cdef double load_example(double x, double y)

cdef fmesh get_circle_fmesh(int layers, int pp_layer, double xcenter, double ycenter, double radius)

cdef np.ndarray fmesh_to_vbo(fmesh mesh, int solve, dirichlet b_c, InputFunc load, int iterations)

cpdef np.ndarray vbo_circle(int layers, int pp_layer, double xcenter, double ycenter, double radius, int solveif, double bcmultiplier, double icmultiplier)