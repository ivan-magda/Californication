## Set up your own Firebase Database

To create your own database please follow this steps:

- Go to the [Firebase console](https://console.firebase.google.com/)
- Press `Create new project` and follow the instructions
- Now you should see your newly created project. Press `Database` on the left panel
- Press `Options` button and select `Import from JSON file` option
- Select `californication-database.json` file from the `Database` directory
- Press `Overview` on the left panel and then `Add Firebase to your iOS app`
- Follow instructions (You only need to replace GoogleService-Info.plist with your own)
- Set the `Database Rules` as follows:
```
{
  "rules": {
    ".read": "true",
    ".write": "auth != null"
  }
}
```
- Change the `URL Schemes`:
  - Select the Californication target
  - Info tab and expand URL Types
  - Change the first one with your bundle identifier
  - Change the second one with `REVERSED_CLIENT_ID` from the `GoogleService-Info.plist` file
