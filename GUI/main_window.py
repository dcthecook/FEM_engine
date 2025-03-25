# -*- coding: utf-8 -*-
"""
Created on Wed Oct  2 00:28:56 2024

@author: Enea
"""

from PyQt5.QtWidgets import QMainWindow, QVBoxLayout, QWidget
from PyQt5.QtCore import Qt
from widgets.opengl_widget2 import OpenGLWidget  # Custom OpenGL widget that wraps ModernGL rendering

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("FEM Renderer")

        # Central Widget Layout
        self.main_widget = QWidget()
        self.setCentralWidget(self.main_widget)

        # OpenGL Widget (for 3D rendering)
        self.opengl_widget = OpenGLWidget(self)

        # Layout
        layout = QVBoxLayout(self.main_widget)
        layout.addWidget(self.opengl_widget)

        self.setGeometry(200, 200, 1200, 800)
