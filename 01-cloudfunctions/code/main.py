import functions_framework  # Importing Functions Framework to define HTTP functions for Google Cloud
import os  # Importing OS library for interacting with operating system commands and environment variables
import logging  # Importing logging library to log errors and debug information
from flask import Response, Flask, request, jsonify  # Importing Flask utilities for request handling and JSON responses
from google.cloud import firestore  # Importing Firestore library to interact with Google Firestore database

@functions_framework.http
def gtg(request):
    """
    Google Cloud Function for 'go-to-green' (health check).
    Responds with instance connectivity details if 'details' parameter is present, otherwise returns a basic success response.

    Args:
        request: Flask request object containing query parameters.

    Returns:
        Response: JSON response with connectivity details or a simple success status.
    """
    try:
        request_args = request.args  # Retrieve query parameters from the request
        details = request_args.get("details")  # Get the 'details' parameter if it exists
        hostname = os.popen('hostname -I').read().strip()  # Execute shell command to fetch the hostname/IP of the instance

        if details:
            # If the 'details' parameter exists, return instance connectivity and hostname information
            data = {"connected": "true", "hostname": hostname}
            return Response(jsonify(data).data, status=200, mimetype="application/json")
        else:
            # If 'details' parameter is not provided, return a basic 200 success response
            return Response("", status=200, mimetype="application/json")
    except Exception as e:
        # Log the exception and return a 500 error response
        logging.exception("An error occurred in the gtg function")
        return Response(jsonify({"error": str(e)}).data, status=500, mimetype="application/json")


def candidates(request):
    """
    Google Cloud Function to retrieve all candidate data from Firestore.
    Only supports HTTP GET requests.

    Args:
        request: Flask request object.

    Returns:
        Response: JSON response containing all candidates or an error message.
    """
    try:
        if request.method != 'GET':
            # Reject requests that are not GET with a 405 Method Not Allowed error
            return Response(jsonify({'error': 'Method not allowed'}).data, status=405, mimetype="application/json")
        
        db = firestore.Client()  # Initialize Firestore client
        collection_name = "candidates"  # Name of the Firestore collection to query
        names_array = []  # Initialize an array to store candidate data
        docs = db.collection(collection_name).stream()  # Retrieve all documents from the collection

        for doc in docs:
            # Append each document's data to the names array
            names_array.append(doc.to_dict())

        # Return the list of candidates as a JSON response
        return Response(jsonify(names_array).data, status=200, mimetype="application/json")
    except Exception as e:
        # Log the exception and return a 500 error response
        logging.exception("An error occurred in the candidates function")
        return Response(jsonify({"error": str(e)}).data, status=500, mimetype="application/json")


def candidate(request):
    """
    Google Cloud Function to retrieve or create a single candidate record in Firestore.
    Supports HTTP GET and POST requests.

    Args:
        request: Flask request object.

    Returns:
        Response: JSON response containing candidate data or an error message.
    """
    try:
        name = request.path[1:]  # Extract the candidate name from the URL path

        if not name or '/' in name:
            # If the name is missing or invalid (contains '/'), return a 400 Bad Request error
            return Response(jsonify({'error': 'name is invalid'}).data, status=400, mimetype="application/json")

        if request.method == 'GET':
            # Handle GET request: Retrieve candidate data from Firestore
            db = firestore.Client()  # Initialize Firestore client
            collection_name = "candidates"  # Name of the Firestore collection
            doc_ref = db.collection(collection_name).document(name)  # Reference the document by name
            doc = doc_ref.get()  # Fetch the document

            if doc.exists:
                # If the document exists, return its data as a JSON response
                return Response(jsonify(doc.to_dict()).data, status=200, mimetype="application/json")
            else:
                # If the document does not exist, return a 404 Not Found error
                return Response(jsonify({'error': 'name not found'}).data, status=404, mimetype="application/json")
            
        if request.method == 'POST':
            # Handle POST request: Create or update candidate data in Firestore
            db = firestore.Client()  # Initialize Firestore client
            collection_name = "candidates"  # Name of the Firestore collection
            doc_id = name  # Use the name as the document ID
            data = {"CandidateName": name}  # Create a dictionary with the candidate's name
            doc_ref = db.collection(collection_name).document(doc_id)  # Reference the document by name
            doc_ref.set(data)  # Save the data to Firestore
            return Response(jsonify(data).data, status=200, mimetype="application/json")
          
        # Reject unsupported HTTP methods with a 405 Method Not Allowed error
        return Response(jsonify({'error': 'Method not allowed'}).data, status=405, mimetype="application/json")
    except Exception as e:
        # Log the exception and return a 500 error response
        logging.exception("An error occurred in the candidate function")
        return Response(jsonify({"error": str(e)}).data, status=500, mimetype="application/json")
