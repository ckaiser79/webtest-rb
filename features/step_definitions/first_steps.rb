require 'pry'

class LongVegetable

  attr_reader :length

  def initialize length
    @length = length
  end

  def cut length

    l = @length - length
    @length = @length - l

    LongVegetable.new l
  end

end

#encoding: utf-8
Given /^a cucumber that is (\d+) cm long$/ do |length|
  @cucumber1 = LongVegetable.new length.to_i
end

When /^I cut it in halves$/ do
  @cucumber2 = @cucumber1.cut @cucumber1.length/2
end

Then /^I have two cucumbers$/ do
  expect(@cucumber2).not_to be nil
  expect(@cucumber1).not_to be nil
end

Then /^both are (\d+) cm long$/ do |length|
  expect(@cucumber1.length).to eq length.to_i
  expect(@cucumber2.length).to eq length.to_i
end