local function fetch_and_paste_url_title()
    -- Get content of the unnamed register
    local url = vim.fn.getreg('*')

    -- Check if the content is likely a URL
    if not url:match('^https?://') then
        print('Register does not contain a valid URL')
        return
    end

    -- Use curl to fetch the webpage content. Adjust timeout as necessary.
    local cmd = string.format('curl -m 5 -s %s', vim.fn.shellescape(url))
    local result = vim.fn.system(cmd)

    -- Extract the title of the webpage
    local title = result:match('<title>(.-)</title>')
    if not title or title == '' then
      title = ""
    end

    -- Format and paste the Markdown link
    local markdown_link = string.format('[%s](%s)', title, url)
    vim.api.nvim_put({markdown_link}, 'l', true, true)
end
return {
  fetch_and_paste_url_title = fetch_and_paste_url_title
}
