#!/bin/bash

# reference: https://askubuntu.com/questions/113544/how-can-i-reduce-the-file-size-of-a-scanned-pdf-file

# bash parameter substitution way to get the file name
# http://www.tldp.org/LDP/LG/issue18/bash.html
# Given: foo=/tmp/my.dir/filename.tar.gz
# path = ${foo%/*}
# To get: /tmp/my.dir (like dirname)
# file = ${foo##*/}
# To get: filename.tar.gz (like basename)
# base = ${file%%.*}
# To get: filename
# ext = ${file#*.}
# To get: tar.gz

in_file=$1
path=${in_file%/*}
in_file=${in_file##*/} # to get the file name if it's not on the same folder as the scripts
in_file_base=${in_file%%.*}
out_file=${in_file_base}_grey.pdf

gs \
	-sDEVICE=pdfwrite \
	-sColorConversionStrategy=Gray \
	-dProcessColorModel=/DeviceGray \
	-dAutoRotatePages=/None \
	-dCompatibilityLevel=1.4 \
	-dNOPAUSE \
	-dQUIET \
	-dBATCH \
	-sOutputFile=${path}/${out_file} \
	${path}/${in_file}
# -dPDFSETTINGS=/screen lower quality, smaller size.
# -dPDFSETTINGS=/ebook for better quality, but slightly larger pdfs.
# -dPDFSETTINGS=/prepress output similar to Acrobat Distiller "Prepress Optimized" setting
# -dPDFSETTINGS=/printer selects output similar to the Acrobat Distiller "Print Optimized" setting
# -dPDFSETTINGS=/default selects output intended to be useful across a wide variety of uses, possibly at the expense of a larger output file


# ## the other parameter, change the image resolution to 150 dpi 
# gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dDownsampleColorImages=true \
# 	-dColorImageResolution=150 -dNOPAUSE  -dBATCH -sOutputFile=${path}${out_file} ${path}${in_file}
