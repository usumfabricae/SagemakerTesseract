# SagemakerTesseract
Example to build a custom Sagemaker container for tesseract.
**As it is it is supporting only Italian language but can be easily extended to other languages supported by Tesseract.  
It handle pdf as input and generates a indexed pdf file (the same original pdf with test underneath the image) and an HOCR file for each page of the original pdf document archived in a tar.gz file **


Once the container has been build it can be used for:
* Training on new custom fonts
* Create an endpoint for prediction
* Create batch prediction


## Training
....


## Predict
The model has been developed in order to support input as pdf files, input files shall be saved on a S3 bucket and listed in a csv document that is sent to the Sagemaker in order to start the transcription process
Batch prediction is recomended from price efficiency point of view since tesseract uses a lot of cpu resources, batch prediction using large instances (i.e. c5.18xlarge) can parse about one page per second (it depends on the page complexity).


## ToDo
* Multiple languages
* Multiple output formats (i.e. including generation of documents to feed the training process)
* Multiple input formats

