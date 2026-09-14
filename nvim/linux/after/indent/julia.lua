local function find_matching_open_paren(lnum)
  local depth = 1
  local search_lnum = lnum - 1

  while search_lnum >= 1 and depth > 0 do
    local line = vim.fn.getline(search_lnum)

    for i = #line, 1, -1 do
      local ch = line:sub(i, i)

      if ch == ')' then
        depth = depth + 1
      elseif ch == '(' then
        depth = depth - 1

        if depth == 0 then
          local after = line:sub(i + 1):match('^%s*;')
          if after then
            return search_lnum
          end
          return nil
        end
      end
    end

    search_lnum = search_lnum - 1
  end
  return nil
end

local function find_enclosing_semi_block(lnum)
  local depth = 0
  local search_lnum = lnum - 1

  while search_lnum >= 1 do
    local line = vim.fn.getline(search_lnum)

    for i = #line, 1, -1 do
      local ch = line:sub(i, i)

      if ch == ')' then
        depth = depth + 1
      elseif ch == '(' then
        if depth == 0 then
          local after = line:sub(i + 1):match('^%s*;')
          if after then
            return search_lnum
          end
          return nil
        end
        depth = depth - 1
      end
    end

    search_lnum = search_lnum - 1
  end
  return nil
end

local function julia_indent()
  local lnum = vim.v.lnum
  if lnum <= 1 then
    return 0
  end

  local sw = vim.fn.shiftwidth()

  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  local prev_line = vim.fn.getline(prev_lnum)

  if prev_line:match('%(%s*;%s*$') then
    return vim.fn.indent(prev_lnum) + sw
  end

  local cur_line = vim.fn.getline(lnum)
  local trimmed = cur_line:match('^%s*(.)')

  if trimmed == ')' then
    local found = find_matching_open_paren(lnum)
    if found then
      return vim.fn.indent(found)
    end
  end

  local inside = find_enclosing_semi_block(lnum)
  if inside then
    return vim.fn.indent(inside) + sw
  end

  return require('nvim-treesitter').indentexpr()
end

_G.cincinperin_julia_indentexpr = julia_indent
vim.bo.indentexpr = "v:lua.cincinperin_julia_indentexpr()"
