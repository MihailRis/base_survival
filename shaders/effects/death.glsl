vec4 effect() {
    vec4 color = texture(u_screen, v_uv);
    color = texture(u_screen, v_uv + color.rg * (0.1 + sin(u_timer * 1211.5) * 0.02));
    float mid = (color.r + color.g + color.b) * 0.333 * 2.5;
    return vec4(mid, mid, mid, 1.0);
}
