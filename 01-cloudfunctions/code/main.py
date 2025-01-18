import functions_framework
import os  # Import OS library to interact with environment variables
import logging  # Import logging library for capturing logs
from flask import Response, Flask, request, jsonify
from google.cloud import firestore

@functions_framework.http
def gtg(request):
    try:
        request_args = request.args
        details = request_args.get("details")
        hostname = os.popen('hostname -I').read().strip()

        if details:
            # If 'details' parameter exists, return instance connectivity and hostname details
            data = {"connected": "true", "hostname": hostname}
            return Response(jsonify(data).data, status=200, mimetype="application/json")
        else:
            # If no 'details' parameter, return a simple success response
            return Response("", status=200, mimetype="application/json")
    except Exception as e:
        logging.exception("An error occurred in the gtg function")
        return Response(jsonify({"error": str(e)}).data, status=500, mimetype="application/json")


def candidates(request):

    try:
        if request.method != 'GET':
            return Response(jsonify({'error': 'Method not allowed'}).data, status=405, mimetype="application/json")
       
        db = firestore.Client()
        collection_name = "candidates"
        names_array = []
        docs = db.collection(collection_name).stream()

        for doc in docs:
            names_array.append(doc.to_dict())

        return Response(jsonify(names_array).data, status=200, mimetype="application/json")
    except Exception as e:
        logging.exception("An error occurred in the candidates function")
        return Response(jsonify({"error": str(e)}).data, status=500, mimetype="application/json")


def candidate(request):
    try:
        name = request.path[1:]

        if not name or '/' in name:
            return Response(jsonify({'error': 'name is invalid'}).data, status=400, mimetype="application/json")

        if request.method == 'GET':
            db = firestore.Client()
            collection_name = "candidates"
            doc_ref = db.collection(collection_name).document(name)
            doc = doc_ref.get()

            if doc.exists:
                return Response(jsonify(doc.to_dict()).data, status=200, mimetype="application/json")
            else:
                return Response(jsonify({'error': 'name not found'}).data, status=404, mimetype="application/json")
            
        if request.method == 'POST':
            db = firestore.Client()
            collection_name = "candidates"
            doc_id = name
            data = { "CandidateName" : name }
            doc_ref = db.collection(collection_name).document(doc_id)
            doc_ref.set(data)
            return Response(jsonify(data).data, status=200, mimetype="application/json")
          
        return Response(jsonify({'error': 'Method not allowed'}).data, status=405, mimetype="application/json")
    except Exception as e:
        logging.exception("An error occurred in the candidate function")    
        return Response(jsonify({"error": str(e)}).data, status=500, mimetype="application/json")
