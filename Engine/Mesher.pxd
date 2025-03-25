##
#Header declaration
##

ctypedef struct Vertex1D:
    double x
    int vid_nr

ctypedef struct Vertex2D:
    double x
    double y
    int vid_nr




ctypedef struct Face:
    Vertex2D ver1
    Vertex2D ver2
    Vertex2D ver3
    int fid_nr

ctypedef struct Line:
    Vertex1D ver1
    Vertex1D ver2
    int fid_nr

cdef Vertex2D create_vertex2d(double x_coord, double y_coord, int vid_number)

cdef Vertex1D create_vertex1d(double x_coord, int vid_number)

cdef Face create_face(Vertex2D vertex1, Vertex2D vertex2, Vertex2D vertex3, int fid_number)

cdef Line create_line(Vertex1D vertex1, Vertex1D vertex2, int fid_number)

cdef Vertex2D* dealloc_from_varray(Vertex2D* original_array, int current_size, int remove_index)

cdef Vertex1D* dealloc_from_varray1d(Vertex1D* original_array, int current_size, int remove_index)

cdef Vertex2D* realloc_to_varray(Vertex2D* old_array, int current_size, Vertex2D new_vertex)

cdef Vertex1D* realloc_to_varray1d(Vertex1D* old_array, int current_size, Vertex1D new_vertex)

cdef Face* realloc_to_mesh(Face* mesh, int current_size, Face new_face)

cdef Line* realloc_to_mesh1d(Line* mesh, int current_size, Line new_face)

cdef Face* dealloc_from_mesh(Face* original_mesh, int current_size, int remove_index)

cdef Line* dealloc_from_mesh1d(Line* original_mesh, int current_size, int remove_index)

cdef Vertex2D* alloc_varr(int size, double var)

cdef Vertex1D* alloc_varr1d(int size, double var)

cdef double magnitude(double x, double y)

cdef double dot_product(Vertex2D v1, Vertex2D v2)

cdef double distance(Vertex2D v1, Vertex2D v2)

cdef Vertex2D circumcenter(Vertex2D v1, Vertex2D v2, Vertex2D v3)

cdef double circumradius(Vertex2D v1, Vertex2D v2, Vertex2D v3)

cdef int in_circumcircle(Face f, Vertex2D p)

cdef Face create_super_triangle(Vertex2D* points, int num_points)

cdef void sort_by_angle_cclockwise(Vertex2D* free_vertexes, Vertex2D center_vertex, int size)

cdef Face* triangulate(Vertex2D* original_array, int varr_size, int* gm_size)
