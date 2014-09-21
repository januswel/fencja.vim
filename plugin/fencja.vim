" vim plugin file
" Filename:     fencja.vim
" Maintainer:   janus_wel <janus.wel.3@gmail.com>
" License:      MIT License {{{1
"   See under URL.  Note that redistribution is permitted with LICENSE.
"   https://github.com/januswel/fencja.vim/blob/master/LICENSE

" preparation {{{1
" check if this plugin is already loaded or not
if exists('loaded_fencja')
    finish
endif
let loaded_fencja = 1

" check vim has the required feature
if !(has('multi_byte') && has('autocmd'))
    finish
endif

" reset the value of 'cpoptions' for portability
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" main: {{{1
" constants {{{2
" default names of encoding
" Other constant variables s:eucjp and s:jisx are defined in the end of this
" script.
let s:cp932 = ['cp932']
lockvar s:cp932
let s:bom   = ['ucs-bom']
lockvar s:bom
let s:utf   = ['utf-8']
lockvar s:utf

" functions {{{2
" check if iconv supports JIS X 0213
" "iso-2022-jp-3" is the superset of "iso-2022-jp"
" "eucjp-ms" and "euc-jisx0213" are the superset of "euc-jp"
" but "euc-jp" can be specified the 'encoding'
function! s:CheckIconvCapability()
    " use U+3327 "SQUARE TON" and U+3326 "SQUARE DORU"
    let test_ms   = iconv("\xe3\x8c\xa7\xe3\x8c\xa6", 'utf-8', 'eucjp-ms')
    let test_jisx = iconv("\xe3\x8c\xa7\xe3\x8c\xa6", 'utf-8', 'euc-jisx0213')
    let correct = "\xad\xc5\xad\xcb"
    if test_ms ==# correct
        return [['eucjp-ms', 'euc-jp'], ['iso-2022-jp-3']]
    elseif test_jisx ==# correct
        return [['euc-jisx0213', 'euc-jp'], ['iso-2022-jp-3']]
    else
        return [['euc-jp'], ['iso-2022-jp']]
    endif
endfunction

function! s:FileEncodingSet()
    " the order is important
    " test for a while
    return s:jisx + s:eucjp + s:cp932 + s:bom + s:utf
endfunction

function! s:GetOptimalFileEncodings()
    " get the order of fileencodings
    let result = s:FileEncodingSet()

    " remove the one as same as &encoding
    let idx = index(result, &encoding)
    if idx != -1
        call remove(result, idx)
    endif

    " enable guessing the encoding if it's available
    if has('guess_encode')
        call add(result, 'guess')
    endif

    return join(result, ',')
endfunction

" autocmd {{{2
augroup fencja
    autocmd! fencja

    autocmd VIMEnter,EncodingChanged *
        \ let &fileencodings = s:GetOptimalFileEncodings()
augroup END

" execute codes {{{2
" once on ahead
let [s:eucjp, s:jisx] = s:CheckIconvCapability()
lockvar s:eucjp
lockvar s:jisx

" post-processing {{{1
" restore the value of 'cpoptions'
let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" }}}1
" vim: ts=4 sw=4 sts=0 et fdm=marker fdc=3
