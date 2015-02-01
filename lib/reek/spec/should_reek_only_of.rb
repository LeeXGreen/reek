require 'reek/examiner'
require 'reek/cli/report/formatter'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell and no others.
    #
    class ShouldReekOnlyOf < ShouldReekOf
      def matches?(actual)
        matches_examiner?(Examiner.new(actual))
      end

      def matches_examiner?(examiner)
        @examiner = examiner
        @warnings = @examiner.smells
        return false unless @warnings.length == 1
        @warning = @warnings[0]
        no_smell_details_given? ? match_without_smell_details? : match_with_smell_details?
      end

      def failure_message
        rpt = Cli::Report::Formatter.format_list(@warnings)
        "Expected #{@examiner.description} to reek only of #{@smell_category}, but got:\n#{rpt}"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek only of #{@smell_category}, but it did"
      end

      private

      def match_without_smell_details?
        @warning.matches?(@smell_category)
      end

      def match_with_smell_details?
        @smell_details_list.map do |smell_detail|
          @warning.matches?(@smell_category, smell_detail)
        end.all?
      end
    end

    #
    # Checks the target source code for instances of +smell_category+,
    # and returns +true+ only if it can find one and only one of them that matches.
    # Additionally you can be more specific and pass in a list of "smell_details" you
    # want to check for as well e.g. "name" or "count" (see the examples below).
    #
    # smell_category - The smell category we check for
    # smells_details_list - An AoH with each hash containing smell_warning parameters
    #
    # Examples
    #
    #   reek_only_of(UncommunicativeParameterName, name: 'x2')
    #   reek_only_of(DataClump, count: 3)
    #
    # Examples from a real spec
    #
    #   expect(src).to reek_only_of(:TooManyStatements,  count: 6)
    #
    def reek_only_of(smell_category, *smell_details_list)
      ShouldReekOnlyOf.new(smell_category, *smell_details_list)
    end
  end
end
