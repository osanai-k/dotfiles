#!/bin/sh

for file in $(find $(pwd) -type f -regex ".+/\.[^/]+"); do
	echo ${file}
	ln -s ${file} ${HOME}/
done

