# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an action that requires authentication' do |http_method, path, params = {}|
  context 'when not authenticated' do
    it 'redirects to the new session path' do
      send(http_method, path.is_a?(Proc) ? instance_exec(&path) : path, params: params)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
