return {
	{
		"stevearc/conform.nvim",
		dependencies = { "williamboman/mason.nvim" },
		lazy = true,
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		init = function()
			-- Install the conform formatter on VeryLazy
			require("util").on_very_lazy(function()
				require("util.format").register({
					name = "conform.nvim",
					priority = 100,
					primary = true,
					format = function(buf)
						local plugin = require("lazy.core.config").plugins["conform.nvim"]
						local Plugin = require("lazy.core.plugin")
						local opts = Plugin.values(plugin, "opts", false)

						require("conform").format(require("util").merge({}, opts.format, { bufnr = buf }))
					end,
					sources = function(buf)
						local ret = require("conform").list_formatters(buf)

						---@param v conform.FormatterInfo
						return vim.tbl_map(function(v)
							return v.name
						end, ret)
					end,
				})
			end)
		end,
		opts = {
			-- util.format will use these options when formatting with the conform.nvim formatter
			format = {
				timeout_ms = 3000,
				async = false, -- not recommended to change
				quiet = false, -- not recommended to change
				lsp_fallback = true, -- not recommended to change
			},
			---@type table<string, conform.FormatterUnit[]>
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "shfmt" },
			},
			-- The options you set here will be merged with the builtin formatters.
			-- You can also define any custom formatters here.
			---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
			formatters = {
				injected = { options = { ignore_errors = true } },
			},
		},
		config = function(_, opts)
			for _, key in ipairs({ "format_on_save", "format_after_save" }) do
				if opts[key] then
					require("util").warn(
						("Don't set `opts.%s` for `conform.nvim`.\n**This Vim Configuration** will use the conform formatter automatically"):format(
							key
						)
					)
					---@diagnostic disable-next-line: no-unknown
					opts[key] = nil
				end
			end
			require("conform").setup(opts)
		end,
	},
}
