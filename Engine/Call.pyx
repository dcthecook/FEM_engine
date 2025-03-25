# -*- coding: utf-8 -*-
"""
Created on Wed Sep 11 04:04:27 2024

@author: Enea
"""

from Mesher cimport Vertex2D, alloc_varr, triangulate
from Math cimport fmesh, get_fmesh, implicit_jacobi_poisson, dirichlet, InputFunc
cimport cython
#import matplotlib.pyplot as plt
from libc.math cimport cos, sin, pi
from cython cimport NULL
from libc.stdlib cimport free
import numpy as np
cimport numpy as np
#import struct



cdef inline char is_cc(double x1, double y1, double x2, double y2, double x3, double y3):
    cdef double k
    k = (y2-y1)*(x3-x1) - (x2-x1)*(y3-y2)
    if (k <= 0):
        return 1
    return 0


cdef double load_example(double x, double y):
    return 2.0



cdef fmesh get_circle_fmesh(int layers, int pp_layer, double xcenter, double ycenter, double radius):
    vsize = 1+layers*pp_layer
    cdef Vertex2D* varr
    varr = alloc_varr(vsize, 0)
    varr[0].x = xcenter
    varr[0].y = ycenter
    cdef double angle_step = 0
    #cdef int index
    cdef fmesh result
    cdef int i
    cdef int j
    for i in range(layers):
        for j in range(pp_layer):
            angle_step = 2*pi*j / pp_layer
            index = 1+i*pp_layer+j
            varr[index].x = xcenter + ((i+1)/layers)*radius *cos(angle_step)
            varr[index].y = ycenter + ((i+1)/layers)*radius *sin(angle_step)
    result = get_fmesh(varr, vsize)
    free(varr)
    varr = NULL
    return result
            
    
cdef np.ndarray fmesh_to_vbo(fmesh mesh, int solve, dirichlet b_c, InputFunc load, int iterations):
    cdef np.ndarray result = np.zeros((3*mesh.fsize, 3), dtype='f8')
    cdef double[::1] solution
    cdef int i
    cdef int j
    for i in range(mesh.fsize):
        result[3*i][0] = mesh.ogmesh[i].ver1.x
        result[3*i][1] = mesh.ogmesh[i].ver1.y
        # result[3*i][2] = 0 #or insert value from solution for 3D plot
        result[3*i + 1][0] = mesh.ogmesh[i].ver2.x
        result[3*i + 1][1] = mesh.ogmesh[i].ver2.y
        # result[3*i + 1][2] = 0 #or insert value from solution for 3D plot
        result[3*i + 2][0] = mesh.ogmesh[i].ver3.x
        result[3*i + 2][1] = mesh.ogmesh[i].ver3.y
        # result[3*i + 2][2] = 0 #or insert value from solution for 3D plot
        
    if solve == 1:
        solution = implicit_jacobi_poisson(mesh, b_c, load, iterations)
        for j in range(mesh.fsize):
            result[3*j][2] = solution[mesh.ogmesh[j].ver1.vid_nr]
            result[3*j + 1][2] = solution[mesh.ogmesh[j].ver2.vid_nr]
            result[3*j + 2][2] = solution[mesh.ogmesh[j].ver3.vid_nr]
    # free(mesh.ogmesh) #if needed
    # mesh.ogmesh = NULL
    return result






cpdef np.ndarray vbo_circle(int layers, int pp_layer, double xcenter, double ycenter, double radius, int solveif, double bcmultiplier, double icmultiplier):
    cdef np.ndarray result
    cdef dirichlet boundary_0
    cdef fmesh circletest
    cdef double[::1] solution
    boundary_0.size = pp_layer
    cdef int[::1] bvids_memview = np.zeros((pp_layer), dtype='i4')
    cdef double[::1] bvalues_memview = np.zeros((pp_layer), dtype='f8')
    cdef int i
    for i in range(pp_layer):
        bvids_memview[i] = (pp_layer)*(layers-1) + 1 + i
        bvalues_memview[i] = bcmultiplier*np.sin((2*np.pi*icmultiplier*i)/pp_layer)
    boundary_0.vids = &bvids_memview[0]
    boundary_0.values = &bvalues_memview[0]
    
    circletest = get_circle_fmesh(layers, pp_layer, xcenter, ycenter, radius)
    
    if solveif == 1:
        result = fmesh_to_vbo(circletest, 1, boundary_0, load_example, 1550)
    else:
        result = fmesh_to_vbo(circletest, 0, boundary_0, load_example, 1550)
    
    return(result)



    
    

# some independant test units below hehe

# a = vbo_circle(5, 16, 0, 0, 1, 1, 4)
# print(a)


# cpdef np.ndarray xxfmesh_to_vbo(double[:,::1] vertex_arr):
    
#     cdef int nr_vertexes = vertex_arr.shape[0]
#     cdef Vertex2D* s_varr
#     cdef fmesh mesh
#     s_varr = alloc_varr(nr_vertexes, 0)
#     for i in range(nr_vertexes):
#         s_varr[i].x = vertex_arr[i][0]
#         s_varr[i].y = vertex_arr[i][1]
    
#     mesh = get_fmesh(s_varr, nr_vertexes)
#     free(s_varr)
#     s_varr = NULL
#     cdef np.ndarray result = np.zeros((3*mesh.fsize, 3), dtype='f8')
#     for j in range(mesh.fsize):
#         result[3*j][0] = mesh.ogmesh[j].ver1.x
#         result[3*j][1] = mesh.ogmesh[j].ver1.y
#         #ver2
#         result[3*j + 1][0] = mesh.ogmesh[j].ver2.x
#         result[3*j + 1][1] = mesh.ogmesh[j].ver2.y
#         #ver3
#         result[3*j + 2][0] = mesh.ogmesh[j].ver3.x
#         result[3*j + 2][0] = mesh.ogmesh[j].ver3.y
#     free(mesh.ogmesh)
#     mesh.ogmesh = NULL
#     return result
            
            



# cpdef bytes vbo_format(double[:,::1] vertex_arr):
#     cdef int nr_vertexes = vertex_arr.shape[0]
#     cdef int bytes_per_vertex = 24  # 3 doubles, 8 bytes each (x, y, z)
#     cdef int total_bytes = nr_vertexes * bytes_per_vertex
    
#     # Allocate memory for the vertex data
#     result = bytearray(total_bytes)
    
#     #allocate a struct array for the vertexes, and one for the fmesh
#     cdef Vertex2D* s_varr
#     cdef fmesh mesh
#     s_varr = alloc_varr(nr_vertexes, 0)
    
#     # Fill the struct array with vertex coordinates
#     for i in range(nr_vertexes):
#         s_varr[i].x = vertex_arr[i][0]
#         s_varr[i].y = vertex_arr[i][1]

#     # Get the mesh using filled vertices
#     mesh = get_fmesh(s_varr, nr_vertexes)

#     # Fill the byte array with triangle data (counterclockwise check included)
#     cdef int offset = 0
#     cdef double* double_ptr
#     for j in range(mesh.fsize):
#         if is_cc(mesh.ogmesh[j].ver1.x, mesh.ogmesh[j].ver1.y, 
#                 mesh.ogmesh[j].ver2.x, mesh.ogmesh[j].ver2.y, 
#                 mesh.ogmesh[j].ver3.x, mesh.ogmesh[j].ver3.y):
            
#             # Add ver1
#             double_ptr = <double*>(<char*>result + offset)
#             double_ptr[0], double_ptr[1], double_ptr[2] = mesh.ogmesh[j].ver1.x, mesh.ogmesh[j].ver1.y, 0.0
#             offset += bytes_per_vertex

#             # Add ver2
#             double_ptr = <double*>(<char*>result + offset)
#             double_ptr[0], double_ptr[1], double_ptr[2] = mesh.ogmesh[j].ver2.x, mesh.ogmesh[j].ver2.y, 0.0
#             offset += bytes_per_vertex

#             # Add ver3
#             double_ptr = <double*>(<char*>result + offset)
#             double_ptr[0], double_ptr[1], double_ptr[2] = mesh.ogmesh[j].ver3.x, mesh.ogmesh[j].ver3.y, 0.0
#             offset += bytes_per_vertex
#         else:
#             # Add ver2
#             double_ptr = <double*>(<char*>result + offset)
#             double_ptr[0], double_ptr[1], double_ptr[2] = mesh.ogmesh[j].ver2.x, mesh.ogmesh[j].ver2.y, 0.0
#             offset += bytes_per_vertex

#             # Add ver1
#             double_ptr = <double*>(<char*>result + offset)
#             double_ptr[0], double_ptr[1], double_ptr[2] = mesh.ogmesh[j].ver1.x, mesh.ogmesh[j].ver1.y, 0.0
#             offset += bytes_per_vertex

#             # Add ver3
#             double_ptr = <double*>(<char*>result + offset)
#             double_ptr[0], double_ptr[1], double_ptr[2] = mesh.ogmesh[j].ver3.x, mesh.ogmesh[j].ver3.y, 0.0
#             offset += bytes_per_vertex

#     # Free allocated memory
#     free(s_varr)
#     s_varr = NULL
#     #free(mesh.ogmesh)
#     #mesh.ogmesh = NULL

#     # Return the packed byte data
#     return bytes(result)




# cpdef np.ndarray get_circle_test(int layers, int pp_layer, double xcenter, double ycenter, double radius):
#     vsize = 1 + layers*pp_layer
#     cdef double[:,::1] varr = np.zeros((vsize, 3), dtype='f8')
#     varr[0, 0] = xcenter
#     varr[0, 1] = ycenter
#     varr[0, 2] = 0
#     cdef size_t i, j
#     cdef double angle_step
#     for i in range(layers):
#         for j in range(pp_layer):
#             angle_step = 2*pi*j / pp_layer
#             index = 1+i*pp_layer+j
#             varr[index, 0] = xcenter + ((i+1)/layers)*radius *cos(angle_step)
#             varr[index, 1] = ycenter + ((i+1)/layers)*radius *sin(angle_step)
#             varr[index, 2] = 0
            
#     return(fmesh_to_vbo(varr))




            

# a = get_circle_test(2, 8, 0, 0, 1)
# print(a)


# def color():
#     return "#{:02x}{:02x}{:02x}".format(100, 100, 100)

    
    
# cdef plot_triangulation(fmesh mesh):
#     print("------\n------\nNow for a plot\n------\n------\n")
#     fig, axes = plt.subplots(figsize=(40, 40))
#     # fig, axes = plt.subplots(1, 3, figsize=(50, 15))   for full solution axes
#     # image1 = axes[1].spy(globalmatrix)
#     # image2 = axes[2].plot(np.asarray(solution))  dont forget to change fx inputs
#     plt.gca().set_facecolor('black')

#     cdef str ver1txt
#     cdef str ver2txt
#     cdef str ver3txt
#     cdef double ox = 0
#     cdef double oy = 0
#     for f in range(mesh.fsize):
#         ox = 0.3333*(mesh.ogmesh[f].ver1.x+mesh.ogmesh[f].ver2.x+mesh.ogmesh[f].ver3.x)
#         oy = 0.3333*(mesh.ogmesh[f].ver1.y+mesh.ogmesh[f].ver2.y+mesh.ogmesh[f].ver3.y)
#         # Get vertices
        
#         # Draw the triangle
#         axes.fill((mesh.ogmesh[f].ver1.x, mesh.ogmesh[f].ver2.x, mesh.ogmesh[f].ver3.x, mesh.ogmesh[f].ver1.x), (mesh.ogmesh[f].ver1.y, mesh.ogmesh[f].ver2.y, mesh.ogmesh[f].ver3.y, mesh.ogmesh[f].ver1.y), color=color(), edgecolor='black')
#         ver1txt = f"{mesh.ogmesh[f].ver1.vid_nr}:" + f"({mesh.ogmesh[f].ver1.x:.2f}" + ", " + f"{mesh.ogmesh[f].ver1.y:.2f})"
#         ver2txt = f"{mesh.ogmesh[f].ver2.vid_nr}:" + f"({mesh.ogmesh[f].ver2.x:.2f}" + ", " + f"{mesh.ogmesh[f].ver2.y:.2f})"
#         ver3txt = f"{mesh.ogmesh[f].ver3.vid_nr}:" + f"({mesh.ogmesh[f].ver3.x:.2f}" + ", " + f"{mesh.ogmesh[f].ver3.y:.2f})"
#         # Annotate each vertex with its index
#         axes.text(mesh.ogmesh[f].ver1.x, mesh.ogmesh[f].ver1.y, ver1txt, color='red', fontsize=20, ha='right', va='top')
#         axes.text(mesh.ogmesh[f].ver2.x, mesh.ogmesh[f].ver2.y, ver2txt, color='red', fontsize=20, ha='right', va='top')
#         axes.text(mesh.ogmesh[f].ver3.x, mesh.ogmesh[f].ver3.y, ver3txt, color='red', fontsize=20, ha='right', va='top')
#         axes.text(ox, oy, "f:"+str(mesh.ogmesh[f].fid_nr), color='black', fontsize=12, ha='center', va='center')
#     axes.set_title('Triangulation', fontsize=35)
#     plt.show()
    
    
    
    
    
    
# cdef fmesh circle = get_circle_fmesh(3, 16, 0, 0, 1)
# plot_triangulation(circle)

# print(vbo_circle(3, 16, 0, 0, 1))
# ## hehe
# free(circle.ogmesh)
# circle.ogmesh = NULL
    
    
    
    
