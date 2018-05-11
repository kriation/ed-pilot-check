"""
    ed-pilot-check returns last known location of pilot from edsm.net
    Copyright (C) 2018  Armen Kaleshian

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
import http.client
import json
import logging
import os
import boto3
from datetime import datetime
from jinja2 import Environment, select_autoescape

LOGGER = logging.getLogger()
LOGGER.setLevel(os.environ.get('LOGGING_LEVEL', logging.INFO))
HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Elite Dangerous: Status of Commander {{ commander }} </title>
</head>
<body>
Commander {{ commander }} was last docked in a {{ ship }} at station {{ 
station }} 
roughly {{ days }} days and {{ "%.2f"|format(hours|float) }} hours ago.
</body>
</html>
"""


def get_api_key():
    client = boto3.client('ssm')
    response = client.get_parameter(
        Name='edsm-api-key')
    return response['Parameter']['Value']


def process_json(data):
    position_data = json.loads(data)
    date_docked = datetime.strptime(position_data['dateDocked'],
                                    '%Y-%m-%d %H:%M:%S')
    ship_type = position_data['shipType']
    station = position_data['station']
    now = datetime.now()
    time_delta = now - date_docked
    hours_delta = time_delta.seconds / 60 / 60
    custom_data = {'days_since': time_delta.days,
                   'hours_since': hours_delta,
                   'last_ship': ship_type,
                   'last_station': station}
    return custom_data


def build_response(pilot_data):
    env = Environment(autoescape=select_autoescape(['html']))
    template = env.from_string(HTML)
    response_body = template.render(ship=pilot_data['last_ship'],
                                    station=pilot_data['last_station'],
                                    days=pilot_data['days_since'],
                                    hours=pilot_data['hours_since'],
                                    commander=pilot_data['commander_name'])
    response = {'statusCode': 200,
                'headers': {'Content-Type': 'text/html'},
                'body': response_body}

    return response


def lambda_handler(event, context):
    api_key = get_api_key()
    commander_name = event['queryStringParameters']['commander'][0]
    conn = http.client.HTTPSConnection('www.edsm.net')
    conn.request('GET', '/api-logs-v1/get-position?commanderName='
                 + commander_name
                 + '&apiKey=' + api_key)
    response = conn.getresponse()
    if response.status == 200:
        raw_data = response.read()
        custom_data = process_json(raw_data)
        custom_data['commander_name'] = commander_name
        return build_response(custom_data)
    else:
        raise Exception('edsm.net did not return expected data due to %s',
                        response.reason)
