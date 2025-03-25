# -*- coding: utf-8 -*-
"""
Created on Mon Sep  9 01:05:36 2024

@author: Enea
"""

from Mesher cimport Vertex2D, Face

ctypedef struct fmesh:
    Face* ogmesh
    int fsize
    int vsize

ctypedef struct dirichlet:
    int size
    int* vids
    double* values
    
ctypedef double (*InputFunc)(double, double)

cdef void sort3(int *a, int *b, int *c) nogil

cdef void sortface(Face *face) nogil

cdef double get_area(Face f) nogil

cdef void print_memview(double[:, ::1] memview)

cdef double load_function(double x, double y) nogil

cdef fmesh get_fmesh(Vertex2D* vx_array, int vx_size)

cdef double[:,::1] dense_global_matrix(fmesh mesh)

cdef double[::1] dense_global_load(fmesh mesh, InputFunc load_fx)

cdef void apply_dirichlet(double[::1] points, dirichlet conditions)

cdef double[::1] implicit_jacobi_poisson(fmesh mesh, dirichlet bc, InputFunc fx, int iterations)

