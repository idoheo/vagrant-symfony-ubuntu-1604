#!/bin/bash

if [[ $(php <<< "<?php echo intval(boolval(extension_loaded(\"$1\")));" ) -ne 1 ]]; then
        echo "Extension $1 not loaded"
        exit 1
fi

if [[ ! -f "$2" ]]; then
        echo "Extension $1 config file $2 not found"
        exit 2
fi

INI_TEMP=$(mktemp)
EXTENSION_LINE=$(cat $2 | egrep "^[[:space:]]*(zend_|)extension[[:space:]]*=[[:space:]]*.*$" -o | head -n 1)
PRIORITY_LINE=$(cat $2 | egrep "^[[:space:]]*;[[:space:]]*priority[[:space:]]*=[[:space:]]*.*$" -o | head -n 1)

echo "[$1]" > $INI_TEMP
echo $EXTENSION_LINE >> $INI_TEMP
echo $PRIORITY_LINE >> $INI_TEMP

php >> $INI_TEMP << EOF
<?php
\$reflection=new \\ReflectionExtension("$1");
\$entries = \$reflection->getINIEntries();
ksort(\$entries);
foreach (\$entries as \$key => \$value) { 
        if (is_string(\$value) && !preg_match('/^-?[0-9]+(.[0-9]+)?$/', \$value)) {
                 \$value = sprintf('"%s"', \$value);
         }
         echo sprintf("%s%s = %s\\n", is_null(\$value) ? ';' : '', \$key, \$value);
}
EOF

cp "$INI_TEMP" "$2"
cat $INI_TEMP
rm $INI_TEMP
