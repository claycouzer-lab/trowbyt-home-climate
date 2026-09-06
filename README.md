# Couser Home Climate for Tronbyt

This custom Tronbyt app displays four live Home Assistant temperatures together in a 2x2 grid:

- Master Bedroom Govee temperature
- Guest Bedroom Govee temperature
- Office temperature
- Sensi thermostat temperature

The thermostat is in the top-left, Master Bedroom in the top-right, Guest Bedroom in the bottom-left, and Office in the bottom-right. Each tile has an animated pixel icon and shows temperature to one decimal place. All labels are white. Room temperatures are blue at least 1°F below the thermostat setpoint, white from less than 1°F below through less than 2°F above, yellow from 2°F through less than 3°F above, and red at least 3°F above. The thermostat temperature is blue in Cool mode, green in Auto mode, and orange in Heat mode.

## Tronbyt configuration

The app asks for two settings when it is added:

1. **Home Assistant URL** — usually `http://homeassistant.local:8123`
2. **Long-Lived Access Token** — create this at the bottom of the Home Assistant profile page
Never publish or share your Long-Lived Access Token. Enter it only in the app's private configuration screen on your Tronbyt server.

## Repository layout

Keep the files in this structure when uploading them to a GitHub repository:

```text
apps/
  homeclimate/
    home_climate.star
    manifest.yaml
```

Then enter the GitHub repository URL under **Tronbyt → Settings → Content → Custom App Repo**, press **Refresh**, and search for **Couser Home Climate** under **Add App**.
