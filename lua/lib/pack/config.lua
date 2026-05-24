local M = {}

-- Maximum number of commits shown per plugin in the log.
M.max_commits = 12

-- When true, commits of a `dimmed_commit_types` kind are omitted from the log
-- entirely; when false they are shown but dimmed (lazy.nvim's behaviour).
M.hide_dimmed_commits = true

-- Commit subjects matching any of these Lua patterns are dropped from the log
-- entirely. These are automated/noise commits that aren't conventional commits.
M.ignored_commit_subjects = {
    "^%[docgen%]",
    "^Update SchemaStore catalog",
}

-- Conventional-commit types that carry little signal in a changelog.
M.dimmed_commit_types = {
    bot = true,
    build = true,
    chore = true,
    ci = true,
    docs = true,
    style = true,
    test = true,
}

return M
