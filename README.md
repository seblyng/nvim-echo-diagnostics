# nvim-echo-diagnostics

This plugin provides functions to echo diagnostics without being prompted to press enter.

## Installation

### packer.nvim

```Lua
use 'seblyng/nvim-echo-diagnostics'
```

### vim-plug

```Vim
call plug#begin()

Plug 'seblyng/nvim-echo-diagnostics'

call plug#end()
```

## Setup

```lua
require('echo-diagnostics').setup({
    show_diagnostic_number = true,
    show_diagnostic_source = false,
})
```

## Usage

You can now utilize the functions to echo the entire message or a message that fits in the commandline based on `set cmdheight`

```vim
" NOTE: You should consider setting updatetime to less than default.
" This could be set with `set updatetime=300`
" This will echo the diagnostics on CursorHold, and will also consider cmdheight
autocmd CursorHold * lua require('echo-diagnostics').echo_line_diagnostic()

" This will echo the entire diagnostic message.
" Should prompt you with Press ENTER or type command to continue.

nnoremap <leader>cd <cmd>lua require("echo-diagnostics").echo_entire_diagnostic()<CR>
```
