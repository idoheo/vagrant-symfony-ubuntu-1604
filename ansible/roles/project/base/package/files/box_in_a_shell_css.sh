#!/bin/bash
echo $(for i in $(ls /etc/shellinabox/options-enabled/*.css |
                                 sed -e                                       \
                                    's/.*[/]\([0-9]*\)[-_+][^/:,;]*[.]css/\1/'|
                                 sort -u); do
                        for j in /etc/shellinabox/options-enabled/"$i"*.css; do
                          echo -n "$j" |
                          sed -e 's/\(.*[/]\)\([0-9]*\)\([-_+]\)\([^/:,;]*\)[.]css/\4:\3\1\2\3\4.css,/
                                  s/:_/:-/'
                        done |
                        sed -e 's/,$/;/'
                      done |
                      sed -e "s/;$//
                              //b
                              s/.*/--user-css '\0'/") 
