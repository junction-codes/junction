# frozen_string_literal: true

module Junction
  # Shared parameter permitting for an entity's tags, labels and links.
  #
  # The three describe the entity rather than configuring anything, which is
  # what separates them from annotations. Tags are free-form and filterable,
  # labels are exact-match pairs for machines, and links point outside Junction.
  module HasMetadata
    extend ActiveSupport::Concern

    private

    # Expected parameters for an entity's metadata.
    #
    # Labels arrive as rows rather than as the labels themselves, because the
    # editor has to let the key be edited as well as the value.
    #
    # @return [Array<Hash>] Expected parameters.
    def metadata_param_entries
      [ { tags: [], label_rows: [ %i[key value] ], links: [ %i[url title icon] ] } ]
    end
  end
end
