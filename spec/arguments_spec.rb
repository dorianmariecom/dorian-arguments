# frozen_string_literal: true

require "spec_helper"

RSpec.describe "arguments" do
  it "works" do
    expect(`bin/print Hello world`).to eq("Hello\nworld\n")
  end
end
