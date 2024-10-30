Period.seed(:id,
            { id: 1, started_on: 2.months.ago, ended_on: 2.months.ago.advance(weeks: 1), user_id: 1 },
            { id: 2, started_on: 1.months.ago, ended_on: 1.months.ago.advance(weeks: 1), user_id: 1 }
)
