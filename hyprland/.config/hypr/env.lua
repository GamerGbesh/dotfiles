hl.env("XCURSOR_THEME",             "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE",              "24")
hl.env("HYPRCURSOR_THEME",          "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",           "24")
-- Hybrid Intel+NVIDIA laptop: the panel is on Intel, so don't force every app onto NVIDIA
-- (they force every app through PRIME offload). Use `prime-run <app>` to run something on the dGPU.
-- hl.env("LIBVA_DRIVER_NAME",         "nvidia")
-- hl.env("GBM_BACKEND",               "nvidia-drm")
hl.env("NVD_BACKEND",               "direct")
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("WLR_DRM_NO_ATOMIC",         "1")
hl.env("XDG_CURRENT_DESKTOP",       "Hyprland")
hl.env("XDG_SESSION_TYPE",          "wayland")

