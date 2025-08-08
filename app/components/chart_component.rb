# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  def initialize(records:)
    @records_for_chart = records.each_with_object({}) do |record, hash|
      hash[record.recorded_on.to_s] = record.weight
    end
    @minimum_record = @records_for_chart.min_by { |a| a[1] }[1].to_i
  end

  def average_records_for_chart
    calculate_moving_average(@records_for_chart)
  end

  private

  # 2週間の移動平均を計算
  # { '2021-01-01' => 60, '2021-01-02' => 61, ... }
  def calculate_moving_average(records)
    sorted_records = records.sort_by { |date, _value| Date.parse(date) }
    moving_average = {}

    sorted_records.each_with_index do |record, index|
      moving_average[record[0]] = calculate_average_for_date(sorted_records, index)
    end

    moving_average
  end

  def calculate_average_for_date(records, index)
    weight_sum = 0
    count = 0
    parsed_date = Date.parse(records[index][0])

    # 14日間以内のデータを対象に移動平均を計算
    records[0..index].reverse_each do |record|
      past_date = Date.parse(record[0])
      break if parsed_date - past_date >= 14

      weight_sum += record[1]
      count += 1
    end

    weight_sum / count
  end
end
