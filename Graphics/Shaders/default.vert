#version 330 core
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_gpu_shader_fp64 : enable
#extension GL_ARB_vertex_attrib_64bit : enable

in vec3 in_vert;
in vec3 in_color;

out vec3 v_color; // NEW out vec3 color

uniform mat4 m_proj;
uniform mat4 m_view;
uniform mat4 m_model;





void main() {
    v_color = in_color;  // NEW 
    gl_Position = m_proj * m_view * m_model * vec4(in_vert, 1.0);
}