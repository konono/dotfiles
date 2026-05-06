return {
  "m00qek/baleia.nvim",
  event = "BufReadPost",
  config = function()
    local ASYNC_THRESHOLD = 20000

    local baleia_sync = require("baleia").setup({
      strip_ansi_codes = true,
      async = false,
    })

    local baleia_async = require("baleia").setup({
      strip_ansi_codes = true,
      async = true,
    })

    vim.api.nvim_create_user_command("BaleiaColorize", function()
      baleia_sync.once(vim.api.nvim_get_current_buf())
    end, { bang = true })

    local function has_ansi(lines)
      for _, line in ipairs(lines) do
        if line:find("\027%[") then
          return true
        end
      end
      return false
    end

    local function colorize_if_ansi(buf)
      local line_count = vim.api.nvim_buf_line_count(buf)
      local head = vim.api.nvim_buf_get_lines(buf, 0, math.min(50, line_count), false)
      local tail = line_count > 50
          and vim.api.nvim_buf_get_lines(buf, math.max(0, line_count - 50), line_count, false)
        or {}
      if has_ansi(head) or has_ansi(tail) then
          if line_count > ASYNC_THRESHOLD then
            baleia_async.once(buf)
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_set_option_value("modified", false, { buf = buf })
              end
            end, 500)
          else
            baleia_sync.once(buf)
            vim.api.nvim_set_option_value("modified", false, { buf = buf })
          end
          return
        end
    end

    vim.api.nvim_create_autocmd({ "BufReadPost" }, {
      callback = function()
        colorize_if_ansi(vim.api.nvim_get_current_buf())
      end,
    })

    -- 遅延ロードのトリガーとなった最初のバッファもチェック
    colorize_if_ansi(vim.api.nvim_get_current_buf())
  end,
}
