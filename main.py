import moderngl_window as mglw
import numpy as np
from GLGUI.camera import OrbitCameraWindow
import moderngl



class TriangleWithCamera(OrbitCameraWindow):
    title = "Triangle with Orbit Camera"
    aspect_ratio = 16 / 9
    resizable = True

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.camera.zoom = 2.5  # Initial zoom level
        self.camera_enabled = True

        # Define the shaders
        vertex_shader = """
        #version 330
        layout(location = 0) in vec3 in_position;
        layout(location = 1) in vec3 in_color;

        out vec3 frag_color;
        uniform mat4 projection;
        uniform mat4 modelview;

        void main() {
            gl_Position = projection * modelview * vec4(in_position, 1.0);
            frag_color = in_color;
        }
        """

        fragment_shader = """
        #version 330
        in vec3 frag_color;
        out vec4 out_color;

        void main() {
            out_color = vec4(frag_color, 1.0);
        }
        """

        # Compile shader program
        self.shader_program = self.ctx.program(
            vertex_shader=vertex_shader,
            fragment_shader=fragment_shader,
        )

        # Define triangle vertices with positions and colors
        self.vertices = np.array([[
            0.0,  0.5, 0.0, 1.0, 0.0, 0.0],[  # Top vertex (Red)
           -0.5, -0.5, 0.0, 0.0, 1.0, 0.0],[  # Bottom-left vertex (Green)
            0.5, -0.5, 0.0, 0.0, 0.0, 1.0   # Bottom-right vertex (Blue)
        ]], dtype='f4')

        self.vbo = self.ctx.buffer(self.vertices)
        self.vao = self.ctx.vertex_array(
            self.shader_program,
            [(self.vbo, '3f 3f', 'in_position', 'in_color')],
        )

    def modify_vertices(self):
        """Modify the vertex color values randomly."""
        # Generate random float values for the colors (between 0 and 1)
        self.vertices[0,3] = np.random.rand()  # Modify first color (Red)
        self.vertices[1,4] = np.random.rand()  # Modify second color (Green)
        self.vertices[2,5] = np.random.rand()  # Modify third color (Blue)

        # Update the VBO with the new vertex data
        self.vbo.write(self.vertices)

    def on_render(self, time: float, frame_time: float):
        self.ctx.enable_only(moderngl.DEPTH_TEST)
        self.wnd.fbo.clear(color=(0.0, 0.0, 0.0))

        # Call modify_vertices to change the color of the triangle every frame
        self.modify_vertices()

        self.shader_program['projection'].write(self.camera.projection.matrix)
        self.shader_program['modelview'].write(self.camera.matrix)

        self.vao.render()

    def key_event(self, key, action, modifiers):
        super().key_event(key, action, modifiers)  # Keep camera controls
        if action == self.wnd.keys.ACTION_PRESS:
            if key == self.wnd.keys.ESCAPE:
                self.wnd.close()


if __name__ == "__main__":
    TriangleWithCamera.run()
