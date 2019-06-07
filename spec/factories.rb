FactoryBot.define do
  factory :clue do
    text { 'text' }
    answer { 'answer' }
    category { 'category' }
    value { 500 }
    code { 'code' }
    tweeted { false }
    status_id { 'status_id' }
  end
end
