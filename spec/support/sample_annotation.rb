# frozen_string_literal: true

# A stand-in annotation key for specs exercising the annotations feature.
#
# The engine registers no annotations of its own, so a spec that needs a key
# supplies this one rather than borrowing a real registration. Defined here so
# that every spec using it can run on its own.
SAMPLE_ANNOTATION = "junction.codes/team"
