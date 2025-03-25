# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 11:32:37 2024

@author: Enea
"""

def load_shader(path):
    # Helper function to load shaders from files
    with open(path, 'r') as file:
        return file.read()
