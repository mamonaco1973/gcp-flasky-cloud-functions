import functions_framework
import os  # Import OS library to interact with environment variables
import logging  # Import logging library for capturing logs
import socket  # Import socket library to retrieve hostname and IP information
import json  # Import JSON library for handling JSON data
from flask import Response,Flask, request, jsonify

@functions_framework.http
def gtg(request):

    request_args = request.args
    details = request_args.get("details");
    hostname = socket.gethostname()  # Retrieve the hostname of the current instance

    if details:
        # If 'details' parameter exists, return instance connectivity and hostname details
        data = {"connected": "true", "hostname": hostname}
        return Response(json.dumps(data), status=200, mimetype="application/json")
    else:
        # If no 'details' parameter, return a simple success response
        return ""

def candidates(request):
    if request.method != 'GET':
        return jsonify({'error': 'Method not allowed'}), 405  # 405 Method Not Allowed
    # Handle POST request logic here
    return jsonify({'message': 'candidates GET request received'})

def candidate(request):
    if request.method == 'GET':
        return jsonify({'message': 'candidate GET request received'})

    if request.method == 'POST':
        return jsonify({'message': 'candidate POST request received'})
    
    return jsonify({'error': 'Method not allowed'}), 405  # 405 Method Not Allowed

