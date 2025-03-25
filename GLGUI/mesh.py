import moderngl_window as mglw
from pathlib import Path


class MeshLoader:
    """
    A class to handle importing meshes in OBJ, STL, and direct VAO formats using mglw.
    """

    def __init__(self, ctx):
        self.ctx = ctx

    def load_obj(self, file_path: str):
        """
        Load a mesh in OBJ format.

        :param file_path: Path to the .obj file
        :return: Loaded scene object
        """
        return mglw.scene.Scene.from_file(file_path)

    def load_stl(self, file_path: str):
        """
        Load a mesh in STL format.

        :param file_path: Path to the .stl file
        :return: Loaded scene object
        """
        return mglw.scene.Scene.from_file(file_path)

    def load_direct_vao(self, vertices, indices=None):
        """
        Load a mesh directly into a VAO from provided vertices and optional indices.

        :param vertices: Array of vertex positions, normals, UVs, etc.
        :param indices: Optional array of indices for indexed drawing
        :return: VAO object
        """
        vbo = self.ctx.buffer(vertices.tobytes())
        ibo = self.ctx.buffer(indices.tobytes()) if indices is not None else None
        vao_content = [
            (vbo, '3f 3f 2f', 'in_position', 'in_normal', 'in_texcoord')
        ]
        vao = self.ctx.vertex_array(self.ctx.program, vao_content, ibo)
        return vao


# Utility function to detect and load a mesh
def load_mesh(ctx, file_path: str):
    """
    Load a mesh automatically based on its file extension.

    :param ctx: moderngl context
    :param file_path: Path to the mesh file (.obj or .stl)
    :return: Loaded scene object
    """
    file_path = Path(file_path)
    loader = MeshLoader(ctx)

    if file_path.suffix.lower() == ".obj":
        return loader.load_obj(file_path)
    elif file_path.suffix.lower() == ".stl":
        return loader.load_stl(file_path)
    else:
        raise ValueError(f"Unsupported file format: {file_path.suffix}")
