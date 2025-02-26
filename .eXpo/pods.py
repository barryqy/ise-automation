from expo import CiscoExpoApi  # make sure expo.py is present in the same folder

api = CiscoExpoApi()

# Access the eXpo
expo = api.get_expo("aa2luz73bvbj3mg0lk3zoklzq")
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
