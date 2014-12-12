# Jeopardy! Bot #

A robot which tweets Jeopardy Answers every hour. Live [here](https://twitter.com/Jeopardy_Bot)

## 209 Game Summary ##
Date: 12/12/2014

Number Of Games
```ruby
BotData.where.not(:winner => nil).count
=> 209
```

Winner Breakdown
```ruby
winners = Hash.new(0)
BotData.where.not(:winner => nil).each {|game| winners[game.winner] += 1};nil

winners.sort_by{|k, v| v}.reverse.each do |winner_name, games_won|
  puts "Contestant: #{winner_name} - Games Won: #{games_won}"
end
Contestant: frostillicus2 - Games Won: 69
Contestant: Pseudo_Watson - Games Won: 60
Contestant: rob0515 - Games Won: 27
Contestant: bloodlesscoup - Games Won: 8
Contestant: _Pseudo_Watson_ - Games Won: 8
Contestant: dannibean13 - Games Won: 5
Contestant: TheHudlReferee - Games Won: 3
Contestant: umamijones - Games Won: 3
Contestant: UncleTrilly - Games Won: 3
Contestant: tygorz - Games Won: 2
Contestant: RyanJPODonnell - Games Won: 2
Contestant: samuelgilleran - Games Won: 2
Contestant: southsidehitman - Games Won: 2
Contestant: dr_graz - Games Won: 2
Contestant: RainPotatoes - Games Won: 2
Contestant: cyan_sunshine - Games Won: 1
Contestant: EddieTimanus - Games Won: 1
Contestant: 4our3hree - Games Won: 1
Contestant: CoolVidsFTW - Games Won: 1
Contestant: Kryten2X4B1 - Games Won: 1
Contestant: timryansays - Games Won: 1
Contestant: AMFrei - Games Won: 1
Contestant: NIU_SID_Matt - Games Won: 1
Contestant: el_rucko - Games Won: 1
Contestant: Dorktacular - Games Won: 1
Contestant: vamosdavid - Games Won: 1
```
