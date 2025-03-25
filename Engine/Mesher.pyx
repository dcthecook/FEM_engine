# -*- coding: utf-8 -*-
"""
Created on Thu Jul 21 16:22:42 2024

@author: Enea

A basic proof of concept code regarding the concept of Delaunay Triangulation
"""


cimport cython
from libc.stdlib cimport malloc, free
from cython cimport sizeof, NULL
from libc.math cimport sqrt
from Mesher cimport Vertex1D, Vertex2D, Face, Line






###########################
###########################

"""Below structs for the basic geometry"""

###########################
###########################



"""First layer simplex. The Vertex2D and 1D"""
"""Below functions to create an instance of the struct"""
# ctypedef struct Vertex1D:
#     double x
#     int vid_nr

# ctypedef struct Vertex2D:
#     double x
#     double y
#     int vid_nr

    


cdef Vertex2D create_vertex2d(double x_coord, double y_coord, int vid_number):
    cdef Vertex2D v
    v.x = x_coord
    v.y = y_coord
    v.vid_nr = vid_number
    return v

cdef Vertex1D create_vertex1d(double x_coord, int vid_number):
    cdef Vertex1D v
    v.x = x_coord
    v.vid_nr = vid_number
    return v



##
"""The Face"""
"""Functions to create instances of Face or line"""
# ctypedef struct Face:
#     Vertex2D ver1
#     Vertex2D ver2
#     Vertex2D ver3
#     int fid_nr

# ctypedef struct Line:
#     Vertex1D ver1
#     Vertex1D ver2
#     int fid_nr
    

cdef Face create_face(Vertex2D vertex1, Vertex2D vertex2, Vertex2D vertex3, int fid_number):
    cdef Face f
    f.ver1 = vertex1
    f.ver2 = vertex2
    f.ver3 = vertex3
    f.fid_nr = fid_number
    return f


cdef Line create_line(Vertex1D vertex1, Vertex1D vertex2, int fid_number):
    cdef Line l
    l.ver1 = vertex1
    l.ver2 = vertex2
    l.fid_nr = fid_number
    return l




###########################
###########################

"""Below functions for dynamic allocation purposes"""

###########################
###########################



"""deallocates and moves all elements under the removed index 1 upward"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex2D* dealloc_from_varray(Vertex2D* original_array, int current_size, int remove_index):
    #careful remove_index is actual position - 1
    cdef Vertex2D* new_array = <Vertex2D*>malloc((current_size-1) * sizeof(Vertex2D))
    cdef int i
    cdef int j
    cdef int upper_limit = remove_index
    for i in range(upper_limit):
        new_array[i] = original_array[i]
    for j in range(upper_limit+1, current_size):
        new_array[j-1] = original_array[j]
        
    free(original_array)
    return new_array
        
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex1D* dealloc_from_varray1d(Vertex1D* original_array, int current_size, int remove_index):
    #careful remove_index is actual position - 1
    cdef Vertex1D* new_array = <Vertex1D*>malloc((current_size-1) * sizeof(Vertex1D))
    cdef int i
    cdef int j
    cdef int upper_limit = remove_index
    for i in range(upper_limit):
        new_array[i] = original_array[i]
    for j in range(upper_limit+1, current_size):
        new_array[j-1] = original_array[j]
        
    free(original_array)
    return new_array

"""A function like the one below to realloc a vertex array instead of a face array"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex2D* realloc_to_varray(Vertex2D* old_array, int current_size, Vertex2D new_vertex):
    cdef int new_size = current_size + 1
    cdef Vertex2D* new_array = <Vertex2D*>malloc(new_size * sizeof(Vertex2D))
    cdef int i
    for i in range(current_size):
        new_array[i] = old_array[i]
    new_array[current_size] = new_vertex
    
    free(old_array)
    return new_array


#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex1D* realloc_to_varray1d(Vertex1D* old_array, int current_size, Vertex1D new_vertex):
    cdef int new_size = current_size + 1
    cdef Vertex1D* new_array = <Vertex1D*>malloc(new_size * sizeof(Vertex1D))
    cdef int i
    for i in range(current_size):
        new_array[i] = old_array[i]
    new_array[current_size] = new_vertex
    
    free(old_array)
    return new_array


"""A function that takes a pointer to an array of Face structs. It creates a new array 1 size larger."""
"""It then appends the -new face- to it. Returns the new array. Frees the old one from memory"""
"""ATTENTION!!::: THE FACE* MESH INPUT MUST BE A MALLOC'ED ARRAY OR A POINTER TO A STATICALLY DECLARED ONE BY REFERENCING"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Face* realloc_to_mesh(Face* mesh, int current_size, Face new_face):
    cdef int new_size = current_size + 1
    cdef Face* new_mesh = <Face*>malloc(new_size * sizeof(Face))
    cdef int i
    for i in range(current_size):
        new_mesh[i] = mesh[i]
    new_mesh[current_size] = new_face
    free(mesh)

    return new_mesh


#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Line* realloc_to_mesh1d(Line* mesh, int current_size, Line new_face):
    cdef int new_size = current_size + 1
    cdef Line* new_mesh = <Line*>malloc(new_size * sizeof(Line))
    cdef int i
    for i in range(current_size):
        new_mesh[i] = mesh[i]
    new_mesh[current_size] = new_face
    free(mesh)

    return new_mesh


"""Removes a Face in a mesh of a certain index"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Face* dealloc_from_mesh(Face* original_mesh, int current_size, int remove_index):

    cdef Face* new_mesh = <Face*>malloc((current_size-1) * sizeof(Face))
    cdef int i
    cdef int j
    cdef int upper_limit = remove_index
    for i in range(upper_limit):
        new_mesh[i] = original_mesh[i]
    for j in range(upper_limit+1, current_size):
        new_mesh[j-1] = original_mesh[j]
    free(original_mesh)

    
    return new_mesh


#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Line* dealloc_from_mesh1d(Line* original_mesh, int current_size, int remove_index):

    cdef Line* new_mesh = <Line*>malloc((current_size-1) * sizeof(Line))
    cdef int i
    cdef int j
    cdef int upper_limit = remove_index
    for i in range(upper_limit):
        new_mesh[i] = original_mesh[i]
    for j in range(upper_limit+1, current_size):
        new_mesh[j-1] = original_mesh[j]
    free(original_mesh)

    
    return new_mesh


"""A function to jumptstart allocate the Vertex2D struct in an array for testing purposes"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex2D* alloc_varr(int size, double var):
    cdef Vertex2D* varray = <Vertex2D*>malloc(size * sizeof(Vertex2D))
    cdef int i
    for i in range(size):
        varray[i] = create_vertex2d(var, var, i)
    return varray


#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex1D* alloc_varr1d(int size, double var):
    cdef Vertex1D* varray = <Vertex1D*>malloc(size * sizeof(Vertex1D))
    cdef int i
    for i in range(size):
        varray[i] = create_vertex1d(var, i)
    return varray


############################
############################

"""Below functions for useful geometrical comparisons"""

############################
############################



"""return magnitude of vector"""
#works
cdef inline double magnitude(double x, double y):
    return sqrt(x*x+y*y)



"""return dot product with respect to origin"""
#works
cdef inline double dot_product(Vertex2D v1, Vertex2D v2):
    return v1.x * v2.x + v1.y * v2.y



"""Distance between vertices"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef inline double distance(Vertex2D v1, Vertex2D v2):
    return sqrt((v1.x - v2.x)**2 + (v1.y - v2.y)**2)



"""Circumcenter"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef Vertex2D circumcenter(Vertex2D v1, Vertex2D v2, Vertex2D v3):
    cdef Vertex2D center
    cdef double D = (v1.x*(v2.y-v3.y) + v2.x*(v3.y-v1.y) + v3.x*(v1.y-v2.y))*2
    center.x = (1/D)*((v1.x**2 + v1.y**2)*(v2.y-v3.y) + (v2.x**2 + v2.y**2)*(v3.y-v1.y) + (v3.x**2 + v3.y**2)*(v1.y-v2.y))
    center.y = (1/D)*((v1.x**2 + v1.y**2)*(v3.x-v2.x) + (v2.x**2 + v2.y**2)*(v1.x-v3.x) + (v3.x**2 + v3.y**2)*(v2.x-v1.x))
    center.vid_nr = -1
    return center


"""Circumradius"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef double circumradius(Vertex2D v1, Vertex2D v2, Vertex2D v3):
    cdef Vertex2D ccenter = circumcenter(v1, v2, v3)
    cdef double radius = sqrt((v1.x-ccenter.x)**2 + (v1.y-ccenter.y)**2)
    
    return radius



"""Check if Vertex2D p is in Circumcircle of v1v2v3"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef int in_circumcircle(Face f, Vertex2D p):
    cdef Vertex2D c_center = circumcenter(f.ver1, f.ver2, f.ver3)
    cdef double c_radius = circumradius(f.ver1, f.ver2, f.ver3)
    cdef double distance_from_circumcenter = distance(c_center, p)
    return distance_from_circumcenter < c_radius




"""Create the super Triangle"""
"""First create the max rectangle"""
"""Then set the triangle with sqrt3 formulas"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Face create_super_triangle(Vertex2D* points, int num_points):
    cdef Face super_triangle
    
    cdef double min_x = points[0].x
    cdef double min_y = points[0].y
    cdef double max_x = points[3].x
    cdef double max_y = points[3].y
    cdef int i
    for i in range(num_points):
        if points[i].x < min_x:
            min_x = points[i].x

        if points[i].y < min_y:
            min_y = points[i].y
            
    for i in range(num_points):
        if points[i].x > max_x:
            max_x = points[i].x

        if points[i].y > max_y:
            max_y = points[i].y
            
    cdef double a = (max_x - min_x)
    cdef double b = (max_y - min_y)
    super_triangle.ver1.x = min_x + a*0.5
    super_triangle.ver1.y = max_y + a*0.5
    super_triangle.ver1.vid_nr = -1
    super_triangle.ver2.x = max_x + b
    super_triangle.ver2.y = min_y - 1
    super_triangle.ver2.vid_nr = -2
    super_triangle.ver3.x = min_x - b
    super_triangle.ver3.y = min_y - 1
    super_triangle.ver3.vid_nr = -3
    super_triangle.fid_nr = 0
    return super_triangle






############################
############################

"""Below functions for meshing IN 2D"""

############################
############################





"""The most important part to have valid faces with no crossings. It takes a list of free vertexes and orients them c-clockwise"""
"""Uses the Dot product orthogonality and Bubble Sort"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef inline void sort_by_angle_cclockwise(Vertex2D* free_vertexes, Vertex2D center_V, int size):
    cdef int vertexes_over_x_axis = 0
    cdef int vertexes_under_x_axis = 0
    cdef Vertex2D* displaced_vertexes_overx = <Vertex2D*>malloc(sizeof(Vertex2D))
    cdef Vertex2D* displaced_vertexes_underx = <Vertex2D*>malloc(sizeof(Vertex2D))
    cdef Vertex2D center_vertex = center_V
    ###
    

    cdef double x_newcoord
    cdef double y_newcoord
    
    cdef int i
    for i in range(size):
        x_newcoord = free_vertexes[i].x - center_vertex.x
        y_newcoord = free_vertexes[i].y - center_vertex.y

        if y_newcoord >= 0.:
            displaced_vertexes_overx = realloc_to_varray(displaced_vertexes_overx, vertexes_over_x_axis, free_vertexes[i])
            vertexes_over_x_axis = vertexes_over_x_axis + 1
            
            
        elif y_newcoord < 0.:
            displaced_vertexes_underx = realloc_to_varray(displaced_vertexes_underx, vertexes_under_x_axis, free_vertexes[i])
            vertexes_under_x_axis = vertexes_under_x_axis + 1
        

    cdef int j
    cdef int k
    cdef int l
    cdef int p
    cdef Vertex2D tmp_vertex1
    cdef Vertex2D tmp_vertex2
    cdef double tmp_mag1
    cdef double tmp_mag2

    cdef double tmp_projection1
    cdef double tmp_projection2
    for j in range(vertexes_over_x_axis):
        for k in range(vertexes_over_x_axis-j-1):
            tmp_mag1 = magnitude((displaced_vertexes_overx[k].x-center_vertex.x), (displaced_vertexes_overx[k].y-center_vertex.y))
            tmp_mag2 = magnitude((displaced_vertexes_overx[k+1].x-center_vertex.x), (displaced_vertexes_overx[k+1].y-center_vertex.y))
            if tmp_mag1 == 0.:
                return
            elif tmp_mag2 == 0.:
                return
            
            
            tmp_projection1 = (displaced_vertexes_overx[k].x-center_vertex.x)/tmp_mag1
            tmp_projection2 = (displaced_vertexes_overx[k+1].x-center_vertex.x)/tmp_mag2

            if tmp_projection1 <= tmp_projection2:
                tmp_vertex1 = displaced_vertexes_overx[k]
                displaced_vertexes_overx[k] = displaced_vertexes_overx[k+1]
                displaced_vertexes_overx[k+1] = tmp_vertex1
    for l in range(vertexes_under_x_axis):
        for p in range(vertexes_under_x_axis-l-1):
            tmp_mag1 = (magnitude(displaced_vertexes_underx[p].x-center_vertex.x, displaced_vertexes_underx[p].y-center_vertex.y))
            tmp_mag2 = (magnitude(displaced_vertexes_underx[p+1].x-center_vertex.x, displaced_vertexes_underx[p+1].y-center_vertex.y))
            if tmp_mag1 == 0.:
                return
            elif tmp_mag2 == 0.:
                return
            
            
            tmp_projection1 = (displaced_vertexes_underx[p].x-center_vertex.x)/tmp_mag1
            tmp_projection2 = (displaced_vertexes_underx[p+1].x-center_vertex.x)/tmp_mag2


            if tmp_projection1 > tmp_projection2:
                tmp_vertex2 = displaced_vertexes_underx[p]
                displaced_vertexes_underx[p] = displaced_vertexes_underx[p+1]
                displaced_vertexes_underx[p+1] = tmp_vertex2
    cdef int m
    cdef int n
    for m in range(vertexes_over_x_axis):
        free_vertexes[m] = displaced_vertexes_overx[m]
    

    for n in range(vertexes_over_x_axis, size):
        free_vertexes[n] = displaced_vertexes_underx[n-vertexes_over_x_axis]
    

    free(displaced_vertexes_overx)
    displaced_vertexes_overx = NULL
    free(displaced_vertexes_underx)
    displaced_vertexes_underx = NULL
#end function




    
    
"""The main triangulate function. Takes a dataset and uses the B-W algorithm to triangulate in O(n*n) time"""
#SUPER EXPERIMENTAL
# !! USE AT YOUR OWN RISK !!
# Mongrel Intruder! Though cometh here to optimize it seemeth?
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Face* triangulate(Vertex2D* original_array, int varr_size, int* gm_size):

    cdef Face* final_mesh = <Face*>malloc(sizeof(Face))
    cdef int final_mesh_size = 0
    
    cdef Face* bad_mesh = <Face*>malloc(sizeof(Face))
    cdef Vertex2D* free_vertices = <Vertex2D*>malloc(sizeof(Vertex2D))
    cdef int bad_mesh_size = 0
    cdef int free_vertices_size = 0
    
    cdef Face temp_face
    cdef Face super_triangle = create_super_triangle(original_array, varr_size)
    
    final_mesh = realloc_to_mesh(final_mesh, final_mesh_size, super_triangle)
    final_mesh_size = final_mesh_size + 1


    cdef int q, r, i, k, l, m, s
    
    for r in range(varr_size):
        q = 0
        while True:
            if q == final_mesh_size:
                break
            if in_circumcircle(final_mesh[q], original_array[r]):
                bad_mesh = realloc_to_mesh(bad_mesh, bad_mesh_size, final_mesh[q])
                bad_mesh_size = bad_mesh_size + 1
                final_mesh = dealloc_from_mesh(final_mesh, final_mesh_size, q)
                final_mesh_size = final_mesh_size - 1
            else:
                q = q + 1
        for i in range(bad_mesh_size):
            free_vertices = realloc_to_varray(free_vertices, free_vertices_size, bad_mesh[i].ver1)
            free_vertices_size = free_vertices_size + 1
            free_vertices = realloc_to_varray(free_vertices, free_vertices_size, bad_mesh[i].ver2)
            free_vertices_size = free_vertices_size + 1
            free_vertices = realloc_to_varray(free_vertices, free_vertices_size, bad_mesh[i].ver3)
            free_vertices_size = free_vertices_size + 1

        for n in range(bad_mesh_size):
            bad_mesh = dealloc_from_mesh(bad_mesh, bad_mesh_size, 0)
        bad_mesh_size = 0
        
        
        k=0
        while k < free_vertices_size - 1:
            l = k + 1
            while l < free_vertices_size:
                if free_vertices[l].vid_nr == free_vertices[k].vid_nr:
                    free_vertices = dealloc_from_varray(free_vertices, free_vertices_size, l)
                    free_vertices_size = free_vertices_size - 1
                else:
                    l = l + 1
            k = k + 1
            
        sort_by_angle_cclockwise(free_vertices, original_array[r], free_vertices_size)
        
        for m in range(free_vertices_size):
            temp_face = create_face(original_array[r], free_vertices[m], free_vertices[(m+1)%free_vertices_size], 0)
            final_mesh = realloc_to_mesh(final_mesh, final_mesh_size, temp_face)
            final_mesh_size = final_mesh_size + 1
            
        for s in range(free_vertices_size):
            free_vertices = dealloc_from_varray(free_vertices, free_vertices_size, 0)
        free_vertices_size = 0
    cdef int index = 0

    while True:
        if index == final_mesh_size:
            break
        
        if final_mesh[index].ver1.vid_nr < 0 or final_mesh[index].ver2.vid_nr < 0 or final_mesh[index].ver3.vid_nr < 0:
            final_mesh = dealloc_from_mesh(final_mesh, final_mesh_size, index)
            final_mesh_size = final_mesh_size - 1

        else:
            index = index + 1
            
    cdef int z
    
    for z in range(final_mesh_size):
        final_mesh[z].fid_nr = z
    
    gm_size[0] = final_mesh_size   
    return final_mesh





############################
############################

"""Below functions for meshing IN 1D"""

############################
############################
"""
cdef Vertex1D* iterative_quicksort(Vertex1D* original_array, int varr_size):
    # Create a copy of the input array
    cdef Vertex1D* sorted_array = <Vertex1D*>malloc(varr_size * sizeof(Vertex1D))
    cdef int i
    for i in range(varr_size):
        sorted_array[i] = original_array[i]

    # Create an auxiliary stack
    cdef int stack[varr_size]
    cdef int top = -1
    # Push initial values of left and right to the stack
    cdef int left = 0
    cdef int right = varr_size - 1
    top += 1
    stack[top] = left
    top += 1
    stack[top] = right
    # Keep popping from stack while it is not empty
    while top >= 0:
        # Pop right and left
        right = stack[top]
        top -= 1
        left = stack[top]
        top -= 1

        # Set pivot element at its correct position in sorted array
        cdef int i = left
        cdef int j = right
        cdef double pivot = sorted_array[(left + right) // 2].x
        cdef Vertex1D temp

        while i <= j:
            while sorted_array[i].x < pivot:
                i += 1
            while sorted_array[j].x > pivot:
                j -= 1
            if i <= j:
                temp = sorted_array[i]
                sorted_array[i] = sorted_array[j]
                sorted_array[j] = temp
                i += 1
                j -= 1

        # Push left and right indices of subarrays to stack
        if left < j:
            top += 1
            stack[top] = left
            top += 1
            stack[top] = j
        if i < right:
            top += 1
            stack[top] = i
            top += 1
            stack[top] = right
    return sorted_array



cdef Line* create_mesh1d(Vertex1D* original_array, int varr_size, int* gm_size):
    
    cdef int final_mesh_size = varr_size - 1
    cdef Line* final_mesh = <Line*>malloc(final_mesh_size * sizeof(Line))
    cdef Vertex1D* sorted_array = iterative_quicksort(original_array, varr_size)
    cdef int i
    for i in range(final_mesh_size):
        final_mesh[i] = create_line(sorted_array[i], sorted_array[i+1], i)
    
    free(sorted_array)
    sorted_array = NULL
    return final_mesh

"""