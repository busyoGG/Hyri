hl.layer_rule({
    name         = "blur",
    match        = { namespace = ".*" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name  = "no_blur",
    match = {
        namespace = table.concat({
            "gtk4%-layer%-shell",
            "selection",
            "awww%-daemon",
            "linux%-wallpaperengine",
            "quickshell",
            "^dms:.*:background$",
        }, "|"),
    },
    blur  = false,
})
