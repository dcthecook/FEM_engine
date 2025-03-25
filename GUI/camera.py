# # -*- coding: utf-8 -*-
# """
# Created on Thu Sep 12 19:32:07 2024

# @author: Enea
# """


import glm
from PySide6.QtCore import Qt

FOV = 50
NEAR = 0.1
FAR = 100
SPEED = 0.01
SENSITIVITY = 0.1


class Camera:
    def __init__(self, app, position=(0, 0, 4), yaw=-90, pitch=0):
        self.app = app
        self.aspect_ratio = app.width() / app.height()
        self.position = glm.vec3(*position)
        self.up = glm.vec3(0, 1, 0)
        self.forward = glm.vec3(0, 0, -1)
        self.right = glm.vec3(1, 0, 0)
        self.yaw = yaw
        self.pitch = pitch
        self.m_proj = self.get_projection_matrix()
        self.m_view = self.get_view_matrix()

    def update_projection_matrix(self):
        self.m_proj = self.get_projection_matrix()

    def rotate(self, rel_x, rel_y):
        """Rotate the camera using mouse movement."""
        self.yaw += rel_x * SENSITIVITY
        self.pitch -= rel_y * SENSITIVITY
        self.pitch = max(-89, min(89, self.pitch))
        self.update_camera_vectors()

    def update_camera_vectors(self):
        """Update camera direction vectors based on yaw and pitch."""
        yaw, pitch = glm.radians(self.yaw), glm.radians(self.pitch)
        self.forward.x = glm.cos(yaw) * glm.cos(pitch)
        self.forward.y = glm.sin(pitch)
        self.forward.z = glm.sin(yaw) * glm.cos(pitch)
        self.forward = glm.normalize(self.forward)
        self.right = glm.normalize(glm.cross(self.forward, glm.vec3(0, 1, 0)))
        self.up = glm.normalize(glm.cross(self.right, self.forward))

    def move(self, keys_pressed, delta_time):
        """Move the camera based on key inputs."""
        velocity = SPEED * delta_time
        if Qt.Key_W in keys_pressed:
            self.position += self.forward * velocity
        if Qt.Key_S in keys_pressed:
            self.position -= self.forward * velocity
        if Qt.Key_A in keys_pressed:
            self.position -= self.right * velocity
        if Qt.Key_D in keys_pressed:
            self.position += self.right * velocity
        if Qt.Key_Q in keys_pressed:
            self.position += self.up * velocity
        if Qt.Key_E in keys_pressed:
            self.position -= self.up * velocity

    def update(self, keys_pressed, delta_time):
        """Update the camera's position and view matrix."""
        self.move(keys_pressed, delta_time)
        self.m_view = self.get_view_matrix()

    def get_projection_matrix(self):
        """Return the camera's projection matrix."""
        return glm.perspective(glm.radians(FOV), self.aspect_ratio, NEAR, FAR)

    def get_view_matrix(self):
        """Return the camera's view matrix."""
        return glm.lookAt(self.position, self.position + self.forward, self.up)



# import glm
# from PyQt5.QtCore import Qt

# FOV = 50
# NEAR = 0.1
# FAR = 100
# SPEED = 0.01
# SENSITIVITY = 0.1

# class Camera:
#     def __init__(self, app, position=(0, 0, 4), yaw=-90, pitch=0):
#         self.app = app
#         self.aspect_ratio = app.width() / app.height()
#         self.position = glm.vec3(2, 3, 3)
#         self.up = glm.vec3(0, 1, 0)
#         self.right = glm.vec3(1, 0, 0)
#         self.forward = glm.vec3(0, 0, -1)
#         self.yaw = yaw
#         self.pitch = pitch
#         #form the view matrix
#         self.m_view = self.get_view_matrix()
#         #projection matrix
#         self.m_proj = self.get_projection_matrix()

#     def update_view_matrix(self):
#         self.m_view = self.get_view_matrix()

#     def rotate(self, mouse_delta):
#         rel_x, rel_y = mouse_delta  # Use mouse_delta provided by Qt
#         self.yaw += rel_x * SENSITIVITY
#         self.pitch -= rel_y * SENSITIVITY
#         self.pitch = max(-89, min(89, self.pitch))

#     def update_camera_vectors(self):
#         yaw, pitch = glm.radians(self.yaw), glm.radians(self.pitch)

#         self.forward.x = glm.cos(yaw) * glm.cos(pitch)
#         self.forward.y = glm.sin(pitch)
#         self.forward.z = glm.sin(yaw) * glm.cos(pitch)

#         self.forward = glm.normalize(self.forward)
#         self.right = glm.normalize(glm.cross(self.forward, glm.vec3(0, 1, 0)))
#         self.up = glm.normalize(glm.cross(self.right, self.forward))

#     def update(self, keys_pressed, mouse_delta):
#         self.move(keys_pressed)
#         self.rotate(mouse_delta)
#         self.update_camera_vectors()
#         self.update_view_matrix()

#     def move(self, keys_pressed):
#         velocity = SPEED * self.app.delta_time
#         if Qt.Key_W in keys_pressed:
#             self.position += self.forward * velocity
#         if Qt.Key_S in keys_pressed:
#             self.position -= self.forward * velocity
#         if Qt.Key_A in keys_pressed:
#             self.position -= self.right * velocity
#         if Qt.Key_D in keys_pressed:
#             self.position += self.right * velocity
#         if Qt.Key_Q in keys_pressed:
#             self.position += self.up * velocity
#         if Qt.Key_E in keys_pressed:
#             self.position -= self.up * velocity

#     def get_projection_matrix(self):
#         return glm.perspective(glm.radians(FOV), self.aspect_ratio, NEAR, FAR)

#     def get_view_matrix(self):
#         return glm.lookAt(self.position, self.position + self.forward, self.up)
