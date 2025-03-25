# -*- coding: utf-8 -*-
"""
Created on Thu Sep 12 00:36:43 2024

@author: Enea
"""


import moderngl
import numpy as np
from PIL import Image
from fx_calls import circle, circle_test

# Create a standalone context
ctx = moderngl.create_standalone_context()

# Define the shaders
prog = ctx.program(
    vertex_shader='''
        #version 330

        in vec3 in_vert;   // Vertex position
        in vec3 in_color;  // Vertex color

        out vec3 v_color;  // Pass color to the fragment shader

        void main() {
            v_color = in_color;
            gl_Position = vec4(in_vert, 1.0);
        }
    ''',
    fragment_shader='''
        #version 330

        in vec3 v_color;   // Interpolated color from the vertex shader
        out vec3 f_color;  // Output color

        void main() {
            f_color = v_color;
        }
    '''
)

# Define the vertex positions and colors for the triangle (3 vertices)
# test = circle_test()
# test[:,2] = 0.

# print(test)
# print(test.shape)

vertices = np.asarray(circle_test(), dtype='f4')


print(vertices)
print(vertices.shape)
# Create a buffer with the vertex data
vbo = ctx.buffer(vertices.tobytes())

# Create a vertex array object (VAO) to store the vertex specification
vao = ctx.simple_vertex_array(prog, vbo, 'in_vert', 'in_color')

# Create a framebuffer to render to (512x512 resolution)
fbo = ctx.simple_framebuffer((2000, 2000))
fbo.use()

# Clear the framebuffer with a black background
fbo.clear(0.0, 0.0, 0.0, 1.0)

# Render the triangle
vao.render(moderngl.TRIANGLES)

# Read the framebuffer and convert it to an image
image = Image.frombytes('RGB', fbo.size, fbo.read(), 'raw', 'RGB', 0, -1)

# Display the rendered image
image.show()



# Define the vertex positions and colors for the triangle (3 vertices)
# vertices = np.array([
#     # 2D position    # RGB color
#     -0.5,  0.0, 0.0,      1.0, 0.0, 0.0,   # Red vertex
#      0.5,  0.0, 0.0,      0.0, 1.0, 0.0,   # Green vertex
#      0.0,  1.0, 0.0,      0.0, 0.0, 1.0,   # Blue vertex
#      0.5,  0.0, 0.0,      1.0, 0.0, 0.0,   # Red vertex
#     -0.5,  0.0, 0.0,      0.0, 1.0, 0.0,   # Green vertex
#      0.0, -1.0, 0.0,      1.0, 0.5, 0.0    # Blue vertex
# ], dtype='f4')
