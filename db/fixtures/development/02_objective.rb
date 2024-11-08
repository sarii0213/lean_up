Objective.seed(:id,
               { id: 1, objective_type: 1, verbal: '服の買い物がぐっと楽しくなる', comment: '', user_id: 1, order: 0 },
               { id: 2, objective_type: 0, verbal: '', comment: '秋になったらゲットする', user_id: 1, order: 1 },
               { id: 3, objective_type: 1, verbal: '脂肪の下に隠れた美しい筋肉', comment: '', user_id: 1, order: 2 }
)
Objective.find(2).images.attach( io: File.open(Rails.root.join('db/images/lilith_black.png')), filename: 'lilith_black.png' )

