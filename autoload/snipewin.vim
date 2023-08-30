let s:host = has('nvim') ? 'nvim' : 'vim'

function! snipewin#select(callback = g:snipewin#callback#default) abort
  let fonts = snipewin#font#load(g:snipewin_label_font)
  let label = g:snipewin_label_chars->split('\zs')
  let label_idx = 0
  " @type Record<string, { label: winid, target: winid }>
  let label_win = {}

  let targets = snipewin#{s:host}#list_win()
  for Filter in g:snipewin_filters
    let targets = targets->copy()->filter({ -> Filter(v:val) })
  endfor
  if len(targets) ==# 0 || (g:snipewin_ignore_single && len(targets) ==# 1)
    return
  endif
  for target in targets
    if label_idx >= len(label)
      call snipewin#_echoerr('Window overflows the length of label. Stop labeling...')
      break
    endif
    let label_win[label[label_idx]] = #{
          \ label: win_id2win(target)->snipewin#{s:host}#create_label(fonts[label[label_idx]]),
          \ target: target,
          \ }
    let label_idx += 1
  endfor

  redraw
  let selected = getcharstr()->toupper()

  call snipewin#{s:host}#clear_label(label_win->values())
  let winid = label_win->get(selected, {})->get('target')
  if winid || v:mouse_winid
    return a:callback(winid ? winid : v:mouse_winid)
  endif
  return v:null
endfunction

function! s:echoerr(msg) abort
  echohl WarningMsg
  echomsg '[snipewin]' a:msg
  echohl None
endfunction
function! snipewin#_echoerr(msg) abort
  call timer_start(0, { -> s:echoerr(a:msg) })
endfunction
