import json
import os

# Get the path to the .env file in the same directory as the script
env_file_path = os.path.join(os.path.dirname(__file__), '.env')

with open(env_file_path, 'r') as f:
    content = f.readlines()

# Convert to json -> put to Secrets manager
secrets_dict = {}
for line in content:
    if '=' in line:
        key, value = line.strip().split('=', 1)
        secrets_dict[key] = value
print(json.dumps(secrets_dict))

print("========================================================")

# Get list of keys in json
secrets_keys = list(secrets_dict.keys())
print(json.dumps(secrets_keys))