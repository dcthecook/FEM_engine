#version 330

in vec3 frag_color;  // Color from the vertex shader
out vec4 out_color;  // Output final color

void main()
{
    out_color = vec4(frag_color, 1.0);  // Set the output color
}
