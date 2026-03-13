return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            include = {
              "**/.claude",
              "**/.claude/**",
              "**/CLAUDE.md",
              "**/.github",
              "**/.github/**",
            },
            jump = {
              close = true,
            },
            layout = {
              preset = "default",
            },
          },
        },
      },
    },
  },
}
