require 'open-uri'
require 'json'

class ChampionsController < ApplicationController

  def new
    @message = ""
    if (!params[:message].blank?)
      @message = params[:message]
    end
  end

  def list
    if (params[:summonername].blank?)
      redirect_to action: "new", message: "Please Enter a Summoner Name"
    else
      # /api/lol/{region}/v1.4/summoner/by-name/{summonerNames}
      weights = {"S+" => 100,  "S" => 99,  "S-" => 98,
                 "A+" => 97,  "A" => 96,  "A-" => 95,
                 "B+" => 94,  "B" => 93,  "B-" => 92,
                 "C+" => 91,  "C" => 90, "C-" => 89,
                 "D+" => 88, "D" => 87, "D-" => 86,
                 "F"  => 85, "No Grade" => 0}
      api_key = Rails.application.secrets.rito_api_key
      @summonername = params[:summonername]

      version_uri = "https://na.api.pvp.net/api/lol/static-data/#{params[:region].downcase}/v1.2/realm?api_key=#{api_key}"

      @realm = JSON.parse(open(version_uri).read)
      @version = @realm["v"]
      @cdn_url = @realm["cdn"]

      summoner_uri = "https://na.api.pvp.net/api/lol/#{params[:region]}/v1.4/summoner/by-name/#{params[:summonername]}?api_key=#{api_key}"

      begin
        test = JSON.parse(open(summoner_uri).read)

        player_id = test[params[:summonername].downcase]["id"]
        mastery_uri = "https://na.api.pvp.net/championmastery/location/#{params[:region]}1/player/#{player_id}/champions?api_key=#{api_key}"
        @masteries = JSON.parse(open(mastery_uri).read).map { |row| [row["championId"], row] }.to_h

        champion_uri = "https://global.api.pvp.net/api/lol/static-data/#{params[:region].downcase}/v1.2/champion?api_key=#{api_key}"
        champions = JSON.parse(open(champion_uri).read)
        @display_info = champions["data"]
        @display_info.each {|name, champ| champ["masteries"] = @masteries[champ["id"]]}
        @display_info = @display_info.reject {|name, champ| champ["masteries"] == nil || champ["masteries"]["chestGranted"]}
        @display_info.each {|name, champ| champ["masteries"]["highestGrade"] = "No Grade" unless(champ["masteries"]["highestGrade"] != nil)}
        @display_info.each {|name, champ| champ["masteries"]["gradeWeight"] = weights[champ["masteries"]["highestGrade"]] }
        @display_info = @display_info.sort_by{|name, champ| [champ["masteries"]["gradeWeight"], champ["masteries"]["championLevel"], champ["masteries"]["championPoints"] ]}.reverse
        @top_champion = @display_info.shift
        @display_info = @display_info.first(5)
      rescue OpenURI::HTTPError => e
        redirect_to action: "new", message: "Unable to find any information for that Summoner. Please make sure you have the correct region selected and spelled the Summoner name correctly."
      end
    end
  end
end
