# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 01:56:06 2024

@author: Enea
"""

from PyQt5.QtWidgets import QOpenGLWidget
import moderngl
from camera import Camera
from PyQt5.QtCore import Qt, QTimer
import time
from model import Mesh
import numpy as np

class OpenGLWidget(QOpenGLWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.mesh = None
        self.camera = Camera(self)
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_scene)
        self.timer.start(16)  # Roughly 60 FPS
        self.last_mouse_position = None
        self.keys_pressed = set()

        # Initialize last_time for delta_time calculation
        self.last_time = time.time()
        self.delta_time = 0

    # def initializeGL(self):
    #     self.ctx = moderngl.create_context()  # Create ModernGL context
    #     self.ctx.enable(moderngl.DEPTH_TEST)
    #     self.mesh = Mesh(self.ctx)  # Load the mesh and shaders
    
    def initializeGL(self):
        self.ctx = moderngl.create_context()
        self.ctx.enable(moderngl.DEPTH_TEST)
    
        # Define a simple triangle vertex data (2D for simplicity, no colors)
        vertices = np.array([
            [-0.6, -0.6, 0.0],  # Vertex 1
            [ 0.6, -0.6, 0.0],  # Vertex 2
            [ 0.0,  0.6, 0.0],  # Vertex 3
            ], dtype='f4')
    
        # Create buffer and VAO
        self.vbo = self.ctx.buffer(vertices.tobytes())
        
        # Load shaders (simple vertex and fragment shaders)
        self.program = self.ctx.program(
            vertex_shader='''
                #version 330
                uniform mat4 m_proj;
                uniform mat4 m_view;
                uniform mat4 m_model;
                
                in vec3 in_vert;
                void main() {
                    gl_Position = m_proj * m_view * m_model * vec4(in_vert, 1.0);
                    }
                ''',
                fragment_shader='''
                #version 330
                out vec4 fragColor;
                void main() {
                    fragColor = vec4(0.1, 0.8, 0.3, 1.0);  // Green color for triangle
                    }
                '''
                )
        
        # Set up vertex array object (VAO)
        self.vao = self.ctx.vertex_array(self.program, [(self.vbo, '3f', 'in_vert')])
        
        # Camera setup (uses m_proj and m_view uniform matrices)
        self.camera.update_view_matrix()


    def resizeGL(self, w, h):
        # Update the projection matrix on resize
        self.camera.aspect_ratio = w / h
        self.camera.m_proj = self.camera.get_projection_matrix()

    # def paintGL(self):
    #     # Clear the context and render the scene
    #     self.ctx.clear(0.1, 0.1, 0.1, 1.0)
    #     self.mesh.render()
    
    def paintGL(self):
        self.ctx.clear(0.1, 0.1, 0.1)  # Clear the screen with a dark gray background
        
        # Update camera matrices
        self.program['m_proj'].write(self.camera.m_proj)
        self.program['m_view'].write(self.camera.m_view)
        self.program['m_model'].write(np.eye(4, dtype='f4'))  # No rotation, identity model matrix
        
        # Render the triangle
        self.vao.render()


    def update_scene(self):
        """ Update the scene, handle camera movement and rendering """

        # Calculate delta_time (time between frames)
        current_time = time.time()
        self.delta_time = current_time - self.last_time
        self.last_time = current_time

        mouse_delta = (0, 0)
        if self.last_mouse_position:
            mouse_pos = self.mapFromGlobal(self.cursor().pos())
            rel_x = mouse_pos.x() - self.last_mouse_position.x()
            rel_y = mouse_pos.y() - self.last_mouse_position.y()
            mouse_delta = (rel_x, rel_y)
        
        # Update the camera based on input
        self.camera.update(self.keys_pressed, mouse_delta)
        
        # Update the mouse position
        self.last_mouse_position = self.mapFromGlobal(self.cursor().pos())
        
        # Update the OpenGL window
        self.update()

    def keyPressEvent(self, event):
        """ Track key presses for camera movement """
        self.keys_pressed.add(event.key())

    def keyReleaseEvent(self, event):
        """ Track key releases """
        if event.key() in self.keys_pressed:
            self.keys_pressed.remove(event.key())

    def mouseMoveEvent(self, event):
        """ Track mouse movement for camera rotation """
        if self.last_mouse_position is None:
            self.last_mouse_position = event.pos()
