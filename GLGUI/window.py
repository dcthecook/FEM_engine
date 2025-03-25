# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 11:32:26 2024

@author: Enea
"""

import moderngl_window
from moderngl_window import geometry
import glm
from GLGUI.shaders import load_shader

class NavierStokes2D(moderngl_window.WindowConfig):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.solver = kwargs.get('solver')  # Get the FEM solver instance
        self.mesh = kwargs.get('mesh')      # Get the mesh generator instance
        
        # Setup shader programs (loaded using load_shader or directly)
        self.texture_prog = self.load_program("shaders/navier-stokes/texture.glsl")
        self.drop_prog = self.load_program("shaders/navier-stokes/drop.glsl")
        # Initialize the mesh and other FEM settings
        self.setup_fem()

    def setup_fem(self):
        # Set up the FEM simulation (could involve setting boundary conditions, mesh details, etc.)
        pass

    def render(self, time, frame_time):
        # Call the solver for the simulation step and update results
        self.solver.step(self.mesh)

        # Render the updated simulation results using shaders
        self.quad_fs.render(self.texture_prog)
