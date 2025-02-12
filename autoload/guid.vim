function! GuidNew()
    if has('win32') || has('win64')
        let guid = system('powershell -command "[guid]::NewGuid().ToString()"')
    else
        let guid = system('uuidgen')
    endif
    let guid = substitute(guid, '\n\+$', '', '')
    execute "normal! i" . guid
endfunction 