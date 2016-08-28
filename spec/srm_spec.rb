# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/srm/social_rhythm_metric.rb'

RSpec.describe 'Social Rhythm Metric' do
  BASE_FOLDER = File.join(File.dirname(__FILE__), '../lib/data/')

  let(:srm) { SocialRhythmMetric.new }

  it 'reports correct srm scores' do
    participants = %w(215836 215836 216973 216973 217844 218266 218266)
    dates = %w(8.12 8.19 10.3 10.10 5.2 8.14 8.21)
    results = [2.2, 3.6, 1.4, 4.2, 3.2, 3.8, 2.8]

    participants.zip(dates, results) do |participant, date, result|
      expect(
        srm.calculate_srm("#{BASE_FOLDER}srm_data_#{participant}_#{date}.yml")
      ).to eq result
    end
  end

  it 'does not report scores if there are less than minimum samples' do
    expect(
      srm.calculate_srm("#{BASE_FOLDER}/srm_data_fake_min.yml")
    ).to eq 0
  end

  it 'returns the correct hits' do
    times = ['06:00', '05:50', '08:01', '07:55', '05:45', '05:50', '05:50']
    results = [21_600, 21_000, 20_700, 21_000, 21_000]

    expect(srm.return_hits(times)).to eq results
  end

  it 'converts times to seconds' do
    times = ['00:00', '06:12', '12:00', '18:43', '24:00']
    results = [0, 22_320, 43_200, 67_380, 86_400]

    expect(srm.convert_time_to_seconds(times)).to eq results
  end

  it 'removes the correct outliers' do
    series = [100, 150, 200, 250, 300]
    mean = 200
    offset = 50
    results = [150, 200, 250]

    expect(srm.remove_outliers(series, mean, offset)).to eq results
  end

  it 'returns the sum' do
    values = [1, 2, 3, 4, 5]

    expect(srm.sum(values)).to eq 15
  end

  it 'retuns the mean' do
    values = [1, 2, 3, 4, 5]

    expect(srm.mean(values)).to eq 3
  end

  it 'returns the sample variance' do
    values = [1, 2, 3, 4, 5]

    expect(srm.sample_variance(values)).to eq 2.5
  end

  it 'returns the standard deviation' do
    values = [1, 2, 3, 4, 5]

    expect(srm.standard_deviation(values).round(3)).to eq 1.581
  end
end
