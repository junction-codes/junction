# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Annotated do
  it_behaves_like "an annotated model", :group
  it_behaves_like "an annotated model", :component
  it_behaves_like "an annotated model", :domain
  it_behaves_like "an annotated model", :system
end
