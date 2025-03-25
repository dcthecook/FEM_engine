#version 330

in vec2 in_position;  // Input position from vertex data
in vec3 in_color;     // Input color from vertex data
out vec3 frag_color;  // Output color to pass to fragment shader


uniform mat4 m_proj;  // Projection matrix (to apply transformations)

void main()
{
    gl_Position = m_proj * vec4(in_position, 0.0, 1.0);  // Apply transformation using m_proj
    frag_color = in_color;  // Pass color to fragment shader
}