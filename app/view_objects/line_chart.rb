class LineChart

  attr_accessor :records_for_chart, :minimum_record

  def initialize(records)
    self.records_for_chart = records.each_with_object({}) do |record, hash|
      hash[record.recorded_on.to_s] = record.weight
    end
    self.minimum_record = (self.records_for_chart.min { |x, y| x[1] <=> y[1] }[1]).to_i
  end

  def average_records_for_chart
    calculate_moving_average(self.records_for_chart)
  end

  private

  # 2週間の移動平均を計算
  def calculate_moving_average(records, window_size = 14)
    sorted_records = records.sort_by { |date, _value| Date.parse(date)}
    moving_average = {}
    sorted_records.each_cons(window_size).with_index do |window, index|
      date, _ = sorted_records[index + window_size - 1]
      avg = window.map { |_, value| value }.sum / window_size
      moving_average[date] = avg
    end

    moving_average
  end
end
