# frozen_string_literal: true

require 'yaml'

# class for calculating the Social Rhytm Metric for use in RAY (Swartz)
class SocialRhythmMetric
  MINIMUM_SAMPLES = 3

  def calculate_srm(data_file)
    # read series from yaml
    series = open(data_file) { |file| YAML.load(file.read) }

    # declare arrays for later use
    number_of_hits = []

    # `series` is a hash; key = activity type; value = array of activity times
    # activity times are strings (e.g. "HH:MM" [24 hour clock])
    series.each do |_activity, activity_times|
      # need count of possible hits
      next unless activity_times.length >= MINIMUM_SAMPLES

      hits = return_hits(activity_times)

      number_of_hits << hits.length
    end

    unless  number_of_hits == []
      srm = sum(number_of_hits).to_f / number_of_hits.length.to_f
    end

    srm || 0
  end

  def return_hits(times)
    series = convert_time_to_seconds(times) # remove when update to EPOCH

    mean_time = mean(series)
    std = standard_deviation(series)

    unless std <= 600.0
      offset = 1.5 * std
      series = remove_outliers(series, mean_time, offset)
    end

    habitual_time = mean(series)
    hit_range = 45.0 * 60.0
    remove_outliers(series, habitual_time, hit_range)
  end

  # this will become obsolete when using EPOCH time
  def convert_time_to_seconds(times)
    times.map do |time|
      hours = time[0..1].to_i * 60 * 60
      minutes = time[3..4].to_i * 60
      time = hours + minutes
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
    sum / (times.length - 1).to_f
  end

  def standard_deviation(times)
    Math.sqrt(sample_variance(times))
  end
end
