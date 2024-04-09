local M = {}

local defaults = {
	icons = {
		misc = {
			dots = "󰇘",
		},
		dap = {
			Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
			Breakpoint = " ",
			BreakpointCondition = " ",
			BreakpointRejected = { " ", "DiagnosticError" },
			LogPoint = ".>",
		},
		diagnostics = {
			Error = " ",
			Warn = " ",
			Hint = " ",
			Info = " ",
		},
		git = {
			added = " ",
			modified = " ",
			removed = " ",
		},
		kinds = {
			Array = " ",
			Boolean = "󰨙 ",
			Class = "𝓒 ",
			Codeium = "󰘦 ",
			Color = " ",
			Control = " ",
			Collapsed = " ",
			Constant = "󰏿 ",
			Constructor = " ",
			Copilot = " ",
			Enum = "ℰ ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Folder = " ",
			Function = "󰊕 ",
			Interface = " ",
			Key = "🔐 ",
			Keyword = " ",
			Method = "󰊕 ",
			Module = " ",
			Namespace = "󰦮 ",
			Null = " ",
			Number = "󰎠 ",
			Object = "⦿ ",
			Operator = "+ ",
			Package = " ",
			Property = " ",
			Reference = " ",
			Snippet = " ",
			String = "𝓐 ",
			Struct = "󰆼 ",
			TabNine = "󰏚 ",
			Text = " ",
			TypeParameter = "𝙏 ",
			Unit = " ",
			Value = " ",
			Variable = "󰀫 ",
		},
	},
}

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	local ft = vim.bo[buf].filetype

	if M.kind_filter == false then
		return
	end

	if M.kind_filter[ft] == false then
		return
	end

	if type(M.kind_filter[ft]) == "table" then
		return M.kind_filter[ft]
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

M.did_init = false

function M.init()
	if M.did_init then
		return
	end

	M.did_init = true

	-- delay notifications till vim.notify was replaced or after 500ms
	-- LazyVim.lazy_notify()

	-- load options here, before lazy init while sourcing plugin modules
	-- this is needed to make sure options will be correctly applied
	-- after installing missing plugins
	require("config.options")

	require("util.plugin").setup()
end

function M.setup()
	local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		callback = function()
			require("config.keymaps")
			require("util.format").setup()
			require("util.root").setup()
		end,
	})

	require("config.keymaps")
end

setmetatable(M, {
	__index = function(_, key)
		return vim.deepcopy(defaults)[key]
	end,
})

return M
