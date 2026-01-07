from expo import CiscoExpoApi  # make sure expo.py is present in the same folder

api = CiscoExpoApi()

# Access the eXpo
expo = api.get_expo("3v1qrg682fecfx9cu21uak47d")
print(f"Expo Name: {expo.name}")
if api.choose_datacenter():
    # Create an engagement (replace with your email and demo UID)
    engagement = api.create_engagement()
else:
  print("Data center not selected, quiting")
  quit()
if engagement:
    print(f"Engagement UID: {engagement.uid}")
    # Set lab environment
    api.set_env(engagement.uid)
