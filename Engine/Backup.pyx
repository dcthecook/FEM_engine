%%cython
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






###########################
###########################

"""Below structs for the basic geometry"""

###########################
###########################



"""First layer simplex. The Vertex2D"""
"""Below functions to create an instance of the struct"""
ctypedef struct Vertex2D:
    double x
    double y
    int vid_nr

    


cdef Vertex2D create_vertex(double x_coord, double y_coord, int vid_number):
    cdef Vertex2D v
    v.x = x_coord
    v.y = y_coord
    v.vid_nr = vid_number
    return v





##
"""The Face"""
"""Functions to create instances of Face"""
ctypedef struct Face:
    Vertex2D ver1
    Vertex2D ver2
    Vertex2D ver3
    int fid_nr


    

cdef Face create_face(Vertex2D vertex1, Vertex2D vertex2, Vertex2D vertex3, int fid_number):
    cdef Face f
    f.ver1 = vertex1
    f.ver2 = vertex2
    f.ver3 = vertex3
    f.fid_nr = fid_number
    return f







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
        


"""A function like the one below to realloc a vertex array instead of a face array"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef inline Vertex2D* realloc_to_varray(Vertex2D* old_array, int current_size, Vertex2D new_vertex):
    cdef int new_size = current_size + 1
    cdef Vertex2D* new_array = <Vertex2D*>malloc(new_size * sizeof(Vertex2D))
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
cdef inline Face* realloc_to_mesh(Face* mesh, int current_size, Face new_face):
    cdef int new_size = current_size + 1
    cdef Face* new_mesh = <Face*>malloc(new_size * sizeof(Face))
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





"""A function to jumptstart allocate the Vertex2D struct in an array for testing purposes"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Vertex2D* alloc_varr(int size, double var):
    cdef Vertex2D* varray = <Vertex2D*>malloc(size * sizeof(Vertex2D))
    cdef int i
    for i in range(size):
        varray[i] = create_vertex(var, var, i)
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
#input 3 vertexes to calculate circumcenter of circumcircle
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef inline Vertex2D circumcenter(Vertex2D v1, Vertex2D v2, Vertex2D v3):
    cdef Vertex2D center
    #inverse of determinant method (by wedge product)
    cdef double D = (v1.x*(v2.y-v3.y) + v2.x*(v3.y-v1.y) + v3.x*(v1.y-v2.y))*2
    center.x = (1/D)*((v1.x**2 + v1.y**2)*(v2.y-v3.y) + (v2.x**2 + v2.y**2)*(v3.y-v1.y) + (v3.x**2 + v3.y**2)*(v1.y-v2.y))
    center.y = (1/D)*((v1.x**2 + v1.y**2)*(v3.x-v2.x) + (v2.x**2 + v2.y**2)*(v1.x-v3.x) + (v3.x**2 + v3.y**2)*(v2.x-v1.x))
    center.vid_nr = -1
    return center


"""Circumradius"""
#works
#you have to be retarded to not know what this returns
@cython.boundscheck(False)
@cython.wraparound(False)
cdef inline double circumradius(Vertex2D v1, Vertex2D v2, Vertex2D v3):
    cdef Vertex2D ccenter = circumcenter(v1, v2, v3)
    cdef double radius = sqrt((v1.x-ccenter.x)**2 + (v1.y-ccenter.y)**2)
    
    return radius



"""Check if Vertex2D p is in Circumcircle of v1v2v3"""
#works
#returns 0 or 1 based on condition if p is in C(v)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef inline int in_circumcircle(Face f, Vertex2D p):
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

"""Below functions for meshing"""

############################
############################





"""The most important part to have valid faces with no crossings. It takes a list of free vertexes and oriens them c-clockwise"""
"""Uses the Dot product orthogonality and Bubble Sort"""
#works
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef inline void sort_by_angle_cclockwise(Vertex2D* free_vertexes, Vertex2D center_vertex, int size):
    cdef int vertexes_over_x_axis = 0
    cdef int vertexes_under_x_axis = 0
    ###  !DON'T FORGET TO FREE!  ###
    #2 arrays are first allocateed. They will be filled with elements whose y
    #coordinate is either above or below thee y coordinate of center_vertex
    cdef Vertex2D* displaced_vertexes_overx = <Vertex2D*>malloc(sizeof(Vertex2D))
    cdef Vertex2D* displaced_vertexes_underx = <Vertex2D*>malloc(sizeof(Vertex2D))
    ###
    

    cdef double x_newcoord
    cdef double y_newcoord
    
    cdef int i
    
    #This loop compares the y's of the Vertex2Des to be sorted relative to the center we chose
    #Then it allocates them to the overx or underx arrays respectively while adjusting size
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
    
    
    #Use bubble sort. The arrays are expected to be relatively small
    #We first normalize the Vertex2D-center vector system. Then we use Vector translation invariance to calculate the
    #Projection onto the x-Axis created by the center vertex parallel to the actual x-y system
    #They are sorted in order from bigger to smaller. This guarantees counter-clockwiseness due to the
    #monotonically decreasing nature of the cosinus function between 0 and pi. (we are essentially just calculating the x coordinate 
    #of the dot product of our vector with (1, 0) which is just its x coordinatee.
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
    
    #Same as the loop above but the cosinus becomes monotonically increasing between
    #pi and 2pi so we have to ordeer fromm smaller to biggest.
    #When we merege both sets we are guaranteed a full counterclockwise set
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
    
    #Adjust the elements of the actual array with the 2 new temp arrays we ordered
    #This avoids a return statement
    cdef int m
    cdef int n
    for m in range(vertexes_over_x_axis):
        free_vertexes[m] = displaced_vertexes_overx[m]
    

    for n in range(vertexes_over_x_axis, size):
        free_vertexes[n] = displaced_vertexes_underx[n-vertexes_over_x_axis]
    
    #Free the temp arrays from memory
    free(displaced_vertexes_overx)
    free(displaced_vertexes_underx)
#end function




    
    
"""The main triangulate function. Takes a dataset and uses the B-W algorithm to triangulate in O(n*n) time"""
#SUPER EXPERIMENTAL
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Face* triangulate(Vertex2D* original_array, int varr_size, int* gm_size):
    #Main triangulate function. It takes an array Pointer to a Vertex2D-type dataset, its size
    #and a pointer to a global array gm_size which will be the final recorded mesh size
    #This is needed for later purposes outside the function itself. It is therefore necessary
    #to keep the variable in memory. Because a normal global int is immutable, i cannot
    #define gm_size as a regular int. This actually works to our advantage, in that i can later
    #dynamically expand gm_size if i decide to hold multiple independant triangulations of meshes
    #all in one scene. This means i need not pre-determine how many independant int's need exist
    #because i can just expand a dynamic array full of them.
    
    
    #We start by initializing a final_mesh in memory along with a counter of its size
    #internally the size starts at 1 but it will get commputed as if it starts at 0
    #the size will get incremented as needed
    cdef Face* final_mesh = <Face*>malloc(sizeof(Face))
    cdef int final_mesh_size = 0
    
    #Here we do the same allocation process but for a bad_mesh
    #which will hold a list of all Triangle elements which are marked as
    # "bad" so that their Vertex2Des can form new triangles later in the code
    #This is also adjusted dynamically by size
    #free_vertices will hold the vertexes of the bad triangles temporarely
    cdef Face* bad_mesh = <Face*>malloc(sizeof(Face))
    cdef Vertex2D* free_vertices = <Vertex2D*>malloc(sizeof(Vertex2D))
    cdef int bad_mesh_size = 0
    cdef int free_vertices_size = 0
    
    #temp_face will serve as a temporary face later for comparisons
    #The process starts off with creating the super_triangle Face relative to the dataset
    #The super triangle is then allocated to the final_mesh as the first element and its size is +1
    cdef Face temp_face
    cdef Face super_triangle = create_super_triangle(original_array, varr_size)
    
    final_mesh = realloc_to_mesh(final_mesh, final_mesh_size, super_triangle)
    final_mesh_size = final_mesh_size + 1


    cdef int q, r, i, k, l, m, s
    
    #Here we enter the main loop over all Vertex2Des present in our array
    #It goes through the main array Vertex2Des and uses 'r' as the main index
    for r in range(varr_size):

        q = 0
        #Here we enter the secondary loop through all the elements in the final mesh
        #Each has to have its Circumcenter compared to the point 'r' in the main vertex array
        #If the elements CC inscribes point 'r' then this element is declared invalid
        #and it is thrown in the bad_mesh. Sizes are adjusted accordingly
        #This cannot be written with a for-range() loop because the loop boundaries
        #are dynamic. They depend on weather we remove the element or not
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
                
        #All vertexes in bad mesh are added to the array that holds free vertexes. 
        #Then bad mesh is emptied
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
        
        
        #Use bubble compare to remove all Vertex2Des with a duplicate vid_nr in the free array
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
            
            
        #Use the sort by angle function to sort all Vertex2Des in the free array
        #counterclockwise by Angle starting from the one nearest to the (1, 0) relative
        #unit vector.
        sort_by_angle_cclockwise(free_vertices, original_array[r], free_vertices_size)
        
        #Create a temp face with each vertex in the free array in order. This guarantees no intersecting
        #edges because they are ordered by angle
        #Then empty the free vertexes array to make it ready for the next main iteration
        for m in range(free_vertices_size):
            temp_face = create_face(original_array[r], free_vertices[m], free_vertices[(m+1)%free_vertices_size], 0)
            final_mesh = realloc_to_mesh(final_mesh, final_mesh_size, temp_face)
            final_mesh_size = final_mesh_size + 1
            
        for s in range(free_vertices_size):
            free_vertices = dealloc_from_varray(free_vertices, free_vertices_size, 0)
        free_vertices_size = 0
    
    
    #Remove all Triangles in the final main mesh that share a Vertex2D with th super triangle.
    #This can be done because the super triangle has Vertex2Des with negative int's in the vid_nr
    #A simple loop and compare through the final mesh is fairly simple
    cdef int index = 0

    while True:
        if index == final_mesh_size:
            break
        
        if final_mesh[index].ver1.vid_nr < 0 or final_mesh[index].ver2.vid_nr < 0 or final_mesh[index].ver3.vid_nr < 0:
            final_mesh = dealloc_from_mesh(final_mesh, final_mesh_size, index)
            final_mesh_size = final_mesh_size - 1

        else:
            index = index + 1
            
            
    #Assign a fid_nr to all faces in order. All fid_nr or vid_nr MUST be positive
    #for easier counting purposes and troubleshooting
    cdef int z
    
    for z in range(final_mesh_size):
        final_mesh[z].fid_nr = z
    
    #Set the global 0'th element of global mesh size to our calculated final_mesh size
    gm_size[0] = final_mesh_size
        
    return final_mesh
        

    
#########################################################################################
#########################################################################################

"""TEST UNITS"""

#########################################################################################
#########################################################################################

import random
import matplotlib.pyplot as plt
from libc.math cimport cos, sin, pi
    

"""unit test for angular sorting and using the dealloc functions on a mesh and varray"""
#start the array of Zero-Zero Vertices
#!! THIS ARRAY IS MALLOCED BUT NOT FREED BY DEFAULT !! THE SIZE HAS TO BE KEPT TRACK OF
cdef int varr_ssize = 3601
cdef Vertex2D* og_array = alloc_varr(varr_ssize, 0)
cdef int* global_mesh_size = <int*>malloc(sizeof(int))
global_mesh_size[0] = 0 #dynamically changed through triangulate fx




# Center point
og_array[0].x = 0
og_array[0].y = 0

# Generating points in circular patterns
total_layers = 40
total_points_per_layer = 90
circle_radius = 2

for layer in range(total_layers):
    angle_step = 2 * pi / total_points_per_layer
    
    for i in range(total_points_per_layer):
        index = layer * total_points_per_layer + i + 1
        angle = i * angle_step
        radius = circle_radius * (layer + 1) / total_layers  # Subdivide radius
        og_array[index].x = radius * cos(angle)
        og_array[index].y = radius * sin(angle)
    og_array[i].y = 3 * sin(angle)



cdef Face* testmesh = triangulate(og_array, varr_ssize, global_mesh_size)



    
    
    
print("------\n------\nNow for a plot\n------\n------\n")



plt.figure(figsize = (30, 30))
plt.gca().set_facecolor('black')
def random_color():
    return "#{:02x}{:02x}{:02x}".format(random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))



# Set custom x and y axis limits
plt.xlim(-2.3, 2.3)
plt.ylim(-2.3, 2.3)


for f in range(global_mesh_size[0]):
    plt.fill((testmesh[f].ver1.x, testmesh[f].ver2.x, testmesh[f].ver3.x, testmesh[f].ver1.x), (testmesh[f].ver1.y, testmesh[f].ver2.y, testmesh[f].ver3.y, testmesh[f].ver1.y), color=random_color())






plt.show()
free(testmesh)
testmesh = NULL
free(og_array)
og_array = NULL
free(global_mesh_size)
global_mesh_size = NULL