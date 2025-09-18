# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  include Chartkick::Helper

  MOVING_AVERAGE_DAYS = 14

  def initialize(records:, display_body_fat:, since_when:, user_id:)
    @display_body_fat = display_body_fat
    @raw_records = records
    @since_when = since_when
    @user_id = user_id
  end

  def records_for_chart
    @records_for_chart ||= build_records_for_chart
  end

  def average_records_for_chart
    @average_records_for_chart ||= build_average_records_for_chart
  end

  def minimum_record
    @minimum_record ||= calculate_extremum(:min)
  end

  def maximum_record
    @maximum_record ||= calculate_extremum(:max)
  end

  private

  # 体脂肪 表示時の出力データ： [{name:'weight', data: {'YY-MM-DD': '60', ..}},{name:'body fat', data: {...}}]
  # 体脂肪 非表示時の出力データ： {'YY-MM-DD': '60', ..}
  def build_records_for_chart
    build_chart_from(@raw_records, weight_accessor: :weight, body_fat_accessor: :body_fat)
  end

  def build_average_records_for_chart
    average_records = Record.find_by_sql(moving_average_sql)
    build_chart_from(average_records, weight_accessor: :average_weight, body_fat_accessor: :average_body_fat)
  end

  # rubocop:disable Metrics/MethodLength
  def moving_average_sql
    # 体重記録は連続した日付にならないこと多々あり
    # → 連続した日付の仮想テーブルcalendarを基準に移動平均値を計算
    sql = <<~SQL.squish
      SELECT
        calendar.recorded_on,
        AVG(r.weight) OVER (
          ORDER BY calendar.recorded_on
          ROWS BETWEEN :window_size PRECEDING AND CURRENT ROW
        ) AS average_weight,
        AVG(r.body_fat) OVER (
          ORDER BY calendar.recorded_on
          ROWS BETWEEN :window_size PRECEDING AND CURRENT ROW
        ) AS average_body_fat
      FROM
        generate_series(
          (SELECT MIN(recorded_on) FROM records WHERE user_id = :user_id),
          CURRENT_DATE,
          '1 day'
        ) AS calendar(recorded_on)
      LEFT JOIN
        records r ON r.recorded_on = calendar.recorded_on AND r.user_id = :user_id
      WHERE
        calendar.recorded_on >= :since_when
    SQL

    # SQLインジェクション対策
    ActiveRecord::Base.sanitize_sql_array([
                                            sql,
                                            { window_size: MOVING_AVERAGE_DAYS - 1,
                                              user_id: @user_id,
                                              since_when: @since_when.to_date }
                                          ])
  end
  # rubocop:enable Metrics/MethodLength

  def build_chart_from(records, weight_accessor:, body_fat_accessor:)
    if @display_body_fat
      weight_list = { name: 'weight (kg)', data: value_hash(records) { |r| r.public_send(weight_accessor) } }
      body_fat_list = { name: 'body fat (%)', data: value_hash(records) { |r| r.public_send(body_fat_accessor) } }
      [weight_list, body_fat_list]
    else
      value_hash(records) { |r| r.public_send(weight_accessor) }
    end
  end

  def value_hash(records)
    records.each_with_object({}) do |record, hash|
      value = yield(record)
      # 平均値算出時に、非記録日にnilが入りグラフの線が切れるのでnilのレコードを排除
      next if value.blank?

      hash[record.recorded_on.to_s] = value
    end
  end

  def calculate_extremum(operation)
    if @display_body_fat
      calculate_multi_series_extremum(operation)
    else
      calculate_single_series_extremum(operation)
    end
  end

  def calculate_multi_series_extremum(operation)
    weight_extremum = records_for_chart.dig(0, :data).values.compact.public_send(operation)
    body_fat_extremum = records_for_chart.dig(1, :data).values.compact.public_send(operation)
    [weight_extremum, body_fat_extremum].compact.public_send(operation).to_i
  end

  def calculate_single_series_extremum(operation)
    records_for_chart.values.compact.public_send(operation).to_i
  end
end
