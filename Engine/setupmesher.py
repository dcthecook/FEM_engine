from setuptools import setup
from Cython.Build import cythonize
from setuptools.extension import Extension





#python setupmesher.py build_ext --inplace


extensions = [
    Extension(
        name='Mesher',
        sources=['Mesher.pyx'],
    ),
]

setup(
    ext_modules=cythonize(extensions),
    description='FEM solver mesher',
    # Specify the directory where the compiled files should be placed
    script_args=["build_ext", "--inplace", "--build-lib=build"]
)