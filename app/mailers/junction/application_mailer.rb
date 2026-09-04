# frozen_string_literal: true

module Junction
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    # Engine views live under app/views/junction, so the layout has to be
    # named from the view root rather than as a bare "mailer".
    layout "junction/layouts/mailer"
  end
end
