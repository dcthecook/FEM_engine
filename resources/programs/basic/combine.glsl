#version 330

#if defined VERTEX_SHADER

in vec3 in_position;
in vec3 in_color;

out vec3 v_color;

uniform mat4 m_proj;
uniform mat4 m_view;
uniform mat4 m_model;

void main() {
    v_color = in_color;
    gl_Position = m_proj * m_view * m_model * vec4(in_position, 1.0);
}


#elif defined FRAGMENT_SHADER

in vec3 v_color;

out vec4 fragColor;

void main() {
    fragColor = vec4(v_color, 1.0);
}


#endif
