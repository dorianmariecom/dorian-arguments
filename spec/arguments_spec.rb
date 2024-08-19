# frozen_string_literal: true

require "spec_helper"

RSpec.describe "arguments" do
  it "works" do
    expect(`bin/print Hello world`).to eq("Hello\nworld\n")
    expect(`bin/print --inverse=false --reverse=0`).to eq("")
    expect(`bin/print --inverse=true --reverse=1`).to eq("REVERSE\nINVERSE\n")
  end
end
