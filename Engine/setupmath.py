from setuptools import setup
from Cython.Build import cythonize
from setuptools.extension import Extension
import numpy




#python setupmath.py build_ext --inplace

    
    
extensions = [
    Extension(
        name='Math',
        sources=['Math.pyx'],
        include_dirs=[numpy.get_include()],
    ),
]

setup(
    ext_modules=cythonize(extensions),
    description='FEM solver math',
    install_requires=[
        'numpy',
    ],
    # Specify the directory where the compiled files should be placed
    script_args=["build_ext", "--inplace", "--build-lib=build"]
)