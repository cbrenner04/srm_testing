# frozen_string_literal: true

require 'time'
require 'yaml'

# class for calculating the Social Rhytm Metric for use in RAY (Swartz)
class SocialRhythmMetric
  MINIMUM_SAMPLES = 3

  def calculate_srm
    # comment if testing paper values
    # read series from yaml
    series = open('/Users/Chris/Work/srm_testing/srm_data_215836_8.12.yml') do |file|
      YAML.load(file.read)
    end

    # declare arrays for later use
    number_of_hits = []

    # `series` is a hash; key = activity type; value = array of activity times
    series.each do |_activity, activity_times|
    # end of non-paper test comment block

      # # uncomment if testing paper values
      # activity_times = ["06:00", "05:50", "08:01", "07:55", "05:45", "05:50", "05:50"]
      # number_of_hits = [4, 1, 2, 7]
      # # end of paper test comment block
      puts "ACTIVITY TIMES: #{activity_times}"
      # need count of possible hits
      next unless activity_times.length >= MINIMUM_SAMPLES # comment if testing paper values

      hits = return_hits(activity_times)
      puts "HITS: #{hits.map { |h| convert_to_human_readable(h) }} = #{hits.length}\n\n"

      number_of_hits << hits.length
    end # comment if testing paper values

    puts "NUMBER OF HITS: #{number_of_hits}"
    srm = sum(number_of_hits).to_f / number_of_hits.length.to_f
    puts "SRM: #{sum(number_of_hits).to_f} / #{number_of_hits.length.to_f} = #{srm}"
    srm
  end

  def return_hits(times)
    series = convert_time_to_seconds(times)

    mean_time = mean(series)
    puts "MEAN TIME: #{convert_to_human_readable(mean_time)}"
    std = standard_deviation(series)
    puts "STD: #{std / 60.0}"

    unless std <= 0.5
      offset = 1.5 * std
      puts "OFFSET: #{offset / 60.0}"
      series = remove_outliers(series, mean_time, offset)
    end

    habitual_time = mean(series)
    puts "HABITUAL TIME: #{convert_to_human_readable(habitual_time)}"
    hit_range = 45.0 * 60.0
    remove_outliers(series, habitual_time, hit_range)
  end

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
    puts "UPPER LIMIT: #{convert_to_human_readable(upper_limit)}; " \
         "LOWER LIMIT: #{convert_to_human_readable(lower_limit)}"

    new_times = []
    times.each do |time|
      next unless (time >= lower_limit) && (time <= upper_limit)
      new_times << time
    end

    puts "NEW TIMES: #{new_times.map { |n| convert_to_human_readable(n) }}"
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

  # these are just for testing
  def convert_to_human_readable(time)
    minutes = (time / 60) % 60
    hours = time / (60 * 60)

    format('%02d:%02d', hours, minutes)
  end
end

SocialRhythmMetric.new.calculate_srm
