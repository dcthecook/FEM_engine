from setuptools import setup
from Cython.Build import cythonize
from setuptools.extension import Extension
import numpy





#python setupcall.py build_ext --inplace


extensions = [
    Extension(
        name='Call',
        sources=['Call.pyx'],
        include_dirs=[numpy.get_include()],
    ),
]

setup(
    ext_modules=cythonize(extensions),
    description='format calls',
    # Specify the directory where the compiled files should be placed
    install_requires=[
        'numpy',
    ],
    script_args=["build_ext", "--inplace", "--build-lib=build"]
)