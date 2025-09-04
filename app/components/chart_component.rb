# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  include Chartkick::Helper

  # 体脂肪 表示時の出力データ： [{name:'weight', data: {'YY-MM-DD': '60', ..}},{name:'body fat', data: {...}}]
  # 体脂肪 非表示時の出力データ： {'YY-MM-DD': '60', ..}
  def initialize(records:, display_body_fat:)
    @display_body_fat = display_body_fat
    @records_for_chart =
      if @display_body_fat
        weight_hash =
          records.each_with_object({}) do |record, hash|
            hash[record.recorded_on.to_s] = record.weight
          end
        weight_list = { name: 'weight (kg)', data: weight_hash }

        # 体重記録ｱﾘ 体脂肪率記録ﾅｼ のケースも考慮
        body_fat_hash =
          records.each_with_object({}) do |record, hash|
            # binding.b
            next unless record.body_fat.present?
            hash[record.recorded_on.to_s] = record.body_fat
          end
        body_fat_list = { name: 'body fat (%)', data: body_fat_hash }
        [weight_list, body_fat_list]
      else
        records.each_with_object({}) do |record, hash|
          hash[record.recorded_on.to_s] = record.weight
        end
      end
    # グラフの最小値は体脂肪率表示する場合は体脂肪率の最小値, 非表示の場合は体重の最小値
    @minimum_record =
      if @display_body_fat
        body_fat_data = @records_for_chart[1][:data]
        if body_fat_data.all? { |item| item[1].nil? }
          weight_data = @records_for_chart[0][:data]
          weight_data.min_by { |a| a[1] }[1].to_i
        else
          body_fat_data.min_by { |a| a[1] }[1].to_i
        end
      else
        @records_for_chart.min_by { |a| a[1] }[1].to_i
      end
    @maximum_record =
      if @display_body_fat
        weight_data = @records_for_chart[0][:data]
        weight_data.max_by { |a| a[1] }[1].to_i
      else
        @records_for_chart.max_by { |a| a[1].to_i }[1].to_i
      end
  end

  def average_records_for_chart
    calculate_moving_average(@records_for_chart)
  end

  private

  # 2週間の移動平均を計算
  def calculate_moving_average(records)
    if @display_body_fat
      # records = [{name:,data:{'date'=>num,..}},{name:,data:{'date'=>num,..}}]
      sorted_weights = records[0][:data].sort_by { |date, _value| Date.parse(date) }
      weight_averages = {}
      sorted_weights.each_with_index do |record, index|
        weight_averages[record[0]] = calculate_average_for_date(sorted_weights, index)
      end
      weight_average_list = { name: 'weight (kg)', data: weight_averages }

      sorted_body_fats = records[1][:data].sort_by { |date, _value| Date.parse(date) }
      body_fat_averages = {}
      sorted_body_fats.each_with_index do |record, index|
        next unless record.present?
        body_fat_averages[record[0]] = calculate_average_for_date(sorted_body_fats, index)
      end
      body_fat_average_list = { name: 'body fat (%)', data: body_fat_averages }

      [weight_average_list, body_fat_average_list]
    else
      sorted_records = records.sort_by { |date, _value| Date.parse(date) }
      moving_average = {}

      sorted_records.each_with_index do |record, index|
        moving_average[record[0]] = calculate_average_for_date(sorted_records, index)
      end

      moving_average
    end
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
