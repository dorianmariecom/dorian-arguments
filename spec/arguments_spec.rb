# frozen_string_literal: true

require "spec_helper"

RSpec.describe "arguments" do
  it "works" do
    expect(`bin/print Hello world`).to eq("Hello\nworld\n")
    expect(`bin/print --inverse=false --reverse false`).to eq("")
    expect(`bin/print --inverse=true --reverse true`).to eq(
      "REVERSE\nINVERSE\n"
    )
  end
end
