# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 01:54:27 2024

@author: Enea
"""




# main.py
import sys
from PySide6.QtWidgets import QApplication
from GLWindow import OpenGLWindow

if __name__ == "__main__":
    app = QApplication.instance() or QApplication(sys.argv)
    window = OpenGLWindow()
    window.setGeometry(100, 100, 800, 600)
    window.show()
    sys.exit(app.exec())
