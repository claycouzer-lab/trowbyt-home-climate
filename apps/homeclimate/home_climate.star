"""
Applet: Couser Home Climate
Summary: Home Assistant room temperatures
Description: Shows four Home Assistant temperature sensors together on one screen.
Author: OpenAI for Clay Couser
"""

load("http.star", "http")
load("images/guest_bed.png", GUEST_BED_ICON_ASSET = "file")
load("images/guest_bed_label.png", GUEST_BED_LABEL_ASSET = "file")
load("images/master_bed.png", MASTER_BED_ICON_ASSET = "file")
load("images/master_bed_label.png", MASTER_BED_LABEL_ASSET = "file")
load("images/office.png", OFFICE_ICON_ASSET = "file")
load("images/office_label.png", OFFICE_LABEL_ASSET = "file")
load("images/thermostat.png", THERMOSTAT_ICON_ASSET = "file")
load("images/thermostat_label.png", THERMOSTAT_LABEL_ASSET = "file")
load("render.star", "render")
load("schema.star", "schema")

GUEST_BED_ICON = GUEST_BED_ICON_ASSET.readall()
GUEST_BED_LABEL = GUEST_BED_LABEL_ASSET.readall()
MASTER_BED_ICON = MASTER_BED_ICON_ASSET.readall()
MASTER_BED_LABEL = MASTER_BED_LABEL_ASSET.readall()
OFFICE_ICON = OFFICE_ICON_ASSET.readall()
OFFICE_LABEL = OFFICE_LABEL_ASSET.readall()
THERMOSTAT_ICON = THERMOSTAT_ICON_ASSET.readall()
THERMOSTAT_LABEL = THERMOSTAT_LABEL_ASSET.readall()

HA_URL = "ha_url"
HA_TOKEN = "ha_token"

MASTER_TEMP = "sensor.h5075_db34_temperature"
GUEST_TEMP = "sensor.h5075_f159_temperature"
OFFICE_TEMP = "sensor.office_temperature"
THERMOSTAT_TEMP = "sensor.sensi_thermostat_temperature"
THERMOSTAT_CLIMATE = "climate.sensi_thermostat"

TEMP_COLOR = "#FFFFFF"
COOL_BLUE = "#3FA9FF"
AUTO_GREEN = "#43E06F"
HEAT_ORANGE = "#FF8C32"
ROOM_BLUE = "#3FA9FF"
ROOM_LIGHT_BLUE = "#79D8FF"
ROOM_YELLOW = "#FFE14A"
ROOM_RED = "#FF3B30"
DIVIDER_COLOR = "#555555"

DEMO_STATES = {
    MASTER_TEMP: {"state": "70.0", "attributes": {}},
    GUEST_TEMP: {"state": "74.7", "attributes": {}},
    OFFICE_TEMP: {"state": "75.9", "attributes": {}},
    THERMOSTAT_TEMP: {"state": "74.0", "attributes": {}},
    THERMOSTAT_CLIMATE: {
        "state": "auto",
        "attributes": {
            "current_temperature": 74,
            "target_temp_high": 68,
            "target_temp_low": 62,
        },
    },
}

def fetch_entity(config, entity_id):
    if config.bool("demo", False):
        return DEMO_STATES[entity_id]

    ha_url = config.get(HA_URL)
    token = config.get(HA_TOKEN)
    if not ha_url:
        fail("Home Assistant URL is required")
    if ha_url.endswith("/"):
        ha_url = ha_url[:-1]

    response = http.get(
        "%s/api/states/%s" % (ha_url, entity_id),
        headers = {
            "Authorization": "Bearer %s" % token,
            "Content-Type": "application/json",
        },
    )
    if response.status_code != 200:
        fail("Home Assistant returned HTTP %d for %s" % (response.status_code, entity_id))
    return response.json()

def thermostat_color(mode):
    if mode == "cool":
        return COOL_BLUE
    if mode == "auto" or mode == "heat_cool":
        return AUTO_GREEN
    if mode == "heat":
        return HEAT_ORANGE
    return TEMP_COLOR

def get_setpoint(climate):
    attrs = climate.get("attributes", {})
    mode = climate.get("state", "auto")
    if mode == "heat":
        setpoint = attrs.get("target_temp_low")
    else:
        setpoint = attrs.get("target_temp_high")
    if setpoint == None:
        setpoint = attrs.get("temperature")
    return setpoint

def room_temperature_color(temperature, setpoint):
    if setpoint == None:
        return TEMP_COLOR
    difference = float(temperature) - float(setpoint)
    if difference >= 3:
        return ROOM_RED
    if difference >= 2:
        return ROOM_YELLOW
    if difference < -2:
        return ROOM_BLUE
    if difference <= -2:
        return ROOM_LIGHT_BLUE
    return TEMP_COLOR

def format_temperature(value):
    number = float(value)
    if number >= 0:
        rounded = int(number * 10 + 0.5) / 10.0
    else:
        rounded = int(number * 10 - 0.5) / 10.0
    return "%s°" % rounded

def format_temperature_number(value):
    number = float(value)
    if number >= 0:
        rounded = int(number * 10 + 0.5) / 10.0
    else:
        rounded = int(number * 10 - 0.5) / 10.0
    return "%s" % rounded

def format_setpoint(value):
    if value == None:
        return "--"
    number = float(value)
    rounded = int(number + 0.5)
    return "%s" % rounded

def sensor_tile(title, temperature, icon, width, height, temperature_color = TEMP_COLOR):
    return render.Box(
        width = width,
        height = height,
        child = render.Column(
            expanded = True,
            cross_align = "center",
            main_align = "center",
            children = [
                render.Text(
                    content = title,
                    color = TEMP_COLOR,
                    font = "tom-thumb",
                ),
                render.Row(
                    main_align = "center",
                    children = [
                        render.Image(src = icon),
                        render.Text(
                            content = format_temperature(temperature),
                            color = temperature_color,
                            font = "5x8",
                        ),
                    ],
                ),
            ],
        ),
    )

def thermostat_tile(temperature, setpoint, mode):
    return render.Box(
        width = 31,
        height = 15,
        child = render.Column(
            expanded = True,
            cross_align = "center",
            main_align = "center",
            children = [
                render.Text(
                    content = "THERMOSTAT",
                    color = TEMP_COLOR,
                    font = "tom-thumb",
                ),
                render.Row(
                    cross_align = "center",
                    main_align = "center",
                    children = [
                        render.Text(
                            content = format_temperature_number(temperature),
                            color = room_temperature_color(temperature, setpoint),
                            font = "5x8",
                        ),
                        render.Box(width = 1, height = 1, color = thermostat_color(mode)),
                        render.Text(
                            content = format_setpoint(setpoint),
                            color = thermostat_color(mode),
                            font = "5x8",
                        ),
                    ],
                ),
            ],
        ),
    )

def main(config):
    if not config.bool("demo", False) and not config.get(HA_TOKEN):
        return render.Root(
            child = render.WrappedText(
                content = "ADD HOME ASSISTANT TOKEN",
                width = 64,
                height = 32,
                align = "center",
                color = ROOM_YELLOW,
                font = "tb-8",
            ),
        )

    master_temp = fetch_entity(config, MASTER_TEMP)["state"]
    guest_temp = fetch_entity(config, GUEST_TEMP)["state"]
    office_temp = fetch_entity(config, OFFICE_TEMP)["state"]
    thermostat_temp = fetch_entity(config, THERMOSTAT_TEMP)["state"]
    thermostat = fetch_entity(config, THERMOSTAT_CLIMATE)
    thermostat_mode = thermostat["state"]
    setpoint = get_setpoint(thermostat)

    return render.Root(
        child = render.Column(
            children = [
                render.Row(
                    children = [
                        thermostat_tile(thermostat_temp, setpoint, thermostat_mode),
                        render.Box(width = 1, height = 15, color = DIVIDER_COLOR),
                        sensor_tile("MASTER BED", master_temp, MASTER_BED_ICON, 32, 15, room_temperature_color(master_temp, setpoint)),
                    ],
                ),
                render.Box(width = 64, height = 1, color = DIVIDER_COLOR),
                render.Row(
                    children = [
                        sensor_tile("GUEST BED", guest_temp, GUEST_BED_ICON, 31, 16, room_temperature_color(guest_temp, setpoint)),
                        render.Box(width = 1, height = 16, color = DIVIDER_COLOR),
                        sensor_tile("OFFICE", office_temp, OFFICE_ICON, 32, 16, room_temperature_color(office_temp, setpoint)),
                    ],
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = HA_URL,
                name = "Home Assistant URL",
                desc = "Example: http://homeassistant.local:8123",
                icon = "link",
                default = "http://homeassistant.local:8123",
            ),
            schema.Text(
                id = HA_TOKEN,
                name = "Long-Lived Access Token",
                desc = "Create this at the bottom of your Home Assistant profile page.",
                icon = "key",
                secret = True,
            ),
        ],
    )
