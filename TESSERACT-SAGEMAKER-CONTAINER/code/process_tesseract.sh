#!/bin/bash
cd "$(dirname "$0")"

echo "Start Processing"
if [ "${INPUT_BUCKET_NAME}X" = "X" ]
then
        echo "Missing Environment variable INPUT_BUCKET_NAME"
        exit 1
fi
echo "Input Bucket: ${INPUT_BUCKET_NAME}"

if [ "${INPUT_PATH}X" = "X" ]
then
        echo "Missing Environment variable INPUT_PATH"
        exit 1
fi
echo "Input Path: ${INPUT_PATH}"

if [ "${INPUT_FILE_NAME}X" = "X" ]
then
        echo "Missing Environment variable INPUT_FILE_NAME"
        exit 1
fi
echo "Input File Name: ${INPUT_FILE_NAME}"

if [ "${OUTPUT_BUCKET_NAME}X" = "X" ]
then
echo "Missing Environment variable OUTPUT_BUCKET_NAME"
        exit 1
fi
echo "Output Bucket: ${OUTPUT_BUCKET}"

if [ "${OUTPUT_PATH}X" = "X" ]
then
        echo "Missing Environment variable OUTPUT_PATH"
        exit 1
fi
echo "Output Path: ${OUTPUT_PATH}"

if [ "${OUTPUT_FILE_NAME}X" = "X" ]
then
        echo "Missing Environment variable OUTPUT_FILE_NAME"
        exit 1
fi
echo "Output File Name: ${OUTPUT_FILE_NAME}"

export MODEL_OUTPUT_DIR=/opt/ml/model/tessdata
export TESSDATA_PREFIX=${MODEL_OUTPUT_DIR}

if [ "${DOC_LANG}X" = "X" ]
then
        DOC_LANG=ita
        echo "Setting document language ${DOC_LANG}"
fi



fileout=$(basename ${INPUT_FILE_NAME} .pdf)_ocr.pdf

#Cleanup from previuos processing
rm -f ${INPUT_FILE_NAME}
rm -f ${fileout}
rm -rf hocr

echo "############################### DOWNLOAD INPUT FILE ###########################"
aws2 s3 cp s3://${INPUT_BUCKET_NAME}/${INPUT_PATH}/${INPUT_FILE_NAME} ${INPUT_FILE_NAME}
#pdfsandwich ${INPUT_FILE_NAME} -pdfunite ./pdfunite_hocr_wrapper.sh -nthreads 48  -lang ${DOC_LANG} -tesso "-c tessedit_create_pdf=1 -c tessedit_create_hocr=1 -c hocr_font_info=0"
echo "############################### TESSERACT EXECUTION ###########################"
./pdfsandwich_hocr ${INPUT_FILE_NAME} -pdfunite ./pdfunite_hocr_wrapper.sh -nthreads 48  -lang ${DOC_LANG} -tesso "-c tessedit_create_pdf=1 -c tessedit_create_hocr=1 -c hocr_font_info=0"


echo "############################ PACKAGE OUTPUT AND UPLOAD ########################"
aws2 s3 cp $fileout s3://${OUTPUT_BUCKET_NAME}/${OUTPUT_PATH}/${OUTPUT_FILE_NAME}
gzip ${OUTPUT_FILE_NAME}_hocr.tar
aws2 s3 cp ${OUTPUT_FILE_NAME}_hocr.tar.gz s3://${OUTPUT_BUCKET_NAME}/${OUTPUT_PATH}/${OUTPUT_FILE_NAME}_hocr.tar.gz

echo "################################ PROCESSING COMPLETE ##########################"
