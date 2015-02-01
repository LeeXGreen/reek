require 'reek/examiner'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell.
    #
    class ShouldReekOf
      def initialize(smell_category, *smell_details_list)
        @smell_category     = normalize smell_category
        @smell_details_list = smell_details_list
      end

      def matches?(actual)
        @examiner = Examiner.new(actual)
        @all_smells = @examiner.smells
        no_smell_details_given? ? match_without_smell_details? : match_with_smell_details?
      end

      def failure_message
        "Expected #{@examiner.description} to reek of #{@smell_category}, but it didn't"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek of #{@smell_category}, but it did"
      end

      private

      def no_smell_details_given?
        @smell_details_list.empty?
      end

      def match_without_smell_details?
        @all_smells.any? { |warning| warning.matches?(@smell_category) }
      end

      def match_with_smell_details?
        @smell_details_list.map do |smell_detail|
          @all_smells.any? { |warning| warning.matches?(@smell_category, smell_detail) }
        end.all?
      end

      def normalize(smell_category_or_type)
        # In theory, users can give us many different types of input:
        #   - :UtilityFunction
        #   - "UtilityFunction"
        #   - UtilityFunction (this works in our specs because we tend to do "include Reek:Smells")
        #   - Reek::Smells::UtilityFunction
        #   - "Duplication" or :Duplication which is a category that is not expressed as a class

        # We're basically ignoring all of those subleties and just return a string with
        # the prepending namespace stripped.
        smell_category_or_type.to_s.split(/::/)[-1]
      end
    end

    #
    # Checks the target source code for instances of +smell_category+,
    # and returns +true+ only if it can find one of them that matches.
    # Additionally you can be more specific and pass in a list of "smell_details" you
    # want to check for as well e.g. "name" or "count" (see the examples below).
    #
    # smell_category - The smell category we check for
    # smells_details_list - An AoH with each hash containing smell_warning parameters
    #
    # Examples
    #
    #   reek_of(UncommunicativeParameterName, name: 'x2')
    #   reek_of(DataClump, count: 3)
    #
    # Examples from a real spec
    #
    #   expect(src).to reek_of(DuplicateMethodCall, name: '@other.thing')
    #
    def reek_of(smell_category, *smell_details_list)
      ShouldReekOf.new(smell_category, *smell_details_list)
    end
  end
end
