# -*- coding: utf-8 -*-
"""
Created on Thu Aug 22 22:03:03 2024

@author: Enea
"""

import numpy as np
import glm
#cimport numpy as np
from fx_calls import circle, circle_test

class Mesh:
    def __init__(self, app):
        self.app = app
        self.ctx = app.ctx
        self.vbo = self.get_vbo()
        # self.vbo_solution
        self.shader_program = self.get_shader_program('default')
        self.vao = self.get_vao()  
        self.m_model = self.get_model_matrix()
        self.on_init()
        
    def update(self):
        m_model = glm.rotate(self.m_model, 0.4*self.app.time, glm.vec3(0, 1, 0))
        self.shader_program['m_model'].write(m_model)
        self.shader_program['m_view'].write(self.app.camera.m_view)
        
    def get_model_matrix(self):
        m_model = glm.mat4()
        return m_model
        
    
    def on_init(self):
        self.shader_program['m_proj'].write(self.app.camera.m_proj)
        self.shader_program['m_view'].write(self.app.camera.m_view)
        self.shader_program['m_model'].write(self.m_model)
    
    def render(self):
        self.update()
        self.vao.render()
        
    def destroy(self):
        self.vbo.release()
        self.shader_program.release()
        self.vao.release()
    
    # Associating the vertex_buffer with shader_program. '3f8' is the buffer format for position, 'f8' for the solution value.
    def get_vao(self):
        vao = self.ctx.vertex_array(self.shader_program, self.vbo, 'in_vert', 'in_color')
        return vao
        
    def get_vertex_data(self):
        vertex_data = circle_test()
        return vertex_data
    
    #send vertex data to GPU
    def get_vbo(self):
        vertex_data = self.get_vertex_data()
        vbo = self.ctx.buffer(vertex_data.tobytes())
        return vbo
    
    
    #get vertex and fragment shaders saftely
    def get_shader_program(self, shader_name):
        with open(f'shaders/{shader_name}.vert') as file:
            vertex_shader = file.read()
            
        with open(f'shaders/{shader_name}.frag') as file:
            fragment_shader = file.read()
            
        # with open(f'shaders/{shader_name}.geom') as file:
        #     geometry_shader = file.read()
            
        program = self.ctx.program(vertex_shader=vertex_shader,
                                   fragment_shader=fragment_shader)
                                   #geometry_shader=geometry_shader)
        return program
    
    
    
    # # Associating the vertex_buffer with shader_program. '3f8' is the buffer format for position, 'f8' for the solution value.
    # def get_vao(self):
    #     vao = self.ctx.vertex_array(
    #         self.shader_program, 
    #         [
    #             (self.vbo, '3f4 /v', 'in_position')
    #         ]
    #     )
    #     return vao