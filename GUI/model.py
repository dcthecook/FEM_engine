# -*- coding: utf-8 -*-
"""
Created on Wed Oct  2 00:29:55 2024

@author: Enea
"""

import glm
#import numpy as np
from fx_calls import circle_test


class Mesh:
    def __init__(self, ctx, camera):
        self.ctx = ctx
        self.camera = camera
        self.vbo = self.get_vbo()
        self.shader_program = self.get_shader_program('default')
        self.vao = self.get_vao()
        self.m_model = glm.mat4()

    def update(self, time):
        """Update the model matrix (e.g., for animations)."""
        self.m_model = glm.rotate(glm.mat4(), time * 0.5, glm.vec3(0.0, 1.0, 0.0))
        self.shader_program['m_model'].write(self.m_model)
        self.shader_program['m_view'].write(self.camera.m_view)
        self.shader_program['m_proj'].write(self.camera.m_proj)

    def render(self):
        """Render the mesh."""
        self.vao.render()

    def get_vbo(self):
        """Create and return a Vertex Buffer Object."""
        vertex_data = circle_test()
        return self.ctx.buffer(vertex_data.tobytes())

    def get_vao(self):
        """Create and return a Vertex Array Object."""
        return self.ctx.simple_vertex_array(self.shader_program, self.vbo, 'in_vert')

    def get_shader_program(self, shader_name):
        """Load and compile shaders."""
        with open(f'shaders/{shader_name}.vert') as vs_file:
            vertex_shader = vs_file.read()
        with open(f'shaders/{shader_name}.frag') as fs_file:
            fragment_shader = fs_file.read()

        return self.ctx.program(vertex_shader=vertex_shader, fragment_shader=fragment_shader)




# # import numpy as np
# import glm  # GLM for matrix operations
# from fx_calls import circle, circle_test


# class Mesh:
#     def __init__(self, ctx):
#         """
#         Initialize the Mesh object with ModernGL context
#         """
#         self.ctx = ctx
#         self.vbo = self.get_vbo()  # Initialize the Vertex Buffer Object
#         self.shader_program = self.get_shader_program('default')  # Load shaders
#         self.vao = self.get_vao()  # Initialize the Vertex Array Object
#         self.m_model = self.get_model_matrix()  # Model transformation matrix

#     def update(self, time):
#         """
#         Update the model matrix (e.g., apply rotation or animations)
#         :param time: Current time or frame-based time
#         """
#         self.m_model = glm.rotate(
#             glm.mat4(), time * 0.5, glm.vec3(0.0, 1.0, 0.0)
#         )  # Rotate around Y-axis
#         self.shader_program['m_model'].write(self.m_model)  # Update shader uniform

#     def get_model_matrix(self):
#         """
#         Return the identity model matrix
#         """
#         return glm.mat4()

#     def get_vao(self):
#         """
#         Create and return a Vertex Array Object
#         """
#         vao = self.ctx.simple_vertex_array(self.shader_program, self.vbo, 'in_vert', 'in_color')
#         return vao

#     def get_vbo(self):
#         """
#         Create and return a Vertex Buffer Object
#         """
#         vertex_data = circle_test()
#         vbo = self.ctx.buffer(vertex_data.tobytes())
#         return vbo



#     def get_shader_program(self, shader_name):
#         """
#         Load vertex and fragment shaders and return a compiled program
#         :param shader_name: Name of the shader files (without extension)
#         """
#         with open(f'shaders/{shader_name}.vert') as vs_file:
#             vertex_shader = vs_file.read()
#         with open(f'shaders/{shader_name}.frag') as fs_file:
#             fragment_shader = fs_file.read()

#         return self.ctx.program(
#             vertex_shader=vertex_shader,
#             fragment_shader=fragment_shader,
#         )

#     def render(self):
#         """
#         Render the mesh
#         """
#         self.update()
#         self.vao.render()
