import moderngl_window as mglw
from moderngl_window.scene.camera import KeyboardCamera, OrbitCamera


class CameraWindow(mglw.WindowConfig):
    """Base class with built in 3D camera support"""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.camera = KeyboardCamera(self.wnd.keys, aspect_ratio=self.wnd.aspect_ratio)
        self.camera_enabled = True

    def on_key_event(self, key, action, modifiers):
        keys = self.wnd.keys

        if self.camera_enabled:
            self.camera.key_input(key, action, modifiers)

        if action == keys.ACTION_PRESS:
            if key == keys.C:
                self.camera_enabled = not self.camera_enabled
                self.wnd.mouse_exclusivity = self.camera_enabled
                self.wnd.cursor = not self.camera_enabled
            if key == keys.SPACE:
                self.timer.toggle_pause()

    def on_mouse_position_event(self, x: int, y: int, dx, dy):
        if self.camera_enabled:
            self.camera.rot_state(-dx, -dy)

    def on_resize(self, width: int, height: int):
        self.camera.projection.update(aspect_ratio=self.wnd.aspect_ratio)


class OrbitCameraWindow(mglw.WindowConfig):
    """Base class with built in 3D orbit camera support

    Move the mouse to orbit the camera around the view point.
    """

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.camera = OrbitCamera(aspect_ratio=self.wnd.aspect_ratio)
        self.camera_enabled = False #Camera starts disabled
        self.right_button_pressed = False
        self.left_button_pressed = False
        self.last_mouse_position = None


    
    def on_mouse_press_event(self, x: int, y: int, button: int):
        """Enable camera when right mouse button is pressed"""
        if button == 3: #0 left button, 1 middle button, 2 right button
            self.right_button_pressed = True
            self.camera_enabled = True
            self.wnd.mouse_exclusivity = True  # Capture mouse
            self.wnd.cursor = False  # Hide cursor
        if button == 1:
            self.left_button_pressed = True
            
    def on_mouse_release_event(self, x: int, y: int, button: int):
        """Disable camera when right mouse button is released"""
        if button == 3:#self.wnd.keys.MOUSE_BUTTON_RIGHT:
            self.right_button_pressed = False
            self.camera_enabled = False
            self.wnd.mouse_exclusivity = False  # Release mouse
            self.wnd.cursor = True  # Show cursor
        if button == 1:
            self.left_button_pressed = False

    def on_mouse_position_event(self, x: int, y: int, dx, dy):
        if self.camera_enabled:
            if self.right_button_pressed and self.left_button_pressed:
                #Pan the camera when both buttons pressed
                self.pan_camera(dx, dy)
            elif self.right_button_pressed:
                #orbit only if right button pressed
                self.camera.rot_state(dx, dy)
            self.last_mouse_position = (x, y)

    def on_mouse_scroll_event(self, x_offset: float, y_offset: float):
        if self.camera_enabled:
            self.camera.zoom_state(y_offset)

    def on_resize(self, width: int, height: int):
        self.camera.projection.update(aspect_ratio=self.wnd.aspect_ratio)


class OrbitDragCameraWindow(mglw.WindowConfig):
    """Base class with drag-based 3D orbit support

    Click and drag with the left mouse button to orbit the camera around the view point.
    """

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.camera = OrbitCamera(aspect_ratio=self.wnd.aspect_ratio)

    def key_event(self, key, action, modifiers):
        keys = self.wnd.keys

        if action == keys.ACTION_PRESS:
            if key == keys.SPACE:
                self.timer.toggle_pause()

    def mouse_drag_event(self, x: int, y: int, dx, dy):
        self.camera.rot_state(dx, dy)

    def mouse_scroll_event(self, x_offset: float, y_offset: float):
        self.camera.zoom_state(y_offset)

    def resize(self, width: int, height: int):
        self.camera.projection.update(aspect_ratio=self.wnd.aspect_ratio)
        
        
    def pan_camera(self, dx, dy):
        """Pan the camera by adjusting its position."""
        if self.last_mouse_pos:
            # Translate the camera in the XY plane
            pan_factor = 0.005  # Adjust this for sensitivity
            self.camera.position[0] -= dx * pan_factor
            self.camera.position[1] += dy * pan_factor
            self.camera.target[0] -= dx * pan_factor
            self.camera.target[1] += dy * pan_factor
    # def key_event(self, key, action, modifiers):
    #     keys = self.wnd.keys

    #     if action == keys.ACTION_PRESS:
    #         if key == keys.C:
    #             self.camera_enabled = not self.camera_enabled
    #             self.wnd.mouse_exclusivity = self.camera_enabled
    #             self.wnd.cursor = not self.camera_enabled
    #         if key == keys.SPACE:
    #             self.timer.toggle_pause()
    #old code above from using C to enable disable
    #new code below to use right mouse button as even release