require 'open-uri'
require 'json'

class ChampionsController < ApplicationController

  def new

  end

  def list
    # /api/lol/{region}/v1.4/summoner/by-name/{summonerNames}
    api_key = Rails.application.secrets.rito_api_key
    summoner_uri = "https://na.api.pvp.net/api/lol/#{params[:region]}/v1.4/summoner/by-name/#{params[:summonername]}?api_key=#{api_key}"
    test = JSON.parse(open(summoner_uri).read)
    player_id = test[params[:summonername].downcase]["id"]
    mastery_uri = "https://na.api.pvp.net/championmastery/location/#{params[:region]}1/player/#{player_id}/champions?api_key=#{api_key}"
    @masteries = JSON.parse(open(mastery_uri).read).map { |row| [row["championId"], row] }.to_h

    champion_uri = "https://global.api.pvp.net/api/lol/static-data/#{params[:region].downcase}/v1.2/champion?api_key=#{api_key}"
    champions = JSON.parse(open(champion_uri).read)

    @display_info = champions["data"]
  end
end
