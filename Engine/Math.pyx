# -*- coding: utf-8 -*-
"""
Created on Tue Aug  6 16:33:38 2024

@author: Enea
"""

import matplotlib.pyplot as plt
cimport cython
from libc.stdlib cimport malloc, free
from cython cimport sizeof, NULL
import numpy as np
cimport numpy as np
from libc.math cimport fabs


from Math cimport InputFunc, fmesh, dirichlet
from Mesher cimport Vertex2D, Face, triangulate
#######################
######
#datastruct for efficient mesh transversal (adjecant matrix method)
######
#######################

#new struct - > mesh data below still to be used correctly
""" to be used later when git gud
ctypedef struct mesh:
    int nr_vertexes
    int nr_faces
    int* v_adjacency
    Vertex2D* vertex
    Vertex2D** connections
"""


# ctypedef struct fmesh:
#     Face* ogmesh
#     int fsize
#     int vsize

# ctypedef struct dirichlet:
#     int size
#     int* vids
#     double* values

# Declare a function pointer type needed for the load fx
#ctypedef double (*InputFunc)(double, double)



#######################
######
#FX, sort, maths or misc functionsss
######
#######################

cdef void sort3(int *a, int *b, int *c) nogil:
    cdef int temp
    if a[0] > b[0]:
        temp = a[0]
        a[0] = b[0]
        b[0] = temp
    if a[0] > c[0]:
        temp = a[0]
        a[0] = c[0]
        c[0] = temp
    if b[0] > c[0]:
        temp = b[0]
        b[0] = c[0]
        c[0] = temp
        


cdef void sortface(Face *face) nogil:
    cdef Vertex2D temp
    if face[0].ver1.vid_nr > face[0].ver2.vid_nr:
        temp = face[0].ver1
        face[0].ver1 = face[0].ver2
        face[0].ver2 = temp
    if face[0].ver1.vid_nr > face[0].ver3.vid_nr:
        temp = face[0].ver1
        face[0].ver1 = face[0].ver3
        face[0].ver3 = temp
    if face[0].ver2.vid_nr > face[0].ver3.vid_nr:
        temp = face[0].ver2
        face[0].ver2 = face[0].ver3
        face[0].ver3 = temp
        


cdef double get_area(Face f) nogil:
    return fabs(0.5 * (f.ver1.x*(f.ver2.y-f.ver3.y) + f.ver2.x*(f.ver3.y-f.ver1.y) + f.ver3.x*(f.ver1.y-f.ver2.y)))


cpdef void printm(float[:, ::1] matrix):
    cdef int rows = matrix.shape[0]
    cdef int cols = matrix.shape[1]
    cdef int i, j
    print("\n[", end="")  # Print the opening square bracket at the start
    for i in range(rows):
        if i > 0:  # Print a newline only after the first row
            print()  # Print the newline before the next row
        row_str = "["
        for j in range(cols):
            row_str += "{:10.4f}".format(matrix[i, j])  # Format each element
            if j < cols - 1:
                row_str += ", "
        row_str += "]"
        print(row_str, end="")  # Print the row without a newline
    print("]\n")  # Print the closing square bracket after the last row




        
cpdef void printv(float[::1] vector):
    cdef int length = vector.shape[0]
    cdef int i
    print("\n", end="")
    print("[", end="")  # Opening square bracket for the vector
    for i in range(length):
        print("{:10.4f}".format(vector[i]), end="")  # Format each element
        if i < length - 1:
            print(", ", end="")  # Add commas between elements except the last
    print("]")  # Closing square bracket for the vector
        
       
        
       
#######################################################################
#######################################################################
#######################################################################
#######################################################################

### NEW NEW NEW STUFF

#######################################################################
#######################################################################
#######################################################################
#######################################################################

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void vs_mul(float* v, float scalar, int size) nogil:
    """
    Multiplies all elements of vector v by a scalar.
    Operates in-place.
    """
    cdef int i
    cdef int length = size
    for i in range(length):
        v[i] *= scalar



@cython.boundscheck(False)
@cython.wraparound(False)
cdef void ms_mul(float* A, float scalar, int row, int col) nogil:
    """
    Multiplies all elements of matrix A by a scalar.
    Operates in-place.
    """
    cdef int i, j
    cdef int rows = row
    cdef int cols = col
    for i in range(rows):
        for j in range(cols):
            index = i * cols + j
            A[index] *= scalar


            
@cython.boundscheck(False)
@cython.wraparound(False)
cdef float vv_mul(float* x, float* y, int size) nogil:
    """
    Computes the dot product of two vectors x and y.
    Returns the result as a float.
    """
    cdef int i
    cdef float result = 0.0
    for i in range(size):
        result += x[i] * y[i]
    return result

            

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void mv_mul(float* A, float* x, float* result, int rows, int cols) nogil:
    """
    Multiplies matrix A by vector x and stores the result in vector result.
    Operates in-place.
    """
    cdef int i, j, index
    for i in range(rows):
        result[i] = 0
        for j in range(cols):
            index = i * cols + j  # Flatten 2D index for matrix A
            result[i] += A[index] * x[j]  # Matrix-vector multiplication
        
#######################################################################
#######################################################################
#######################################################################
#######################################################################

### END of NEW STUFF

#######################################################################
#######################################################################
#######################################################################
#######################################################################


#######################################################################
## !!!! IMPORTANT !!! ##
########################
# This below is the force function in the poisson equation itself. Edit for any other force function #
cdef double load_function(double x, double y) nogil:
    #put some fx here
    return 2.
########################
## !!!! IMPORTANT !!! ##
#######################################################################


#######################
######
#FX, mesh formats and their matrices
######
#######################

# Keeps the same format as the old mesh intertwined structs with proper calls. Adds extra info to the mesh like its sizes. This will be
# used , at least for now, for computations while i develop the sparse format
@cython.boundscheck(False)
@cython.wraparound(False)
cdef fmesh get_fmesh(Vertex2D* vx_array, int vx_size):
    cdef int[1] global_mesh_size
    global_mesh_size[0] = 0
    cdef fmesh result
    result.ogmesh = triangulate(vx_array, vx_size, global_mesh_size)
    result.fsize = global_mesh_size[0]
    result.vsize = vx_size
    # cdef int i
    # for i in range(result.fsize):
    #     sortface(&result.ogmesh[i])    
    return result






@cython.boundscheck(False)
@cython.wraparound(False)
cdef double[:,::1] dense_global_matrix(fmesh mesh):
    cdef double[:,::1] result = np.zeros((mesh.vsize, mesh.vsize), dtype=np.float64)
    cdef double tmp_Area = 0.
    cdef double b1, b2, b3
    b1 = 0.
    b2 = 0.
    b3 = 0.
    cdef double c1, c2, c3
    c1 = 0.
    c2 = 0.
    c3 = 0.
    for i in range(mesh.fsize):
        #sortface(&mesh.ogmesh[i]) not needed the logic takes care of it
        tmp_Area = get_area(mesh.ogmesh[i])
        b1 = mesh.ogmesh[i].ver2.y - mesh.ogmesh[i].ver3.y
        b2 = mesh.ogmesh[i].ver3.y - mesh.ogmesh[i].ver1.y
        b3 = mesh.ogmesh[i].ver1.y - mesh.ogmesh[i].ver2.y
        
        c1 = mesh.ogmesh[i].ver3.x - mesh.ogmesh[i].ver2.x
        c2 = mesh.ogmesh[i].ver1.x - mesh.ogmesh[i].ver3.x
        c3 = mesh.ogmesh[i].ver2.x - mesh.ogmesh[i].ver1.x
        
        #diagonals first
        result[mesh.ogmesh[i].ver1.vid_nr, mesh.ogmesh[i].ver1.vid_nr] += 0.25*(1/tmp_Area)*(b1**2 + c1**2)
        result[mesh.ogmesh[i].ver2.vid_nr, mesh.ogmesh[i].ver2.vid_nr] += 0.25*(1/tmp_Area)*(b2**2 + c2**2)
        result[mesh.ogmesh[i].ver3.vid_nr, mesh.ogmesh[i].ver3.vid_nr] += 0.25*(1/tmp_Area)*(b3**2 + c3**2)
        #offdiags U
        result[mesh.ogmesh[i].ver1.vid_nr, mesh.ogmesh[i].ver2.vid_nr] += 0.25*(1/tmp_Area)*((b1*b2) + (c1*c2))
        result[mesh.ogmesh[i].ver1.vid_nr, mesh.ogmesh[i].ver3.vid_nr] += 0.25*(1/tmp_Area)*((b1*b3) + (c1*c3))
        result[mesh.ogmesh[i].ver2.vid_nr, mesh.ogmesh[i].ver3.vid_nr] += 0.25*(1/tmp_Area)*((b2*b3) + (c2*c3))
        #offdiags L
        result[mesh.ogmesh[i].ver2.vid_nr, mesh.ogmesh[i].ver1.vid_nr] += 0.25*(1/tmp_Area)*((b2*b1) + (c2*c1))
        result[mesh.ogmesh[i].ver3.vid_nr, mesh.ogmesh[i].ver1.vid_nr] += 0.25*(1/tmp_Area)*((b3*b1) + (c3*c1))
        result[mesh.ogmesh[i].ver3.vid_nr, mesh.ogmesh[i].ver2.vid_nr] += 0.25*(1/tmp_Area)*((b3*b2) + (c3*c2))
    
    return result



@cython.boundscheck(False)
@cython.wraparound(False)
cdef double[::1] dense_global_load(fmesh mesh, InputFunc load_fx):
    cdef double[::1] result = np.zeros(mesh.vsize, dtype=np.float64)
    cdef double tmp_Area = 0
    cdef double a1, a2, a3
    a1 = 0.
    a2 = 0.
    a3 = 0.
    cdef int i
    for i in range(mesh.fsize):
        tmp_Area = get_area(mesh.ogmesh[i])
        result[mesh.ogmesh[i].ver1.vid_nr] += -0.33333333333*tmp_Area*load_fx(mesh.ogmesh[i].ver1.x, mesh.ogmesh[i].ver1.y)
        result[mesh.ogmesh[i].ver2.vid_nr] += -0.33333333333*tmp_Area*load_fx(mesh.ogmesh[i].ver2.x, mesh.ogmesh[i].ver2.y)
        result[mesh.ogmesh[i].ver3.vid_nr] += -0.33333333333*tmp_Area*load_fx(mesh.ogmesh[i].ver3.x, mesh.ogmesh[i].ver3.y)
    return result
    


cdef void apply_dirichlet(double[::1] points, dirichlet conditions):
    cdef int i
    for i in range(conditions.size):
        points[conditions.vids[i]] = conditions.values[i]


#######################
######
#FX, solvers (jacobi, gauss, CG, etc) etc
######
#######################
@cython.boundscheck(False)
@cython.wraparound(False)
cdef double[::1] implicit_jacobi_poisson(fmesh mesh, dirichlet bc, InputFunc fx, int iterations):
    cdef int i, k
    #cdef double[::1] old = np.zeros((mesh.vsize), dtype=np.float64)
    cdef double[::1] result = np.zeros((mesh.vsize), dtype=np.float64)
    cdef double[::1] load_vector = dense_global_load(mesh, fx)
    cdef double[:,::1] global_matrix = dense_global_matrix(mesh)
    cdef double[:,::1] global_diags = np.zeros((mesh.vsize, mesh.vsize), dtype=np.float64)
    for k in range(mesh.vsize):
        global_diags[k,k] = 1/global_matrix[k, k]
        global_matrix[k, k] = 0.
    apply_dirichlet(result, bc)
    for i in range(iterations):
        result = np.matmul(global_diags, load_vector-np.matmul(global_matrix, result))
        apply_dirichlet(result, bc)
            
    return result
    
    

    
