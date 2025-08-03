function! GuidNew() range
    if has('win32') || has('win64')
        let guid = system('powershell -command "[guid]::NewGuid().ToString()"')
    else
        let guid = system('uuidgen')
    endif
    let guid = substitute(guid, '\n\+$', '', '')
    
    if a:firstline != a:lastline || getpos("'<")[1] != 0
        execute "normal! gv"
        execute "normal! c" . guid
    else
        execute "normal! a" . guid
    endif
endfunction 
