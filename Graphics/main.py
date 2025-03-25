# -*- coding: utf-8 -*-
"""
Created on Tue Aug  6 16:34:14 2024

@author: Enea
"""
# cimport cython
import pygame as pg
import moderngl as mgl
import sys
from model import *
from camera import Camera



class GraphicsEngine:
    def __init__(self, win_size=(2200, 1250)):
        #init pygame modules
        pg.init()
        #window size
        self.WIN_SIZE = win_size
        #alias MSAA
        pg.display.gl_set_attribute(pg.GL_MULTISAMPLEBUFFERS, 1)
        pg.display.gl_set_attribute(pg.GL_MULTISAMPLESAMPLES, 2)
        #set opengl attributes and vers u wanna use hehe
        pg.display.gl_set_attribute(pg.GL_CONTEXT_MAJOR_VERSION, 3)
        pg.display.gl_set_attribute(pg.GL_CONTEXT_MINOR_VERSION, 3)
        pg.display.gl_set_attribute(pg.GL_CONTEXT_PROFILE_MASK, pg.GL_CONTEXT_PROFILE_CORE)
        #create opengl context
        pg.display.set_mode(self.WIN_SIZE, flags=pg.OPENGL | pg.DOUBLEBUF)
        #mouse settings
        pg.event.set_grab(True)
        pg.mouse.set_visible(False)
        #detect and use existing opengl context
        self.ctx = mgl.create_context()
        self.ctx.enable(flags=mgl.DEPTH_TEST)
        #create and object to help track time
        self.clock = pg.time.Clock()
        self.time = 0
        self.delta_time = 0
        #camera hehe
        self.camera = Camera(self)
        #scene
        self.scene = Mesh(self)
        
    def check_events(self):
        for event in pg.event.get():
            if event.type == pg.QUIT or (event.type == pg.KEYDOWN and event.key == pg.K_ESCAPE):
                self.scene.destroy()
                pg.quit()
                sys.exit()
                
    def render(self):
        #clear framebuffer
        self.ctx.clear(color=(0.08, 0.16, 0.18))
        #render scene
        self.scene.render()
        #swap buffers
        pg.display.flip()
        
    
    def get_time(self):
        self.time = pg.time.get_ticks() * 0.001
        
    
    
    def run(self):
        while True:
            self.get_time()
            self.check_events()
            self.camera.update()
            self.render()
            self.delta_time = self.clock.tick(240)
            
if __name__ == '__main__':
    app = GraphicsEngine()
    app.run()
