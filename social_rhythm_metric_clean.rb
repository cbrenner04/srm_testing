# frozen_string_literal: true

require 'time'
require 'yaml'

# class for calculating the Social Rhytm Metric for use in RAY (Swartz)
class SocialRhythmMetric
  MINIMUM_SAMPLES = 3

  def calculate_srm
    # read series from yaml
    series = open('/Users/Chris/Work/srm_data.yml') do |file|
      YAML.load(file.read)
    end

    # declare arrays for later use
    number_of_hits = []
    total_activities_counted = 0

    # `series` is a hash; key = activity type; value = array of activity times
    series.each do |_activity, activity_times|
      # need count of possible hits
      next unless activity_times.length >= MINIMUM_SAMPLES

      total_activities_counted += 1

      hits = return_hits(activity_times)

      number_of_hits << hits.length
    end

    srm = sum(number_of_hits).to_f / total_activities_counted.to_f
    puts "SRM: #{sum(number_of_hits).to_f} / #{total_activities_counted.to_f} = #{srm}"
    srm
  end

  def return_hits(times)
    times_in_seconds = convert_time_to_seconds(times)

    mean_time = mean(times_in_seconds)
    std = standard_deviation(times_in_seconds)
    offset = 1.5 * std
    series = remove_outliers(times_in_seconds, mean_time, offset)

    habitual_time = mean(series)
    hit_range = 45.0 * 60.0
    remove_outliers(series, habitual_time, hit_range)
  end

  def convert_time_to_seconds(times)
    times.map do |time|
      midnight = Time.parse('00:00')
      time = Time.parse(time)
      time -= midnight
      time
    end
  end

  def remove_outliers(times, mean, offset)
    lower_limit = mean - offset
    upper_limit = mean + offset

    new_times = []
    times.each do |time|
      next unless (time >= lower_limit) && (time <= upper_limit)
      new_times << time
    end

    new_times
  end

  # stolen from http://stackoverflow.com/questions/7749568/how-can-i-do-standard-deviation-in-ruby
  def sum(times)
    times.inject(0) { |a, e| a + e }
  end

  def mean(times)
    sum(times) / times.length.to_f
  end

  def sample_variance(times)
    m = mean(times)
    sum = times.inject(0) { |a, e| a + (e - m)**2 }
    sum / times.length.to_f
  end

  def standard_deviation(times)
    Math.sqrt(sample_variance(times))
  end
end

SocialRhythmMetric.new.calculate_srm
