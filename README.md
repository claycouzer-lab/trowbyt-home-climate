# Couser Home Climate for Tronbyt

This custom Tronbyt app displays four live Home Assistant temperatures together in a 2x2 grid:

- Master Bedroom Govee temperature
- Guest Bedroom Govee temperature
- Office temperature
- Sensi thermostat temperature

The thermostat is in the top-left, Master Bedroom in the top-right, Guest Bedroom in the bottom-left, and Office in the bottom-right. Horizontal and vertical divider lines form four boxes. Each tile has a still pixel icon and shows temperature to one decimal place with a tightly spaced decimal. The white headings use the compact labels `THERMO`, `MAST BED`, `GST BED`, and `OFFICE`.

The thermostat tile shows `current room temperature • setpoint`. The dot and setpoint are blue in Cool mode, green in Auto mode, and orange in Heat mode. The thermostat's current room temperature uses the same setpoint comparison colors as the other three sensors.

All room temperatures are compared with the Sensi cooling setpoint (`target_temp_high`) in Auto/Cool mode and heating setpoint (`target_temp_low`) in Heat mode:

- More than 2°F below: blue
- Exactly 2°F below: light blue
- Between 2°F below and 2°F above (not including either endpoint): white
- 2°F through less than 3°F above: yellow
- At least 3°F above: red

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
    home_climate.webp
    images/
```

Then enter the GitHub repository URL under **Tronbyt → Settings → Content → Custom App Repo**, press **Refresh**, and search for **Couser Home Climate** under **Add App**.
