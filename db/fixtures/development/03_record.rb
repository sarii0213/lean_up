360.times do |n|
  Record.seed(:id,
              { id: n + 1,
                user_id: 1,
                recorded_on: 1.year.ago + n.days,
                weight: rand(50.0..60.0),
                body_fat: rand(20.0..30.0) }
  )
end
