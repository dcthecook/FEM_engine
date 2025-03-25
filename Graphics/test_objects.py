# -*- coding: utf-8 -*-
"""
Created on Thu Sep 12 00:42:48 2024

@author: Enea
"""
# from arrtest import triangle_buffer


# a = triangle_buffer()
# print(a)

from Engine import fx_calls as fx
import matplotlib.pyplot as plt

a = fx.get_circle_test(2, 6, 0, 0, 1)

print(a)

def color():
    return "#{:02x}{:02x}{:02x}".format(100, 100, 100)

def plot_triangulation(arr):
    print("------\n------\nNow for a plot\n------\n------\n")
    fig, axes = plt.subplots(figsize=(40, 40))
    # fig, axes = plt.subplots(1, 3, figsize=(50, 15))   for full solution axes
    # image1 = axes[1].spy(globalmatrix)
    # image2 = axes[2].plot(np.asarray(solution))  dont forget to change fx inputs
    plt.gca().set_facecolor('black')

    # cdef str ver1txt
    # cdef str ver2txt
    # cdef str ver3txt
    # cdef double ox = 0
    # cdef double oy = 0
    for f in range(arr.shape[0]):
        # ox = 0.3333*(mesh.ogmesh[f].ver1.x+mesh.ogmesh[f].ver2.x+mesh.ogmesh[f].ver3.x)
        # oy = 0.3333*(mesh.ogmesh[f].ver1.y+mesh.ogmesh[f].ver2.y+mesh.ogmesh[f].ver3.y)
        # Get vertices
        
        # Draw the triangle
        axes.fill((arr[3*f][0], arr[3*f + 1][0], arr[3*f + 2][0], arr[3*f][0]), (arr[3*f][1], arr[3*f + 1][1], arr[3*f + 2][1], arr[3*f][1]), color=color(), edgecolor='black')
        # ver1txt = f"{mesh.ogmesh[f].ver1.vid_nr}:" + f"({mesh.ogmesh[f].ver1.x:.2f}" + ", " + f"{mesh.ogmesh[f].ver1.y:.2f})"
        # ver2txt = f"{mesh.ogmesh[f].ver2.vid_nr}:" + f"({mesh.ogmesh[f].ver2.x:.2f}" + ", " + f"{mesh.ogmesh[f].ver2.y:.2f})"
        # ver3txt = f"{mesh.ogmesh[f].ver3.vid_nr}:" + f"({mesh.ogmesh[f].ver3.x:.2f}" + ", " + f"{mesh.ogmesh[f].ver3.y:.2f})"
        # Annotate each vertex with its index
        # axes.text(mesh.ogmesh[f].ver1.x, mesh.ogmesh[f].ver1.y, ver1txt, color='red', fontsize=20, ha='right', va='top')
        # axes.text(mesh.ogmesh[f].ver2.x, mesh.ogmesh[f].ver2.y, ver2txt, color='red', fontsize=20, ha='right', va='top')
        # axes.text(mesh.ogmesh[f].ver3.x, mesh.ogmesh[f].ver3.y, ver3txt, color='red', fontsize=20, ha='right', va='top')
        # axes.text(ox, oy, "f:"+str(mesh.ogmesh[f].fid_nr), color='black', fontsize=12, ha='center', va='center')
    axes.set_title('Triangulation', fontsize=35)
    plt.show()
    
plot_triangulation(a)