# frozen_string_literal: true

# The `Views::Base` is an abstract class for all your views.
class Views::Base < Components::Base
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::FormWith
end
