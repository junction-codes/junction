# frozen_string_literal: true

# Shared examples for annotations overview controller actions.
#
# @param http_method [Symbol] HTTP verb for the request.
# @param path [Proc, String] Path or proc returning the request path.
# @param permission [String] Permission required to access the action.
RSpec.shared_examples "an annotations overview action" do |http_method, path, permission|
  context "when the user is not authenticated" do
    it_behaves_like "an action that requires authentication",
      http_method, path
  end

  context "when the user is authenticated" do
    requires_authentication

    it_behaves_like "an action that requires permission",
      http_method, path, [ permission ]

    it "renders a successful response" do
      sign_in_user_with_permissions([ permission ])
      send(http_method, path.is_a?(Proc) ? instance_exec(&path) : path)

      expect(response).to be_successful
    end
  end
end

# Asserts the annotations index includes a lazy Turbo Frame.
#
# @param frame_id [String] Expected turbo-frame element id.
# @param src_path [Proc, String] Expected frame src path fragment.
RSpec.shared_examples "an annotations overview lazy frame" do |frame_id, src_path|
  before { sign_in_user_with_permissions(%w[junction.codes/annotations.all.read]) }

  it "includes a lazy turbo-frame for #{frame_id}" do
    get annotations_path
    frame = Nokogiri::HTML(response.body).at_css("turbo-frame##{frame_id}")
    expected_src = src_path.is_a?(Proc) ? instance_exec(&src_path) : src_path

    expect(frame["src"]).to include(expected_src)
  end
end
