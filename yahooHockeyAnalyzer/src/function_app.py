import azure.functions as func
import logging
import os
import json
import datetime
import requests
import pandas as pd
from yahoo_fantasy_api import game
from yahoo_oauth import OAuth2

app = func.FunctionApp()

# --- CONFIGURATION ---
# Run every Tuesday at 10:00 AM UTC
@app.schedule(schedule="0 0 10 * * 2", arg_name="myTimer", run_on_startup=True, use_monitor=False)
def fantasy_hockey_analyzer(myTimer: func.TimerRequest) -> None:
    logging.info('🏒 Starting Real Fantasy Hockey Analysis...')

    # 1. AUTHENTICATE WITH YAHOO
    try:
        # Get the full JSON blob we saved in Azure (contains keys + tokens)
        token_string = os.environ.get("YAHOO_TOKEN_JSON")
        if not token_string:
            logging.error("❌ Missing Environment Variable: YAHOO_TOKEN_JSON")
            return

        # Write to a temp file because the library requires a file path
        temp_file_path = "/tmp/oauth.json"
        with open(temp_file_path, "w") as f:
            f.write(token_string)
        
        # Initialize OAuth using that temp file
        sc = OAuth2(None, None, from_file=temp_file_path)
        
        # Connect to NHL and League
        gm = game.Game(sc, 'nhl')
        league_id = os.environ.get("YAHOO_LEAGUE_ID")
        lg = gm.to_league(league_id)
        logging.info(f"✅ Successfully Connected to League ID: {league_id}")

    except Exception as e:
        logging.error(f"❌ Authentication Failed: {e}")
        return

    # 2. GET REAL NHL SCHEDULE
    logging.info("📅 Fetching NHL Schedule...")
    try:
        team_game_counts = get_nhl_schedule_next_week()
        logging.info(f"   Schedule fetched for {len(team_game_counts)} teams.")
    except Exception as e:
        logging.error(f"❌ Schedule Fetch Failed: {e}")
        team_game_counts = {}

    # 3. SCAN WAIVER WIRE (Example: Top 10 Centers)
    logging.info("🔍 Scanning Waiver Wire...")
    try:
        free_agents = lg.free_agents('C')[:10]
        recommendations = []
        
        for player in free_agents:
            name = player['name']
            team = player['editorial_team_abbr'].upper()
            games = team_game_counts.get(team, 0)
            
            # Simple Logic: Only recommend if they play 3+ games
            if games >= 3:
                recommendations.append(f"{name} ({team}) - {games} Games")
        
        # 4. OUTPUT RESULTS
        if recommendations:
            logging.info("\n🏆 --- RECOMMENDED PICKUPS ---")
            for rec in recommendations:
                logging.info(rec)
        else:
            logging.info("No 3-game players found in the top 10 free agents.")
            
    except Exception as e:
        logging.error(f"❌ Player Analysis Failed: {e}")


# --- HELPER FUNCTIONS ---
def get_nhl_schedule_next_week():
    today = datetime.date.today()
    next_week = today + datetime.timedelta(days=7)
    url = f"https://api-web.nhle.com/v1/schedule/{today}"
    
    try:
        resp = requests.get(url).json()
        team_counts = {}
        for game_week in resp.get('gameWeek', []):
            for game in game_week.get('games', []):
                game_date = datetime.datetime.strptime(game['startTimeUTC'][:10], "%Y-%m-%d").date()
                if today <= game_date <= next_week:
                    home = game['homeTeam']['abbrev']
                    away = game['awayTeam']['abbrev']
                    team_counts[home] = team_counts.get(home, 0) + 1
                    team_counts[away] = team_counts.get(away, 0) + 1
        return team_counts
    except Exception as e:
        logging.warning(f"Error parsing NHL schedule: {e}")
        return {}