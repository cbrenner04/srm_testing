# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/srm/social_rhythm_metric.rb'

RSpec.describe 'Social Rhythm Metric', type: :feature do
  let(:srm) { SocialRhythmMetric.new }

  it 'reports correct srm scores' do
    base_folder = '/Users/Chris/Work/srm_testing/lib/data/'
    participants = %w(215836 215836 216973 216973 217844 218266 218266)
    dates = %w(8.12 8.19 10.3 10.10 5.2 8.14 8.21)
    results = [2.2, 3.6, 1.4, 4.2, 3.2, 3.8, 2.8]

    participants.zip(dates, results) do |participant, date, result|
      expect(
        srm.calculate_srm("#{base_folder}srm_data_#{participant}_#{date}.yml")
      ).to eq result
    end
  end
end
