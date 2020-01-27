import os
import sys
import json
import pickle

#Sagemaker directory structure
prefix = '/opt/ml/'
input_path = prefix + 'input/data'
output_path = os.path.join(prefix, 'output')
model_path = os.path.join(prefix, 'model')
param_path = os.path.join(prefix, 'input/config/hyperparameters.json')
inputdata_path = os.path.join(prefix,'input/config/inputdataconfig.json')

with open(param_path, 'r') as tc:
    trainingParams = json.load(tc)
    print ("Training Params")
    print (trainingParams)

with open(inputdata_path, 'r') as tc:
    inputParams = json.load(tc)
    print ("Input Params")
    print (inputParams)

    
#Set-up environment variables for later bash processes
for key in inputParams.keys():
    var_name="SM_CHANNEL_{}".format(key.upper())
    path_name="/opt/ml/input/data/{}".format(key)
    os.environ[var_name]=path_name

os.environ['SM_EPOCH']=trainingParams['epoch']

print ("Starting Processing")
print ("Arguments")
print (sys.argv[0:])

print ("Environment")
print(os.environ)
print ("End Environment")

if 'SAGEMAKER_BATCH' in os.environ:
    if (os.environ['SAGEMAKER_BATCH'].lower()=='true'): 
        print ("Start Image Processing")
        os.system('/usr/bin/find /opt/ml')
  
else:
    print ("Start Training")
    os.system('/bin/bash sagemaker_train_tesseract.sh')
    print ("Training Complete")

print ("End Processing training")

