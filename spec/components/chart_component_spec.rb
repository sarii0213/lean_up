# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChartComponent, type: :component do
  let(:user) { create(:user) }
  let(:component) { ChartComponent.new(records:) }

  # 値比較時に表記を統一するために 0.6e2 -> 60.0 のように変換
  def format_averages(averages)
    averages.transform_values { |v| v.to_f }
  end

  context '14日連続で記録がある場合' do
    let(:records) {
      (1..15).map do |i|
        date = "2024-01-#{i.to_s.rjust(2, '0')}"
        create(:record, user:, recorded_on: Date.parse(date), weight: 59 + i)
      end
    }
    it "全記録の2週間移動平均値の計算" do
      average_records = component.average_records_for_chart
      formatted_average_records = format_averages(average_records)
      expect(formatted_average_records).to eq({
                                                "2024-01-01" => 60.0,
                                                "2024-01-02" => (60+61)/2.0,
                                                "2024-01-03" => (60+61+62)/3.0,
                                                "2024-01-04" => (60+61+62+63)/4.0,
                                                "2024-01-05" => (60+61+62+63+64)/5.0,
                                                "2024-01-06" => (60+61+62+63+64+65)/6.0,
                                                "2024-01-07" => (60+61+62+63+64+65+66)/7.0,
                                                "2024-01-08" => (60+61+62+63+64+65+66+67)/8.0,
                                                "2024-01-09" => (60+61+62+63+64+65+66+67+68)/9.0,
                                                "2024-01-10" => (60+61+62+63+64+65+66+67+68+69)/10.0,
                                                "2024-01-11" => (60+61+62+63+64+65+66+67+68+69+70)/11.0,
                                                "2024-01-12" => (60+61+62+63+64+65+66+67+68+69+70+71)/12.0,
                                                "2024-01-13" => (60+61+62+63+64+65+66+67+68+69+70+71+72)/13.0,
                                                "2024-01-14" => (60+61+62+63+64+65+66+67+68+69+70+71+72+73)/14.0,
                                                "2024-01-15" => (61+62+63+64+65+66+67+68+69+70+71+72+73+74)/14.0
                                              }
                                           )
    end
  end

  context '1日おきに記録がある場合' do
    let(:records) {
      (1..15).map do |i|
        date = "2024-01-#{(i*2).to_s.rjust(2, '0')}"
        create(:record, user:, recorded_on: Date.parse(date), weight: 59 + i)
      end
    }
    it "全記録の2週間移動平均値の計算" do
      average_records = component.average_records_for_chart
      formatted_average_records = format_averages(average_records)
      expect(formatted_average_records).to eq({
                                                "2024-01-02" => 60.0,
                                                "2024-01-04" => (60+61)/2.0,
                                                "2024-01-06" => (60+61+62)/3.0,
                                                "2024-01-08" => (60+61+62+63)/4.0,
                                                "2024-01-10" => (60+61+62+63+64)/5.0,
                                                "2024-01-12" => (60+61+62+63+64+65)/6.0,
                                                "2024-01-14" => (60+61+62+63+64+65+66)/7.0,
                                                "2024-01-16" => (61+62+63+64+65+66+67)/7.0,
                                                "2024-01-18" => (62+63+64+65+66+67+68)/7.0,
                                                "2024-01-20" => (63+64+65+66+67+68+69)/7.0,
                                                "2024-01-22" => (64+65+66+67+68+69+70)/7.0,
                                                "2024-01-24" => (65+66+67+68+69+70+71)/7.0,
                                                "2024-01-26" => (66+67+68+69+70+71+72)/7.0,
                                                "2024-01-28" => (67+68+69+70+71+72+73)/7.0,
                                                "2024-01-30" => (68+69+70+71+72+73+74)/7.0
                                              }
                                           )
    end
  end
end
