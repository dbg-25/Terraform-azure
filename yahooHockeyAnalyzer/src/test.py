from yahoo_oauth import OAuth2
import json

# 1. Define your credentials in a dictionary
creds = {
    "consumer_key": "dj0yJmk9ZDFOYmNNdE82TmlqJmQ9WVdrOWRHMTNUV051VnpZbWNHbzlNQT09JnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PWU4",  # This is the key you sent
    "consumer_secret": "c19439ce3bff650fc5a5a09fc94115a1c028e7f4"                   # <--- YOU MUST PASTE THE SECRET HERE
}

# 2. Save them to a file so the library can find them
with open('oauth2.json', "w") as f:
    json.dump(creds, f)

# 3. Start the authentication
# This will open your web browser. Click "Allow" or "Agree".
oauth = OAuth2(None, None, from_file='oauth2.json')

print("✅ Success! Open 'oauth2.json' and copy the token inside.")

