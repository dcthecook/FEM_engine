import moderngl as mgl
#import numpy as np
import time
from PySide6.QtOpenGL import QOpenGLWindow
from PySide6.QtCore import Qt
from PySide6.QtGui import QCursor
from camera import Camera
from model import Mesh


class OpenGLWindow(QOpenGLWindow):
    def __init__(self):
        super().__init__()
        self.ctx = None
        self.camera = None
        self.mesh = None
        self.last_time = time.time()
        self.delta_time = 0
        self.keys_pressed = set()
        self.last_mouse_position = None
        self.mouse_locked = False

    def initializeGL(self):
        """Initialize OpenGL context and resources."""
        self.ctx = mgl.create_context()
        self.ctx.enable(mgl.DEPTH_TEST)
        self.ctx.clear(0.58, 0.08, 0.08, 1.0)

        # Initialize camera and mesh
        self.camera = Camera(self)
        self.mesh = Mesh(self.ctx, self.camera)

    def resizeGL(self, width, height):
        """Resize OpenGL viewport and update the camera aspect ratio."""
        self.ctx.viewport = (0, 0, width, height)
        self.camera.aspect_ratio = width / height
        self.camera.update_projection_matrix()

    def paintGL(self):
        """Render the scene."""
        # Update timing
        current_time = time.time()
        self.delta_time = current_time - self.last_time
        self.last_time = current_time

        # Handle mouse movement for camera rotation
        if self.mouse_locked:
            current_mouse_pos = self.cursor().pos()
            if self.last_mouse_position:
                rel_x = current_mouse_pos.x() - self.last_mouse_position.x()
                rel_y = current_mouse_pos.y() - self.last_mouse_position.y()
                self.camera.rotate(rel_x, rel_y)
            self.last_mouse_position = current_mouse_pos

        # Update the camera and render the mesh
        self.camera.update(self.keys_pressed, self.delta_time)
        self.ctx.clear(0.08, 0.08, 0.08, 1.0)
        self.mesh.render()

    def keyPressEvent(self, event):
        """Handle key press events."""
        self.keys_pressed.add(event.key())
        if event.key() == Qt.Key_Escape:
            self.close()

    def keyReleaseEvent(self, event):
        """Handle key release events."""
        self.keys_pressed.discard(event.key())

    def mousePressEvent(self, event):
        """Lock mouse movement when pressed."""
        if event.button() == Qt.LeftButton:
            self.mouse_locked = True
            # Center the cursor in the window
            self.center_cursor()

    def mouseReleaseEvent(self, event):
        """Unlock mouse movement when released."""
        if event.button() == Qt.LeftButton:
            self.mouse_locked = False

    def center_cursor(self):
        """Center the cursor within the window."""
        center_pos = self.mapToGlobal(self.geometry().center())
        QCursor.setPos(center_pos)

    def mouseMoveEvent(self, event):
        """Handle mouse movement for camera rotation."""
        if self.mouse_locked:
            # Calculate mouse movement
            current_pos = event.globalPosition().toPoint()
            center_pos = self.mapToGlobal(self.geometry().center())
            delta = current_pos - center_pos
            
            # Update the camera based on mouse delta
            self.camera.rotate(delta.x(), delta.y())
            
            # Re-center the cursor
            self.center_cursor()






# import moderngl as mgl
# from PySide6.QtOpenGL import QOpenGLWindow
# from PySide6.QtCore import QTimer
# from model import Mesh  # Import Mesh class from model.py
# # from camera import Camera
# import time


# class OpenGLWindow(QOpenGLWindow):
#     def __init__(self, win_size=(2200, 1250)):
#         super().__init__()
#         mgl.init()
#         self.WIN_SIZE = win_size
#         self.ctx = None
#         self.mesh = None  # Placeholder for Mesh object
#         self.camera = None
#         self.time = 0
#         self.delta_time = 0
#         self.last_time = time.time()
#         self.timer = QTimer(self)
#         self.timer.timeout.connect(self.update_scene)
#         self.timer.start(16)  # Roughly 60 FPS

#     def initializeGL(self):
#         """ Initialize OpenGL context and resources """
#         self.ctx = mgl.create_context()
#         self.ctx.enable(mgl.DEPTH_TEST)  # Enable depth testing for 3D rendering
#         # self.ctx.clear(0.08, 0.16, 0.18, 1.0)  # Clear color for the window
        
#         # Initialize Camera
#         # self.camera = Camera(self)
        
#         # Initialize the Mesh object
#         self.mesh = Mesh(self.ctx)  # Pass context and camera to Mesh class

#     def resizeGL(self, width, height):
#         """ Resize the OpenGL viewport """
#         self.ctx.viewport = (0, 0, width, height)
#         # if self.camera:
#         #     self.camera.aspect_ratio = width / height
#         #     self.camera.m_proj = self.camera.get_projection_matrix()

#     def paintGL(self):
#         """ Render the scene """
#         self.ctx.clear(0.3, 0.1, 0.1, 1.0)  # Clear the screen
#         # print("Rendering frame...")

#         # # Write camera matrices (replace these with static for testing)
#         # self.mesh.shader_program['m_proj'].write(self.camera.m_proj)
#         # self.mesh.shader_program['m_view'].write(self.camera.m_view)
        
#         # # Log matrices for debugging
#         # print("Projection Matrix:", self.camera.m_proj)
#         # print("View Matrix:", self.camera.m_view)
        
#         # Render the mesh
#         self.mesh.render()


#     def update_scene(self):
#         """ Update the scene, camera, and other dynamic elements """
#         current_time = time.time()
#         self.delta_time = current_time - self.last_time
#         self.last_time = current_time

#         # if self.camera:
#         #     # Mock key press and mouse delta (replace with actual logic later)
#         #     keys_pressed = set()  # Replace with real input tracking
#         #     mouse_delta = (0, 0)  # Replace with actual mouse delta
            
#         #     self.camera.move(keys_pressed, self.delta_time)
#         #     self.camera.rotate(mouse_delta)

#         self.update()  # Trigger a repaint

        
#     # # Load vertex and fragment shaders
#     # def get_shader_program(self, shader_name):
#     #     with open(f'shaders/{shader_name}.vert') as file:
#     #         vertex_shader = file.read()
            
#     #     with open(f'shaders/{shader_name}.frag') as file:
#     #         fragment_shader = file.read()
            
#     #     return self.ctx.program(vertex_shader=vertex_shader, fragment_shader=fragment_shader)
    
    
    

