if vim.o.ft == 'go' then
  vim.cmd('ab gb GoBuild')
  vim.cmd('cab gt GoTest')
  vim.cmd('cab gn GoGenerate')
  vim.cmd('cab gd GoDebug')
  vim.cmd('cab dt GoDebug -t')
  vim.cmd('cab ds GoDebug -s')
  vim.cmd('cab ts GoTestSum')
  vim.cmd('cab tc GoCoverage')
  vim.cmd('cab sc GoTestSubCase')
  vim.cmd('cab tf GoTestFunc')
  vim.cmd('cab at GoAddTest')

  -- vim.cmd('ab gg GoGet')
end
vim.cmd('cab sudo w !sudo tee %')
