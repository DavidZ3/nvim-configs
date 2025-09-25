return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local startify = require("alpha.themes.startify")

    -- Normalize a path for comparison (absolute, forward slashes, trim trailing slash,
    -- case-insensitive on Windows).
    local function normalize(p)
      if not p or p == "" then return "" end
      p = vim.fn.fnamemodify(p, ":p")         -- absolute
      p = p:gsub("\\", "/")                    -- backslash -> slash
      if p:sub(-1) == "/" then p = p:sub(1, -2) end
      if vim.loop.os_uname().sysname == "Windows_NT" then
        p = p:lower()
      end
      return p
    end

    -- Build an MRU group; uppercase=true uses A..Z, lowercase uses a..z.
    -- If cwd_only=true, only include files under current working directory.
    local function mru_letters(max_items, uppercase, cwd_only)
      local cwd = normalize(vim.fn.getcwd())
      local items, seen = {}, {}

      local keys_lower = { "a","s","d","f","g","h","j","k","l",
                           "q","w","e","r","t","y","u","i","o","p",
                           "z","x","c","v","b","n","m",
                           "1","2","3","4","5","6","7","8","9","0" }
      local keys_upper = { "A","S","D","F","G","H","J","K","L",
                           "Q","W","E","R","T","Y","U","I","O","P",
                           "Z","X","C","V","B","N","M",
                           "1","2","3","4","5","6","7","8","9","0" }
      local keys = uppercase and keys_upper or keys_lower

      for _, f in ipairs(vim.v.oldfiles) do
        if #items == max_items then break end
        if vim.fn.filereadable(f) == 1 then
          local fp = normalize(f)
          local in_cwd = (fp == cwd) or (fp:sub(1, #cwd + 1) == cwd .. "/")
          if (not cwd_only) or in_cwd then
            if not seen[fp] then
              seen[fp] = true
              local short = vim.fn.fnamemodify(f, ":~")
              table.insert(items, startify.file_button(f, keys[#items + 1] or tostring(#items + 1), short, false))
            end
          end
        end
      end

      return { type = "group", val = items }
    end

    -- MRU (lowercase, global) and MRU_CWD (UPPERCASE, filtered to cwd)
    startify.section.mru.val[4].val     = function() return { mru_letters(20, false, false) } end
    startify.section.mru_cwd.val[4].val = function() return { mru_letters(20, true,  true ) } end

    alpha.setup(startify.config)
  end,
}
