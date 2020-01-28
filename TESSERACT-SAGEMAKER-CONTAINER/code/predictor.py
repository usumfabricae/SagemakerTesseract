# This is the file that implements a flask server to do inferences. It's the file that you will modify
# to implement the prediction for your own algorithm.

from __future__ import print_function

import os, sys, stat
from io import StringIO
import json
import shutil
import flask
from flask import Flask, jsonify
import glob
import pandas as pd

print ("Setup Model")            

# The flask app for serving predictions
app = flask.Flask(__name__)

@app.route('/ping', methods=['GET'])
def ping():
    """Determine if the container is working and healthy. In this sample container, we declare
    it healthy."""
    
    status = 200 
    return flask.Response(response='\n', status=status, mimetype='application/json')

@app.route('/execution-parameters', methods=['GET'])
def execution_parameters():
    return_value='{"MaxConcurrentTransforms": 1,"BatchStrategy": "SINGLE_RECORD","MaxPayloadInMB": 1}'
    
    return flask.Response(response=jsonify(return_value), status=status, mimetype='application/json')
    
@app.route('/invocations', methods=['POST'])
def invocations():

    print ("Request")
    print (flask.request.content_type)
    print ("Data")
    data = flask.request.data.decode('utf-8')
    s = StringIO(data)
    df = pd.read_csv(s, header=None)
    outputFiles=[]
    for index, row in df.iterrows():
        (input_bucket,input_path,input_name,output_bucket,output_path,output_name)=row
        os.environ['INPUT_BUCKET_NAME']=input_bucket
        os.environ['INPUT_PATH']=input_path
        os.environ['INPUT_FILE_NAME']=input_name
        os.environ['OUTPUT_BUCKET_NAME']=output_bucket
        os.environ['OUTPUT_PATH']=output_path
        os.environ['OUTPUT_FILE_NAME']=output_name
        os.environ['DOC_LANG']='ita_impact'
        os.system('/bin/bash process_tesseract.sh')
        outputFiles.append({"fileName":"{}/{}/{}".format(output_bucket,output_path,output_name) })
        
    print ("Returning")
    # Convert result to JSON
    return_value = { "predictions": outputFiles }
    #return_value["predictions"]["class"] = str(predictions[0])
    print(return_value)

    return jsonify(return_value) 