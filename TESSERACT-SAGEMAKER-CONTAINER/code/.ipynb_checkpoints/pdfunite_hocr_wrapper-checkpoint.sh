#!/bin/bash
pdfunite $@

let i=0

mkdir hocr
outfile=${@: -1}
echo "ARGUMENTS: $@"

for file in $@
do
        hocrname=$file.hocr
        let i=$i+1
        nome=$
        mv $hocrname hocr/${OUTPUT_FILE_NAME}_page_$(printf %05d  ${i}).hocr
done
tar cvf ${OUTPUT_FILE_NAME}_hocr.tar hocr