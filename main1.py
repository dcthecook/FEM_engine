from pathlib import Path
import moderngl
from GLGUI.camera import OrbitCameraWindow

class MainApp(OrbitCameraWindow):
    """
    Example of main app. camera + model
    """
    aspect_ratio = 16 / 9
    resource_dir = Path(__file__).parent.resolve() / 'resources'
    title = "Test-App"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.wnd.mouse_exclusivity = True
        self.scene = self.load_scene('scenes/crate.obj')

        self.camera.projection.update(near=0.1, far=100.0)
        self.camera.mouse_sensitivity = 0.75
        self.camera.zoom = 2.5

    def on_render(self, time: float, frametime: float):
        """Override render method to handle custom rendering"""
        self.ctx.enable_only(moderngl.DEPTH_TEST | moderngl.CULL_FACE)

        # Render the scene with camera's projection and view matrices
        self.scene.draw(
            projection_matrix=self.camera.projection.matrix,
            camera_matrix=self.camera.matrix,
            time=time,
        )


if __name__ == '__main__':
    MainApp.run()


    
    
# from GLGUI.mesh import MeshLoader
# from GLGUI.camera import OrbitCameraWindow
# from pathlib import Path
# from GLGUI.mesh import MeshLoader

# class MainApp(OrbitCameraWindow, MeshLoader):
#     """
#     Main application that combines camera and mesh loading.
#     """
#     aspect_ratio = 16 / 9
#     resource_dir = Path(__file__).parent.resolve() / 'resources'
#     title = "Test"

#     def __init__(self, **kwargs):
#         # Initialize the parent classes
#         OrbitCameraWindow.__init__(self, **kwargs)
#         MeshLoader.__init__(self, self.ctx)  # Pass the context to MeshLoader

#         self.wnd.mouse_exclusivity = True

#         # Use MeshLoader to load the scene
#         self.scene = self.load_obj('scenes/crate.obj')

#         self.camera.projection.update(near=0.1, far=100.0)
#         self.camera.mouse_sensitivity = 0.75
#         self.camera.zoom = 2.5

#     def render(self, time: float, frametime: float):
#         self.ctx.enable_only(moderngl.DEPTH_TEST | moderngl.CULL_FACE)

#         self.scene.draw(
#             projection_matrix=self.camera.projection.matrix,
#             camera_matrix=self.camera.matrix,
#             time=time,
#         )


# if __name__ == '__main__':
#     MainApp.run()
