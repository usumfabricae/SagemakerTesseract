#/bin/bash
#

export MODEL_TRAINING_DIR=/opt/ml/model/impact_from_full
export MODEL_OUTPUT_DIR=/opt/ml/model/tessdata

export LANG_DATA=/opt/ml/langdata

export TRAIN_INPUT_PATH=${SM_CHANNEL_TRAIN} # ../tesstutorial/itatrain

export TMP_TRAINING_DATA=../tesstutorial/itatrain
export TMP_EVAL_DATA=../tesstutorial/itaeval

export TESSDATA_PREFIX=${MODEL_OUTPUT_DIR}

cp -ar /opt/ml/input_model/* /opt/ml/model/

mkdir -p ${TMP_TRAINING_DATA}
mkdir -p ${TMP_EVAL_DATA}

#COPY INPUT FILE TO tesstrain.sh input
for fi in $(ls ${TRAIN_INPUT_PATH})
do
    echo "Addind training file $fi"
    mv  ${TRAIN_INPUT_PATH}/$fi ${LANG_DATA}/ita_box/.
done

echo -e "\n***** Prepare Training Data. \n"
tesstrain.sh --fonts_dir /usr/share/fonts --lang ita --linedata_only \
  --noextract_font_properties --langdata_dir ${LANG_DATA} \
  --tessdata_dir ${MODEL_OUTPUT_DIR} --output_dir ${TMP_TRAINING_DATA} 2>/dev/null
  
  
echo -e "\n***** Making evaluation data for itaeval set for scratch and impact training using Impact font."
tesstrain.sh --fonts_dir /usr/share/fonts --lang ita --linedata_only \
  --noextract_font_properties --langdata_dir ${LANG_DATA} \
  --tessdata_dir ${MODEL_OUTPUT_DIR} \
  --fontlist "Impact Condensed" --output_dir ${TMP_EVAL_DATA} 1>/dev/null 2>&1
  

echo -e "\n***** Extract LSTM model from best traineddata. \n"
combine_tessdata -e ${TESSDATA_PREFIX}/best/ita.traineddata \
  ${MODEL_TRAINING_DIR}/ita.lstm


echo -e "\n***** Run lstmtraining with debug output for first 100 iterations. \n"
lstmtraining \
  --model_output ${MODEL_TRAINING_DIR}/impact \
  --continue_from ${MODEL_TRAINING_DIR}/ita.lstm \
  --traineddata ${MODEL_OUTPUT_DIR}/ita.traineddata \
  --train_listfile ${TMP_TRAINING_DATA}/ita.training_files.txt \
  --debug_interval -1 \
  --max_iterations 100 2>/tmp/lstmtraining.log
  
tail -1 /tmp/lstmtraining.log
  
echo -e "\n***** Continue lstmtraining till ${SM_EPOCH} iterations. \n"
lstmtraining \
  --model_output ${MODEL_TRAINING_DIR}/impact \
  --continue_from ${MODEL_TRAINING_DIR}/ita.lstm \
  --traineddata ${MODEL_OUTPUT_DIR}/ita.traineddata \
  --train_listfile ${TMP_TRAINING_DATA}/ita.training_files.txt \
  --debug_interval 0 \
  --max_iterations ${SM_EPOCH} 2>/tmp/lstmtraining.log
  
tail -1 /tmp/lstmtraining.log
  
echo -e "\n***** Run lstmeval on eval set. \n"
lstmeval \
  --verbosity 0 \
  --model ${MODEL_TRAINING_DIR}/impact_checkpoint \
  --traineddata ${MODEL_OUTPUT_DIR}/ita.traineddata \
  --eval_listfile ${TMP_EVAL_DATA}/ita.training_files.txt 2>/tmp/lstmtraining.log
  
tail -1 /tmp/lstmtraining.log  
  
echo -e "\n***** Run lstmeval on itatrain set. \n"
lstmeval \
  --verbosity 0 \
  --model ${MODEL_TRAINING_DIR}/impact_checkpoint \
  --traineddata ${MODEL_OUTPUT_DIR}/ita.traineddata \
  --eval_listfile ${TMP_TRAINING_DATA}/ita.training_files.txt 2>/tmp/lstmtraining.log
  
tail -1 /tmp/lstmtraining.log 
  
echo -e "\n***** Stop lstmtraining and convert to traineddata. \n"
lstmtraining \
  --stop_training \
  --continue_from ${MODEL_TRAINING_DIR}/impact_checkpoint \
  --traineddata ${MODEL_OUTPUT_DIR}/ita.traineddata \
  --model_output ${MODEL_TRAINING_DIR}/ita_impact.traineddata

cp    ${MODEL_TRAINING_DIR}/ita_impact.traineddata ${MODEL_OUTPUT_DIR}/



