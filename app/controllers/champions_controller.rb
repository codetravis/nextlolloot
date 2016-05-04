require 'open-uri'
require 'json'

class ChampionsController < ApplicationController

  def new

  end

  def list
    # /api/lol/{region}/v1.4/summoner/by-name/{summonerNames}
    weights = {"S+" => 0,  "S" => 1,  "S-" => 2,
               "A+" => 3,  "A" => 4,  "A-" => 5,
               "B+" => 6,  "B" => 7,  "B-" => 8,
               "C+" => 9,  "C" => 10, "C-" => 11,
               "D+" => 12, "D" => 13, "D-" => 14,
               "F"  => 20, "No Grade" => 100}
    api_key = Rails.application.secrets.rito_api_key

    version_uri = "https://na.api.pvp.net/api/lol/static-data/#{params[:region].downcase}/v1.2/realm?api_key=#{api_key}"

    @realm = JSON.parse(open(version_uri).read)
    @version = @realm["v"]
    @cdn_url = @realm["cdn"]

    summoner_uri = "https://na.api.pvp.net/api/lol/#{params[:region]}/v1.4/summoner/by-name/#{params[:summonername]}?api_key=#{api_key}"
    test = JSON.parse(open(summoner_uri).read)
    player_id = test[params[:summonername].downcase]["id"]
    mastery_uri = "https://na.api.pvp.net/championmastery/location/#{params[:region]}1/player/#{player_id}/champions?api_key=#{api_key}"
    @masteries = JSON.parse(open(mastery_uri).read).map { |row| [row["championId"], row] }.to_h

    champion_uri = "https://global.api.pvp.net/api/lol/static-data/#{params[:region].downcase}/v1.2/champion?api_key=#{api_key}"
    champions = JSON.parse(open(champion_uri).read)
    @display_info = champions["data"]
    @display_info.each {|name, champ| champ["masteries"] = @masteries[champ["id"]]}
    @display_info = @display_info.reject {|name, champ| champ["masteries"] == nil}
    @display_info.each {|name, champ| champ["masteries"]["highestGrade"] = "No Grade" unless(champ["masteries"]["highestGrade"] != nil)}
    @display_info.each {|name, champ| champ["masteries"]["gradeWeight"] = weights[champ["masteries"]["highestGrade"]] }
    @display_info = @display_info.sort_by{|name, champ| champ["masteries"]["gradeWeight"] }
  end
end
