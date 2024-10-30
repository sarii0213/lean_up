User.seed(:id,
          { id: 1, username: 'example01', email: 'example01@example.com', password: 'password', goal_weight: rand(50..53), height: 155 + rand(0..5) },
          { id: 2, username: 'example02', email: 'example02@example.com', password: 'password' }
)
