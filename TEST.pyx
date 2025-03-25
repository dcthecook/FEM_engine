cimport cython
import numpy as np
cimport numpy as np

#from cython cimport sizeof, NULL
#from libc.stdlib cimport malloc, free

cdef extern from "C_func.c":
    #C included it says in docs so that it neednt be compiled
    pass

cdef extern from "C_func.h":
    void scale_C(double *, double *, unsigned int)
    void dot_C(double *, double *, double *, unsigned int)
    
def scale(arr, double factor):
    if not arr.flags['C_CONTIGUOUS']:
        arr = np.ascontiguousarray(arr)
        
    cdef double[::1] arr_memview = arr
    
    scale_C(&arr_memview[0], &factor, arr_memview.shape[0])
    
    return arr


a = np.ones(5, dtype=np.double)
print(scale(a, 3))
    