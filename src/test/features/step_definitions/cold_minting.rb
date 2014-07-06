
When(/^node "(.*?)" generates a new cold minting address "(.*?)" with the minting key "(.*?)" and the spending key "(.*?)"$/) do |arg1, arg2, arg3, arg4|
  node = @nodes[arg1]
  cold_minting_address_name = arg2
  minting_address = @addresses[arg3]
  spending_address = @addresses[arg4]

  @addresses[cold_minting_address_name] = node.rpc("addcoldmintingaddress", minting_address, spending_address)
end

When(/^all nodes reach (\d+) transaction in memory pool$/) do |arg1|
  wait_for do
    expect(@nodes.values.map { |node| node.rpc("getmininginfo")["pooledtx"] }).to eq(Array.new(@nodes.size, arg1.to_i))
  end
end

Then(/^node "(.*?)" should have a minting only balance of "([^"]*?)"$/) do |arg1, arg2|
  expect(@nodes[arg1].info["mintingonly"]).to eq(parse_number(arg2))
end

When(/^node "(.*?)" finds block until just received coins are able to mint$/) do |arg1|
  node = @nodes[arg1]
  min_age = 60 * 60 * 24
  blocks = 5
  time_between_blocks = min_age / blocks
  blocks.times do
    time_travel(time_between_blocks)
    node.rpc("generatestake")
  end
  max_age = 60 * 60 * 24 * 90
  time_travel(max_age - min_age)
  node.rpc("generatestake")
  step 'all nodes reach the same height'
end

Then(/^node "(.*?)" should be able to find a block "(.*?)"$/) do |arg1, arg2|
  step "node \"#{arg1}\" finds a block \"#{arg2}\""
end

Then(/^node "(.*?)" should not be able to find a block "(.*?)"$/) do |arg1, arg2|
  node = @nodes[arg1]
  expect(node.rpc("generatestake", DEFAULT_TIMEOUT / 2)).to eq("0000000000000000000000000000000000000000000000000000000000000000")
end

Then(/^node "(.*?)" should have a stake of "([^"]*?)"$/) do |arg1, arg2|
  wait_for do
    expect(@nodes[arg1].info["stake"]).to eq(parse_number(arg2))
  end
end

Then(/^node "(.*?)" should have a stake of "(.*?)" \+ the reward on block "(.*?)"$/) do |arg1, arg2, arg3|
  node = @nodes[arg1]
  expected_stake = parse_number(arg2)
  block = @blocks[arg3]

  block_info = node.rpc("getblock", block)
  reward = block_info["mint"]
  expected_stake += reward
  expect(node.info["stake"]).to eq(expected_stake)
end

When(/^node "(.*?)" finds enough block for a Proof of Stake block to mature$/) do |arg1|
  node = @nodes[arg1]
  (5 + 1).times do
    time_travel 30 * 60
    node.generate_stake
  end
end

When(/^node "(.*?)" should have a minting only balance of "(.*?)" \+ the reward on block "(.*?)"$/) do |arg1, arg2, arg3|
  node = @nodes[arg1]
  expected_mintingonly = parse_number(arg2)
  block = @blocks[arg3]

  block_info = node.rpc("getblock", block)
  reward = block_info["mint"]
  expected_mintingonly += reward
  expect(node.info["mintingonly"]).to eq(expected_mintingonly)
end

When(/^node "(.*?)" dumps the private key of "(.*?)"$/) do |arg1, arg2|
  node = @nodes[arg1]
  address_name = arg2

  @private_keys ||= {}
  @private_keys[address_name] = node.rpc("dumpprivkey", @addresses[address_name])
end

When(/^node "(.*?)" imports the private key of "(.*?)"$/) do |arg1, arg2|
  node = @nodes[arg1]
  address_name = arg2

  node.rpc("importprivkey", @private_keys[address_name])
end

Then(/^node "(.*?)" should have a balance of "(.*?)" \+ the reward on block "(.*?)"$/) do |arg1, arg2, arg3|
  node = @nodes[arg1]
  expected_balance = parse_number(arg2)
  block = @blocks[arg3]

  block_info = node.rpc("getblock", block)
  reward = block_info["mint"]
  expected_balance += reward
  expect(node.info["balance"]).to eq(expected_balance)
end

