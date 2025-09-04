# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  include Chartkick::Helper

  # 体脂肪 表示時の出力データ： [{name:'weight', data: {'YY-MM-DD': '60', ..}},{name:'body fat', data: {...}}]
  # 体脂肪 非表示時の出力データ： {'YY-MM-DD': '60', ..}
  def initialize(records:, display_body_fat:)
    @display_body_fat = display_body_fat
    @records_for_chart = records_for_chart(records)
    @minimum_record = minimum_record
    @maximum_record = maximum_record
  end

  def average_records_for_chart
    calculate_moving_average(@records_for_chart)
  end

  private

  def records_for_chart(records)
    if @display_body_fat
      weight_list = { name: 'weight (kg)', data: value_hash(records, &:weight) }
      body_fat_list = { name: 'body fat (%)', data: value_hash(records, reject_blank: true, &:body_fat) }
      [weight_list, body_fat_list]
    else
      value_hash(records, &:weight)
    end
  end

  def value_hash(records, reject_blank: false)
    pairs = records.map { |r| [r.recorded_on.to_s, yield(r)] }
    pairs.reject! { |_, v| v.blank? } if reject_blank
    pairs.to_h
  end

  def minimum_record
    # 体脂肪 非表示時の出力データ： {'YY-MM-DD': '60', ..}
    @records_for_chart.values.compact.min.to_i unless @display_body_fat

    # 体脂肪 表示時の出力データ： [{name:'weight', data: {'YY-MM-DD': '60', ..}},{name:'body fat', data: {...}}]
    [weight_min, body_fat_min].compact.min.to_i
  end

  def weight_min
    # weightはNOT NULLなのでnilかどうかの確認不要
    @records_for_chart.dig(0, :data).values.compact.min
  end

  def body_fat_min
    body_fat_data = @records_for_chart.dig(1, :data)
    return nil unless body_fat_data

    body_fat_data.values.compact.min
  end

  def maximum_record
    @records_for_chart.values.compact.max.to_i unless @display_body_fat

    @records_for_chart.dig(0, :data).values.compact.max.to_i
  end

  # 2週間の移動平均を計算
  def calculate_moving_average(records)
    if @display_body_fat
      weight_records = records[0][:data]
      weight_average_list = { name: 'weight (kg)', data: average_hash(weight_records) }

      body_fat_records = records[1][:data]
      body_fat_average_list = { name: 'body fat (%)', data: average_hash(body_fat_records) }

      [weight_average_list, body_fat_average_list]
    else
      average_hash(records)
    end
  end

  def average_hash(records)
    sorted_records = records.sort_by { |date, _value| Date.parse(date) }
    moving_average = {}

    sorted_records.each_with_index do |record, index|
      moving_average[record[0]] = calculate_average_for_date(sorted_records, index)
    end

    moving_average
  end

  def calculate_average_for_date(records, index)
    sum = 0
    count = 0
    parsed_date = Date.parse(records[index][0])

    # 14日間以内のデータを対象に移動平均を計算
    records[0..index].reverse_each do |record|
      past_date = Date.parse(record[0])
      break if parsed_date - past_date >= 14

      sum += record[1]
      count += 1
    end

    sum / count
  end
end
