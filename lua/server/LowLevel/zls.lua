vim.lsp.config('zls', {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'build.zig', 'build.zig.zon', '.git' },
  settings = {
    zls = {
      zig_exe_path = vim.fn.exepath('zig'), -- explicit path, avoids ZLS hunting
    }
  }
})

vim.lsp.enable('zls')
