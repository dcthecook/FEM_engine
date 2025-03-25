#version 330 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader_fp64 : enable
#extension GL_ARB_vertex_attrib_64bit : enable

// noperspective in vec3 barycentric_coords;  // Barycentric coordinates from the geometry shader
in vec3 v_color;  // NEW Interpolated color from the vertex shader

out vec3 fragColor;

void main() {
    fragColor = v_color;
}